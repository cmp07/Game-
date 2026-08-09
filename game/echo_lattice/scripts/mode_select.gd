extends Control
##
## Mode select — Campaign / Daily / Endless Shift + stubs.
##

signal mode_chosen(mode_id: String)
signal back_pressed()

@onready var list: VBoxContainer = %ModeList
@onready var detail: Label = %Detail
@onready var back_button: Button = %BackButton
@onready var play_button: Button = %PlayButton
@onready var status_label: Label = %Status

var _selected: int = ModeService.Mode.CAMPAIGN
var _buttons: Dictionary = {}


func _ready() -> void:
	back_button.pressed.connect(func(): emit_signal("back_pressed"))
	play_button.pressed.connect(_on_play)
	_build_list()
	_select(ModeService.Mode.CAMPAIGN)


func _build_list() -> void:
	for child in list.get_children():
		child.queue_free()
	_buttons.clear()
	var order: Array = [
		ModeService.Mode.CAMPAIGN,
		ModeService.Mode.DAILY,
		ModeService.Mode.ENDLESS,
		ModeService.Mode.ZEN,
		ModeService.Mode.SPEEDRUN,
		ModeService.Mode.HOTSEAT,
	]
	for mode in order:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(360, 44)
		var title: String = ModeService.title_for(mode)
		if ModeService.is_stub(mode):
			btn.text = "%s  ·  SOON" % title
			btn.modulate = Color(1, 1, 1, 0.55)
		else:
			btn.text = title
		btn.add_theme_font_size_override("font_size", 20)
		var captured: int = mode
		btn.pressed.connect(func(): _select(captured))
		list.add_child(btn)
		_buttons[mode] = btn


func _select(mode: int) -> void:
	_selected = mode
	detail.text = ModeService.blurb_for(mode)
	for m in _buttons.keys():
		var b: Button = _buttons[m]
		if int(m) == mode:
			b.modulate = Color(1.0, 0.85, 0.7, 1.0) if ModeService.is_stub(mode) else Color(1.0, 0.55, 0.4, 1.0)
		else:
			b.modulate = Color(1, 1, 1, 0.55) if ModeService.is_stub(int(m)) else Color(1, 1, 1, 1)
	if mode == ModeService.Mode.DAILY:
		var stamp: String = ModeService.utc_datestamp()
		var seed: int = ModeService.daily_seed_for(stamp)
		var ch: int = ModeService.pick_daily_chamber(seed)
		var played: String = "played today" if ModeService.has_played_daily_today() else "fresh"
		status_label.text = "%s · chamber %d · %s" % [stamp, ch + 1, played]
		play_button.text = "Retry Daily" if ModeService.has_played_daily_today() else "Play Daily"
	elif mode == ModeService.Mode.ENDLESS:
		status_label.text = "Best streak: %d" % ModeService.endless_best
		play_button.text = "Start Shift"
	elif ModeService.is_stub(mode):
		status_label.text = "Stub — local shell only."
		play_button.text = "Open Stub"
	else:
		status_label.text = "%d chambers · induction in first 90s" % ChamberBook.chamber_count()
		play_button.text = "Play Campaign"
	play_button.grab_focus()


func _on_play() -> void:
	emit_signal("mode_chosen", ModeService.mode_id(_selected))
