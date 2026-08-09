extends Node
## Remappable input for Echo Lattice actions.
## Autoload name: ActionRemap
## Stores bindings in SettingsStore.input_bindings and syncs Godot InputMap.
## Keyboard remaps preserve gamepad events so Steam Deck / Xbox pads keep working.

signal bindings_changed()
signal rebind_conflict(action: String, event: InputEvent)

const ACTIONS: PackedStringArray = [
	"move_up",
	"move_down",
	"move_left",
	"move_right",
	"undo",
	"restart",
	"pause_menu",
	"confirm",
	"ghost_assist",
]

const DISPLAY_NAMES := {
	"move_up": "Move Up",
	"move_down": "Move Down",
	"move_left": "Move Left",
	"move_right": "Move Right",
	"undo": "Undo",
	"restart": "Restart",
	"pause_menu": "Pause / Menu",
	"confirm": "Confirm",
	"ghost_assist": "Show Ghost Path (assist)",
}

## Default gamepad bindings kept when keyboard remaps (Xbox / Steam Deck).
## Must match joypad events in project.godot so reset / first remap keeps pad feel.
const GAMEPAD_DEFAULTS := {
	"move_up": [JOY_BUTTON_DPAD_UP],
	"move_down": [JOY_BUTTON_DPAD_DOWN],
	"move_left": [JOY_BUTTON_DPAD_LEFT],
	"move_right": [JOY_BUTTON_DPAD_RIGHT],
	"undo": [JOY_BUTTON_X],
	"restart": [JOY_BUTTON_Y],
	"pause_menu": [JOY_BUTTON_B, JOY_BUTTON_START],
	"confirm": [JOY_BUTTON_A],
	"ghost_assist": [JOY_BUTTON_LEFT_SHOULDER],
}

var _store: Node = null
var _listening_action: String = ""


func _ready() -> void:
	_store = get_node_or_null("/root/SettingsStore")
	ensure_actions_exist()
	apply_saved_bindings()
	if _store != null and _store.has_signal("settings_reloaded"):
		_store.settings_reloaded.connect(apply_saved_bindings)


func ensure_actions_exist() -> void:
	for action in ACTIONS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)


func apply_saved_bindings() -> void:
	ensure_actions_exist()
	var bindings := _bindings_dict()
	for action in ACTIONS:
		var preserved_joy: Array = _collect_joy_events(action)
		InputMap.action_erase_events(action)
		var keys: Array = bindings.get(action, [])
		for key_name in keys:
			var ev := _event_from_key_name(str(key_name))
			if ev != null:
				InputMap.action_add_event(action, ev)
		if preserved_joy.is_empty():
			preserved_joy = _default_joy_events(action)
		for joy_ev in preserved_joy:
			InputMap.action_add_event(action, joy_ev)
	# Stick axes for movement (Steam Deck / Xbox left stick).
	_ensure_stick_axes()
	bindings_changed.emit()


func get_bindings() -> Dictionary:
	return _bindings_dict()


func get_binding_labels(action: String) -> PackedStringArray:
	var labels: PackedStringArray = []
	for key_name in _bindings_dict().get(action, []):
		labels.append(str(key_name))
	return labels


func start_rebind(action: String) -> void:
	if action in ACTIONS:
		_listening_action = action


func cancel_rebind() -> void:
	_listening_action = ""


func is_listening() -> bool:
	return not _listening_action.is_empty()


func listening_action() -> String:
	return _listening_action


func _input(event: InputEvent) -> void:
	if _listening_action.is_empty():
		return
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var key_event := event as InputEventKey
		if key_event.keycode == KEY_ESCAPE or key_event.physical_keycode == KEY_ESCAPE:
			cancel_rebind()
			get_viewport().set_input_as_handled()
			return
		rebind(_listening_action, key_event, true)
		_listening_action = ""
		get_viewport().set_input_as_handled()


func rebind(action: String, event: InputEventKey, steal_conflicts: bool = true) -> bool:
	if action not in ACTIONS:
		return false
	var key_name := _key_name_from_event(event)
	if key_name.is_empty():
		return false
	var bindings := _bindings_dict()
	if steal_conflicts:
		for other in ACTIONS:
			if other == action:
				continue
			var other_keys: Array = bindings.get(other, []).duplicate()
			if key_name in other_keys:
				other_keys.erase(key_name)
				bindings[other] = other_keys
				rebind_conflict.emit(other, event)
	var keys: Array = bindings.get(action, []).duplicate()
	if keys.is_empty():
		keys = [key_name]
	else:
		keys[0] = key_name
	bindings[action] = keys
	_save_bindings(bindings)
	apply_saved_bindings()
	return true


func reset_to_defaults() -> void:
	if _store != null and _store.has_method("reset_section"):
		_store.call("reset_section", "input_bindings")
	apply_saved_bindings()


func action_display_name(action: String) -> String:
	return str(DISPLAY_NAMES.get(action, action))


func _bindings_dict() -> Dictionary:
	if _store != null and _store.has_method("get_section"):
		return (_store.call("get_section", "input_bindings") as Dictionary).duplicate(true)
	return {
		"move_up": ["W", "Up"],
		"move_down": ["S", "Down"],
		"move_left": ["A", "Left"],
		"move_right": ["D", "Right"],
		"undo": ["Z"],
		"restart": ["R"],
		"pause_menu": ["Escape"],
		"confirm": ["Enter", "Space"],
		"ghost_assist": ["G"],
	}


func _save_bindings(bindings: Dictionary) -> void:
	if _store == null:
		return
	for action in bindings.keys():
		_store.call("set_value", "input_bindings", str(action), bindings[action], false)
	if _store.has_method("save_settings"):
		_store.call("save_settings")


func _key_name_from_event(event: InputEventKey) -> String:
	var code := event.keycode
	if code == KEY_NONE:
		code = event.physical_keycode
	return OS.get_keycode_string(code)


func _event_from_key_name(key_name: String) -> InputEventKey:
	var code := OS.find_keycode_from_string(key_name)
	if code == KEY_NONE:
		return null
	var ev := InputEventKey.new()
	ev.keycode = code
	ev.physical_keycode = code
	return ev


func _collect_joy_events(action: String) -> Array:
	var out: Array = []
	if not InputMap.has_action(action):
		return out
	for ev in InputMap.action_get_events(action):
		if ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
			out.append(ev)
	return out


func _default_joy_events(action: String) -> Array:
	var out: Array = []
	var buttons: Array = GAMEPAD_DEFAULTS.get(action, [])
	for btn in buttons:
		var ev := InputEventJoypadButton.new()
		ev.button_index = int(btn)
		ev.pressed = true
		out.append(ev)
	return out


func _ensure_stick_axes() -> void:
	_add_axis_if_missing("move_left", JOY_AXIS_LEFT_X, -1.0)
	_add_axis_if_missing("move_right", JOY_AXIS_LEFT_X, 1.0)
	_add_axis_if_missing("move_up", JOY_AXIS_LEFT_Y, -1.0)
	_add_axis_if_missing("move_down", JOY_AXIS_LEFT_Y, 1.0)


func _add_axis_if_missing(action: String, axis: int, axis_value: float) -> void:
	if not InputMap.has_action(action):
		return
	for ev in InputMap.action_get_events(action):
		if ev is InputEventJoypadMotion:
			var m := ev as InputEventJoypadMotion
			if m.axis == axis and signf(m.axis_value) == signf(axis_value):
				return
	var motion := InputEventJoypadMotion.new()
	motion.axis = axis
	motion.axis_value = axis_value
	InputMap.action_add_event(action, motion)
