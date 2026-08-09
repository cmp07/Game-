class_name HabitSignature
extends RefCounted

## Lightweight movement fingerprint for the elevated chamber loop.
## Built from GameState.move_ring (+ optional path cells) and traverse counts —
## no Lattice / PathRecorder dependency. Duck-typed for HabitArchetype.

const DIR_UP := Vector2i(0, -1)
const DIR_DOWN := Vector2i(0, 1)
const DIR_LEFT := Vector2i(-1, 0)
const DIR_RIGHT := Vector2i(1, 0)

var dir_bias: Dictionary = {}
var dominant_dir: Vector2i = Vector2i.ZERO
var dominant_bias: float = 0.0
var turn_rate: float = 0.0
var backtrack_rate: float = 0.0
var visit_counts: Dictionary = {}
var straight_streaks: Array = []
var total_steps: int = 0
var unique_cell_count: int = 0
var _sorted_hot: Array = []


static func from_dirs_and_visits(dirs_in: Array, visits: Dictionary, exclude: Array = []) -> HabitSignature:
	var sig := HabitSignature.new()
	var dirs: Array = []
	for d in dirs_in:
		var v: Vector2i = _as_dir(d)
		if v != Vector2i.ZERO:
			dirs.append(v)
	sig.total_steps = dirs.size()
	sig.visit_counts = visits.duplicate()
	sig.unique_cell_count = sig.visit_counts.size()
	sig._compute_direction_stats(dirs)
	sig._compute_hot_cells(exclude)
	return sig


static func from_game_state(gs: Node, traverse: Dictionary, exclude: Array = []) -> HabitSignature:
	var ring: Array = []
	if gs != null and "move_ring" in gs:
		ring = gs.move_ring
	return from_dirs_and_visits(ring, traverse, exclude)


static func _as_dir(d) -> Vector2i:
	if typeof(d) == TYPE_VECTOR2I:
		return d
	match str(d):
		"up":
			return DIR_UP
		"down":
			return DIR_DOWN
		"left":
			return DIR_LEFT
		"right":
			return DIR_RIGHT
		_:
			return Vector2i.ZERO


func _compute_direction_stats(dirs: Array) -> void:
	dir_bias = {DIR_UP: 0.0, DIR_DOWN: 0.0, DIR_LEFT: 0.0, DIR_RIGHT: 0.0}
	dominant_dir = Vector2i.ZERO
	dominant_bias = 0.0
	turn_rate = 0.0
	backtrack_rate = 0.0
	straight_streaks = []
	if dirs.is_empty():
		return
	var counts := {DIR_UP: 0, DIR_DOWN: 0, DIR_LEFT: 0, DIR_RIGHT: 0}
	var turns := 0
	var backtracks := 0
	var streaks: Array = []
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
	var total := float(dirs.size())
	for k in counts.keys():
		dir_bias[k] = float(counts[k]) / total
	var order: Array = [DIR_UP, DIR_DOWN, DIR_LEFT, DIR_RIGHT]
	var best_dir: Vector2i = order[0]
	var best_val := -1.0
	for d in order:
		var v: float = float(dir_bias[d])
		if v > best_val:
			best_val = v
			best_dir = d
	dominant_dir = best_dir
	dominant_bias = best_val
	if dirs.size() > 1:
		var denom := float(dirs.size() - 1)
		turn_rate = float(turns) / denom
		backtrack_rate = float(backtracks) / denom


func _compute_hot_cells(exclude: Array) -> void:
	var blocked := {}
	for e in exclude:
		blocked[_as_cell(e)] = true
	var entries: Array = []
	for cell in visit_counts.keys():
		var pos: Vector2i = _as_cell(cell)
		if blocked.has(pos):
			continue
		entries.append({"pos": pos, "n": int(visit_counts[cell])})
	entries.sort_custom(func(a, b):
		if int(a["n"]) != int(b["n"]):
			return int(a["n"]) > int(b["n"])
		var pa: Vector2i = a["pos"]
		var pb: Vector2i = b["pos"]
		if pa.y != pb.y:
			return pa.y < pb.y
		return pa.x < pb.x
	)
	_sorted_hot.clear()
	for e in entries:
		_sorted_hot.append(e["pos"])


static func _as_cell(c) -> Vector2i:
	if typeof(c) == TYPE_VECTOR2I:
		return c
	if typeof(c) == TYPE_DICTIONARY:
		return Vector2i(int(c.get("x", 0)), int(c.get("y", 0)))
	return Vector2i.ZERO


func hot_cells(k: int = 8) -> Array:
	var out: Array = []
	var limit: int = mini(k, _sorted_hot.size())
	for i in range(limit):
		out.append(_sorted_hot[i])
	return out


func to_data() -> Dictionary:
	return {
		"dominant_bias": dominant_bias,
		"turn_rate": turn_rate,
		"backtrack_rate": backtrack_rate,
		"total_steps": total_steps,
		"unique_cells": unique_cell_count,
		"straight_streaks": straight_streaks.duplicate(),
	}
