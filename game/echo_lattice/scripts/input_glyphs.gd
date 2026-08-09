extends Node
##
## InputGlyphs — Xbox / Steam Deck face-button labels for on-screen hints.
## Tracks the last used device so menus show gamepad glyphs after a stick/button press.
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
	return "D-Pad / Stick" if prefer_gamepad_on_deck() else "WASD / Arrows"


func undo_label() -> String:
	return "X" if prefer_gamepad_on_deck() else "Z"


func restart_label() -> String:
	return "Y" if prefer_gamepad_on_deck() else "R"


func menu_label() -> String:
	## project.godot binds pause_menu to B and Start.
	return "Start / B" if prefer_gamepad_on_deck() else "Esc"


func confirm_label() -> String:
	return "A" if prefer_gamepad_on_deck() else "Enter / Space"


func back_label() -> String:
	return "B" if prefer_gamepad_on_deck() else "Esc"


func ghost_assist_label() -> String:
	return "LB" if prefer_gamepad_on_deck() else "G"


func controls_line() -> String:
	if prefer_gamepad_on_deck():
		return "Move  D-Pad/Stick     Undo  X     Restart  Y     Menu  Start/B     Confirm  A"
	return "Move  WASD / Arrows     Undo  Z     Restart  R     Menu  Esc     Confirm  Enter"


func restart_button_text() -> String:
	return "Restart (%s)" % restart_label()


func menu_button_text() -> String:
	return "Menu (%s)" % menu_label()
