class_name ScreenShake
extends Node
## Applies camera trauma with a hard accessibility toggle.
## Attach under a Camera2D or call apply_offset() from a camera controller.

signal shake_applied(offset: Vector2)
signal shake_suppressed()

@export var decay_per_second: float = 1.6
@export var max_offset_px: float = 10.0

var _trauma: float = 0.0
var _a11y: Node = null
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	_a11y = get_node_or_null("/root/AccessibilityService")


func set_accessibility_service(service: Node) -> void:
	_a11y = service


func add_trauma(amount: float) -> void:
	if not _enabled():
		shake_suppressed.emit()
		return
	_trauma = clampf(_trauma + amount * _intensity(), 0.0, 1.0)


## Instant bump used by rewrite / fail juice.
func bump(strength: float = 0.35) -> void:
	add_trauma(strength)


func _process(delta: float) -> void:
	if _trauma <= 0.0:
		return
	if not _enabled():
		_trauma = 0.0
		shake_applied.emit(Vector2.ZERO)
		shake_suppressed.emit()
		return
	var shake := _trauma * _trauma
	var offset := Vector2(
		_rng.randf_range(-1.0, 1.0),
		_rng.randf_range(-1.0, 1.0)
	) * max_offset_px * shake * _intensity()
	shake_applied.emit(offset)
	_trauma = maxf(_trauma - decay_per_second * delta, 0.0)
	if _trauma <= 0.0:
		shake_applied.emit(Vector2.ZERO)


func current_offset() -> Vector2:
	if not _enabled() or _trauma <= 0.0:
		return Vector2.ZERO
	var shake := _trauma * _trauma
	return Vector2(
		_rng.randf_range(-1.0, 1.0),
		_rng.randf_range(-1.0, 1.0)
	) * max_offset_px * shake * _intensity()


func _enabled() -> bool:
	if _a11y != null and _a11y.has_method("screen_shake_enabled"):
		return bool(_a11y.call("screen_shake_enabled"))
	return true


func _intensity() -> float:
	if _a11y != null and _a11y.has_method("screen_shake_intensity"):
		return float(_a11y.call("screen_shake_intensity"))
	return 1.0
