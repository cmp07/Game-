extends Node
## Boot scene — briefly displays the studio ident then hands off to the main
## menu. Kept intentionally tiny so `run/main_scene` cost stays low.

@onready var _fader: ColorRect = $Fader
@onready var _title: Label = $Center/Title
@onready var _tagline: Label = $Center/Tagline


func _ready() -> void:
	_fader.color.a = 1.0
	_title.modulate.a = 0.0
	_tagline.modulate.a = 0.0
	var tw := create_tween().set_parallel(false)
	tw.tween_property(_fader, "color:a", 0.0, 0.35)
	tw.tween_property(_title, "modulate:a", 1.0, 0.5)
	tw.tween_property(_tagline, "modulate:a", 1.0, 0.45)
	tw.tween_interval(1.1)
	tw.tween_property(_title, "modulate:a", 0.0, 0.35)
	tw.tween_property(_tagline, "modulate:a", 0.0, 0.3)
	tw.finished.connect(_goto_main_menu)


func _goto_main_menu() -> void:
	SceneRouter.go_to_main_menu()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_goto_main_menu()
