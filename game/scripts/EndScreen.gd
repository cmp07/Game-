extends Control
## EndScreen — one scene reused for both win and lose. `set_outcome()` swaps
## copy, colors, and the summary stats.

@onready var _kicker: Label = %Kicker
@onready var _title: Label = %Title
@onready var _flavor: Label = %Flavor
@onready var _accent: Panel = %Accent
@onready var _stat_time: Label = %StatTime
@onready var _stat_habit: Label = %StatHabit
@onready var _btn_retry: Button = %BtnRetry
@onready var _btn_menu: Button = %BtnMenu
@onready var _fader: ColorRect = %Fader
@onready var _art: Control = %Art

var _won: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	_btn_retry.pressed.connect(_on_retry)
	_btn_menu.pressed.connect(_on_menu)
	_stat_time.text = "Loop time — %s" % GameState.format_time(GameState.run_seconds)
	_stat_habit.text = "Habit ended at %d" % int(round(GameState.habit))
	_fader.color.a = 0.0
	var tw := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_fader, "color:a", 0.55, 0.3)
	tw.tween_callback(func():
		_btn_retry.grab_focus()
	)


func set_outcome(won: bool) -> void:
	_won = won
	if is_inside_tree():
		_apply_outcome()
	else:
		call_deferred("_apply_outcome")


func _apply_outcome() -> void:
	if _won:
		_kicker.text = "LOOP CLOSED"
		_title.text = "The lattice holds."
		_flavor.text = "You steered the rewrites without letting the habit calcify. A quiet win — the kind that stays."
		_accent.self_modulate = Color(0.486275, 0.976471, 1.0, 1.0)
		_kicker.modulate = _accent.self_modulate
	else:
		_kicker.text = "LOOP BROKEN"
		_title.text = "The lattice shatters."
		_flavor.text = "The rewrites piled up. That's fine — habits break easier the second time."
		_accent.self_modulate = Color(1, 0.478, 0.541, 1)
		_kicker.modulate = _accent.self_modulate


func _on_retry() -> void:
	get_tree().paused = false
	GameState.start_new_run()
	SceneRouter.go_to_game()


func _on_menu() -> void:
	get_tree().paused = false
	SceneRouter.go_to_main_menu()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_menu()
		get_viewport().set_input_as_handled()
