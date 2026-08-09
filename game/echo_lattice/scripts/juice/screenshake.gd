class_name JuiceScreenShake
extends RefCounted
## Trauma² screen shake (Squirrel Eiserloh). Decay 1.35/s.


var trauma: float = 0.0
var _t: float = 0.0
var _seed: float = randf() * 1000.0


func bump(amount: float) -> void:
	trauma = clampf(trauma + amount, 0.0, 1.0)


func update(real_dt: float) -> void:
	_t += real_dt
	trauma = clampf(trauma - real_dt * 1.35, 0.0, 1.0)


func offset(max_px: float = 14.0, max_rot_deg: float = 3.0) -> Vector3:
	# Returns (dx, dy, rotation_radians).
	var s: float = trauma * trauma
	var f: float = _t * 42.0
	var dx: float = max_px * s * _noise1(_seed + 1.0, f)
	var dy: float = max_px * s * _noise1(_seed + 2.0, f)
	var r: float = deg_to_rad(max_rot_deg) * s * _noise1(_seed + 3.0, f)
	return Vector3(dx, dy, r)


func _noise1(seed_v: float, t: float) -> float:
	var s: float = sin(seed_v * 12.9898 + t * 78.233) * 43758.5453
	return (s - floorf(s)) * 2.0 - 1.0
