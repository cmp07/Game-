class_name Maze
extends Node2D

const _MazeGeneratorScript = preload("res://scripts/maze_generator.gd")

signal goal_touched(body: Node)

const CELL_SIZE: float = 48.0

const WALL_COLOR: Color        = Color(0.16, 0.19, 0.32)
const WALL_EDGE_COLOR: Color   = Color(0.24, 0.28, 0.45)
const FLOOR_COLOR: Color       = Color(0.08, 0.09, 0.14)
const START_MARK_COLOR: Color  = Color(0.90, 0.78, 0.35)
const GOAL_MARK_COLOR: Color   = Color(0.35, 0.85, 0.55)

var _lines: PackedStringArray = PackedStringArray()
var _size_cells: Vector2i     = Vector2i.ZERO
var _start_cell: Vector2i     = Vector2i.ZERO
var _goal_cell: Vector2i      = Vector2i.ZERO
var _walls: Node2D            = null
var _markers: Node2D          = null
var _goal_area: Area2D        = null


func build(lines: PackedStringArray) -> void:
	_lines = lines
	_clear()
	if _lines.is_empty():
		push_warning("Maze.build called with empty layout")
		return

	_size_cells = Vector2i(_lines[0].length(), _lines.size())
	_add_floor()
	_walls = _add_container("Walls")
	_markers = _add_container("Markers")

	for y: int in _size_cells.y:
		var row: String = _lines[y]
		for x: int in row.length():
			var ch: String = row.substr(x, 1)
			var cell: Vector2i = Vector2i(x, y)
			match ch:
				_MazeGeneratorScript.WALL:
					_spawn_wall(cell)
				_MazeGeneratorScript.START:
					_start_cell = cell
					_spawn_marker(cell, START_MARK_COLOR, 0.32, "StartMark")
				_MazeGeneratorScript.GOAL:
					_goal_cell = cell
					_spawn_goal(cell)


func start_world() -> Vector2:
	return cell_to_world(_start_cell)


func goal_world() -> Vector2:
	return cell_to_world(_goal_cell)


func size_pixels() -> Vector2:
	return Vector2(_size_cells) * CELL_SIZE


func cell_to_world(cell: Vector2i) -> Vector2:
	return Vector2(cell) * CELL_SIZE + Vector2.ONE * CELL_SIZE * 0.5


func _clear() -> void:
	_goal_area = null
	for child: Node in get_children():
		child.queue_free()


func _add_container(node_name: String) -> Node2D:
	var n: Node2D = Node2D.new()
	n.name = node_name
	add_child(n)
	return n


func _add_floor() -> void:
	var floor_rect: ColorRect = ColorRect.new()
	floor_rect.name = "Floor"
	floor_rect.color = FLOOR_COLOR
	floor_rect.size = size_pixels()
	floor_rect.z_index = -10
	add_child(floor_rect)


func _spawn_wall(cell: Vector2i) -> void:
	var pos: Vector2 = cell_to_world(cell)
	var body: StaticBody2D = StaticBody2D.new()
	body.position = pos

	var col: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2.ONE * CELL_SIZE
	col.shape = rect
	body.add_child(col)

	var face: ColorRect = ColorRect.new()
	face.color = WALL_COLOR
	face.size = Vector2.ONE * CELL_SIZE
	face.position = -Vector2.ONE * CELL_SIZE * 0.5
	body.add_child(face)

	var edge: ColorRect = ColorRect.new()
	edge.color = WALL_EDGE_COLOR
	var thickness: float = 2.0
	edge.size = Vector2(CELL_SIZE, thickness)
	edge.position = Vector2(-CELL_SIZE * 0.5, -CELL_SIZE * 0.5)
	body.add_child(edge)

	_walls.add_child(body)


func _spawn_marker(cell: Vector2i, color: Color, size_ratio: float, node_name: String = "Mark") -> void:
	var pos: Vector2 = cell_to_world(cell)
	var side: float = CELL_SIZE * size_ratio
	var mark: ColorRect = ColorRect.new()
	mark.name = node_name
	mark.color = color
	mark.size = Vector2.ONE * side
	mark.position = pos - Vector2.ONE * side * 0.5
	_markers.add_child(mark)


func _spawn_goal(cell: Vector2i) -> void:
	var pos: Vector2 = cell_to_world(cell)
	_spawn_marker(cell, GOAL_MARK_COLOR, 0.55, "GoalMark")

	_goal_area = Area2D.new()
	_goal_area.position = pos
	_goal_area.monitoring = true

	var col: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2.ONE * CELL_SIZE * 0.7
	col.shape = rect
	_goal_area.add_child(col)

	_goal_area.body_entered.connect(_on_goal_body_entered)
	_markers.add_child(_goal_area)


func _on_goal_body_entered(body: Node) -> void:
	goal_touched.emit(body)
