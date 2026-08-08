extends Control
## Main menu — entry hub. Handles focus management, hover parallax, and hands
## navigation off to the SceneRouter / Settings dialog.

@onready var _new_run: Button = %BtnNewRun
@onready var _continue: Button = %BtnContinue
@onready var _settings: Button = %BtnSettings
@onready var _credits: Button = %BtnCredits
@onready var _quit: Button = %BtnQuit
@onready var _version: Label = %VersionLabel
@onready var _lattice: Control = %LatticeArt
@onready var _tagline: Label = %Tagline

const SettingsDialogScene := preload("res://scenes/menus/SettingsDialog.tscn")

var _time := 0.0


func _ready() -> void:
	_version.text = "v%s  ·  echo lattice" % ProjectSettings.get_setting("application/config/version", "0.1")
	_new_run.pressed.connect(_on_new_run)
	_continue.pressed.connect(_on_continue)
	_settings.pressed.connect(_on_settings)
	_credits.pressed.connect(_on_credits)
	_quit.pressed.connect(_on_quit)
	_continue.disabled = true  # No save system yet.
	_continue.tooltip_text = "Continue is unlocked once a run is in progress."

	_lattice.set_process(true)
	_new_run.call_deferred("grab_focus")


func _process(delta: float) -> void:
	_time += delta
	if Accessibility.reduce_motion():
		_lattice.rotation = 0.0
	else:
		_lattice.rotation = sin(_time * 0.15) * 0.02


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_quit_hint()


func _on_new_run() -> void:
	Audio.play("confirm")
	GameState.start_new_run()
	SceneRouter.go_to_game()


func _on_continue() -> void:
	Audio.play("nav")


func _on_settings() -> void:
	Audio.play("nav")
	var dlg: Window = SettingsDialogScene.instantiate()
	add_child(dlg)
	dlg.popup_centered_ratio(0.7)
	dlg.close_requested.connect(func(): dlg.queue_free())
	dlg.tree_exited.connect(func():
		if is_instance_valid(_settings):
			_settings.grab_focus()
	)


func _on_credits() -> void:
	Audio.play("nav")
	SceneRouter.go_to_credits()


func _on_quit() -> void:
	Audio.play("cancel")
	SceneRouter.quit_to_desktop()


func _on_quit_hint() -> void:
	_quit.grab_focus()
