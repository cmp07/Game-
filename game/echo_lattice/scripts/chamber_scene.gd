extends Control
##
## Chamber scene root — hosts Chamber + HUD + diegetic PA strip.
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
@onready var pa_label: Label = %PALabel
@onready var undo_hint: Label = %UndoHint
@onready var mode_label: Label = %ModeLabel


func _ready() -> void:
	restart_button.pressed.connect(func(): chamber_node.reset_chamber())
	menu_button.pressed.connect(func(): emit_signal("menu_requested"))
	chamber_node.chamber_won.connect(_on_chamber_won)
	chamber_node.moves_changed.connect(_on_moves_changed)
	chamber_node.caption_changed.connect(_on_caption_changed)
	chamber_node.self_trap_detected.connect(_on_self_trap)
	chamber_node.undo_performed.connect(_on_undo)
	DiegeticPA.line_played.connect(_on_pa_line)
	_refresh_title()
	_on_moves_changed(0)
	var data: Dictionary = ChamberBook.get_chamber(GameState.current_chamber)
	_on_caption_changed(str(data.get("caption", "")))
	_refresh_mode_label()
	undo_hint.visible = false
	pa_label.text = DiegeticPA.current_text()


func _refresh_title() -> void:
	var idx: int = GameState.current_chamber
	var data: Dictionary = ChamberBook.get_chamber(idx)
	title_label.text = "%s — %s" % [
		_mode_prefix(),
		str(data.get("title", "")),
	]


func _mode_prefix() -> String:
	match ModeService.active_mode:
		ModeService.Mode.DAILY:
			return "Daily"
		ModeService.Mode.ENDLESS:
			return "Shift %d" % (ModeService.endless_clears + 1)
		ModeService.Mode.CAMPAIGN:
			return "Chamber %d/%d" % [GameState.current_chamber + 1, ChamberBook.chamber_count()]
		_:
			return "Chamber %d/%d" % [GameState.current_chamber + 1, ChamberBook.chamber_count()]


func _refresh_mode_label() -> void:
	match ModeService.active_mode:
		ModeService.Mode.DAILY:
			mode_label.text = "SEED %s" % ModeService.daily_datestamp
		ModeService.Mode.ENDLESS:
			mode_label.text = "STREAK %d  BEST %d" % [ModeService.endless_clears, ModeService.endless_best]
		_:
			mode_label.text = ModeService.title_for(ModeService.active_mode).to_upper()


func _on_chamber_won(chamber_id: int, moves: int) -> void:
	emit_signal("chamber_won", chamber_id, moves)


func _on_moves_changed(moves: int) -> void:
	moves_label.text = "Moves: %d" % moves
	habit_label.text = "Habit: %s" % _habit_summary()


func _on_caption_changed(text: String) -> void:
	# Keep captions short — never a wall. PA strip handles event lines.
	caption_label.text = text


func _on_self_trap() -> void:
	undo_hint.visible = true
	undo_hint.text = "Z · UNDO"


func _on_undo() -> void:
	undo_hint.visible = false


func _on_pa_line(_id: String, text: String, channel: String) -> void:
	if text == "":
		pa_label.text = ""
		return
	if channel == "plate":
		pa_label.text = "⟦ %s ⟧" % text
	else:
		pa_label.text = text


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
