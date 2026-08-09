extends Control
##
## Chamber-won screen — stars + habit beat between chambers.
## Identity bosses / Mirror Birth moments also print a ledger portrait stamp.
## Every clear archives a Museum self and plays a short chalk replay vignette.
##

signal next_pressed()
signal replay_pressed()
signal menu_pressed()

const STAMP_CARD_SCRIPT: Script = preload("res://scripts/identity_stamp_card.gd")
const VIGNETTE_SCRIPT: Script = preload("res://scripts/habit_replay_vignette.gd")

@onready var title_label: Label = %Title
@onready var subtitle_label: Label = %Subtitle
@onready var stats_label: Label = %Stats
@onready var next_button: Button = %NextButton
@onready var replay_button: Button = %ReplayButton
@onready var menu_button: Button = %MenuButton

var _stamp_card: Control = null
var _stamp_label: Label = null
var _museum_label: Label = null
var _vignette: Control = null


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
	_ensure_stamp_widgets()
	_ensure_museum_widgets()


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
	if DemoBuild.is_demo():
		next_text = tr("won.next_chamber") if not is_last else tr("won.finish_demo")
	elif GameState.run_mode == "daily":
		next_text = tr("won.next_daily") if not is_last else tr("won.daily_complete")
	elif GameState.run_mode == "endless":
		next_text = tr("won.next_endless")
		is_last = false
	elif GameState.run_mode == "ghost":
		next_text = tr("won.back_museum")
		is_last = true
	next_button.text = next_text
	var mode_line: String = ""
	if GameState.run_mode == "daily":
		if GameState.daily_friend_code != "":
			mode_line = tr("won.daily_line_code") % [GameState.daily_label, GameState.daily_friend_code]
		else:
			mode_line = tr("won.daily_line") % GameState.daily_label
	elif GameState.run_mode == "endless":
		var pct: int = int(round(GameState.rewrite_pressure() * 100.0))
		mode_line = tr("won.endless_line") % [GameState.endless_label, GameState.endless_depth, pct]
	elif GameState.run_mode == "ghost":
		var raced: Dictionary = GameState.raced_museum_self() if GameState.has_method("raced_museum_self") else {}
		mode_line = tr("won.ghost_line") % str(raced.get("title", tr("museum.title")))
	var stamp: Dictionary = GameState.last_identity_stamp
	var stamp_line: String = ""
	if not stamp.is_empty():
		stamp_line = "\n" + _stamp_summary(stamp)
	var museum_row: Dictionary = GameState.last_museum_self
	var museum_line: String = ""
	if not museum_row.is_empty():
		museum_line = "\n" + _museum_summary(museum_row)
	stats_label.text = (tr("won.stats") % [
		star_str, moves, best, best_stars, GameState.last_clear_bfs_par, mode_line, _habit_summary()
	]) + stamp_line + museum_line
	_show_stamp(stamp)
	_show_museum(museum_row)


func _ensure_stamp_widgets() -> void:
	if _stamp_card != null:
		return
	var vbox: Node = next_button.get_parent()
	if vbox == null:
		return
	_stamp_card = Control.new()
	_stamp_card.name = "StampCard"
	_stamp_card.set_script(STAMP_CARD_SCRIPT)
	_stamp_card.custom_minimum_size = Vector2(220, 140)
	_stamp_card.visible = false
	vbox.add_child(_stamp_card)
	vbox.move_child(_stamp_card, stats_label.get_index() + 1)
	_stamp_label = Label.new()
	_stamp_label.name = "StampCaption"
	_stamp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stamp_label.add_theme_font_size_override("font_size", 14)
	_stamp_label.add_theme_color_override("font_color", Palette.SLATE_TEAL)
	_stamp_label.visible = false
	vbox.add_child(_stamp_label)
	vbox.move_child(_stamp_label, _stamp_card.get_index() + 1)


func _show_stamp(stamp: Dictionary) -> void:
	_ensure_stamp_widgets()
	if _stamp_card == null:
		return
	if stamp.is_empty():
		_stamp_card.visible = false
		if _stamp_label:
			_stamp_label.visible = false
		return
	if _stamp_card.has_method("set_stamp"):
		_stamp_card.call("set_stamp", stamp)
	_stamp_card.visible = true
	if _stamp_label:
		_stamp_label.text = _stamp_summary(stamp)
		_stamp_label.visible = true


func _stamp_summary(stamp: Dictionary) -> String:
	var grade: String = str(stamp.get("grade", "scribble"))
	var grade_key := "won.stamp_grade_%s" % grade
	var grade_label: String = tr(grade_key)
	if grade_label == grade_key:
		grade_label = grade
	var pct: int = int(round(float(stamp.get("portrait", 0.0)) * 100.0))
	if bool(stamp.get("identity_boss", false)):
		return tr("won.stamp_boss") % [grade_label, pct]
	return tr("won.stamp_birth") % [grade_label, pct]


func _ensure_museum_widgets() -> void:
	if _museum_label != null:
		return
	var vbox: Node = next_button.get_parent()
	if vbox == null:
		return
	_museum_label = Label.new()
	_museum_label.name = "MuseumCaption"
	_museum_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_museum_label.add_theme_font_size_override("font_size", 14)
	_museum_label.add_theme_color_override("font_color", Palette.RUST_FOSSIL)
	_museum_label.visible = false
	vbox.add_child(_museum_label)
	var insert_at: int = stats_label.get_index() + 1
	if _stamp_label != null:
		insert_at = _stamp_label.get_index() + 1
	elif _stamp_card != null:
		insert_at = _stamp_card.get_index() + 1
	vbox.move_child(_museum_label, insert_at)
	_vignette = Control.new()
	_vignette.name = "HabitReplayVignette"
	_vignette.set_script(VIGNETTE_SCRIPT)
	_vignette.custom_minimum_size = Vector2(280, 120)
	_vignette.visible = false
	vbox.add_child(_vignette)
	vbox.move_child(_vignette, _museum_label.get_index() + 1)


func _show_museum(row: Dictionary) -> void:
	_ensure_museum_widgets()
	if _museum_label == null:
		return
	if row.is_empty():
		_museum_label.visible = false
		if _vignette:
			_vignette.visible = false
		return
	_museum_label.text = _museum_summary(row)
	_museum_label.visible = true
	if _vignette and _vignette.has_method("set_self_row"):
		_vignette.call("set_self_row", row)
		_vignette.visible = true


func _museum_summary(row: Dictionary) -> String:
	var habit: Dictionary = row.get("habit", {}) if typeof(row.get("habit", null)) == TYPE_DICTIONARY else {}
	var arch: String = str(habit.get("archetype", "balanced"))
	var bias_pct: int = int(round(float(habit.get("dominant_bias", 0.0)) * 100.0))
	var count: int = GameState.museum_count()
	return tr("won.museum_archive") % [str(row.get("title", "")), arch, bias_pct, count]


func _habit_summary() -> String:
	if not GameState.is_habit_identity_visible():
		return tr("hud.habit_sealed")
	var hp: Dictionary = GameState.habit_profile
	var total: int = int(hp.get("up", 0)) + int(hp.get("down", 0)) + int(hp.get("left", 0)) + int(hp.get("right", 0))
	if total <= 0:
		return tr("hud.habit_unwritten")
	var dom: String = GameState.dominant_habit()
	var dom_label: String = dom
	if has_node("/root/LocaleManager"):
		dom_label = LocaleManager.habit_label(dom)
	var hand: String = _habit_hand_label(GameState.habit_hand_id())
	return tr("hud.habit_identity") % [dom_label, hand]


func _habit_hand_label(hand_id: String) -> String:
	var key := "habit.hand_%s" % hand_id
	var t: String = tr(key)
	if t == key:
		return hand_id
	return t


func _stars_glyph(n: int) -> String:
	var out := ""
	for i in range(3):
		out += "*" if i < n else "-"
	return tr("won.stars_glyph") % [out, n]
