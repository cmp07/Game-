extends Control
##
## Chamber scene root — hosts the Chamber (Node2D) plus the HUD/legend on top.
## The scene forwards chamber_won upward, offers restart & menu buttons, and
## captures the pause_menu action.
##

signal chamber_won(chamber_id: int, moves: int)
signal menu_requested()

@onready var chamber_node: Node2D = %Chamber
@onready var title_label: Label = %ChamberTitle
@onready var caption_label: Label = %Caption
@onready var moves_label: Label = %MovesLabel
@onready var habit_label: Label = %HabitLabel
@onready var restart_button: Button = %RestartButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	restart_button.pressed.connect(func(): chamber_node.reset_chamber())
	menu_button.pressed.connect(func(): emit_signal("menu_requested"))
	chamber_node.chamber_won.connect(_on_chamber_won)
	chamber_node.moves_changed.connect(_on_moves_changed)
	chamber_node.caption_changed.connect(_on_caption_changed)
	_refresh_title()
	_on_moves_changed(0)


func _refresh_title() -> void:
	var idx: int = GameState.current_chamber
	var data: Dictionary = ChamberBook.get_chamber(idx)
	title_label.text = "Chamber %d / %d — %s" % [
		idx + 1,
		ChamberBook.chamber_count(),
		str(data.get("title", "")),
	]


func _on_chamber_won(chamber_id: int, moves: int) -> void:
	emit_signal("chamber_won", chamber_id, moves)


func _on_moves_changed(moves: int) -> void:
	moves_label.text = "Moves: %d" % moves
	habit_label.text = "Habit: %s" % _habit_summary()


func _on_caption_changed(text: String) -> void:
	caption_label.text = text


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		emit_signal("menu_requested")


func _habit_summary() -> String:
	var hp: Dictionary = GameState.habit_profile
	var total: int = int(hp.get("up", 0)) + int(hp.get("down", 0)) + int(hp.get("left", 0)) + int(hp.get("right", 0))
	if total <= 0:
		return "unwritten"
	var dom: String = GameState.dominant_habit()
	var dv: int = int(hp.get(dom, 0))
	var pct: int = int(round(float(dv) / float(total) * 100.0))
	return "%s-leaning (%d%%)" % [dom, pct]
