extends Control
##
## Chamber-won screen — stars + habit beat between chambers.
##

signal next_pressed()
signal replay_pressed()
signal menu_pressed()

@onready var title_label: Label = %Title
@onready var subtitle_label: Label = %Subtitle
@onready var stats_label: Label = %Stats
@onready var next_button: Button = %NextButton
@onready var replay_button: Button = %ReplayButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	replay_button.text = tr("won.replay")
	menu_button.text = tr("won.menu")
	next_button.pressed.connect(func(): emit_signal("next_pressed"))
	replay_button.pressed.connect(func(): emit_signal("replay_pressed"))
	menu_button.pressed.connect(func(): emit_signal("menu_pressed"))
	next_button.focus_mode = Control.FOCUS_ALL
	replay_button.focus_mode = Control.FOCUS_ALL
	menu_button.focus_mode = Control.FOCUS_ALL
	next_button.grab_focus()
	set_process_unhandled_input(true)


func _unhandled_input(event: InputEvent) -> void:
	## B / Start returns to menu without needing the on-screen keyboard.
	if event.is_action_pressed("pause_menu"):
		emit_signal("menu_pressed")
		get_viewport().set_input_as_handled()


func configure(chamber_id: int, moves: int) -> void:
	var data: Dictionary = ChamberBook.get_chamber(chamber_id)
	title_label.text = tr("won.title")
	var cid: String = str(data.get("content_id", data.get("id", "")))
	var title_fallback: String = str(data.get("title", ""))
	if has_node("/root/LocaleManager") and cid != "":
		subtitle_label.text = LocaleManager.translate_chamber_title(cid, title_fallback)
	else:
		subtitle_label.text = title_fallback
	var best: int = int(GameState.best_moves.get(chamber_id, moves))
	var stars: int = GameState.last_clear_stars
	var best_stars: int = int(GameState.best_stars.get(chamber_id, stars))
	var star_str: String = _stars_glyph(stars)
	var is_last: bool = GameState.run_progress_index() + 1 >= GameState.chambers_in_run()
	var next_text: String = tr("won.next_chamber") if not is_last else tr("won.finish_wing")
	if GameState.run_mode == "daily":
		next_text = tr("won.next_daily") if not is_last else tr("won.daily_complete")
	next_button.text = next_text
	var mode_line: String = ""
	if GameState.run_mode == "daily":
		mode_line = tr("won.daily_line") % GameState.daily_label
	stats_label.text = tr("won.stats") % [
		star_str, moves, best, best_stars, GameState.last_clear_bfs_par, mode_line, _habit_summary()
	]


func _habit_summary() -> String:
	var hp: Dictionary = GameState.habit_profile
	var total: int = int(hp.get("up", 0)) + int(hp.get("down", 0)) + int(hp.get("left", 0)) + int(hp.get("right", 0))
	if total <= 0:
		return tr("hud.habit_unwritten")
	var dom: String = GameState.dominant_habit()
	var dom_label: String = dom
	if has_node("/root/LocaleManager"):
		dom_label = LocaleManager.habit_label(dom)
	return tr("hud.habit_leaning") % dom_label


func _stars_glyph(n: int) -> String:
	var out := ""
	for i in range(3):
		out += "*" if i < n else "-"
	return tr("won.stars_glyph") % [out, n]
