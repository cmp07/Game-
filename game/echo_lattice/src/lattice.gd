## Lattice — the tile grid that Echo Lattice's chambers are made of.
##
## A `Lattice` is a rectangular grid of small integer cell codes. It is a
## pure data container: it never mutates itself when transforms are
## applied — grammars in `grammar.gd` always return a new `Lattice`.
##
## Cell codes are stable across saves and the wire format:
##
##   0 = WALL   — solid; blocks movement.
##   1 = FLOOR  — walkable.
##   2 = START  — walkable; unique per lattice; player spawns here.
##   3 = DOOR   — walkable; unique per lattice; reaching it clears the room.
##
## Invariants that the rest of the codebase relies on and that the QA
## matrix in `docs/ECHO_LATTICE/09_QA.md` enforces:
##
##   • `width > 0` and `height > 0`.
##   • `cells.size() == width * height`.
##   • Every value in `cells` is in `[0, 3]`.
##   • There is exactly one `START` and exactly one `DOOR` cell.
##
## Grammar operations that could otherwise violate the second-to-last
## invariant (duplicating start/door via mirror + append, etc.) always
## work on a copy and are validated by `is_valid()` before being handed
## back to the generator.
class_name Lattice
extends RefCounted

const WALL: int = 0
const FLOOR: int = 1
const START: int = 2
const DOOR: int = 3

var width: int = 0
var height: int = 0
var cells: PackedByteArray = PackedByteArray()


func _init(w: int = 0, h: int = 0, fill: int = WALL) -> void:
	width = w
	height = h
	cells = PackedByteArray()
	cells.resize(w * h)
	for i in range(cells.size()):
		cells[i] = fill


static func from_rows(rows: Array) -> Lattice:
	# Build a lattice from an array of equal-length strings using this legend:
	#   '#' = WALL, '.' = FLOOR, 'S' = START, 'D' = DOOR.
	# Handy for tests that want a small hand-authored grid.
	assert(rows.size() > 0, "from_rows requires at least one row")
	var h: int = rows.size()
	var w: int = String(rows[0]).length()
	var l: Lattice = Lattice.new(w, h, WALL)
	for y in range(h):
		var row: String = String(rows[y])
		assert(row.length() == w, "from_rows requires all rows to have equal length")
		for x in range(w):
			var ch: String = row.substr(x, 1)
			match ch:
				"#":
					l.set_cell(x, y, WALL)
				".":
					l.set_cell(x, y, FLOOR)
				"S":
					l.set_cell(x, y, START)
				"D":
					l.set_cell(x, y, DOOR)
				_:
					push_error("Unknown lattice glyph %s at (%d,%d)" % [ch, x, y])
	return l


func in_bounds(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < width and y < height


func get_cell(x: int, y: int) -> int:
	assert(in_bounds(x, y), "get_cell out of bounds")
	return cells[y * width + x]


func set_cell(x: int, y: int, v: int) -> void:
	assert(in_bounds(x, y), "set_cell out of bounds")
	assert(v >= 0 and v <= 3, "cell value out of range")
	cells[y * width + x] = v


func is_walkable(x: int, y: int) -> bool:
	if not in_bounds(x, y):
		return false
	var v: int = get_cell(x, y)
	return v == FLOOR or v == START or v == DOOR


func find_first(kind: int) -> Vector2i:
	# Returns the first cell of the given kind, or (-1, -1) if none exists.
	for y in range(height):
		for x in range(width):
			if get_cell(x, y) == kind:
				return Vector2i(x, y)
	return Vector2i(-1, -1)


func count_of(kind: int) -> int:
	var n: int = 0
	for v in cells:
		if v == kind:
			n += 1
	return n


func clone() -> Lattice:
	var out: Lattice = Lattice.new(width, height, WALL)
	out.cells = cells.duplicate()
	return out


func equals(other: Lattice) -> bool:
	if other == null:
		return false
	if other.width != width or other.height != height:
		return false
	if other.cells.size() != cells.size():
		return false
	for i in range(cells.size()):
		if cells[i] != other.cells[i]:
			return false
	return true


func is_valid() -> bool:
	# Structural invariants that every chamber must satisfy before it is
	# handed to the player. The generator asserts this after each grammar
	# pass; the safe grammar wrapper reverts any transform that violates it.
	if width <= 0 or height <= 0:
		return false
	if cells.size() != width * height:
		return false
	var starts: int = 0
	var doors: int = 0
	for v in cells:
		if v < 0 or v > 3:
			return false
		if v == START:
			starts += 1
		elif v == DOOR:
			doors += 1
	return starts == 1 and doors == 1


func to_rows() -> Array:
	# Inverse of `from_rows` — useful in test failure messages.
	var out: Array = []
	for y in range(height):
		var s: String = ""
		for x in range(width):
			match get_cell(x, y):
				WALL:
					s += "#"
				FLOOR:
					s += "."
				START:
					s += "S"
				DOOR:
					s += "D"
				_:
					s += "?"
		out.append(s)
	return out
