extends Node2D

const _MazeGeneratorScript = preload("res://scripts/maze_generator.gd")
const _MazeScript = preload("res://scripts/maze.gd")
const _PlayerScript = preload("res://scripts/player.gd")

const MAZE_CELLS_WIDE: int  = 15
const MAZE_CELLS_TALL: int  = 10
const MAZE_SEED: int        = 20260808

const CAMERA_ZOOM: Vector2  = Vector2(1.4, 1.4)
const CAMERA_SMOOTH: float  = 8.0

const HELP_TEXT: String = "WASD / Arrows  •  R restart  •  Reach the green cell"
const WIN_TEXT: String  = "GOAL REACHED — press R to restart"

var _maze: _MazeScript
var _player: _PlayerScript
var _camera: Camera2D
var _help_label: Label
var _win_label: Label


func _enter_tree() -> void:
	_register_default_input_actions()


func _ready() -> void:
	_build_hud()
	_build_maze()
	_build_player()
	_build_camera()
	_reset()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		_reset()


func _reset() -> void:
	_player.snap_to(_maze.start_world())
	_win_label.visible = false


func _on_goal_touched(body: Node) -> void:
	if body == _player:
		_win_label.visible = true


func _build_maze() -> void:
	_maze = _MazeScript.new()
	_maze.name = "Maze"
	_maze.goal_touched.connect(_on_goal_touched)
	add_child(_maze)
	_maze.build(_MazeGeneratorScript.generate(MAZE_CELLS_WIDE, MAZE_CELLS_TALL, MAZE_SEED))


func _build_player() -> void:
	_player = _PlayerScript.new()
	_player.name = "Player"
	add_child(_player)


func _build_camera() -> void:
	_camera = Camera2D.new()
	_camera.name = "Camera"
	_camera.zoom = CAMERA_ZOOM
	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed = CAMERA_SMOOTH
	_camera.limit_left = 0
	_camera.limit_top = 0
	_camera.limit_right = int(_maze.size_pixels().x)
	_camera.limit_bottom = int(_maze.size_pixels().y)
	_player.add_child(_camera)


func _build_hud() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.name = "HUD"
	add_child(layer)

	_help_label = Label.new()
	_help_label.name = "Help"
	_help_label.text = HELP_TEXT
	_help_label.position = Vector2(16, 12)
	_help_label.add_theme_color_override("font_color", Color(0.82, 0.86, 0.98))
	_help_label.add_theme_font_size_override("font_size", 16)
	layer.add_child(_help_label)

	_win_label = Label.new()
	_win_label.name = "Win"
	_win_label.text = WIN_TEXT
	_win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_win_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_win_label.anchor_left = 0.0
	_win_label.anchor_right = 1.0
	_win_label.anchor_top = 0.42
	_win_label.anchor_bottom = 0.5
	_win_label.add_theme_color_override("font_color", Color(0.35, 0.85, 0.55))
	_win_label.add_theme_font_size_override("font_size", 28)
	_win_label.visible = false
	layer.add_child(_win_label)


func _register_default_input_actions() -> void:
	_ensure_action("move_left",  [KEY_A, KEY_LEFT])
	_ensure_action("move_right", [KEY_D, KEY_RIGHT])
	_ensure_action("move_up",    [KEY_W, KEY_UP])
	_ensure_action("move_down",  [KEY_S, KEY_DOWN])
	_ensure_action("restart",    [KEY_R])


func _ensure_action(action: StringName, keys: Array) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	for key: int in keys:
		var event: InputEventKey = InputEventKey.new()
		event.physical_keycode = key
		InputMap.action_add_event(action, event)
