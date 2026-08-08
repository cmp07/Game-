extends Node
## Remappable input for Echo Lattice actions.
## Autoload name: ActionRemap
## Stores bindings in SettingsStore.input_bindings and syncs Godot InputMap.

signal bindings_changed()
signal rebind_conflict(action: String, event: InputEvent)

const ACTIONS: PackedStringArray = [
	"move_north",
	"move_east",
	"move_south",
	"move_west",
	"interact",
	"undo",
	"pause",
	"ghost_assist",
	"confirm",
	"cancel",
]

const DISPLAY_NAMES := {
	"move_north": "Move North",
	"move_east": "Move East",
	"move_south": "Move South",
	"move_west": "Move West",
	"interact": "Interact",
	"undo": "Undo",
	"pause": "Pause",
	"ghost_assist": "Show Ghost Path (assist)",
	"confirm": "Confirm",
	"cancel": "Cancel",
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
		InputMap.action_erase_events(action)
		var keys: Array = bindings.get(action, [])
		for key_name in keys:
			var ev := _event_from_key_name(str(key_name))
			if ev != null:
				InputMap.action_add_event(action, ev)
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
		if key_event.keycode == KEY_ESCAPE:
			cancel_rebind()
			get_viewport().set_input_as_handled()
			return
		rebind(_listening_action, key_event, true)
		_listening_action = ""
		get_viewport().set_input_as_handled()


## Rebind primary slot (index 0). Optionally clear conflicts on other actions.
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
	# Fallback defaults if SettingsStore missing.
	return {
		"move_north": ["W", "Up"],
		"move_east": ["D", "Right"],
		"move_south": ["S", "Down"],
		"move_west": ["A", "Left"],
		"interact": ["E", "Enter"],
		"undo": ["Z", "Backspace"],
		"pause": ["Escape"],
		"ghost_assist": ["G"],
		"confirm": ["Enter", "Space"],
		"cancel": ["Escape"],
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
