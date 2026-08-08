extends CanvasLayer
## PauseMenu — overlays gameplay when Escape/Start is pressed. Uses
## `process_mode = ALWAYS` so we still respond to input while the tree is
## paused.

signal resumed
signal quit_to_menu_requested

@onready var _btn_resume: Button = %BtnResume
@onready var _btn_settings: Button = %BtnSettings
@onready var _btn_menu: Button = %BtnMenu
@onready var _btn_quit: Button = %BtnQuit
@onready var _dim: ColorRect = %Dim
@onready var _panel: PanelContainer = %Panel

const SettingsDialogScene := preload("res://scenes/menus/SettingsDialog.tscn")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_btn_resume.pressed.connect(_on_resume)
	_btn_settings.pressed.connect(_on_settings)
	_btn_menu.pressed.connect(_on_menu)
	_btn_quit.pressed.connect(_on_quit)


func open() -> void:
	visible = true
	_dim.modulate.a = 0.0
	_panel.modulate.a = 0.0
	_panel.pivot_offset = _panel.size * 0.5
	_panel.scale = Vector2(0.95, 0.95)
	get_tree().paused = true
	GameState.set_phase(GameState.Phase.PAUSED)
	var tw := create_tween().set_parallel(true).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_dim, "modulate:a", 1.0, 0.15)
	tw.tween_property(_panel, "modulate:a", 1.0, 0.2)
	tw.tween_property(_panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tw.finished
	_btn_resume.grab_focus()


func close() -> void:
	var tw := create_tween().set_parallel(true).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_dim, "modulate:a", 0.0, 0.15)
	tw.tween_property(_panel, "modulate:a", 0.0, 0.15)
	tw.tween_property(_panel, "scale", Vector2(0.95, 0.95), 0.15)
	await tw.finished
	visible = false
	get_tree().paused = false
	GameState.set_phase(GameState.Phase.PLAYING)
	resumed.emit()


func _on_resume() -> void:
	Audio.play("cancel")
	close()


func _on_settings() -> void:
	Audio.play("nav")
	var dlg: Window = SettingsDialogScene.instantiate()
	add_child(dlg)
	dlg.process_mode = Node.PROCESS_MODE_ALWAYS
	dlg.popup_centered_ratio(0.7)
	dlg.tree_exited.connect(func():
		if is_instance_valid(_btn_settings):
			_btn_settings.grab_focus()
	)


func _on_menu() -> void:
	Audio.play("cancel")
	get_tree().paused = false
	quit_to_menu_requested.emit()
	SceneRouter.go_to_main_menu()


func _on_quit() -> void:
	Audio.play("cancel")
	SceneRouter.quit_to_desktop()
