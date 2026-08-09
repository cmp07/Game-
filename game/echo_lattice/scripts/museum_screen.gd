extends Control
##
## Museum of Selves — thin habit archive browser.
## Browse fossils, replay chalk vignette, or optionally race a Self's handwriting
## as an in-chamber slate overlay. No race ladder, shop, or combat.
##

signal back_pressed()
signal race_self(self_id: String)

const VIGNETTE_SCRIPT: Script = preload("res://scripts/habit_replay_vignette.gd")
const STAMP_CARD_SCRIPT: Script = preload("res://scripts/identity_stamp_card.gd")

@onready var title_label: Label = %Title
@onready var blurb_label: Label = %Blurb
@onready var list_box: VBoxContainer = %SelfList
@onready var empty_label: Label = %EmptyLabel
@onready var back_button: Button = %BackButton
@onready var replay_button: Button = %ReplayButton
@onready var race_button: Button = %RaceButton
@onready var detail_label: Label = %DetailLabel
@onready var vignette_host: Control = %VignetteHost
@onready var stamp_host: Control = %StampHost

var _vignette: Control = null
var _stamp_card: Control = null
var _selected_id: String = ""


func _ready() -> void:
	title_label.text = tr("museum.title")
	blurb_label.text = tr("museum.blurb")
	back_button.text = tr("museum.back")
	replay_button.text = tr("museum.replay")
	race_button.text = tr("museum.race")
	empty_label.text = tr("museum.empty")
	back_button.pressed.connect(func(): emit_signal("back_pressed"))
	replay_button.pressed.connect(_on_replay)
	race_button.pressed.connect(_on_race)
	_ensure_widgets()
	refresh()
	back_button.grab_focus()
	set_process_unhandled_input(true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu") or event.is_action_pressed("ui_cancel"):
		emit_signal("back_pressed")
		get_viewport().set_input_as_handled()


func refresh() -> void:
	for c in list_box.get_children():
		c.queue_free()
	var selves: Array = GameState.list_museum_selves()
	empty_label.visible = selves.is_empty()
	replay_button.disabled = selves.is_empty()
	race_button.disabled = true
	if selves.is_empty():
		_selected_id = ""
		detail_label.text = ""
		if _vignette and _vignette.has_method("clear_vignette"):
			_vignette.call("clear_vignette")
		if _stamp_card and _stamp_card.has_method("set_stamp"):
			_stamp_card.call("set_stamp", {})
		return
	if _selected_id == "" or GameState.get_museum_self(_selected_id).is_empty():
		_selected_id = str(selves[0].get("id", ""))
	for row in selves:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		list_box.add_child(_make_row(row as Dictionary))
	_show_selected()


func _make_row(row: Dictionary) -> Button:
	var btn := Button.new()
	btn.flat = true
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.focus_mode = Control.FOCUS_ALL
	btn.custom_minimum_size = Vector2(0, 36)
	var habit: Dictionary = row.get("habit", {}) if typeof(row.get("habit", null)) == TYPE_DICTIONARY else {}
	var stars: int = int(row.get("stars", 0))
	var star_s: String = ""
	if has_node("/root/LedgerType"):
		star_s = LedgerType.stars_ink(stars)
	else:
		for i in range(3):
			star_s += "★" if i < stars else "☆"
	btn.text = "%s  ·  %s  ·  %s" % [
		str(row.get("title", "Self")),
		star_s,
		str(habit.get("archetype", "balanced")),
	]
	btn.add_theme_color_override("font_color", Palette.INK_BLACK)
	btn.add_theme_color_override("font_hover_color", Palette.SLATE_TEAL)
	btn.add_theme_color_override("font_focus_color", Palette.RUST_FOSSIL)
	var sid := str(row.get("id", ""))
	if sid == _selected_id:
		btn.add_theme_color_override("font_color", Palette.RUST_FOSSIL)
	btn.pressed.connect(func():
		_selected_id = sid
		refresh()
	)
	return btn


func _show_selected() -> void:
	var row: Dictionary = GameState.get_museum_self(_selected_id)
	if row.is_empty():
		race_button.disabled = true
		return
	var habit: Dictionary = row.get("habit", {}) if typeof(row.get("habit", null)) == TYPE_DICTIONARY else {}
	var bias_pct: int = int(round(float(habit.get("dominant_bias", 0.0)) * 100.0))
	detail_label.text = tr("museum.detail") % [
		str(row.get("title", "")),
		str(habit.get("archetype", "balanced")),
		bias_pct,
		int(row.get("moves", 0)),
		str(row.get("mode", "standard")),
	]
	if _vignette and _vignette.has_method("set_self_row"):
		_vignette.call("set_self_row", row)
	var stamp: Dictionary = row.get("stamp", {}) if typeof(row.get("stamp", null)) == TYPE_DICTIONARY else {}
	if _stamp_card and _stamp_card.has_method("set_stamp"):
		_stamp_card.call("set_stamp", stamp)
		_stamp_card.visible = not stamp.is_empty() and typeof(stamp.get("mask", null)) == TYPE_DICTIONARY
	race_button.disabled = not _can_race_selected(row)


func _can_race_selected(row: Dictionary) -> bool:
	if not MuseumOfSelves.can_race(row):
		return false
	var content_id: String = str(row.get("chamber_id", ""))
	return ChamberBook.index_for_content_id(content_id) >= 0


func _on_replay() -> void:
	if _vignette and _vignette.has_method("replay"):
		_vignette.call("replay")
	if has_node("/root/AudioDirector"):
		AudioDirector.on_ui_confirm()


func _on_race() -> void:
	if _selected_id == "" or race_button.disabled:
		return
	if has_node("/root/AudioDirector"):
		AudioDirector.on_ui_confirm()
	emit_signal("race_self", _selected_id)


func _ensure_widgets() -> void:
	if _vignette == null:
		_vignette = Control.new()
		_vignette.name = "ReplayVignette"
		_vignette.set_script(VIGNETTE_SCRIPT)
		_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		vignette_host.add_child(_vignette)
	if _stamp_card == null:
		_stamp_card = Control.new()
		_stamp_card.name = "MuseumStamp"
		_stamp_card.set_script(STAMP_CARD_SCRIPT)
		_stamp_card.custom_minimum_size = Vector2(160, 100)
		stamp_host.add_child(_stamp_card)
