extends Control
##
## Chamber-won Clear Stamp — stars + habit answer + museum archive as a ledger leaf.
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
var _folio_label: Label = null


func _ready() -> void:
	_hide_flat_chrome()
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
	_ensure_folio_mark()
	_ensure_stamp_widgets()
	_ensure_museum_widgets()
	_apply_ledger_type()
	queue_redraw()


func _hide_flat_chrome() -> void:
	var bg := get_node_or_null("Background")
	if bg:
		bg.visible = false
	var accent := get_node_or_null("AccentBar")
	if accent:
		accent.visible = false


func _unhandled_input(event: InputEvent) -> void:
	## B / Start returns to menu without needing the on-screen keyboard.
	if event.is_action_pressed("pause_menu"):
		emit_signal("menu_pressed")
		get_viewport().set_input_as_handled()


func _draw() -> void:
	var vp: Vector2 = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size
	# Lightbox wash behind the clear-stamp plate.
	draw_rect(Rect2(Vector2.ZERO, vp), Palette.PAPER_MARGIN, true)
	if has_node("/root/ArtKit"):
		ArtKit.draw_paper_grain(self, Rect2(Vector2.ZERO, vp), 5, 0.05)
	var plate := Rect2(vp.x * 0.14, vp.y * 0.08, vp.x * 0.72, vp.y * 0.84)
	draw_rect(Rect2(plate.position + Vector2(5, 7), plate.size), Palette.PAPER_SHADOW, true)
	draw_rect(plate, Palette.PAPER_BONE, true)
	if has_node("/root/ArtKit"):
		ArtKit.draw_ledger_grid(self, plate, 28)
		ArtKit.draw_paper_grain(self, plate, 13, 0.06)
	draw_rect(plate, Palette.INK_SOFT, false, 1.5)
	draw_rect(plate.grow(-3.0), Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.4), false, 1.0)
	# Folio header rule.
	draw_line(
		plate.position + Vector2(28, 36),
		plate.position + Vector2(plate.size.x - 28, 36),
		Palette.INK_SOFT,
		1.0
	)
	# Rust accent stamp bar at plate foot.
	draw_rect(
		Rect2(plate.position.x, plate.end.y - 5.0, plate.size.x, 5.0),
		Palette.RUST_FOSSIL,
		true
	)


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
	var best_star_str: String = _stars_glyph(best_stars)
	var is_last: bool = GameState.run_progress_index() + 1 >= GameState.chambers_in_run()
	var next_text: String = tr("won.next_chamber") if not is_last else tr("won.finish_wing")
	if DemoBuild.is_demo():
		next_text = tr("won.next_chamber") if not is_last else tr("won.finish_demo")
	elif GameState.run_mode == "daily":
		next_text = tr("won.next_daily") if not is_last else tr("won.daily_complete")
	elif GameState.run_mode == "endless":
		next_text = tr("won.next_endless")
		is_last = false
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
	var stamp: Dictionary = GameState.last_identity_stamp
	var stamp_line: String = ""
	if not stamp.is_empty():
		stamp_line = "\n" + _stamp_summary(stamp)
	var museum_row: Dictionary = GameState.last_museum_self
	var museum_line: String = ""
	if not museum_row.is_empty():
		museum_line = "\n" + _museum_summary(museum_row)
	var habit_line: String = _habit_answer_line(data)
	stats_label.text = (tr("won.stats") % [
		star_str, moves, best, best_star_str, GameState.last_clear_bfs_par, mode_line, habit_line
	]) + stamp_line + museum_line
	_show_stamp(stamp)
	_show_museum(museum_row)
	queue_redraw()


func _ensure_folio_mark() -> void:
	if _folio_label != null:
		return
	_folio_label = Label.new()
	_folio_label.name = "FolioMark"
	_folio_label.text = tr("won.folio_mark")
	_folio_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_folio_label.add_theme_font_size_override("font_size", 12)
	_folio_label.add_theme_color_override("font_color", Palette.SLATE_TEAL)
	var vbox: Node = next_button.get_parent()
	if vbox == null:
		return
	vbox.add_child(_folio_label)
	vbox.move_child(_folio_label, 0)
	if has_node("/root/LedgerType"):
		LedgerType.apply_to_control(_folio_label, "mono", 12)


func _apply_ledger_type() -> void:
	if not has_node("/root/LedgerType"):
		return
	LedgerType.apply_to_control(title_label, "display", 44)
	LedgerType.apply_to_control(subtitle_label, "body", 20)
	LedgerType.apply_to_control(stats_label, "body", 15)
	LedgerType.apply_to_control(next_button, "display", 20)
	LedgerType.apply_to_control(replay_button, "body", 16)
	LedgerType.apply_to_control(menu_button, "body", 16)
	# Underlined type CTAs — no filled Godot chrome.
	for b in [next_button, replay_button, menu_button]:
		b.flat = true
		b.add_theme_color_override("font_color", Palette.INK_BLACK)
		b.add_theme_color_override("font_hover_color", Palette.SLATE_TEAL)
		b.add_theme_color_override("font_focus_color", Palette.RUST_FOSSIL)


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
	if has_node("/root/LedgerType"):
		LedgerType.apply_to_control(_stamp_label, "mono", 13)


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
	if has_node("/root/LedgerType"):
		LedgerType.apply_to_control(_museum_label, "body", 14)


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


func _habit_answer_line(data: Dictionary) -> String:
	## Remix / Daily / Endless: prefer plain-speech habit answer over HUD jargon.
	if not GameState.is_habit_identity_visible():
		return tr("hud.habit_sealed")
	var answer: Dictionary = GameState.last_habit_answer
	var role: String = str(data.get("role", ""))
	var wants_answer: bool = role in ["remix", "hard", "daily_showcase"] or GameState.run_mode in ["daily", "endless"]
	if wants_answer and not answer.is_empty():
		var arch: String = str(answer.get("archetype", "balanced"))
		var read_key := "habit.read.%s" % arch
		var read_line: String = tr(read_key)
		if read_line == read_key:
			read_line = arch
		var op: String = str(answer.get("op", ""))
		var counter_line: String = ""
		if op != "":
			var op_key := "habit.op.%s" % op
			var op_label: String = tr(op_key)
			if op_label == op_key:
				op_label = op.replace("_", " ")
			counter_line = tr("habit.answer.counter") % op_label
		else:
			counter_line = tr("won.habit_quiet")
		return tr("won.habit_answer") % [read_line, counter_line]
	return _habit_summary()


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
	var ink: String = ""
	if has_node("/root/LedgerType"):
		ink = LedgerType.stars_ink(n)
	else:
		var filled: int = clampi(n, 0, 3)
		for i in range(3):
			ink += "★" if i < filled else "☆"
	return tr("won.stars_glyph") % ink
