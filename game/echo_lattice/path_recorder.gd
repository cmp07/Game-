class_name PathRecorder
extends RefCounted

## Records the sequence of cells a player occupies during a segment/run.
##
## The recorder is deliberately dumb: it is *only* an append-only log with a
## couple of derived queries. Interpretation (turns, backtracks, wall-hug,
## visit counts, undo rate, density slope) lives in HabitSignature so that one
## PathRecorder instance can feed multiple downstream analyses.
##
## Semantics:
## * `record_step(pos)` appends `pos` if it differs from the last recorded cell.
##   Idle ticks (player standing still) collapse into a single entry.
## * `record_move(from, to)` records both endpoints in order.
## * `record_undo()` appends a step to the previous cell **and** increments the
##   `undo_count` field. The append-only trail lets us compute H7 (undo rate)
##   without a mutable log, and preserves determinism for replay.
## * `record_motif_boundary()` snapshots the current path length; used by
##   HabitSignature to window the tail-since-last-motif for combo/telegraph
##   scoring.
##
## The first call establishes the origin. Successive calls are validated to
## be 4-adjacent when `strict_adjacency` is true.

var strict_adjacency: bool = true
var undo_count: int = 0
var _positions: Array[Vector2i] = []
var _undo_flags: Array[bool] = []  ## parallel to _positions; true if the step
                                    ## was an undo append
var _motif_boundaries: PackedInt32Array = PackedInt32Array()


func _init(strict: bool = true) -> void:
	strict_adjacency = strict


func clear() -> void:
	_positions.clear()
	_undo_flags.clear()
	_motif_boundaries.clear()
	undo_count = 0


func length() -> int:
	return _positions.size()


func step_count() -> int:
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
		_undo_flags.append(false)
		return true
	var prev := _positions[_positions.size() - 1]
	if prev == pos:
		return false
	if strict_adjacency:
		var delta: Vector2i = pos - prev
		var manhattan: int = absi(delta.x) + absi(delta.y)
		assert(manhattan == 1, "record_step: non-adjacent jump %s -> %s" % [prev, pos])
	_positions.append(pos)
	_undo_flags.append(false)
	return true


func record_move(from_pos: Vector2i, to_pos: Vector2i) -> void:
	if _positions.is_empty():
		record_step(from_pos)
	elif _positions[_positions.size() - 1] != from_pos:
		if strict_adjacency:
			assert(false, "record_move: last recorded %s but move starts at %s" % [_positions[_positions.size() - 1], from_pos])
		_positions.append(from_pos)
		_undo_flags.append(false)
	record_step(to_pos)


## Record an undo tick. Requires at least two positions logged (there must be
## a "previous" cell to fall back to). Appends the previous cell and flags the
## new entry as an undo append. Returns true if the undo was recorded.
func record_undo() -> bool:
	if _positions.size() < 2:
		return false
	var prev := _positions[_positions.size() - 2]
	_positions.append(prev)
	_undo_flags.append(true)
	undo_count += 1
	return true


## Snapshot the current path length as a motif boundary. HabitSignature slices
## the window as `positions[last_motif..end]` when computing per-motif metrics
## like H6 density slope and near-miss detection.
func record_motif_boundary() -> void:
	_motif_boundaries.append(_positions.size())


func motif_boundaries() -> PackedInt32Array:
	return _motif_boundaries.duplicate()


func undo_flags() -> Array[bool]:
	return _undo_flags.duplicate()


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
	var flags: Array = []
	for f in _undo_flags:
		flags.append(f)
	var motifs: Array = []
	for i in range(_motif_boundaries.size()):
		motifs.append(_motif_boundaries[i])
	return {
		"positions": arr,
		"strict": strict_adjacency,
		"undo_count": undo_count,
		"undo_flags": flags,
		"motif_boundaries": motifs,
	}


static func from_data(data: Dictionary) -> PathRecorder:
	var r := PathRecorder.new(bool(data.get("strict", true)))
	r.strict_adjacency = false
	for entry in data.get("positions", []):
		r._positions.append(Vector2i(int(entry[0]), int(entry[1])))
	var flags_raw = data.get("undo_flags", [])
	for f in flags_raw:
		r._undo_flags.append(bool(f))
	while r._undo_flags.size() < r._positions.size():
		r._undo_flags.append(false)
	r.undo_count = int(data.get("undo_count", 0))
	for m in data.get("motif_boundaries", []):
		r._motif_boundaries.append(int(m))
	r.strict_adjacency = bool(data.get("strict", true))
	return r
