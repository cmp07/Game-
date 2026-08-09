extends Node
##
## Juice — Godot port of the juice pillars (shake, hitstop, flash, particles).
## Vite juice from PR #46 is intentionally not used; this is the in-engine feel layer.
## Real-time systems advance on wall-clock so hitstop never freezes VFX.
## Palette-aligned colors keep rewrite / wall / win punches visually consistent.
##
## Particles use a capped SoA pool (steal-oldest) — no Dictionary allocs in the
## spawn/update hot path (docs/AUDIT/PERFORMANCE.md §3).
##

signal hitstop_ended()

const PARTICLE_CAP: int = 200

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

## SoA particle pool — index 0 .. _live_count-1 are active.
var _px: PackedFloat32Array = PackedFloat32Array()
var _py: PackedFloat32Array = PackedFloat32Array()
var _vx: PackedFloat32Array = PackedFloat32Array()
var _vy: PackedFloat32Array = PackedFloat32Array()
var _life: PackedFloat32Array = PackedFloat32Array()
var _max_life: PackedFloat32Array = PackedFloat32Array()
var _size: PackedFloat32Array = PackedFloat32Array()
var _cr: PackedFloat32Array = PackedFloat32Array()
var _cg: PackedFloat32Array = PackedFloat32Array()
var _cb: PackedFloat32Array = PackedFloat32Array()
var _live_count: int = 0
var _steal_cursor: int = 0

var _last_msec: int = 0
var _shake_scratch: Dictionary = {"dx": 0.0, "dy": 0.0, "rot": 0.0}


func _ready() -> void:
	set_process(true)
	shake_seed = randf() * 1000.0
	_last_msec = Time.get_ticks_msec()
	_ensure_pool()


func _ensure_pool() -> void:
	if _px.size() == PARTICLE_CAP:
		return
	_px.resize(PARTICLE_CAP)
	_py.resize(PARTICLE_CAP)
	_vx.resize(PARTICLE_CAP)
	_vy.resize(PARTICLE_CAP)
	_life.resize(PARTICLE_CAP)
	_max_life.resize(PARTICLE_CAP)
	_size.resize(PARTICLE_CAP)
	_cr.resize(PARTICLE_CAP)
	_cg.resize(PARTICLE_CAP)
	_cb.resize(PARTICLE_CAP)
	_live_count = mini(_live_count, PARTICLE_CAP)


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
		_shake_scratch["dx"] = 0.0
		_shake_scratch["dy"] = 0.0
		_shake_scratch["rot"] = 0.0
		return _shake_scratch
	var s: float = trauma * trauma * intensity
	var f: float = shake_t * 42.0
	_shake_scratch["dx"] = max_px * s * _noise(shake_seed + 1.0, f)
	_shake_scratch["dy"] = max_px * s * _noise(shake_seed + 2.0, f)
	_shake_scratch["rot"] = deg_to_rad(max_rot_deg) * s * _noise(shake_seed + 3.0, f)
	return _shake_scratch


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
	_ensure_pool()
	for _i in range(count):
		var ang: float = randf() * TAU
		var spd: float = randf_range(40.0, 120.0)
		var life: float = randf_range(0.25, 0.55)
		_alloc_particle(
			world_pos.x,
			world_pos.y,
			cos(ang) * spd,
			sin(ang) * spd,
			life,
			0.55,
			randf_range(2.0, 4.5),
			color.r,
			color.g,
			color.b
		)


func _alloc_particle(
	px: float, py: float, vx: float, vy: float,
	life: float, max_life: float, size: float,
	cr: float, cg: float, cb: float
) -> void:
	var idx: int
	if _live_count < PARTICLE_CAP:
		idx = _live_count
		_live_count += 1
	else:
		# Steal-oldest ring — never grow past PARTICLE_CAP.
		idx = _steal_cursor
		_steal_cursor = (_steal_cursor + 1) % PARTICLE_CAP
	_px[idx] = px
	_py[idx] = py
	_vx[idx] = vx
	_vy[idx] = vy
	_life[idx] = life
	_max_life[idx] = max_life
	_size[idx] = size
	_cr[idx] = cr
	_cg[idx] = cg
	_cb[idx] = cb


func live_particle_count() -> int:
	return _live_count


## Compatibility alias used by chamber draw / selftests. Prefer live_particle_count().
var particles: Array:
	get:
		return _particles_view()


func _particles_view() -> Array:
	## Rare debug/compat path — hot draw uses draw_particles().
	var out: Array = []
	out.resize(_live_count)
	for i in range(_live_count):
		out[i] = {
			"pos": Vector2(_px[i], _py[i]),
			"vel": Vector2(_vx[i], _vy[i]),
			"life": _life[i],
			"max_life": _max_life[i],
			"color": Color(_cr[i], _cg[i], _cb[i]),
			"size": _size[i],
		}
	return out


func draw_particles(canvas: CanvasItem) -> void:
	for i in range(_live_count):
		var max_life: float = maxf(0.001, _max_life[i])
		var a: float = clampf(_life[i] / max_life, 0.0, 1.0)
		canvas.draw_circle(Vector2(_px[i], _py[i]), _size[i], Color(_cr[i], _cg[i], _cb[i], a))


func needs_redraw() -> bool:
	return trauma > 0.001 or flash_left > 0.0 or _live_count > 0 or hitstop_left > 0.0


func clear_particles() -> void:
	_live_count = 0
	_steal_cursor = 0


func reset_transient() -> void:
	## Call on stage swaps so autoload juice never bleeds across chambers/menus.
	clear_particles()
	trauma = 0.0
	flash_left = 0.0
	flash_duration = 0.0
	flash_peak = 0.0
	if hitstop_left > 0.0:
		hitstop_left = 0.0
		if DisplayServer.get_name() != "headless":
			Engine.time_scale = _pre_hitstop_scale


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
	while i < _live_count:
		_life[i] = _life[i] - real_dt
		_px[i] = _px[i] + _vx[i] * real_dt
		_py[i] = _py[i] + _vy[i] * real_dt
		var damp: float = 1.0 - real_dt * 3.0
		_vx[i] = _vx[i] * damp
		_vy[i] = _vy[i] * damp
		if _life[i] <= 0.0:
			# Swap-remove — no Array.remove_at shifts.
			var last: int = _live_count - 1
			if i != last:
				_px[i] = _px[last]
				_py[i] = _py[last]
				_vx[i] = _vx[last]
				_vy[i] = _vy[last]
				_life[i] = _life[last]
				_max_life[i] = _max_life[last]
				_size[i] = _size[last]
				_cr[i] = _cr[last]
				_cg[i] = _cg[last]
				_cb[i] = _cb[last]
			_live_count = last
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
