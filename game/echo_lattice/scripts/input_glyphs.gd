extends Node
##
## InputGlyphs — Xbox / Steam Deck face-button labels for on-screen hints.
## Tracks the last used device so menus show gamepad glyphs after a stick/button press.
## Keyboard labels follow ActionRemap; chrome strings go through tr().
##

enum Device { KEYBOARD, GAMEPAD }

var last_device: int = Device.KEYBOARD


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)
	if not Input.joy_connection_changed.is_connected(_on_joy_connection_changed):
		Input.joy_connection_changed.connect(_on_joy_connection_changed)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		last_device = Device.KEYBOARD
	elif event is InputEventJoypadButton and event.pressed:
		last_device = Device.GAMEPAD
	elif event is InputEventJoypadMotion:
		if absf(event.axis_value) >= 0.55:
			last_device = Device.GAMEPAD


func _on_joy_connection_changed(_device: int, connected: bool) -> void:
	# Unplug mid-run: fall back to keyboard glyphs unless another pad remains.
	if connected:
		last_device = Device.GAMEPAD
		return
	if Input.get_connected_joypads().is_empty():
		last_device = Device.KEYBOARD


func using_gamepad() -> bool:
	return last_device == Device.GAMEPAD


func prefer_gamepad_on_deck() -> bool:
	## Boot hint preference when DeckProfile says we are on a Deck.
	if has_node("/root/DeckProfile") and DeckProfile.is_steam_deck():
		return true
	return using_gamepad()


func move_label() -> String:
	if prefer_gamepad_on_deck():
		return tr("glyphs.move_pad")
	var up := _binding_label("move_up", "W")
	var left := _binding_label("move_left", "A")
	var down := _binding_label("move_down", "S")
	var right := _binding_label("move_right", "D")
	# Compact WASD-style when defaults; otherwise list primaries.
	if up == "W" and left == "A" and down == "S" and right == "D":
		return tr("glyphs.move_wasd")
	return "%s/%s/%s/%s" % [up, left, down, right]


func undo_label() -> String:
	return "X" if prefer_gamepad_on_deck() else _binding_label("undo", "Z")


func restart_label() -> String:
	return "Y" if prefer_gamepad_on_deck() else _binding_label("restart", "R")


func menu_label() -> String:
	return "Start" if prefer_gamepad_on_deck() else _binding_label("pause_menu", "Esc")


func confirm_label() -> String:
	return "A" if prefer_gamepad_on_deck() else _binding_label("confirm", "Enter")


func back_label() -> String:
	return "B" if prefer_gamepad_on_deck() else _binding_label("pause_menu", "Esc")


func assist_label() -> String:
	return "B" if prefer_gamepad_on_deck() else _binding_label("ghost_assist", "G")


func controls_line() -> String:
	if prefer_gamepad_on_deck():
		return tr("glyphs.controls_gamepad")
	return tr("glyphs.controls_keyboard") % [
		move_label(),
		undo_label(),
		restart_label(),
		menu_label(),
		confirm_label(),
		assist_label(),
	]


func restart_button_text() -> String:
	return tr("hud.restart_fmt") % restart_label()


func menu_button_text() -> String:
	return tr("hud.menu_fmt") % menu_label()


func _binding_label(action: String, fallback: String) -> String:
	var remap := get_node_or_null("/root/ActionRemap")
	if remap != null and remap.has_method("get_binding_labels"):
		var labels: PackedStringArray = remap.get_binding_labels(action)
		if labels.size() > 0:
			var primary := str(labels[0])
			if primary == "Escape":
				return "Esc"
			return primary
	return fallback
