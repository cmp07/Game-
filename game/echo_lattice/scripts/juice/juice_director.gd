extends Node
##
## JuiceDirector — Godot port of Echo Lattice JUICE v2.
## Owns hitstop, screenshake, flash, camera spring, particles, telegraphs.
## Sim systems (telegraphs, particles) advance on scaled dt; presentation
## (shake/flash/camera) advances on wall-clock real dt so hitstop reads as
## punctuation, not lag.
##

signal rewrite_struck(meta: Variant)

const HitstopScript = preload("res://scripts/juice/hitstop.gd")
const ShakeScript = preload("res://scripts/juice/screenshake.gd")
const FlashScript = preload("res://scripts/juice/flash.gd")
const CameraScript = preload("res://scripts/juice/camera_spring.gd")
const ParticlesScript = preload("res://scripts/juice/particles.gd")
const TelegraphsScript = preload("res://scripts/juice/telegraphs.gd")

const COLOR_REWRITE := Color(0.63, 0.88, 1.0)
const COLOR_ECHO := Color(1.0, 0.36, 0.24)
const COLOR_DUST := Color(0.67, 0.78, 0.94)
const COLOR_NEAR_MISS := Color(1.0, 0.86, 0.70)
const COLOR_HIT := Color(1.0, 0.47, 0.47)

var hitstop = HitstopScript.new()
var shake = ShakeScript.new()
var flash = FlashScript.new()
var camera = CameraScript.new()
var particles = ParticlesScript.new()
var telegraphs = TelegraphsScript.new()

var enabled: bool = true
var _last_usec: int = 0
var _real_time: float = 0.0
var _sim_time: float = 0.0
var _player_vel: Vector2 = Vector2.ZERO
var _last_player_world: Vector2 = Vector2.ZERO


func _ready() -> void:
	_last_usec = Time.get_ticks_usec()
	set_process(true)
	# Engine.time_scale is driven by hitstop so chamber sim slows with it.
	Engine.time_scale = 1.0


func _process(_delta: float) -> void:
	var now_usec: int = Time.get_ticks_usec()
	var real_dt: float = clampf(float(now_usec - _last_usec) / 1_000_000.0, 0.0, 0.25)
	_last_usec = now_usec
	if not enabled:
		Engine.time_scale = 1.0
		return
	hitstop.update(real_dt)
	Engine.time_scale = hitstop.timescale
	shake.update(real_dt)
	flash.update(real_dt)
	camera.recover_zoom(real_dt)
	camera.follow(_last_player_world, _player_vel, real_dt)
	_real_time += real_dt


func track_player(world_pos: Vector2, grid_delta: Vector2 = Vector2.ZERO, cell_size: float = 32.0) -> void:
	# Convert discrete grid steps into a short-lived velocity for lookahead.
	if grid_delta != Vector2.ZERO:
		_player_vel = Vector2(grid_delta.x, grid_delta.y) * cell_size * 8.0
	else:
		_player_vel *= 0.85
	_last_player_world = world_pos


func snap_camera(world_pos: Vector2) -> void:
	camera.snap_to(world_pos)
	_last_player_world = world_pos
	_player_vel = Vector2.ZERO


func update_sim(sim_dt: float) -> Array:
	# Advance telegraphs + particles on scaled sim time. Returns fired zones.
	_sim_time += sim_dt
	var fired: Array = telegraphs.update(sim_dt)
	particles.update(sim_dt)
	for z in fired:
		_on_telegraph_strike(z)
	return fired


func footstep_dust(world_pos: Vector2, facing: Vector2 = Vector2.ZERO) -> void:
	if not enabled:
		return
	var back := -facing.normalized() if facing.length_squared() > 0.01 else Vector2(0, 1)
	particles.spawn_dot({
		"x": world_pos.x + back.x * 6.0,
		"y": world_pos.y + back.y * 6.0,
		"vx": back.x * 20.0 + randf_range(-10.0, 10.0),
		"vy": back.y * 20.0 + randf_range(-10.0, 10.0),
		"max_life": 0.28,
		"size": 1.2,
		"size_grow": 2.0,
		"drag": 5.0,
		"color": COLOR_DUST,
		"glow": 0.7,
	})


func on_rewrite_commit(world_pos: Vector2, segment_count: int) -> void:
	if not enabled:
		return
	var n: int = maxi(0, segment_count)
	shake.bump(minf(0.55, 0.2 + float(n) * 0.03))
	flash.fire(0.28, 0.55, COLOR_REWRITE)
	hitstop.hit(0.09, 0.06)
	camera.punch(0.06)
	camera.target_zoom = 0.94
	particles.spawn_ring({
		"x": world_pos.x, "y": world_pos.y,
		"size": 6.0, "size_grow": 320.0, "max_life": 0.55,
		"color": COLOR_REWRITE, "glow": 0.9,
	})
	particles.spawn_ring({
		"x": world_pos.x, "y": world_pos.y,
		"size": 6.0, "size_grow": 220.0, "max_life": 0.7,
		"color": Color(0.47, 0.78, 1.0), "glow": 0.6,
	})
	particles.burst_sparks(world_pos.x, world_pos.y, 22, 280.0, Color(0.78, 0.94, 1.0))


func foreshadow_wall_birth(world_pos: Vector2, cell: Vector2i, index: int, cell_size: float = 32.0) -> void:
	# Telegraph each pending echo cell before it solidifies (staggered wind-up).
	if not enabled:
		return
	var wind: float = 0.22 + float(index) * 0.02
	telegraphs.add(world_pos.x, world_pos.y, cell_size * 0.55, wind, 0.22, 14.0, {
		"kind": "wall_birth",
		"index": index,
		"cell": cell,
	})


func on_wall_born(world_pos: Vector2) -> void:
	if not enabled:
		return
	particles.burst_echo(world_pos.x, world_pos.y, Color(1.0, 0.55, 0.42))


func on_near_miss(intensity: float = 0.5) -> void:
	if not enabled:
		return
	var m: float = clampf(intensity, 0.0, 1.0)
	shake.bump(0.06 + m * 0.1)
	flash.fire(0.09, 0.15 + m * 0.15, COLOR_NEAR_MISS)
	hitstop.hit(0.03 + m * 0.03, 0.15)


func on_player_struck(world_pos: Vector2) -> void:
	if not enabled:
		return
	shake.bump(0.55)
	flash.fire(0.2, 0.8, COLOR_HIT)
	hitstop.hit(0.12, 0.05)
	particles.burst_sparks(world_pos.x, world_pos.y, 24, 340.0, Color(1.0, 0.70, 0.70))


func spawn_lattice_pulse(world_pos: Vector2, radius: float = 48.0, wind_up: float = 0.75) -> void:
	# Free-standing hostile telegraph (same anatomy as Vite Pulsar strikes).
	if not enabled:
		return
	telegraphs.add(world_pos.x, world_pos.y, radius, wind_up, 0.28, 12.0, {
		"kind": "lattice_pulse",
	})


func draw_fx(ci: CanvasItem) -> void:
	if not enabled:
		return
	telegraphs.draw_on(ci, _real_time)
	particles.draw_on(ci)


func shake_offset() -> Vector3:
	if not enabled:
		return Vector3.ZERO
	return shake.offset()


func camera_offset_for(world_center: Vector2) -> Vector2:
	# How much to shift the drawn world so camera.pos sits at view center.
	if not enabled:
		return Vector2.ZERO
	return world_center - camera.pos


func flash_modulate() -> Color:
	if not enabled:
		return Color(1, 1, 1, 0)
	return flash.modulate_color()


func reset() -> void:
	hitstop = HitstopScript.new()
	shake = ShakeScript.new()
	flash = FlashScript.new()
	particles.clear()
	telegraphs.clear()
	Engine.time_scale = 1.0
	_player_vel = Vector2.ZERO


func _on_telegraph_strike(z: Dictionary) -> void:
	var meta: Variant = z.get("meta", null)
	var kind := ""
	if typeof(meta) == TYPE_DICTIONARY:
		kind = str(meta.get("kind", ""))
	particles.spawn_ring({
		"x": float(z["x"]), "y": float(z["y"]),
		"size": 8.0, "size_grow": 260.0, "max_life": 0.45,
		"color": Color(1.0, 0.59, 0.55),
	})
	particles.burst_sparks(float(z["x"]), float(z["y"]), 16, 260.0, Color(1.0, 0.70, 0.59))
	rewrite_struck.emit(meta)
	if kind == "lattice_pulse":
		# Caller (chamber) decides hit vs near-miss from player distance.
		pass
