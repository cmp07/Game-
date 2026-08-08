class_name FlashGate
extends RefCounted
## Gates full-screen / tile rewrite flashes through accessibility policy.
## Game juice systems should call request_flash() instead of painting raw white.

signal flash_requested(color: Color, intensity: float, duration: float)

var _a11y: Node = null


func _init(accessibility_service: Node = null) -> void:
	_a11y = accessibility_service


## Returns the gated flash parameters, or empty Dictionary if the flash is suppressed.
func gate(color: Color, intensity: float, duration: float) -> Dictionary:
	var max_i := _max_intensity()
	if max_i <= 0.001:
		return {}
	var reduce := _reduce_flash()
	var out_intensity := minf(intensity, max_i)
	var out_duration := duration
	var out_color := color
	if reduce:
		# Soften: desaturate toward lattice gray, stretch duration, never pure white.
		out_color = color.lerp(Color(0.35, 0.4, 0.45, color.a), 0.65)
		out_color.a = minf(out_color.a, 0.35)
		out_intensity = minf(out_intensity, 0.25)
		out_duration = maxf(duration * 1.6, 0.18)
	if _reduce_motion():
		out_duration = maxf(out_duration, 0.25)
		out_intensity *= 0.5
	return {
		"color": out_color,
		"intensity": out_intensity,
		"duration": out_duration,
	}


func request_flash(color: Color, intensity: float = 1.0, duration: float = 0.12) -> bool:
	var gated := gate(color, intensity, duration)
	if gated.is_empty():
		return false
	flash_requested.emit(gated["color"], gated["intensity"], gated["duration"])
	return true


## Checkpoint rewrite cue: respects reduce-flash so walls don't "slam" as a white strobe.
func request_rewrite_flash() -> bool:
	return request_flash(Color.WHITE, 0.85, 0.1)


func _max_intensity() -> float:
	if _a11y != null and _a11y.has_method("flash_max_intensity"):
		return float(_a11y.call("flash_max_intensity"))
	return 1.0


func _reduce_flash() -> bool:
	if _a11y != null and _a11y.has_method("reduce_flash"):
		return bool(_a11y.call("reduce_flash"))
	return false


func _reduce_motion() -> bool:
	if _a11y != null and _a11y.has_method("reduce_motion"):
		return bool(_a11y.call("reduce_motion"))
	return false
