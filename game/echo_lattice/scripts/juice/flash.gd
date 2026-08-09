class_name JuiceFlash
extends RefCounted
## Full-screen additive flash. Lands hard (easeOutQuint), fades fast.

const MathScript = preload("res://scripts/juice/juice_math.gd")

var color: Color = Color(1, 1, 1, 0)
var _t: float = 0.0
var _duration: float = 0.0
var _strength: float = 0.0


func fire(seconds: float, strength: float, rgb: Color = Color(1, 1, 1)) -> void:
	if seconds > _duration - _t or strength > current_alpha():
		_duration = seconds
		_t = 0.0
		_strength = strength
		color = Color(rgb.r, rgb.g, rgb.b, 1.0)


func update(real_dt: float) -> void:
	if _duration <= 0.0:
		return
	_t += real_dt
	if _t >= _duration:
		_duration = 0.0
		_t = 0.0


func current_alpha() -> float:
	if _duration <= 0.0:
		return 0.0
	var p: float = MathScript.clampf01(_t / _duration)
	return _strength * (1.0 - MathScript.ease_out_quint(p))


func modulate_color() -> Color:
	var a: float = current_alpha()
	return Color(color.r, color.g, color.b, a)
