class_name JuiceHitstop
extends RefCounted
## Hitstop-light: timescale floor ≈0.06, easeOutCubic recovery. Never fully zero.

const MathScript = preload("res://scripts/juice/juice_math.gd")

var timescale: float = 1.0
var _t: float = 0.0
var _duration: float = 0.0
var _floor: float = 0.06
var _queued: float = 0.0


func hit(seconds: float, floor_scale: float = 0.06) -> void:
	if seconds > _duration - _t:
		_duration = seconds
		_t = 0.0
		_floor = floor_scale
	else:
		_queued = minf(0.08, _queued + seconds * 0.4)


func update(real_dt: float) -> void:
	if _duration <= 0.0 and _queued > 0.0:
		_duration = _queued
		_queued = 0.0
		_t = 0.0
	if _duration <= 0.0:
		timescale = 1.0
		return
	_t += real_dt
	var p: float = MathScript.clampf01(_t / _duration)
	var eased: float = MathScript.ease_out_cubic(p)
	timescale = _floor + (1.0 - _floor) * eased
	if p >= 1.0:
		_duration = 0.0
		timescale = 1.0


func is_active() -> bool:
	return _duration > 0.0
