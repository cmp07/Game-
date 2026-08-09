class_name JuiceCameraSpring
extends RefCounted
## Critically-damped spring follow + velocity lookahead + zoom-punch.

const MathScript = preload("res://scripts/juice/juice_math.gd")

var pos: Vector2 = Vector2.ZERO
var vel: Vector2 = Vector2.ZERO
var target: Vector2 = Vector2.ZERO
var lookahead: Vector2 = Vector2.ZERO
var zoom: float = 1.0
var target_zoom: float = 1.0

var stiffness: float = 90.0
var damping: float = 20.0
var lookahead_gain: float = 0.14
var lookahead_ease: float = 6.0


func snap_to(p: Vector2) -> void:
	pos = p
	target = p
	vel = Vector2.ZERO
	lookahead = Vector2.ZERO
	zoom = 1.0
	target_zoom = 1.0


func follow(target_pos: Vector2, player_vel: Vector2, dt: float) -> void:
	target = target_pos
	lookahead.x = MathScript.damp(lookahead.x, player_vel.x * lookahead_gain, lookahead_ease, dt)
	lookahead.y = MathScript.damp(lookahead.y, player_vel.y * lookahead_gain, lookahead_ease, dt)
	var goal: Vector2 = target + lookahead
	var ax: float = (goal.x - pos.x) * stiffness - vel.x * damping
	var ay: float = (goal.y - pos.y) * stiffness - vel.y * damping
	vel.x += ax * dt
	vel.y += ay * dt
	pos.x += vel.x * dt
	pos.y += vel.y * dt
	zoom = MathScript.damp(zoom, target_zoom, 6.0, dt)


func punch(zoom_out: float = 0.06) -> void:
	target_zoom = clampf(target_zoom - zoom_out, 0.75, 1.15)


func recover_zoom(real_dt: float) -> void:
	target_zoom = MathScript.damp(target_zoom, 1.0, 4.0, real_dt)
