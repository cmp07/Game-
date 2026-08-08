extends Control

func _ready() -> void:
	%BackBtn.pressed.connect(SceneRouter.go_to_main_menu)
	%BackBtn.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SceneRouter.go_to_main_menu()
		get_viewport().set_input_as_handled()
