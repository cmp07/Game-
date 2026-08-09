extends Node
##
## WeaverJuice — diegetic feel for The Weaver W1 spike.
## Three intentional motions (docs/WEAVER/20_JUICE.md):
##   1. fragment_suck  — chalk/fiber wisps pull a Fragment into hand
##   2. combine_flash  — local paper-press flash at the bind seam
##   3. weave_pulse    — taut Thread body pulses kiln copper (not neon ring)
##
## Ban: purple glow, full-screen energy, magnet catch beams, idle UI breathe.
## VFX advance on wall-clock so feel never freezes under optional hitstop.
##

signal fragment_suck_finished(fragment_id: StringName)
signal combine_flash_finished()
signal weave_pulse_finished()

const WISP_CAP: int = 48
const SUCK_DURATION: float = 0.32
const COMBINE_DURATION: float = 0.14
const WEAVE_DURATION: float = 0.48
const WEAVE_CYCLES: float = 2.0

## Active suck tweens (SoA-ish dictionaries for query/tests).
var _sucks: Array = []
## Local combine flashes (never full-screen).
var _flashes: Array = []
## Weave pulses along a Thread path.
var _pulses: Array = []

## Chalk/fiber wisps spawned by suck.
var _wx: PackedFloat32Array = PackedFloat32Array()
var _wy: PackedFloat32Array = PackedFloat32Array()
var _wvx: PackedFloat32Array = PackedFloat32Array()
var _wvy: PackedFloat32Array = PackedFloat32Array()
var _wlife: PackedFloat32Array = PackedFloat32Array()
var _wmax: PackedFloat32Array = PackedFloat32Array()
var _wsize: PackedFloat32Array = PackedFloat32Array()
var _w_live: int = 0
var _w_steal: int = 0

var reduce_motion: bool = false
var _last_msec: int = 0


func _ready() -> void:
	set_process(true)
	_last_msec = Time.get_ticks_msec()
	_ensure_wisps()


func _process(_delta: float) -> void:
	var now: int = Time.get_ticks_msec()
	var real_dt: float = clampf(float(now - _last_msec) / 1000.0, 0.0, 0.1)
	_last_msec = now
	_update_sucks(real_dt)
	_update_flashes(real_dt)
	_update_pulses(real_dt)
	_update_wisps(real_dt)


## Recover beat — Fragment settles into hand with chalk/fiber suck (not a catch beam).
func fragment_suck(fragment_id: StringName, from: Vector2, to: Vector2, family_tint: Color = Color(0, 0, 0, 0)) -> void:
	var tint: Color = family_tint if family_tint.a > 0.0 else WeaverPalette.timber
	var dur: float = 0.08 if reduce_motion else SUCK_DURATION
	_sucks.append({
		"id": fragment_id,
		"from": from,
		"to": to,
		"t": 0.0,
		"dur": dur,
		"tint": tint,
		"pos": from,
		"scale": 1.0,
	})
	if not reduce_motion:
		_spawn_suck_wisps(from, to)


## Bind beat — local paper-press flash at the seam (chalk_bright, not purple).
func combine_flash(at: Vector2, radius: float = 36.0, peak: float = 0.55) -> void:
	var dur: float = 0.04 if reduce_motion else COMBINE_DURATION
	var gated_peak: float = peak if not reduce_motion else minf(peak, 0.25)
	_flashes.append({
		"at": at,
		"radius": radius,
		"peak": gated_peak,
		"t": 0.0,
		"dur": dur,
		"alpha": gated_peak,
	})


## Tension beat — Thread body pulses kiln copper along the fiber (diegetic load).
func weave_pulse(path: PackedVector2Array, tension: float = 1.0) -> void:
	if path.size() < 2:
		return
	var dur: float = 0.1 if reduce_motion else WEAVE_DURATION
	_pulses.append({
		"path": path,
		"tension": clampf(tension, 0.2, 1.5),
		"t": 0.0,
		"dur": dur,
		"phase": 0.0,
		"width": 2.0,
	})


func active_suck_count() -> int:
	return _sucks.size()


func active_flash_count() -> int:
	return _flashes.size()


func active_pulse_count() -> int:
	return _pulses.size()


func live_wisp_count() -> int:
	return _w_live


func is_sucking(fragment_id: StringName) -> bool:
	for s in _sucks:
		if s["id"] == fragment_id:
			return true
	return false


func needs_redraw() -> bool:
	return not _sucks.is_empty() or not _flashes.is_empty() or not _pulses.is_empty() or _w_live > 0


func reset_transient() -> void:
	_sucks.clear()
	_flashes.clear()
	_pulses.clear()
	_w_live = 0
	_w_steal = 0


## Draw all juice onto a CanvasItem (demo field / future loom view).
func draw_all(canvas: CanvasItem) -> void:
	_draw_wisps(canvas)
	_draw_sucks(canvas)
	_draw_pulses(canvas)
	_draw_flashes(canvas)


func _ensure_wisps() -> void:
	if _wx.size() == WISP_CAP:
		return
	_wx.resize(WISP_CAP)
	_wy.resize(WISP_CAP)
	_wvx.resize(WISP_CAP)
	_wvy.resize(WISP_CAP)
	_wlife.resize(WISP_CAP)
	_wmax.resize(WISP_CAP)
	_wsize.resize(WISP_CAP)


func _spawn_suck_wisps(from: Vector2, to: Vector2) -> void:
	_ensure_wisps()
	var toward: Vector2 = (to - from)
	var dist: float = toward.length()
	if dist < 1.0:
		return
	var dir: Vector2 = toward / dist
	var perp: Vector2 = Vector2(-dir.y, dir.x)
	# Six chalk/fiber wisps max — craft dust, not spark burst.
	for i in range(6):
		var lateral: float = randf_range(-14.0, 14.0)
		var along: float = randf_range(0.0, 0.35) * dist
		var origin: Vector2 = from + dir * along + perp * lateral
		var spd: float = randf_range(90.0, 160.0)
		var life: float = randf_range(0.18, 0.34)
		_alloc_wisp(origin.x, origin.y, dir.x * spd, dir.y * spd, life, randf_range(1.2, 2.4))


func _alloc_wisp(px: float, py: float, vx: float, vy: float, life: float, size: float) -> void:
	var idx: int
	if _w_live < WISP_CAP:
		idx = _w_live
		_w_live += 1
	else:
		idx = _w_steal
		_w_steal = (_w_steal + 1) % WISP_CAP
	_wx[idx] = px
	_wy[idx] = py
	_wvx[idx] = vx
	_wvy[idx] = vy
	_wlife[idx] = life
	_wmax[idx] = life
	_wsize[idx] = size


func _update_sucks(dt: float) -> void:
	var i: int = 0
	while i < _sucks.size():
		var s: Dictionary = _sucks[i]
		s["t"] = float(s["t"]) + dt
		var u: float = clampf(float(s["t"]) / maxf(0.001, float(s["dur"])), 0.0, 1.0)
		# Ease-in cubic — fiber gathers speed as it seats into hand.
		var e: float = u * u * u
		var from: Vector2 = s["from"]
		var to: Vector2 = s["to"]
		s["pos"] = from.lerp(to, e)
		s["scale"] = lerpf(1.0, 0.35, e)
		_sucks[i] = s
		if u >= 1.0:
			var fid: StringName = s["id"]
			_sucks.remove_at(i)
			emit_signal("fragment_suck_finished", fid)
		else:
			i += 1


func _update_flashes(dt: float) -> void:
	var i: int = 0
	while i < _flashes.size():
		var f: Dictionary = _flashes[i]
		f["t"] = float(f["t"]) + dt
		var u: float = clampf(float(f["t"]) / maxf(0.001, float(f["dur"])), 0.0, 1.0)
		# Fast peak then ease-out — paper press, not bloom sustain.
		var envelope: float = 1.0 - u
		envelope = envelope * envelope
		f["alpha"] = float(f["peak"]) * envelope
		_flashes[i] = f
		if u >= 1.0:
			_flashes.remove_at(i)
			emit_signal("combine_flash_finished")
		else:
			i += 1


func _update_pulses(dt: float) -> void:
	var i: int = 0
	while i < _pulses.size():
		var p: Dictionary = _pulses[i]
		p["t"] = float(p["t"]) + dt
		var u: float = clampf(float(p["t"]) / maxf(0.001, float(p["dur"])), 0.0, 1.0)
		p["phase"] = u * WEAVE_CYCLES * TAU
		# Width crest follows copper pulse along the cord.
		var wave: float = 0.5 + 0.5 * sin(float(p["phase"]))
		p["width"] = lerpf(1.6, 4.2, wave) * float(p["tension"])
		_pulses[i] = p
		if u >= 1.0:
			_pulses.remove_at(i)
			emit_signal("weave_pulse_finished")
		else:
			i += 1


func _update_wisps(dt: float) -> void:
	var i: int = 0
	while i < _w_live:
		_wlife[i] = _wlife[i] - dt
		_wx[i] = _wx[i] + _wvx[i] * dt
		_wy[i] = _wy[i] + _wvy[i] * dt
		var damp: float = 1.0 - dt * 2.4
		_wvx[i] = _wvx[i] * damp
		_wvy[i] = _wvy[i] * damp
		if _wlife[i] <= 0.0:
			var last: int = _w_live - 1
			if i != last:
				_wx[i] = _wx[last]
				_wy[i] = _wy[last]
				_wvx[i] = _wvx[last]
				_wvy[i] = _wvy[last]
				_wlife[i] = _wlife[last]
				_wmax[i] = _wmax[last]
				_wsize[i] = _wsize[last]
			_w_live = last
		else:
			i += 1


func _draw_wisps(canvas: CanvasItem) -> void:
	var dust: Color = WeaverPalette.chalk_dust
	for i in range(_w_live):
		var a: float = clampf(_wlife[i] / maxf(0.001, _wmax[i]), 0.0, 1.0) * 0.75
		canvas.draw_circle(Vector2(_wx[i], _wy[i]), _wsize[i], Color(dust.r, dust.g, dust.b, a))


func _draw_sucks(canvas: CanvasItem) -> void:
	for s in _sucks:
		var pos: Vector2 = s["pos"]
		var sc: float = float(s["scale"])
		var tint: Color = s["tint"]
		var half: float = 10.0 * sc
		# Span-like plank silhouette — craft atom, not orb loot.
		var rect := Rect2(pos.x - half * 1.6, pos.y - half * 0.55, half * 3.2, half * 1.1)
		canvas.draw_rect(rect, Color(tint.r, tint.g, tint.b, 0.92), true)
		canvas.draw_rect(rect, WeaverPalette.ink_seat, false, 1.0)
		# Thin fiber strand back toward origin (diegetic pull tell).
		canvas.draw_line(pos, s["from"], Color(WeaverPalette.chalk_dust.r, WeaverPalette.chalk_dust.g, WeaverPalette.chalk_dust.b, 0.45), 1.0)


func _draw_flashes(canvas: CanvasItem) -> void:
	var bright: Color = WeaverPalette.chalk_bright
	for f in _flashes:
		var a: float = float(f["alpha"])
		if a <= 0.001:
			continue
		var at: Vector2 = f["at"]
		var r: float = float(f["radius"])
		# Soft disc + cross crease — paper press, not energy nova.
		canvas.draw_circle(at, r, Color(bright.r, bright.g, bright.b, a * 0.55))
		canvas.draw_circle(at, r * 0.45, Color(bright.r, bright.g, bright.b, a * 0.85))
		var ink: Color = Color(WeaverPalette.ink_soft.r, WeaverPalette.ink_soft.g, WeaverPalette.ink_soft.b, a * 0.5)
		canvas.draw_line(at + Vector2(-r * 0.7, 0), at + Vector2(r * 0.7, 0), ink, 1.5)
		canvas.draw_line(at + Vector2(0, -r * 0.35), at + Vector2(0, r * 0.35), ink, 1.0)


func _draw_pulses(canvas: CanvasItem) -> void:
	var copper: Color = WeaverPalette.kiln_copper
	var ink: Color = WeaverPalette.ink_seat
	for p in _pulses:
		var path: PackedVector2Array = p["path"]
		if path.size() < 2:
			continue
		var u: float = clampf(float(p["t"]) / maxf(0.001, float(p["dur"])), 0.0, 1.0)
		var fade: float = 1.0 - absf(u - 0.5) * 1.6
		fade = clampf(fade, 0.15, 1.0)
		var w: float = float(p["width"])
		# Base seated ink seam.
		canvas.draw_polyline(path, Color(ink.r, ink.g, ink.b, 0.85 * fade), maxf(1.5, w * 0.55), true)
		# Copper crest rides the fiber — load tell, not glow spam.
		var crest: float = 0.5 + 0.5 * sin(float(p["phase"]))
		var ca: float = (0.35 + 0.45 * crest) * fade * float(p["tension"])
		canvas.draw_polyline(path, Color(copper.r, copper.g, copper.b, ca), w, true)
