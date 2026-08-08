class_name MazeGenerator
extends RefCounted

const WALL: String  = "#"
const FLOOR: String = "."
const START: String = "S"
const GOAL: String  = "G"

const _WALL_CP: int  = 35   # '#'
const _FLOOR_CP: int = 46   # '.'
const _START_CP: int = 83   # 'S'
const _GOAL_CP: int  = 71   # 'G'

const _DIRECTIONS: Array[Vector2i] = [
	Vector2i( 1,  0),
	Vector2i(-1,  0),
	Vector2i( 0,  1),
	Vector2i( 0, -1),
]


static func generate(cells_wide: int, cells_tall: int, rng_seed: int = 0) -> PackedStringArray:
	assert(cells_wide >= 2 and cells_tall >= 2, "Maze must be at least 2x2 cells")

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	if rng_seed == 0:
		rng.randomize()
	else:
		rng.seed = rng_seed

	var cols: int = cells_wide * 2 + 1
	var rows: int = cells_tall * 2 + 1
	var grid: Array = _blank_grid(cols, rows)

	var visited: Dictionary = {}
	var stack: Array[Vector2i] = []
	var origin: Vector2i = Vector2i.ZERO
	stack.push_back(origin)
	visited[origin] = true
	_write(grid, _cell_to_tile(origin), _FLOOR_CP)

	while not stack.is_empty():
		var current: Vector2i = stack[stack.size() - 1]
		var frontier: Array[Vector2i] = _unvisited_neighbours(current, cells_wide, cells_tall, visited)
		if frontier.is_empty():
			stack.pop_back()
			continue
		var choice: Vector2i = frontier[rng.randi_range(0, frontier.size() - 1)]
		_write(grid, _cell_to_tile(current) + (choice - current), _FLOOR_CP)
		_write(grid, _cell_to_tile(choice), _FLOOR_CP)
		visited[choice] = true
		stack.push_back(choice)

	_write(grid, _cell_to_tile(Vector2i.ZERO), _START_CP)
	_write(grid, _cell_to_tile(Vector2i(cells_wide - 1, cells_tall - 1)), _GOAL_CP)

	return _to_lines(grid)


static func _blank_grid(cols: int, rows: int) -> Array:
	var out: Array = []
	for _y in rows:
		var row: Array[int] = []
		row.resize(cols)
		row.fill(_WALL_CP)
		out.append(row)
	return out


static func _cell_to_tile(cell: Vector2i) -> Vector2i:
	return Vector2i(cell.x * 2 + 1, cell.y * 2 + 1)


static func _unvisited_neighbours(cell: Vector2i, w: int, h: int, visited: Dictionary) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for d: Vector2i in _DIRECTIONS:
		var n: Vector2i = cell + d
		if n.x < 0 or n.x >= w or n.y < 0 or n.y >= h:
			continue
		if visited.has(n):
			continue
		out.append(n)
	return out


static func _write(grid: Array, tile: Vector2i, codepoint: int) -> void:
	var row: Array[int] = grid[tile.y]
	row[tile.x] = codepoint


static func _to_lines(grid: Array) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	for row: Array in grid:
		var buf: PackedByteArray = PackedByteArray()
		buf.resize(row.size())
		for i: int in row.size():
			buf[i] = row[i]
		out.append(buf.get_string_from_ascii())
	return out
