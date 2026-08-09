class_name FlashGate
extends RefCounted
## Gates full-screen / rewrite flashes through accessibility policy.
## Juice.flash() routes through this so reduce-flash / reduce-motion always apply.

static func gate(color: Color, intensity: float, duration: float, a11y: Node = null) -> Dictionary:
	var svc: Node = a11y
	if svc == null and Engine.get_main_loop() != null:
		var tree := Engine.get_main_loop() as SceneTree
		if tree != null and tree.root != null:
			svc = tree.root.get_node_or_null("AccessibilityService")
	var max_i := 1.0
	var reduce := false
	var motion := false
	if svc != null:
		if svc.has_method("flash_max_intensity"):
			max_i = float(svc.call("flash_max_intensity"))
		if svc.has_method("reduce_flash"):
			reduce = bool(svc.call("reduce_flash"))
		if svc.has_method("reduce_motion"):
			motion = bool(svc.call("reduce_motion"))
	if max_i <= 0.001:
		return {}
	var out_intensity := minf(intensity, max_i)
	var out_duration := duration
	var out_color := color
	if reduce:
		# Soften: desaturate toward ledger ink, stretch duration, never pure white.
		out_color = color.lerp(Color(0.35, 0.32, 0.28, color.a), 0.65)
		out_color.a = minf(out_color.a, 0.35)
		out_intensity = minf(out_intensity, 0.25)
		out_duration = maxf(duration * 1.6, 0.18)
	if motion:
		out_duration = maxf(out_duration, 0.25)
		out_intensity *= 0.5
	return {
		"color": out_color,
		"intensity": out_intensity,
		"duration": out_duration,
	}


static func request_rewrite_flash(a11y: Node = null) -> Dictionary:
	## Legacy helper — rewrite juice no longer full-screen flashes (cadmium is
	## the page-margin heartbeat in Chamber). Kept for tools/tests; returns {}.
	var _unused_a11y: Node = a11y
	return {}
