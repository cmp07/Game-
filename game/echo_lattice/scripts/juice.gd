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
	trauma = clampf(trauma + amount, 0.0, 1.0)


func shake_offset(max_px: float = 10.0, max_rot_deg: float = 2.0) -> Dictionary:
	var s: float = trauma * trauma
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
	flash_duration = maxf(duration, 0.001)
	flash_left = flash_duration
	flash_peak = peak
	# Transparent default → cadmium warn (matches Palette.CADMIUM_WARN; no autoload in default args).
	flash_color = Color("#D6432B") if color.a <= 0.0 else color


func rewrite_punch(segment_count: int = 1) -> void:
	var shake_amt: float = minf(0.55, 0.20 + 0.03 * float(segment_count))
	bump(shake_amt)
	hitstop(0.09, 0.06)
	flash(0.28, 0.55, Color("#D6432B"))


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


static func _noise(seed_v: float, t: float) -> float:
	return sin((seed_v + t) * 12.9898) * cos((seed_v - t) * 4.131)
