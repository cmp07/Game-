extends CanvasLayer
## TutorialLayer — bottom-center toast that surfaces contextual prompts.
## Multiple prompts queue up and animate in/out with a fade + slide.

@export var slide_distance: float = 32.0
@export var default_hold_ms: int = 3500

@onready var _root: Control = $Root
@onready var _label: Label = $Root/Panel/M/V/Text
@onready var _icon: Label = $Root/Panel/M/V/H/Icon
@onready var _panel: PanelContainer = $Root/Panel

var _queue: Array = []
var _busy := false


func _ready() -> void:
	layer = 42
	_root.modulate.a = 0.0
	if not Settings.get_value("gameplay", "tutorial_prompts"):
		hide()
	Settings.settings_changed.connect(func(section, key, value):
		if section == "gameplay" and key == "tutorial_prompts":
			visible = bool(value)
	)
	GameState.tutorial_prompt.connect(func(text, hold): queue_prompt(text, hold))


func queue_prompt(text: String, hold_ms: int = 0) -> void:
	if hold_ms <= 0:
		hold_ms = default_hold_ms
	_queue.append({"text": text, "hold": hold_ms})
	if not _busy:
		_pump()


func _pump() -> void:
	if _queue.is_empty():
		_busy = false
		return
	_busy = true
	var entry: Dictionary = _queue.pop_front()
	await _show_prompt(entry["text"], int(entry["hold"]))
	_pump()


func _show_prompt(text: String, hold_ms: int) -> void:
	_label.text = text
	_icon.text = "◆"
	_root.position.y = slide_distance
	_root.modulate.a = 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_root, "modulate:a", 1.0, 0.25)
	tw.tween_property(_root, "position:y", 0.0, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tw.finished
	await get_tree().create_timer(hold_ms / 1000.0).timeout
	var tw2 := create_tween().set_parallel(true)
	tw2.tween_property(_root, "modulate:a", 0.0, 0.3)
	tw2.tween_property(_root, "position:y", -slide_distance, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tw2.finished
