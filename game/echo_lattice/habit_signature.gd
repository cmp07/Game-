class_name HabitSignature
extends RefCounted

## Aggregate movement fingerprint derived from a PathRecorder + Lattice.
##
## The signature is deterministic, JSON-serializable, and cheap to compare. It
## exposes the features the rewrite operators actually consume:
##
## * `dir_bias` — probability distribution over UP/DOWN/LEFT/RIGHT.
## * `dominant_dir` — argmax of `dir_bias` (Vector2i.ZERO when path is empty).
## * `dominant_bias` — probability mass of the dominant direction (0.0..1.0).
## * `turn_rate` — fraction of steps where direction changed vs prior step.
## * `backtrack_rate` — fraction of steps that reversed the immediately prior
##   direction.
## * `wall_hug` — fraction of *unique* visited cells that touch at least one
##   wall (Cell.WALL or Cell.FOSSIL) in the 4-neighbourhood.
## * `visit_counts` — Dictionary[Vector2i,int] over all visited cells.
## * `hot_cells(k)` — top-k visited cells excluding start/goal, sorted by visit
##   count desc then by (y, x) for stability.
## * `straight_streaks` — sorted lengths of maximal same-direction runs.
##
## The signature is intentionally read-only after construction. Recomputing is
## O(path_length + unique_cells).

const _DIR_UP := Vector2i(0, -1)
const _DIR_DOWN := Vector2i(0, 1)
const _DIR_LEFT := Vector2i(-1, 0)
const _DIR_RIGHT := Vector2i(1, 0)

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
		return sig
	sig._compute_direction_stats(recorder)
	sig._compute_wall_hug(lattice)
	sig._compute_hot_cells(lattice)
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
	for i in range(dirs.size()):
		var d: Vector2i = dirs[i]
		if counts.has(d):
			counts[d] = int(counts[d]) + 1
		if i > 0:
			var prev: Vector2i = dirs[i - 1]
			if d != prev:
				turns += 1
				if d == -prev:
					backtracks += 1
				streaks.append(streak_len)
				streak_len = 1
			else:
				streak_len += 1
	streaks.append(streak_len)
	streaks.sort()
	streaks.reverse()
	straight_streaks = streaks
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


func hot_cells(k: int = 8) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var limit: int = mini(k, _sorted_hot.size())
	for i in range(limit):
		out.append(_sorted_hot[i])
	return out


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
	}


func summary() -> String:
	return "Habit(dom=%s @ %.2f, turn=%.2f, back=%.2f, hug=%.2f, steps=%d, uniq=%d)" % [
		dominant_dir, dominant_bias, turn_rate, backtrack_rate, wall_hug, total_steps, unique_cell_count,
	]
