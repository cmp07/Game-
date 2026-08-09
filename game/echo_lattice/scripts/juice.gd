extends Node
##
## Juice — Godot port of the juice pillars (shake, hitstop, flash, particles).
## Vite juice from PR #46 is intentionally not used; this is the in-engine feel layer.
## Real-time systems advance on wall-clock so hitstop never freezes VFX.
## Palette-aligned colors keep rewrite / wall / win punches visually consistent.
##

signal hitstop_ended()

var trauma: float = 0.0
var trauma_decay: float = 1.35
var shake_seed: float = 0.0
var shake_t: float = 0.0

var hitstop_left: float = 0.0
var hitstop_duration: float = 0.09
var hitstop_floor: float = 0.06
var _pre_hitstop_scale: float = 1.0

var flash_left: float = 0.0
var flash_duration: float = 0.0
var flash_color: Color = Color(1, 1, 1, 0)
var flash_peak: float = 0.0

var particles: Array = []  # Array[Dictionary]
var _last_msec: int = 0


func _ready() -> void:
	set_process(true)
	shake_seed = randf() * 1000.0
	_last_msec = Time.get_ticks_msec()


func _process(_delta: float) -> void:
	var now: int = Time.get_ticks_msec()
	var real_dt: float = clampf(float(now - _last_msec) / 1000.0, 0.0, 0.1)
	_last_msec = now
	shake_t += real_dt
	trauma = clampf(trauma - real_dt * trauma_decay, 0.0, 1.0)
	if flash_left > 0.0:
		flash_left = maxf(0.0, flash_left - real_dt)
	_update_particles(real_dt)
	_update_hitstop(real_dt)


func bump(amount: float) -> void:
	var intensity: float = _shake_intensity()
	if intensity <= 0.001:
		return
	trauma = clampf(trauma + amount * intensity, 0.0, 1.0)


func shake_offset(max_px: float = 10.0, max_rot_deg: float = 2.0) -> Dictionary:
	var intensity: float = _shake_intensity()
	if intensity <= 0.001 or trauma <= 0.0:
		return {"dx": 0.0, "dy": 0.0, "rot": 0.0}
	var s: float = trauma * trauma * intensity
	var f: float = shake_t * 42.0
	var dx: float = max_px * s * _noise(shake_seed + 1.0, f)
	var dy: float = max_px * s * _noise(shake_seed + 2.0, f)
	var rot: float = deg_to_rad(max_rot_deg) * s * _noise(shake_seed + 3.0, f)
	return {"dx": dx, "dy": dy, "rot": rot}


func hitstop(duration: float = 0.09, floor_scale: float = 0.06) -> void:
	if duration <= 0.0:
		return
	# Never alter timescale in headless/CI — it stalls self-tests.
	if DisplayServer.get_name() == "headless":
		return
	if hitstop_left <= 0.0:
		_pre_hitstop_scale = Engine.time_scale
		if _pre_hitstop_scale <= 0.001:
			_pre_hitstop_scale = 1.0
	hitstop_duration = maxf(duration, 0.001)
	hitstop_left = maxf(hitstop_left, duration)
	hitstop_floor = floor_scale
	Engine.time_scale = maxf(floor_scale, 0.05)


func flash(duration: float = 0.22, peak: float = 0.45, color: Color = Color(0, 0, 0, 0)) -> void:
	# Transparent default → ink soft (Field Ledger: cadmium is reserved for the
	# rewrite-imminent margin heartbeat drawn by Chamber, not generic juice).
	var resolved: Color = Color("#3A342C") if color.a <= 0.0 else color
	var gated: Dictionary = FlashGate.gate(resolved, peak, duration)
	if gated.is_empty():
		flash_left = 0.0
		flash_duration = 0.0
		flash_peak = 0.0
		return
	flash_duration = maxf(float(gated.get("duration", duration)), 0.001)
	flash_left = flash_duration
	flash_peak = float(gated.get("intensity", peak))
	flash_color = gated.get("color", resolved)


func rewrite_punch(segment_count: int = 1) -> void:
	# Field Ledger art bible §5: no screen-shake on rewrite (document game).
	# Cadmium is the chamber margin heartbeat only — no full-screen rewrite flash
	# (avoids the old double-gated FlashGate path).
	if not _reduce_motion():
		hitstop(0.09, 0.06)
	# Players who explicitly enable shake get a tiny optional settle, not a punch.
	var intensity: float = _shake_intensity()
	if intensity > 0.001:
		var shake_amt: float = minf(0.14, 0.03 + 0.008 * float(segment_count))
		bump(shake_amt)


func spawn_burst(world_pos: Vector2, color: Color, count: int = 8) -> void:
	for i in range(count):
		var ang: float = randf() * TAU
		var spd: float = randf_range(40.0, 120.0)
		particles.append({
			"pos": world_pos,
			"vel": Vector2(cos(ang), sin(ang)) * spd,
			"life": randf_range(0.25, 0.55),
			"max_life": 0.55,
			"color": color,
			"size": randf_range(2.0, 4.5),
		})


func flash_alpha() -> float:
	if flash_left <= 0.0 or flash_duration <= 0.0:
		return 0.0
	var t: float = flash_left / flash_duration
	return flash_peak * t * t


func _update_hitstop(real_dt: float) -> void:
	if hitstop_left <= 0.0:
		return
	hitstop_left = maxf(0.0, hitstop_left - real_dt)
	if hitstop_left <= 0.0:
		Engine.time_scale = _pre_hitstop_scale
		emit_signal("hitstop_ended")
	else:
		var t: float = clampf(hitstop_left / hitstop_duration, 0.0, 1.0)
		Engine.time_scale = lerpf(_pre_hitstop_scale, hitstop_floor, t)


func _update_particles(real_dt: float) -> void:
	var i: int = 0
	while i < particles.size():
		var p: Dictionary = particles[i]
		p["life"] = float(p["life"]) - real_dt
		p["pos"] = p["pos"] + p["vel"] * real_dt
		p["vel"] = p["vel"] * (1.0 - real_dt * 3.0)
		particles[i] = p
		if float(p["life"]) <= 0.0:
			particles.remove_at(i)
		else:
			i += 1


func _shake_intensity() -> float:
	var a11y := get_node_or_null("/root/AccessibilityService")
	if a11y != null and a11y.has_method("screen_shake_intensity"):
		return float(a11y.call("screen_shake_intensity"))
	return 1.0


func _reduce_motion() -> bool:
	var a11y := get_node_or_null("/root/AccessibilityService")
	if a11y != null and a11y.has_method("reduce_motion"):
		return bool(a11y.call("reduce_motion"))
	return false


static func _noise(seed_v: float, t: float) -> float:
	return sin((seed_v + t) * 12.9898) * cos((seed_v - t) * 4.131)
