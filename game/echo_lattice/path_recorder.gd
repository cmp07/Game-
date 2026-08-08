class_name PathRecorder
extends RefCounted

## Records the sequence of cells a player occupies during a segment/run.
##
## The recorder is deliberately dumb: it is *only* an append-only log with a
## couple of derived queries. Interpretation (turns, backtracks, wall-hug,
## visit counts) lives in HabitSignature so that one PathRecorder instance can
## feed multiple downstream analyses.
##
## Semantics:
## * `record_step(pos)` appends `pos` if it differs from the last recorded cell.
##   Idle ticks (player standing still) collapse into a single entry.
## * `record_move(from, to)` records both endpoints in order. Convenient when
##   the recorder is fed from movement events rather than per-frame position.
## * The first call establishes the origin. Successive calls are validated to
##   be 4-adjacent when `strict_adjacency` is true, which is the default so
##   diagonal teleports don't silently corrupt downstream signatures.

var strict_adjacency: bool = true
var _positions: Array[Vector2i] = []


func _init(strict: bool = true) -> void:
	strict_adjacency = strict


func clear() -> void:
	_positions.clear()


func length() -> int:
	## Number of recorded cells (nodes), i.e. path length in vertices.
	return _positions.size()


func step_count() -> int:
	## Number of transitions (edges) recorded.
	return max(0, _positions.size() - 1)


func positions() -> Array[Vector2i]:
	return _positions.duplicate()


func last() -> Vector2i:
	if _positions.is_empty():
		return Vector2i(-1, -1)
	return _positions[_positions.size() - 1]


func record_step(pos: Vector2i) -> bool:
	## Append a cell. Returns true when the log actually grew.
	if _positions.is_empty():
		_positions.append(pos)
		return true
	var prev := _positions[_positions.size() - 1]
	if prev == pos:
		return false
	if strict_adjacency:
		var delta: Vector2i = pos - prev
		var manhattan: int = absi(delta.x) + absi(delta.y)
		assert(manhattan == 1, "record_step: non-adjacent jump %s -> %s" % [prev, pos])
	_positions.append(pos)
	return true


func record_move(from_pos: Vector2i, to_pos: Vector2i) -> void:
	if _positions.is_empty():
		record_step(from_pos)
	elif _positions[_positions.size() - 1] != from_pos:
		# Non-contiguous source: treat as a teleport-and-step.
		if strict_adjacency:
			assert(false, "record_move: last recorded %s but move starts at %s" % [_positions[_positions.size() - 1], from_pos])
		_positions.append(from_pos)
	record_step(to_pos)


## Direction vectors between successive positions.
## Length is step_count().
func directions() -> Array[Vector2i]:
	var dirs: Array[Vector2i] = []
	for i in range(1, _positions.size()):
		dirs.append(_positions[i] - _positions[i - 1])
	return dirs


## Visit counts per cell.
func visit_counts() -> Dictionary:
	var counts := {}
	for p in _positions:
		counts[p] = int(counts.get(p, 0)) + 1
	return counts


func unique_cells() -> Array[Vector2i]:
	var seen := {}
	var out: Array[Vector2i] = []
	for p in _positions:
		if seen.has(p):
			continue
		seen[p] = true
		out.append(p)
	return out


## Serialize as a plain Array-of-Arrays payload suitable for JSON or resources.
func to_data() -> Dictionary:
	var arr: Array = []
	for p in _positions:
		arr.append([p.x, p.y])
	return {"positions": arr, "strict": strict_adjacency}


static func from_data(data: Dictionary) -> PathRecorder:
	var r := PathRecorder.new(bool(data.get("strict", true)))
	# Bypass adjacency validation on load so historical recordings load cleanly.
	r.strict_adjacency = false
	for entry in data.get("positions", []):
		r._positions.append(Vector2i(int(entry[0]), int(entry[1])))
	r.strict_adjacency = bool(data.get("strict", true))
	return r
