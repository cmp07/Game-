class_name RewriteEngine
extends RefCounted

## Orchestrates the rewrite pipeline (v2).
##
## Pipeline
## --------
##   1. Take a Lattice + HabitSignature + current path.
##   2. Ask RewriteOperators for every candidate rewrite.
##   3. Filter by `enabled_ops`, `min_score`, magnitude-scale under mode
##      (reader/standard/cold) + soft/hard bias + greed_index.
##   4. Tie-break scores with jittered RNG.
##   5. For each candidate in order, verify:
##        a. patches don't overwrite start/goal (Lattice.apply_patches),
##        b. lattice remains solvable (LatticeBFS.is_solvable),
##        c. goal reachable margin (safe zone) still >= config.min_bottleneck,
##        d. player still has at least one exit (`min_player_exits`),
##        e. shortest-path length does not grow beyond
##           baseline_len * max_length_factor (default 1.5 = 50% longer max).
##      The first candidate that survives is committed.
##   6. Optionally chain a second rewrite that `reacts_to` the applied one
##      (combo). The chain rewrite is drawn from the remaining candidates
##      that (i) list the applied op in their `reacts_to`, and (ii) satisfy
##      the same safety checks against the post-commit lattice.
##
## The engine is pure w.r.t. the input Lattice: it never mutates the passed-in
## lattice, only its own clone.
##
## Near-miss detection
## -------------------
## When the FINAL committed lattice has `goal_bottleneck == 1` or
## `player_exits == 1` (from `player_pos`), the result flags `near_miss: true`
## with the offending cell. Higher layers surface this as the "your maze
## almost sealed" clip-worthy moment.
##
## Wall-yourself-in prevention
## ---------------------------
## Even if the lattice remains technically solvable, the engine will reject a
## candidate that would drop `goal_bottleneck_width` below the config's
## `min_bottleneck` OR that would leave the player with fewer than
## `min_player_exits` live exits at the given `player_pos`. Both thresholds
## default to 1 in Cold and Standard modes and 2 in Reader mode.

class Config:
	extends RefCounted
	var max_attempts: int = 32
	var score_jitter: float = 0.05
	var require_shorter_or_equal: bool = false
	var min_score: float = 0.0
	## Magnitude of adaptation. 0.0 = every soft rewrite pruned to minimum
	## patch set. 1.0 = every soft rewrite runs at natural magnitude.
	var soft_hard_bias: float = 0.5
	## Difficulty mode: "reader" | "standard" | "cold". Modulates magnitude
	## scaling and safety thresholds.
	var mode: String = "standard"
	## Safety thresholds (see `safety_ok`).
	var min_bottleneck: int = 1
	var min_player_exits: int = 1
	## Length ceiling. New shortest-path may not exceed
	## baseline_len * max_length_factor. 0.0 disables the check.
	var max_length_factor: float = 1.5
	## Combo chain switch.
	var allow_combo: bool = true
	## Combo score bonus applied to a reacting rewrite before ranking.
	var combo_bonus: float = 0.6
	var enabled_ops: PackedStringArray = PackedStringArray([
		"fossilize_hot_cell",
		"place_deflector",
		"carve_shortcut",
		"grow_wall_far_from_path",
		"widen_hot_corridor",
		"mirror_walked_v",
		"mirror_walked_h",
		"rotate_walked_180",
		"thicken_walked",
		"echo_wisp",
		"seal_backtrack",
	])

	static func for_mode(mode_name: String) -> Config:
		var c := Config.new()
		c.mode = mode_name
		match mode_name:
			"reader":
				c.min_bottleneck = 2
				c.min_player_exits = 2
				c.max_length_factor = 1.25
				c.soft_hard_bias = 0.35
			"cold":
				c.min_bottleneck = 1
				c.min_player_exits = 1
				c.max_length_factor = 2.0
				c.soft_hard_bias = 0.75
			_:
				c.min_bottleneck = 1
				c.min_player_exits = 1
				c.max_length_factor = 1.5
				c.soft_hard_bias = 0.5
		return c


class EngineResult:
	extends RefCounted
	var applied: bool = false
	var lattice: Lattice
	var rewrite: Dictionary = {}
	var combo: Dictionary = {}         ## chained rewrite, if any
	var attempts: int = 0
	var considered: int = 0
	var rejected: Array = []           ## Array<{rewrite, reason, meta?}>
	var reason: String = ""
	var near_miss: bool = false
	var near_miss_cell: Vector2i = Vector2i(-1, -1)
	var safety: Dictionary = {}        ## {path_len, bottleneck, player_exits}

	func summary() -> String:
		if applied:
			var base := "RewriteEngine: applied '%s' (score=%.2f) after %d attempts" % [
				rewrite.get("name", "?"), float(rewrite.get("score", 0.0)), attempts,
			]
			if not combo.is_empty():
				base += " + combo '%s'" % combo.get("name", "?")
			if near_miss:
				base += "  [NEAR-MISS]"
			return base
		return "RewriteEngine: no rewrite applied (considered=%d, reason=%s)" % [considered, reason]


# -----------------------------------------------------------------------------
# Public entry
# -----------------------------------------------------------------------------

static func apply(lattice: Lattice, sig: HabitSignature,
		path: Array = [],
		player_pos: Vector2i = Vector2i(-1, -1),
		rng: RandomNumberGenerator = null,
		config: Config = null) -> EngineResult:
	var result := EngineResult.new()
	result.lattice = lattice.clone()

	var cfg := config if config != null else Config.new()
	var effective_pos: Vector2i = player_pos if player_pos != Vector2i(-1, -1) else lattice.start

	var candidates := RewriteOperators.propose_all(lattice, sig, path)
	if candidates.is_empty():
		result.reason = "no_candidates"
		return result

	var filtered: Array = []
	for c in candidates:
		if not cfg.enabled_ops.has(c["name"]):
			continue
		if float(c["score"]) < cfg.min_score:
			continue
		var scaled := _scale_candidate(c, sig, cfg)
		if scaled.is_empty():
			continue
		filtered.append(scaled)
	if filtered.is_empty():
		result.reason = "no_enabled_candidates"
		return result

	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.seed = 0
	for c in filtered:
		var j := rng.randf_range(-cfg.score_jitter, cfg.score_jitter)
		c["_jittered"] = float(c["score"]) + j
	filtered.sort_custom(func(a, b): return float(a["_jittered"]) > float(b["_jittered"]))

	result.considered = filtered.size()

	var baseline_len := 0
	var base_path := LatticeBFS.shortest_path(lattice, lattice.start, lattice.goal)
	if base_path.is_empty():
		result.reason = "baseline_unsolvable"
		return result
	baseline_len = base_path.size()

	var attempts := 0
	for c in filtered:
		if attempts >= cfg.max_attempts:
			break
		attempts += 1
		var candidate_lat := lattice.clone()
		var ok: bool = candidate_lat.apply_patches(c["patches"])
		if not ok:
			result.rejected.append({"rewrite": c, "reason": "invalid_patch"})
			continue
		var safety_res := _check_safety(candidate_lat, effective_pos, baseline_len, cfg)
		if safety_res["ok"]:
			result.applied = true
			result.attempts = attempts
			result.rewrite = c
			result.lattice = candidate_lat
			result.safety = safety_res["safety"]
			result.near_miss = safety_res["near_miss"]
			result.near_miss_cell = safety_res["near_miss_cell"]
			if cfg.allow_combo:
				var combo := _try_combo(candidate_lat, sig, path, effective_pos, filtered, c, baseline_len, cfg, rng)
				if not combo.is_empty():
					var combo_lat: Lattice = combo["lattice"]
					var combo_rewrite: Dictionary = combo["rewrite"]
					var combo_safety: Dictionary = combo["safety"]
					result.combo = combo_rewrite
					result.lattice = combo_lat
					result.safety = combo_safety
					result.near_miss = combo["near_miss"]
					result.near_miss_cell = combo["near_miss_cell"]
			return result
		result.rejected.append({"rewrite": c, "reason": safety_res["reason"], "safety": safety_res["safety"]})

	result.attempts = attempts
	result.reason = "exhausted"
	return result


## Apply repeatedly until no more rewrites succeed or `max_rewrites` is hit.
static func apply_repeated(lattice: Lattice, sig: HabitSignature,
		path: Array = [],
		player_pos: Vector2i = Vector2i(-1, -1),
		rng: RandomNumberGenerator = null,
		max_rewrites: int = 8, config: Config = null) -> Dictionary:
	var current := lattice.clone()
	var applied_list: Array = []
	var near_misses: int = 0
	for i in range(max_rewrites):
		var res := RewriteEngine.apply(current, sig, path, player_pos, rng, config)
		if not res.applied:
			break
		current = res.lattice
		applied_list.append(res.rewrite)
		if not res.combo.is_empty():
			applied_list.append(res.combo)
		if res.near_miss:
			near_misses += 1
	return {"lattice": current, "applied": applied_list, "near_misses": near_misses}


# -----------------------------------------------------------------------------
# Magnitude scaling (soft/hard + mode + greed_index)
# -----------------------------------------------------------------------------

## Return a scaled copy of the candidate, or {} to skip. Never mutates input.
static func _scale_candidate(cand: Dictionary, sig: HabitSignature, cfg: Config) -> Dictionary:
	var hardness: String = String(cand.get("hardness", "soft"))
	var patches: Array = cand["patches"]
	# HARD ops keep magnitude. SOFT ops scale down under low soft_hard_bias.
	if hardness == "hard":
		return cand.duplicate(true)
	# Base retention: bias 0.5 keeps ~50% of patches; bias 1.0 keeps all;
	# bias 0.0 keeps only the top-1. Reader halves; Cold doubles capped.
	var base_retain := clampf(cfg.soft_hard_bias, 0.0, 1.0)
	if cfg.mode == "reader":
		base_retain *= 0.5
	elif cfg.mode == "cold":
		base_retain = min(1.0, base_retain * 2.0)
	# Greed nudges retention up — reward the greedy pattern with denser scars.
	base_retain = clampf(base_retain + 0.3 * sig.greed_index, 0.0, 1.0)
	var keep_count: int = maxi(1, int(ceil(float(patches.size()) * base_retain)))
	if keep_count >= patches.size():
		return cand.duplicate(true)
	var out: Dictionary = cand.duplicate(true)
	out["patches"] = patches.slice(0, keep_count)
	# Update telegraph.cells for UI parity.
	var telegraph: Dictionary = out.get("telegraph", {})
	if telegraph.has("cells"):
		var cells_arr: Array = telegraph["cells"]
		telegraph["cells"] = cells_arr.slice(0, keep_count)
		out["telegraph"] = telegraph
	return out


# -----------------------------------------------------------------------------
# Safety oracle
# -----------------------------------------------------------------------------

static func _check_safety(candidate_lat: Lattice, player_pos: Vector2i,
		baseline_len: int, cfg: Config) -> Dictionary:
	if not LatticeBFS.is_solvable(candidate_lat):
		return {"ok": false, "reason": "unsolvable", "safety": {},
				"near_miss": false, "near_miss_cell": Vector2i(-1, -1)}
	var path := LatticeBFS.shortest_path(candidate_lat, player_pos, candidate_lat.goal)
	if path.is_empty():
		return {"ok": false, "reason": "player_stranded", "safety": {},
				"near_miss": false, "near_miss_cell": Vector2i(-1, -1)}
	var bottleneck := LatticeBFS.goal_bottleneck_width(candidate_lat)
	var exits := LatticeBFS.player_exits(candidate_lat, player_pos)
	var new_len := path.size()
	if bottleneck < cfg.min_bottleneck:
		return {"ok": false, "reason": "goal_bottleneck_too_narrow",
				"safety": {"path_len": new_len, "bottleneck": bottleneck, "player_exits": exits},
				"near_miss": false, "near_miss_cell": Vector2i(-1, -1)}
	if exits < cfg.min_player_exits:
		return {"ok": false, "reason": "player_exits_too_narrow",
				"safety": {"path_len": new_len, "bottleneck": bottleneck, "player_exits": exits},
				"near_miss": false, "near_miss_cell": Vector2i(-1, -1)}
	if cfg.max_length_factor > 0.0 and baseline_len > 0:
		var ceiling := int(ceil(float(baseline_len) * cfg.max_length_factor))
		if new_len > ceiling:
			return {"ok": false, "reason": "path_grew_too_much",
					"safety": {"path_len": new_len, "bottleneck": bottleneck, "player_exits": exits},
					"near_miss": false, "near_miss_cell": Vector2i(-1, -1)}
	# Near-miss: safe but on the edge.
	var near := (bottleneck <= 1) or (exits <= 1)
	var nm_cell := Vector2i(-1, -1)
	if near:
		nm_cell = _first_open_neighbour(candidate_lat, candidate_lat.goal)
	return {"ok": true, "reason": "safe",
			"safety": {"path_len": new_len, "bottleneck": bottleneck, "player_exits": exits},
			"near_miss": near, "near_miss_cell": nm_cell}


static func _first_open_neighbour(lattice: Lattice, pos: Vector2i) -> Vector2i:
	for d in Lattice.DIRS_4:
		var n := pos + d
		if lattice.is_passable(n):
			return n
	return Vector2i(-1, -1)


# -----------------------------------------------------------------------------
# Combo chains
# -----------------------------------------------------------------------------

## Look through the remaining filtered candidates for one that lists the
## applied op in its `reacts_to`. Return {} if none commits safely.
static func _try_combo(current_lat: Lattice, sig: HabitSignature, path: Array,
		player_pos: Vector2i, filtered: Array, applied: Dictionary,
		baseline_len: int, cfg: Config, rng: RandomNumberGenerator) -> Dictionary:
	var applied_name := String(applied.get("name", ""))
	# Rank chain candidates by score+combo_bonus.
	var chain: Array = []
	for c in filtered:
		if c == applied:
			continue
		var reacts_variant = c.get("reacts_to", PackedStringArray())
		var reacts := PackedStringArray(reacts_variant)
		if not reacts.has(applied_name):
			continue
		var boosted: Dictionary = c.duplicate(true)
		boosted["_chain_score"] = float(c["score"]) + cfg.combo_bonus + rng.randf_range(-cfg.score_jitter, cfg.score_jitter)
		chain.append(boosted)
	if chain.is_empty():
		return {}
	chain.sort_custom(func(a, b): return float(a["_chain_score"]) > float(b["_chain_score"]))
	for c in chain:
		var lat := current_lat.clone()
		if not lat.apply_patches(c["patches"]):
			continue
		var safety := _check_safety(lat, player_pos, baseline_len, cfg)
		if not safety["ok"]:
			continue
		return {
			"lattice": lat,
			"rewrite": c,
			"safety": safety["safety"],
			"near_miss": safety["near_miss"],
			"near_miss_cell": safety["near_miss_cell"],
		}
	return {}
