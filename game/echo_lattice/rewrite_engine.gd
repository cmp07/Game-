class_name RewriteEngine
extends RefCounted

## Orchestrates the rewrite pipeline:
##
##   1. Take a Lattice + HabitSignature.
##   2. Ask RewriteOperators for every candidate rewrite.
##   3. Try them in order (score desc, RNG jitter to break ties) and commit
##      the first one that (a) doesn't remove start/goal and (b) leaves the
##      lattice solvable per BFS.
##   4. Return an `EngineResult` describing what happened.
##
## The engine is pure w.r.t. the input Lattice: it never mutates the passed-in
## lattice, only its own clone. Callers can decide whether to swap the clone in
## place.

class EngineResult:
	extends RefCounted
	var applied: bool = false
	var lattice: Lattice
	var rewrite: Dictionary = {}           # the committed rewrite, if applied
	var attempts: int = 0
	var considered: int = 0
	var rejected: Array = []               # Array<{rewrite, reason}>
	var reason: String = ""                # populated when applied == false

	func summary() -> String:
		if applied:
			return "RewriteEngine: applied '%s' (score=%.2f) after %d attempts" % [
				rewrite.get("name", "?"), float(rewrite.get("score", 0.0)), attempts,
			]
		return "RewriteEngine: no rewrite applied (considered=%d, reason=%s)" % [considered, reason]


class Config:
	extends RefCounted
	var max_attempts: int = 32
	var score_jitter: float = 0.05           # +/- jitter applied per candidate
	var require_shorter_or_equal: bool = false  # if true, only accept when new BFS length <= old
	var min_score: float = 0.0
	var enabled_ops: PackedStringArray = PackedStringArray([
		"fossilize_hot_cell",
		"place_deflector",
		"carve_shortcut",
		"grow_wall_far_from_path",
		"widen_hot_corridor",
	])


static func apply(lattice: Lattice, sig: HabitSignature, rng: RandomNumberGenerator = null, config: Config = null) -> EngineResult:
	var result := EngineResult.new()
	result.lattice = lattice.clone()

	var cfg := config if config != null else Config.new()
	var candidates := RewriteOperators.propose_all(lattice, sig)
	if candidates.is_empty():
		result.reason = "no_candidates"
		return result

	# Filter by enabled ops + min_score.
	var filtered: Array = []
	for c in candidates:
		if not cfg.enabled_ops.has(c["name"]):
			continue
		if float(c["score"]) < cfg.min_score:
			continue
		filtered.append(c)
	if filtered.is_empty():
		result.reason = "no_enabled_candidates"
		return result

	# Apply score jitter for tie-breaking, then re-sort. Preserves determinism
	# when rng.seed is fixed.
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.seed = 0
	for c in filtered:
		var j := rng.randf_range(-cfg.score_jitter, cfg.score_jitter)
		c["_jittered"] = float(c["score"]) + j
	filtered.sort_custom(func(a, b): return float(a["_jittered"]) > float(b["_jittered"]))

	result.considered = filtered.size()

	var baseline_len := -1
	if cfg.require_shorter_or_equal:
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
		if not LatticeBFS.is_solvable(candidate_lat):
			result.rejected.append({"rewrite": c, "reason": "unsolvable"})
			continue
		if cfg.require_shorter_or_equal:
			var new_path := LatticeBFS.shortest_path(candidate_lat, candidate_lat.start, candidate_lat.goal)
			if new_path.size() > baseline_len:
				result.rejected.append({"rewrite": c, "reason": "longer_than_baseline"})
				continue
		result.applied = true
		result.attempts = attempts
		result.rewrite = c
		result.lattice = candidate_lat
		return result

	result.attempts = attempts
	result.reason = "exhausted"
	return result


## Apply repeatedly until no more rewrites succeed or `max_rewrites` is hit.
## Returns the final lattice + list of applied rewrites. Useful for
## between-run "aging" of the maze, or for tests that assert convergence.
static func apply_repeated(lattice: Lattice, sig: HabitSignature, rng: RandomNumberGenerator = null, max_rewrites: int = 8, config: Config = null) -> Dictionary:
	var current := lattice.clone()
	var applied_list: Array = []
	for i in range(max_rewrites):
		var res := RewriteEngine.apply(current, sig, rng, config)
		if not res.applied:
			break
		current = res.lattice
		applied_list.append(res.rewrite)
	return {"lattice": current, "applied": applied_list}
