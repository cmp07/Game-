extends Control
##
## Chamber scene root — Chamber + HUD.
##

signal chamber_won(chamber_id: int, moves: int)
signal menu_requested()

const SETTINGS_SCENE: PackedScene = preload("res://scenes/ui/settings_menu.tscn")

@onready var chamber_node: Node2D = %Chamber
@onready var title_label: Label = %ChamberTitle
@onready var caption_label: Label = %Caption
@onready var moves_label: Label = %MovesLabel
@onready var habit_label: Label = %HabitLabel
@onready var restart_button: Button = %RestartButton
@onready var settings_button: Button = %SettingsButton
@onready var menu_button: Button = %MenuButton

var _settings_overlay: Control = null


func _ready() -> void:
	restart_button.pressed.connect(func(): chamber_node.reset_chamber())
	settings_button.pressed.connect(_open_settings)
	menu_button.pressed.connect(func(): emit_signal("menu_requested"))
	chamber_node.chamber_won.connect(_on_chamber_won)
	chamber_node.moves_changed.connect(_on_moves_changed)
	chamber_node.caption_changed.connect(_on_caption_changed)
	_style_ledger_chrome()
	_refresh_title()
	_on_moves_changed(0)
	var data: Dictionary = ChamberBook.get_chamber(GameState.current_chamber)
	_on_caption_changed(str(data.get("caption", "")))


func _open_settings() -> void:
	if _settings_overlay == null:
		_settings_overlay = SETTINGS_SCENE.instantiate()
		add_child(_settings_overlay)
	_settings_overlay.open_menu()


func _style_ledger_chrome() -> void:
	## Top/bottom bars read as printed page margins, not glass HUD.
	var paper := StyleBoxFlat.new()
	paper.bg_color = Palette.PAPER_BONE
	paper.border_color = Palette.INK_SOFT
	paper.set_border_width_all(0)
	paper.border_width_bottom = 1
	var top: PanelContainer = get_node_or_null("TopBar")
	if top:
		top.add_theme_stylebox_override("panel", paper)
	var paper2 := StyleBoxFlat.new()
	paper2.bg_color = Palette.PAPER_BONE
	paper2.border_color = Palette.INK_SOFT
	paper2.border_width_top = 1
	var bottom: PanelContainer = get_node_or_null("BottomBar")
	if bottom:
		bottom.add_theme_stylebox_override("panel", paper2)


func _refresh_title() -> void:
	var idx: int = GameState.current_chamber
	var data: Dictionary = ChamberBook.get_chamber(idx)
	var mode_tag: String = ""
	if GameState.run_mode == "daily":
		mode_tag = " · Daily %s" % GameState.daily_label
	title_label.text = "%d / %d — %s%s" % [
		GameState.run_progress_index() + 1,
		GameState.chambers_in_run(),
		str(data.get("title", "")),
		mode_tag,
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
