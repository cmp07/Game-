class_name Lattice
extends RefCounted

## Immutable-by-convention 2D grid of cells with a designated start and goal.
##
## The Lattice is the substrate that habit-driven rewrites operate on. It is a
## pure data structure: it never talks to the scene tree, uses only value-type
## fields, and can be cloned, serialized, and compared cheaply.
##
## Coordinate convention: (x, y) with x = column, y = row. y grows downward.
## All lookups take Vector2i.
##
## v2.0 cell additions
## -------------------
## ECHO_WALL       — impassable, distinct from WALL and FOSSIL; the tell-tale
##                   colour of a rewrite born from mirror/rotate operators.
##                   Sim-identical to WALL for solvability.
## CHECKPOINT      — walkable; entering the first time triggers a motif and
##                   fires one rewrite through the RewriteEngine.
## CHECKPOINT_USED — walkable; visually spent (no rewrite fires on re-entry).
## WISP            — walkable *once*; on any exit from a WISP cell the WISP
##                   dissolves back to FLOOR. Used by operators that want a
##                   dramatic near-miss without permanently trapping.
##
## All new cells preserve determinism: they never introduce float coordinates,
## RNG, or wall-clock reads.

enum Cell {
	FLOOR = 0,             ## Walkable empty tile.
	WALL = 1,              ## Impassable, hand-authored.
	START = 2,             ## Walkable; player spawn.
	GOAL = 3,              ## Walkable; success terminal.
	FOSSIL = 4,            ## Impassable; walls fossilized from player habit.
	SOFT = 5,              ## Walkable decorative overlay (still passable).
	ECHO_WALL = 6,         ## Impassable; born from mirror/rotate operators.
	CHECKPOINT = 7,        ## Walkable; first entry fires the rewrite pipeline.
	CHECKPOINT_USED = 8,   ## Walkable; spent checkpoint (visual only).
	WISP = 9,              ## Walkable-once; dissolves on exit.
}

## Cells the sim treats as passable at rest. WISP is technically passable but
## also handled by ChamberRuntime.on_leave to dissolve back to FLOOR.
const PASSABLE := [
	Cell.FLOOR, Cell.START, Cell.GOAL, Cell.SOFT,
	Cell.CHECKPOINT, Cell.CHECKPOINT_USED, Cell.WISP,
]

## Cells the sim treats as impassable walls for BFS / rewrite planning.
const WALL_LIKE := [Cell.WALL, Cell.FOSSIL, Cell.ECHO_WALL]

const DIR_UP := Vector2i(0, -1)
const DIR_DOWN := Vector2i(0, 1)
const DIR_LEFT := Vector2i(-1, 0)
const DIR_RIGHT := Vector2i(1, 0)
const DIRS_4 : Array[Vector2i] = [
	Vector2i(0, -1),
	Vector2i(0, 1),
	Vector2i(-1, 0),
	Vector2i(1, 0),
]

var width: int
var height: int
var start: Vector2i
var goal: Vector2i
## Row-major flat array of Cell ints of length width * height.
var _cells: PackedInt32Array


func _init(w: int = 0, h: int = 0, fill: int = Cell.FLOOR) -> void:
	assert(w >= 0 and h >= 0, "Lattice dimensions must be non-negative")
	width = w
	height = h
	start = Vector2i(-1, -1)
	goal = Vector2i(-1, -1)
	_cells = PackedInt32Array()
	_cells.resize(w * h)
	if fill != 0:
		for i in range(_cells.size()):
			_cells[i] = fill


# -----------------------------------------------------------------------------
# Cell access
# -----------------------------------------------------------------------------

func in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height


func get_cell(pos: Vector2i) -> int:
	assert(in_bounds(pos), "get_cell out of bounds: %s" % pos)
	return _cells[pos.y * width + pos.x]


func set_cell(pos: Vector2i, value: int) -> void:
	assert(in_bounds(pos), "set_cell out of bounds: %s" % pos)
	_cells[pos.y * width + pos.x] = value
	if value == Cell.START:
		start = pos
	elif value == Cell.GOAL:
		goal = pos


func is_passable(pos: Vector2i) -> bool:
	if not in_bounds(pos):
		return false
	return _cells[pos.y * width + pos.x] in PASSABLE


func is_wall(pos: Vector2i) -> bool:
	if not in_bounds(pos):
		return true
	var c := _cells[pos.y * width + pos.x]
	return c in WALL_LIKE


## Return the 4-neighbourhood of pos (regardless of passability).
func neighbors4(pos: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for d in DIRS_4:
		var n := pos + d
		if in_bounds(n):
			out.append(n)
	return out


## Return only passable neighbours.
func passable_neighbors(pos: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for d in DIRS_4:
		var n := pos + d
		if is_passable(n):
			out.append(n)
	return out


# -----------------------------------------------------------------------------
# Bulk operations
# -----------------------------------------------------------------------------

func clone() -> Lattice:
	var copy := Lattice.new(width, height, Cell.FLOOR)
	copy._cells = _cells.duplicate()
	copy.start = start
	copy.goal = goal
	return copy


## Apply a batch of (Vector2i pos, int cell) patches. Rejects overwrites of the
## start or goal tiles to keep terminals canonical. Returns false if any patch
## would violate that or fall out of bounds. All-or-nothing: on rejection,
## the lattice is not mutated.
func apply_patches(patches: Array) -> bool:
	for p in patches:
		var pos: Vector2i = p["pos"]
		if not in_bounds(pos):
			return false
		if pos == start or pos == goal:
			return false
	for p in patches:
		var pos: Vector2i = p["pos"]
		var v: int = p["cell"]
		_cells[pos.y * width + pos.x] = v
	return true


func cells_of(kind: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for y in range(height):
		for x in range(width):
			if _cells[y * width + x] == kind:
				out.append(Vector2i(x, y))
	return out


func count_of(kind: int) -> int:
	var n := 0
	for i in range(_cells.size()):
		if _cells[i] == kind:
			n += 1
	return n


## Sum of fossil-like impassable cells that arose from rewrites. Used by the
## risk/reward layer to reward density of scar tissue for greedy runs.
func fossil_density() -> int:
	return count_of(Cell.FOSSIL) + count_of(Cell.ECHO_WALL)


# -----------------------------------------------------------------------------
# Equality / hashing
# -----------------------------------------------------------------------------

func equals(other: Lattice) -> bool:
	if other == null:
		return false
	if width != other.width or height != other.height:
		return false
	if start != other.start or goal != other.goal:
		return false
	if _cells.size() != other._cells.size():
		return false
	for i in range(_cells.size()):
		if _cells[i] != other._cells[i]:
			return false
	return true


## Cheap FNV-1a-style hash over cells + terminals. Stable across processes.
func fingerprint() -> int:
	var h: int = 1469598103934665603  # FNV offset basis
	var prime := 1099511628211
	h = (h ^ width) * prime
	h = (h ^ height) * prime
	h = (h ^ start.x) * prime
	h = (h ^ start.y) * prime
	h = (h ^ goal.x) * prime
	h = (h ^ goal.y) * prime
	for i in range(_cells.size()):
		h = (h ^ _cells[i]) * prime
	return h


# -----------------------------------------------------------------------------
# ASCII I/O — helpful for tests and for hand-authored chambers.
# -----------------------------------------------------------------------------

## ASCII glyph legend used by from_ascii / to_ascii.
##   '.'  floor    '#'  wall    'S'  start    'G'  goal
##   '*'  fossil   ':'  soft    'E'  echo_wall
##   'C'  checkpoint (fresh)    'c'  checkpoint_used
##   'w'  wisp
const _ASCII_TO_CELL := {
	".": Cell.FLOOR,
	" ": Cell.FLOOR,
	"#": Cell.WALL,
	"S": Cell.START,
	"G": Cell.GOAL,
	"*": Cell.FOSSIL,
	":": Cell.SOFT,
	"E": Cell.ECHO_WALL,
	"C": Cell.CHECKPOINT,
	"c": Cell.CHECKPOINT_USED,
	"w": Cell.WISP,
}

const _CELL_TO_ASCII := {
	Cell.FLOOR: ".",
	Cell.WALL: "#",
	Cell.START: "S",
	Cell.GOAL: "G",
	Cell.FOSSIL: "*",
	Cell.SOFT: ":",
	Cell.ECHO_WALL: "E",
	Cell.CHECKPOINT: "C",
	Cell.CHECKPOINT_USED: "c",
	Cell.WISP: "w",
}


## Parse an ASCII rectangle into a Lattice. Rows are separated by newlines.
## All rows must be equal length; short rows are rejected (no silent padding).
static func from_ascii(text: String) -> Lattice:
	var raw_lines := text.split("\n", false)
	var lines: Array[String] = []
	for l in raw_lines:
		if l.strip_edges(false, true).length() > 0 or l.length() > 0:
			lines.append(l)
	while lines.size() > 0 and lines[lines.size() - 1].strip_edges().length() == 0:
		lines.pop_back()
	assert(lines.size() > 0, "from_ascii received empty input")
	var w := lines[0].length()
	for l in lines:
		assert(l.length() == w, "from_ascii: uneven row widths (%d vs %d): '%s'" % [l.length(), w, l])
	var h := lines.size()
	var lat := Lattice.new(w, h, Cell.FLOOR)
	for y in range(h):
		var row := lines[y]
		for x in range(w):
			var ch := row[x]
			assert(_ASCII_TO_CELL.has(ch), "from_ascii: unknown glyph '%s' at %d,%d" % [ch, x, y])
			var v: int = _ASCII_TO_CELL[ch]
			lat._cells[y * w + x] = v
			if v == Cell.START:
				lat.start = Vector2i(x, y)
			elif v == Cell.GOAL:
				lat.goal = Vector2i(x, y)
	return lat


func to_ascii() -> String:
	var lines: Array[String] = []
	for y in range(height):
		var row := ""
		for x in range(width):
			var v := _cells[y * width + x]
			row += _CELL_TO_ASCII.get(v, "?")
		lines.append(row)
	return "\n".join(lines)


func _to_string() -> String:
	return "Lattice(%dx%d, start=%s, goal=%s)\n%s" % [width, height, start, goal, to_ascii()]
