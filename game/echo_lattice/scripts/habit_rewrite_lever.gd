class_name HabitRewriteLever
extends RefCounted

## Bridges HabitSignature → RewriteScoreBias → chamber fossil cells.
## Pure / offline / deterministic. Does not mutate grids; chamber.gd validates
## FLOOR + BFS before committing. Soft/hard adaptation gates hard counters.

const OP_FOSSILIZE := "fossilize_hot_cell"
const OP_DEFLECTOR := "place_deflector"
const HARD_BIAS_FLOOR := 0.45

## Hardness registry aligned with balance_v2 rewrite_engine.hard_ops.
const HARDNESS := {
	"fossilize_hot_cell": "hard",
	"thicken_walked": "hard",
	"place_deflector": "soft",
	"carve_shortcut": "soft",
	"grow_wall_far_from_path": "soft",
	"widen_hot_corridor": "soft",
}


static func select_echo_cells(
	dirs: Array,
	visit_counts: Dictionary,
	path: Array,
	blocked: Dictionary,
	act_id: int,
	chamber_index: int,
	mode_id: String = "standard",
	chamber_soft_hard: float = -1.0,
	bal: BalanceTuning = null
) -> Dictionary:
	## Returns {cells, op, archetype, confidence, biased, soft_hard_bias}.
	var empty := {
		"cells": [],
		"op": "",
		"archetype": HabitArchetype.ID_BALANCED,
		"confidence": 0.0,
		"biased": [],
		"soft_hard_bias": 0.0,
	}
	var tuning := bal if bal != null else BalanceTuning.load_default()
	var bias := tuning.soft_hard_bias(act_id, mode_id)
	if chamber_soft_hard >= 0.0:
		bias = maxf(bias, chamber_soft_hard)
	empty["soft_hard_bias"] = bias

	var exclude: Array = []
	for k in blocked.keys():
		exclude.append(k)
	var sig := HabitSignature.from_dirs_and_visits(dirs, visit_counts, exclude)
	if sig.total_steps < 1 and sig.visit_counts.is_empty():
		return empty

	var arch := HabitArchetype.classify(sig, tuning)
	var candidates := _propose(sig, path, blocked)
	if candidates.is_empty():
		empty["archetype"] = arch.id
		empty["confidence"] = arch.confidence
		return empty

	var enabled := _enabled_ops(tuning, act_id, chamber_index, mode_id, bias)
	var filtered: Array = []
	for c in candidates:
		var name := str(c.get("name", ""))
		if not enabled.has(name):
			continue
		filtered.append(c)
	if filtered.is_empty():
		empty["archetype"] = arch.id
		empty["confidence"] = arch.confidence
		return empty

	var biased := RewriteScoreBias.apply(filtered, sig, tuning)
	var max_cells := _max_habit_cells(bias)
	var cells: Array = []
	var chosen_op := ""
	var seen := {}
	for c in biased:
		if cells.size() >= max_cells:
			break
		var pos: Vector2i = c.get("meta", {}).get("cell", Vector2i(-1, -1))
		if typeof(pos) != TYPE_VECTOR2I:
			continue
		if seen.has(pos) or blocked.has(pos):
			continue
		seen[pos] = true
		cells.append(pos)
		if chosen_op == "":
			chosen_op = str(c.get("name", ""))
	return {
		"cells": cells,
		"op": chosen_op,
		"archetype": arch.id,
		"confidence": arch.confidence,
		"biased": biased,
		"soft_hard_bias": bias,
	}


static func _enabled_ops(
	tuning: BalanceTuning, act_id: int, chamber_index: int, mode_id: String, soft_hard: float
) -> PackedStringArray:
	var ops := tuning.enabled_ops(act_id, chamber_index, mode_id)
	# Soft/hard adaptation: hard counters need both unlock and bias floor.
	var allow_hard := soft_hard >= HARD_BIAS_FLOOR and tuning.hard_ops_allowed(
		act_id, chamber_index, mode_id
	)
	var hard: Array = tuning.rewrite_engine_config().get("hard_ops", [])
	var out := PackedStringArray()
	for op in ops:
		var name := str(op)
		var is_hard := hard.has(name) or str(HARDNESS.get(name, "soft")) == "hard"
		if is_hard and not allow_hard:
			continue
		out.append(name)
	# Always allow the soft deflector lever when present in defaults — Act I bite.
	if not out.has(OP_DEFLECTOR):
		var defaults: Array = tuning.rewrite_engine_config().get("enabled_ops_default", [])
		if defaults.has(OP_DEFLECTOR) and (not hard.has(OP_DEFLECTOR)):
			out.append(OP_DEFLECTOR)
	return out


static func _max_habit_cells(soft_hard: float) -> int:
	if soft_hard < 0.2:
		return 0
	if soft_hard < 0.55:
		return 1
	return 2


static func _propose(sig: HabitSignature, path: Array, blocked: Dictionary) -> Array:
	var out: Array = []
	out.append_array(_propose_fossilize(sig, blocked))
	out.append_array(_propose_deflector(sig, path, blocked))
	return out


static func _propose_fossilize(sig: HabitSignature, blocked: Dictionary) -> Array:
	var out: Array = []
	for pos in sig.hot_cells(6):
		var p: Vector2i = pos
		if blocked.has(p):
			continue
		var visits: int = int(sig.visit_counts.get(p, 0))
		if visits < 2:
			continue
		var score := 1.0 + float(visits) + 0.5 * sig.dominant_bias
		out.append({
			"name": OP_FOSSILIZE,
			"score": score,
			"meta": {"operator": OP_FOSSILIZE, "cell": p, "visits": visits},
		})
	return out


static func _propose_deflector(sig: HabitSignature, path: Array, blocked: Dictionary) -> Array:
	var out: Array = []
	if sig.total_steps == 0 or sig.dominant_bias < 0.35:
		return out
	var dom: Vector2i = sig.dominant_dir
	if dom == Vector2i.ZERO:
		return out
	var visited: Dictionary = sig.visit_counts
	# Prefer visit histogram; fall back to unique path cells.
	if visited.is_empty():
		for p in path:
			var cell: Vector2i = p if typeof(p) == TYPE_VECTOR2I else Vector2i(int(p.x), int(p.y))
			visited[cell] = int(visited.get(cell, 0)) + 1
	var ranked: Array = []
	for cell in visited.keys():
		var pos: Vector2i = cell if typeof(cell) == TYPE_VECTOR2I else Vector2i(cell)
		var back: Vector2i = pos - dom
		var ahead: Vector2i = pos + dom
		if not visited.has(back):
			continue
		if visited.has(ahead):
			continue
		if blocked.has(ahead):
			continue
		var streak := _streak_back(pos, -dom, visited)
		if streak < 3:
			continue
		var score := 0.5 + float(streak) + 1.5 * sig.dominant_bias
		ranked.append({"pos": ahead, "score": score, "streak": streak})
	ranked.sort_custom(func(a, b):
		if float(a["score"]) != float(b["score"]):
			return float(a["score"]) > float(b["score"])
		var pa: Vector2i = a["pos"]
		var pb: Vector2i = b["pos"]
		if pa.y != pb.y:
			return pa.y < pb.y
		return pa.x < pb.x
	)
	for c in ranked:
		out.append({
			"name": OP_DEFLECTOR,
			"score": float(c["score"]),
			"meta": {
				"operator": OP_DEFLECTOR,
				"cell": c["pos"],
				"streak": int(c["streak"]),
				"dir": dom,
			},
		})
	return out


static func _streak_back(pos: Vector2i, back_dir: Vector2i, visited: Dictionary) -> int:
	var n := 1
	var cur: Vector2i = pos + back_dir
	while visited.has(cur):
		n += 1
		cur += back_dir
		if n > 64:
			break
	return n
