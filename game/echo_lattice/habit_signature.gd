class_name HabitSignature
extends RefCounted

## Aggregate movement fingerprint derived from a PathRecorder + Lattice.
##
## The signature is deterministic, JSON-serialisable, and cheap to compare.
## It exposes the features the rewrite operators actually consume.
##
## v2.0 additions
## --------------
## * `density_slope` (H6) — rate of new-cell discovery over the window.
##   Positive slope = still exploring; negative = crowding old ground.
## * `undo_rate` (H7) — undo appends divided by window step count.
## * `echo_depth` (H8) — length of the longest consecutive backtrack streak
##   (dirs[i] == -dirs[i-1]). Named "echo" because it is the 2-D analogue of
##   the GDD's ECHO verb chain length.
## * `hot_dominance` (D3) — max_visits / total_steps; how much one cell hogs
##   the window.
## * `greed_index` — a scalar in [0,1] combining low undo, high growth, high
##   dominance, high bias. Feeds into risk/reward scaling: greedy runs get
##   denser fossils (bigger patches, richer scars) but harder clears (more
##   deflectors, tighter magnitudes). The formula is intentionally simple so
##   players can *learn* what makes it climb.
## * `fingerprint()` — 64-bit FNV-1a hash for determinism/replay tests.
##
## The signature is read-only after construction. Recomputing is
## O(path_length + unique_cells).

const _DIR_UP := Vector2i(0, -1)
const _DIR_DOWN := Vector2i(0, 1)
const _DIR_LEFT := Vector2i(-1, 0)
const _DIR_RIGHT := Vector2i(1, 0)

## v1 baseline metrics
var dir_bias: Dictionary = {}         # Vector2i -> float in [0, 1]
var dominant_dir: Vector2i = Vector2i.ZERO
var dominant_bias: float = 0.0
var turn_rate: float = 0.0
var backtrack_rate: float = 0.0
var wall_hug: float = 0.0
var visit_counts: Dictionary = {}     # Vector2i -> int
var straight_streaks: Array[int] = []
var total_steps: int = 0
var unique_cell_count: int = 0
var _sorted_hot: Array = []           # Array[Vector2i], excludes start/goal

## v2 additions
var density_slope: float = 0.0        ## H6
var undo_rate: float = 0.0            ## H7
var echo_depth: int = 0               ## H8
var hot_dominance: float = 0.0        ## D3
var greed_index: float = 0.0          ## R1: risk/reward scalar in [0,1]


static func extract(recorder: PathRecorder, lattice: Lattice) -> HabitSignature:
	assert(recorder != null, "extract: recorder is null")
	assert(lattice != null, "extract: lattice is null")
	var sig := HabitSignature.new()
	var positions := recorder.positions()
	sig.visit_counts = recorder.visit_counts()
	sig.unique_cell_count = sig.visit_counts.size()
	if positions.size() < 2:
		sig.dir_bias = {_DIR_UP: 0.0, _DIR_DOWN: 0.0, _DIR_LEFT: 0.0, _DIR_RIGHT: 0.0}
		sig._compute_wall_hug(lattice)
		sig._compute_hot_cells(lattice)
		sig._compute_undo_rate(recorder)
		sig._compute_greed_index()
		return sig
	sig._compute_direction_stats(recorder)
	sig._compute_wall_hug(lattice)
	sig._compute_hot_cells(lattice)
	sig._compute_density_slope(positions)
	sig._compute_undo_rate(recorder)
	sig._compute_hot_dominance()
	sig._compute_greed_index()
	return sig


func _compute_direction_stats(recorder: PathRecorder) -> void:
	var dirs := recorder.directions()
	total_steps = dirs.size()
	if total_steps == 0:
		return
	var counts := {_DIR_UP: 0, _DIR_DOWN: 0, _DIR_LEFT: 0, _DIR_RIGHT: 0}
	var turns := 0
	var backtracks := 0
	var streaks: Array[int] = []
	var streak_len := 1
	var back_streak := 0
	var max_back_streak := 0
	for i in range(dirs.size()):
		var d: Vector2i = dirs[i]
		if counts.has(d):
			counts[d] = int(counts[d]) + 1
		if i > 0:
			var prev: Vector2i = dirs[i - 1]
			if d == -prev:
				backtracks += 1
				back_streak += 1
				if back_streak > max_back_streak:
					max_back_streak = back_streak
			else:
				back_streak = 0
			if d != prev:
				turns += 1
				streaks.append(streak_len)
				streak_len = 1
			else:
				streak_len += 1
	streaks.append(streak_len)
	streaks.sort()
	streaks.reverse()
	straight_streaks = streaks
	echo_depth = max_back_streak
	var total := float(total_steps)
	dir_bias = {}
	for k in counts.keys():
		dir_bias[k] = float(counts[k]) / total
	# Argmax with deterministic tie-break: U > D > L > R.
	var order: Array[Vector2i] = [_DIR_UP, _DIR_DOWN, _DIR_LEFT, _DIR_RIGHT]
	var best_dir: Vector2i = order[0]
	var best_val := -1.0
	for d in order:
		var v: float = dir_bias[d]
		if v > best_val:
			best_val = v
			best_dir = d
	dominant_dir = best_dir
	dominant_bias = best_val
	turn_rate = float(turns) / float(max(1, dirs.size() - 1)) if dirs.size() > 1 else 0.0
	backtrack_rate = float(backtracks) / float(max(1, dirs.size() - 1)) if dirs.size() > 1 else 0.0


func _compute_wall_hug(lattice: Lattice) -> void:
	if visit_counts.is_empty():
		wall_hug = 0.0
		return
	var hugging := 0
	for cell in visit_counts.keys():
		var pos: Vector2i = cell
		for d in Lattice.DIRS_4:
			if lattice.is_wall(pos + d):
				hugging += 1
				break
	wall_hug = float(hugging) / float(visit_counts.size())


func _compute_hot_cells(lattice: Lattice) -> void:
	var entries: Array = []
	for cell in visit_counts.keys():
		var pos: Vector2i = cell
		if pos == lattice.start or pos == lattice.goal:
			continue
		entries.append({"pos": pos, "n": int(visit_counts[cell])})
	entries.sort_custom(func(a, b):
		if a["n"] != b["n"]:
			return a["n"] > b["n"]
		var pa: Vector2i = a["pos"]
		var pb: Vector2i = b["pos"]
		if pa.y != pb.y:
			return pa.y < pb.y
		return pa.x < pb.x
	)
	_sorted_hot = []
	for e in entries:
		_sorted_hot.append(e["pos"])


func _compute_density_slope(positions: Array) -> void:
	## H6 — how fast is the player finding new cells over the window?
	## Slope units are (Δ unique cells) / (Δ steps), sampled from mid-to-end.
	if positions.size() < 4:
		density_slope = 0.0
		return
	var n := positions.size()
	var mid := int(n / 2)
	var seen_mid := {}
	for i in range(mid):
		seen_mid[positions[i]] = true
	var seen_end: Dictionary = seen_mid.duplicate()
	for i in range(mid, n):
		seen_end[positions[i]] = true
	var v_start := seen_mid.size()
	var v_end := seen_end.size()
	var half_span := float(n - mid)
	if half_span <= 0.0:
		density_slope = 0.0
		return
	density_slope = float(v_end - v_start) / half_span


func _compute_undo_rate(recorder: PathRecorder) -> void:
	## H7 — undo appends over total transitions. Uses the recorder's
	## undo_count rather than scanning to preserve O(1) freshness.
	var steps: int = maxi(1, recorder.step_count())
	undo_rate = float(recorder.undo_count) / float(steps)


func _compute_hot_dominance() -> void:
	if visit_counts.is_empty() or total_steps == 0:
		hot_dominance = 0.0
		return
	var top := 0
	for cell in visit_counts.keys():
		var v: int = int(visit_counts[cell])
		if v > top:
			top = v
	hot_dominance = float(top) / float(total_steps)


func _compute_greed_index() -> void:
	## Risk/reward scalar. Rises with:
	##   - low undo_rate (H7 TIDY)  — commits, doesn't second-guess.
	##   - high growth  (H6 GROW)   — always pushing new ground.
	##   - high hot_dominance (D3)  — has a favourite tile.
	##   - high dominant_bias (H2 BIASED) — knows the line it wants.
	## Missing dominance or bias caps the score. The formula is intentionally
	## additive so a player can *learn* what nudges it.
	if total_steps <= 0:
		greed_index = 0.0
		return
	var tidy := clampf(1.0 - undo_rate * 2.0, 0.0, 1.0)  # 0 at 0.5+ undo; 1 at 0
	var grow := clampf(density_slope * 5.0, 0.0, 1.0)
	var dom := clampf(dominant_bias, 0.0, 1.0)
	var hog := clampf(hot_dominance, 0.0, 1.0)
	greed_index = clampf(0.25 * tidy + 0.25 * grow + 0.20 * hog + 0.30 * dom, 0.0, 1.0)


func hot_cells(k: int = 8) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var limit: int = mini(k, _sorted_hot.size())
	for i in range(limit):
		out.append(_sorted_hot[i])
	return out


# -----------------------------------------------------------------------------
# Buckets & fingerprint
# -----------------------------------------------------------------------------

## Return the enum-string bucket for the requested H-metric. See systems doc.
func bucket(id: String) -> String:
	match id:
		"H2":
			if dominant_bias < 0.30:
				return "DIFFUSE"
			if dominant_bias < 0.55:
				return "TILTED"
			return "BIASED"
		"H4":
			var med := _median_streak()
			if med <= 1:
				return "STACCATO"
			if med <= 3:
				return "REGULAR"
			return "LONG"
		"H5":
			if wall_hug < 0.30:
				return "LOOSE"
			if wall_hug < 0.60:
				return "MID"
			return "HUG"
		"H6":
			if density_slope < -0.05:
				return "SHRINK"
			if density_slope > 0.05:
				return "GROW"
			return "STEADY"
		"H7":
			if undo_rate < 0.05:
				return "TIDY"
			if undo_rate < 0.20:
				return "TRIAL"
			return "THRASH"
		"H8":
			if echo_depth == 0:
				return "NONE"
			if echo_depth <= 2:
				return "LIGHT"
			return "REFRAIN"
	push_error("HabitSignature.bucket: unknown id '%s'" % id)
	return "?"


func _median_streak() -> int:
	if straight_streaks.is_empty():
		return 0
	var n := straight_streaks.size()
	if n % 2 == 1:
		return straight_streaks[int(n / 2)]
	return int((straight_streaks[n / 2 - 1] + straight_streaks[n / 2]) / 2)


func fingerprint() -> int:
	var h: int = 1469598103934665603  # FNV offset basis
	var prime := 1099511628211
	h = (h ^ total_steps) * prime
	h = (h ^ unique_cell_count) * prime
	h = (h ^ _quantise(dominant_bias, 1000)) * prime
	h = (h ^ _quantise(turn_rate, 1000)) * prime
	h = (h ^ _quantise(backtrack_rate, 1000)) * prime
	h = (h ^ _quantise(wall_hug, 1000)) * prime
	h = (h ^ _quantise(density_slope, 1000)) * prime
	h = (h ^ _quantise(undo_rate, 1000)) * prime
	h = (h ^ echo_depth) * prime
	h = (h ^ _quantise(hot_dominance, 1000)) * prime
	h = (h ^ _quantise(greed_index, 1000)) * prime
	var order: Array[Vector2i] = [_DIR_UP, _DIR_DOWN, _DIR_LEFT, _DIR_RIGHT]
	for d in order:
		var v: float = dir_bias.get(d, 0.0)
		h = (h ^ _quantise(v, 1000)) * prime
	for s in straight_streaks:
		h = (h ^ s) * prime
	return h


static func _quantise(v: float, scale: int) -> int:
	## Integer-quantise a float to remove float non-determinism from the hash
	## without affecting any downstream decision.
	return int(round(v * float(scale)))


# -----------------------------------------------------------------------------
# Serialisation & summary
# -----------------------------------------------------------------------------

func to_data() -> Dictionary:
	var bias := {}
	for d in dir_bias.keys():
		var v: Vector2i = d
		bias["%d,%d" % [v.x, v.y]] = dir_bias[d]
	return {
		"dir_bias": bias,
		"dominant_dir": [dominant_dir.x, dominant_dir.y],
		"dominant_bias": dominant_bias,
		"turn_rate": turn_rate,
		"backtrack_rate": backtrack_rate,
		"wall_hug": wall_hug,
		"total_steps": total_steps,
		"unique_cells": unique_cell_count,
		"streaks": straight_streaks,
		"density_slope": density_slope,
		"undo_rate": undo_rate,
		"echo_depth": echo_depth,
		"hot_dominance": hot_dominance,
		"greed_index": greed_index,
		"buckets": {
			"H2": bucket("H2"),
			"H4": bucket("H4"),
			"H5": bucket("H5"),
			"H6": bucket("H6"),
			"H7": bucket("H7"),
			"H8": bucket("H8"),
		},
		"fingerprint": fingerprint(),
	}


func summary() -> String:
	return "Habit(dom=%s @ %.2f, turn=%.2f, back=%.2f, hug=%.2f, grow=%+.2f, undo=%.2f, echo=%d, greed=%.2f, steps=%d, uniq=%d)" % [
		dominant_dir, dominant_bias, turn_rate, backtrack_rate, wall_hug,
		density_slope, undo_rate, echo_depth, greed_index,
		total_steps, unique_cell_count,
	]
