extends Control
## Boot composition: brand, one line, one CTA into the frayed-field stub.


func _ready() -> void:
	Loom.reset()


func _on_begin_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/field.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("weave"):
		_on_begin_pressed()
		get_viewport().set_input_as_handled()
