extends Control
## HUD — the in-game overlay. Composed of the goal banner (top), habit meter
## (left rail), rewrite telegraph (right rail), timer (top-right), and
## the tutorial layer / pause layer siblings that live above it.

@onready var _goal: Label = %GoalText
@onready var _goal_kicker: Label = %GoalKicker
@onready var _timer_label: Label = %TimerText
@onready var _controls_row: Label = %ControlsRow
@onready var _accent_bar: Panel = %AccentBar


func _ready() -> void:
	GameState.goal_changed.connect(_on_goal_changed)
	GameState.phase_changed.connect(_on_phase_changed)
	_on_goal_changed(GameState.goal_text)
	_refresh_controls_row()
	Settings.keybinds_changed.connect(_refresh_controls_row)


func _process(_delta: float) -> void:
	_timer_label.text = GameState.format_time(GameState.run_seconds)


func _on_goal_changed(text: String) -> void:
	_goal.text = text


func _on_phase_changed(phase: int) -> void:
	# Fade the accent bar a bit while paused so the HUD feels "on hold".
	var target := 1.0 if phase == GameState.Phase.PLAYING else 0.35
	create_tween().tween_property(_accent_bar, "modulate:a", target, 0.2)


func _refresh_controls_row() -> void:
	var rw := Settings.humanize_event(Settings.first_event_for("game_rewrite", "kbm"))
	var hold := Settings.humanize_event(Settings.first_event_for("game_hold", "kbm"))
	var reset := Settings.humanize_event(Settings.first_event_for("game_reset", "kbm"))
	var pause := Settings.humanize_event(Settings.first_event_for("ui_pause", "kbm"))
	_controls_row.text = "[%s] rewrite   [%s] hold   [%s] reset   [%s] pause" % [rw, hold, reset, pause]
