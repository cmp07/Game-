extends Control
## Boot composition: brand, one line, one CTA into the frayed-field stub.
## Headless: `-- --selftest [--screenshot]` skips the title into the field.
## Cloud capture: `-- --gameplay-demo` (alias `--demo`) skips title into paced loop.


func _ready() -> void:
	if Loom.pending_selftest or Loom.pending_gameplay_demo:
		call_deferred("_enter_field")
		return
	Loom.reset()


func _enter_field() -> void:
	get_tree().change_scene_to_file("res://scenes/field.tscn")


func _on_begin_pressed() -> void:
	_enter_field()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("weave"):
		_on_begin_pressed()
		get_viewport().set_input_as_handled()
