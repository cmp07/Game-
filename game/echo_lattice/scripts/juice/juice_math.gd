class_name JuiceMath
extends RefCounted
## Shared easings / damp helpers for the juice stack (ported from Vite juice pass).


static func clampf01(v: float) -> float:
	return clampf(v, 0.0, 1.0)


static func ease_out_cubic(t: float) -> float:
	var p: float = 1.0 - clampf01(t)
	return 1.0 - p * p * p


static func ease_out_quint(t: float) -> float:
	var p: float = 1.0 - clampf01(t)
	return 1.0 - p * p * p * p * p


static func damp(current: float, target: float, lambda: float, dt: float) -> float:
	# Exponential approach: framerate-independent.
	return lerpf(current, target, 1.0 - exp(-lambda * dt))
