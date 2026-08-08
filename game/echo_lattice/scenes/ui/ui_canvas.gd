class_name UICanvas
extends CanvasLayer
##
## HUD + overlays.
##
## The scaffold ships:
##  - a crosshair
##  - a transient message label driven by EventBus.ui_message_requested
##  - a pause overlay driven by EventBus.game_paused
##  - a debug overlay driven by GameState.debug_overlay_enabled
##
## Screens (main menu, settings, credits) belong in separate scenes swapped
## in via SceneRouter — keep this one focused on the always-on HUD.
##

@onready var _crosshair: Control = $Root/Crosshair
@onready var _message_label: Label = $Root/MessageLayer/MessageLabel
@onready var _pause_panel: Control = $Root/PausePanel
@onready var _debug_panel: Control = $Root/DebugPanel
@onready var _debug_label: Label = $Root/DebugPanel/DebugLabel

var _message_tween: Tween


func _ready() -> void:
	_pause_panel.visible = false
	_debug_panel.visible = false
	_message_label.modulate.a = 0.0
	EventBus.ui_message_requested.connect(_on_ui_message_requested)
	EventBus.game_paused.connect(_on_game_paused)


func _process(_delta: float) -> void:
	if not GameState.debug_overlay_enabled:
		if _debug_panel.visible:
			_debug_panel.visible = false
		return
	if not _debug_panel.visible:
		_debug_panel.visible = true
	_debug_label.text = _debug_text()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"debug_toggle"):
		GameState.toggle_debug_overlay()


func _debug_text() -> String:
	var chamber := String(GameState.current_chamber_id)
	if chamber.is_empty():
		chamber = "-"
	return "chamber: %s\nhabits: %d\npaused: %s\nfps: %d" % [
		chamber,
		HabitTracker.total_events(),
		"yes" if GameState.paused else "no",
		Engine.get_frames_per_second(),
	]


func _on_ui_message_requested(text: String, duration_s: float) -> void:
	_message_label.text = text
	if _message_tween != null and _message_tween.is_valid():
		_message_tween.kill()
	_message_tween = create_tween()
	_message_tween.tween_property(_message_label, "modulate:a", 1.0, 0.15)
	_message_tween.tween_interval(maxf(0.1, duration_s))
	_message_tween.tween_property(_message_label, "modulate:a", 0.0, 0.35)


func _on_game_paused(paused: bool) -> void:
	_pause_panel.visible = paused
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED
