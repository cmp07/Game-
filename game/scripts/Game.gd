extends Node
## Game — the vertical-slice room. Composes the HUD, tutorial layer, pause
## menu, and win/lose overlays, and simulates just enough of the rewrite
## scheduler for the UI to feel alive.

const RewriteKinds := ["echo", "drift", "cascade", "prune"]
const WinScreenScene := preload("res://scenes/game/EndScreen.tscn")

@onready var _hud: Control = $HUD
@onready var _tutorial: CanvasLayer = $TutorialLayer
@onready var _pause: CanvasLayer = $PauseMenu
@onready var _bg: Node2D = $World
@onready var _telegraph: PanelContainer = $HUD/RightRail/RewriteTelegraph

var _time_since_scheduled: float = 0.0
var _next_rewrite_in: float = 3.5
var _win_scheduled: bool = false


func _ready() -> void:
	if GameState.phase != GameState.Phase.PLAYING:
		GameState.start_new_run()
	GameState.phase_changed.connect(_on_phase_changed)
	GameState.tutorial_prompt.emit("Watch the rewrite telegraph on the right. When one arrives, choose to accept or hold.", 5000)
	call_deferred("_queue_next_tutorial")


func _process(delta: float) -> void:
	if GameState.phase != GameState.Phase.PLAYING:
		return
	_time_since_scheduled += delta
	# Drift habit slightly to make the meter feel alive.
	if int(_time_since_scheduled * 4.0) % 2 == 0:
		GameState.adjust_habit(delta * (randf() - 0.5) * 4.0)
	# Fire a synthetic rewrite periodically until real gameplay lands.
	if GameState.rewrite_incoming.is_empty() and _time_since_scheduled > _next_rewrite_in:
		_time_since_scheduled = 0.0
		_next_rewrite_in = randf_range(4.5, 7.5)
		var kind: String = RewriteKinds[randi() % RewriteKinds.size()]
		GameState.schedule_rewrite(kind, randf_range(2.5, 4.0))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause"):
		if GameState.phase == GameState.Phase.PAUSED:
			_pause.close()
		elif GameState.phase == GameState.Phase.PLAYING:
			_pause.open()
		get_viewport().set_input_as_handled()
		return
	if GameState.phase != GameState.Phase.PLAYING:
		return
	if event.is_action_pressed("game_rewrite"):
		GameState.resolve_rewrite(true)
		Audio.play("confirm")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("game_hold"):
		GameState.resolve_rewrite(false)
		Audio.play("cancel")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("game_reset"):
		GameState.adjust_habit(50.0 - GameState.habit)
		GameState.tutorial_prompt.emit("Loop reset — habits pulled to steady.", 2500)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("debug_win"):
		_end("win")
	elif event.is_action_pressed("debug_lose"):
		_end("lose")


func _queue_next_tutorial() -> void:
	await get_tree().create_timer(6.0).timeout
	if GameState.phase == GameState.Phase.PLAYING:
		GameState.tutorial_prompt.emit("Habit sits in the middle band — keep it steady to survive rewrites.", 4000)
	await get_tree().create_timer(7.0).timeout
	if GameState.phase == GameState.Phase.PLAYING:
		GameState.tutorial_prompt.emit("Press Esc (or Start) any time to pause.", 3500)


func _on_phase_changed(phase: int) -> void:
	if phase == GameState.Phase.WON or phase == GameState.Phase.LOST:
		if _win_scheduled:
			return
		_win_scheduled = true
		_show_end_screen(phase == GameState.Phase.WON)


func _end(which: String) -> void:
	if which == "win":
		GameState.win()
	else:
		GameState.lose()


func _show_end_screen(won: bool) -> void:
	var scr: Control = WinScreenScene.instantiate()
	scr.set_outcome(won)
	add_child(scr)
