extends HBoxContainer
## KeybindRow — one action row in the settings screen. Users can rebind either
## the primary keyboard/mouse binding or the primary gamepad binding.

signal rebind_requested(action: String, family: String, row: Node)

@onready var _label: Label = %Label
@onready var _kbm_btn: Button = %KbmBtn
@onready var _pad_btn: Button = %PadBtn
@onready var _clear_kbm: Button = %ClearKbm
@onready var _clear_pad: Button = %ClearPad

var _action: String = ""
var _listening: String = "" # "kbm" | "pad" | ""


func setup(action: String) -> void:
	_action = action
	if is_inside_tree():
		_render()
	else:
		call_deferred("_render")


func _ready() -> void:
	_kbm_btn.pressed.connect(func(): _start_listening("kbm"))
	_pad_btn.pressed.connect(func(): _start_listening("pad"))
	_clear_kbm.pressed.connect(func():
		Settings.clear_action_binding(_action, "kbm")
		_render()
	)
	_clear_pad.pressed.connect(func():
		Settings.clear_action_binding(_action, "pad")
		_render()
	)
	Settings.keybinds_changed.connect(_render)
	if _action != "":
		_render()


func _render() -> void:
	_label.text = _pretty_action(_action)
	var kbm := Settings.first_event_for(_action, "kbm")
	var pad := Settings.first_event_for(_action, "pad")
	_kbm_btn.text = Settings.humanize_event(kbm) if kbm else "[unbound]"
	_pad_btn.text = Settings.humanize_event(pad) if pad else "[unbound]"


func _start_listening(family: String) -> void:
	_listening = family
	var btn := _kbm_btn if family == "kbm" else _pad_btn
	btn.text = "Press any %s…" % ("key" if family == "kbm" else "button")
	set_process_unhandled_input(true)


func _unhandled_input(event: InputEvent) -> void:
	if _listening == "":
		return
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		# Ignore mouse motion; allow mouse buttons for kbm family.
		if not (event is InputEventMouseButton and _listening == "kbm"):
			return
	if _listening == "kbm":
		if event is InputEventKey and event.pressed and not event.echo:
			Settings.rebind_action(_action, event)
			_stop_listening()
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.pressed:
			Settings.rebind_action(_action, event)
			_stop_listening()
			get_viewport().set_input_as_handled()
	elif _listening == "pad":
		if event is InputEventJoypadButton and event.pressed:
			Settings.rebind_action(_action, event)
			_stop_listening()
			get_viewport().set_input_as_handled()
		elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.7:
			Settings.rebind_action(_action, event)
			_stop_listening()
			get_viewport().set_input_as_handled()


func _stop_listening() -> void:
	_listening = ""
	set_process_unhandled_input(false)
	_render()


static func _pretty_action(a: String) -> String:
	match a:
		"ui_accept": return "Confirm"
		"ui_cancel": return "Back / Cancel"
		"ui_up": return "Move Up"
		"ui_down": return "Move Down"
		"ui_left": return "Move Left"
		"ui_right": return "Move Right"
		"ui_pause": return "Pause"
		"game_rewrite": return "Trigger Rewrite"
		"game_hold": return "Hold Lattice"
		"game_reset": return "Reset Loop"
	return a.capitalize()
