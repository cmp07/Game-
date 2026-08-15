extends Node2D
##
## Diegetic gap craft — torn edge, shed-air depth, lamp, taut fiber tell.
## Drawn in local space of VoidGap. Never purple void, never circles-on-black.
##

func _ready() -> void:
	z_index = 1
	set_process(false)
	queue_redraw()


func _draw() -> void:
	var shed_air := Color(0.165, 0.180, 0.173, 1.0)
	var shed_deeper := Color(0.125, 0.137, 0.133, 1.0)
	var ink := Color(0.110, 0.094, 0.078, 0.85)
	var chalk := Color(0.953, 0.925, 0.855, 0.55)
	var lamp := Color(0.769, 0.643, 0.416, 0.14)

	# Depth planes inside the tear (value step, not a dark rectangle).
	var deep := PackedVector2Array([
		Vector2(-70, -200), Vector2(70, -190), Vector2(86, 200), Vector2(-82, 210),
	])
	draw_colored_polygon(deep, shed_air)
	var inner := PackedVector2Array([
		Vector2(-42, -160), Vector2(48, -150), Vector2(58, 160), Vector2(-50, 170),
	])
	draw_colored_polygon(inner, shed_deeper)

	# Fiber whiskers along both torn margins.
	var rng := RandomNumberGenerator.new()
	rng.seed = 19
	for i in range(14):
		var t: float = float(i) / 13.0
		var y: float = lerpf(-210.0, 220.0, t)
		var lx: float = -90.0 + sin(t * 9.0) * 12.0
		var rx: float = 92.0 + cos(t * 8.0) * 11.0
		var wlen: float = rng.randf_range(7.0, 16.0)
		draw_line(Vector2(lx, y), Vector2(lx - wlen, y + rng.randf_range(-4.0, 4.0)), ink, 1.1, true)
		draw_line(Vector2(rx, y), Vector2(rx + wlen, y + rng.randf_range(-4.0, 4.0)), ink, 1.1, true)

	# Survey ticks — prior failed span scars.
	for i in range(4):
		var ty: float = -140.0 + float(i) * 80.0
		draw_line(Vector2(-108, ty), Vector2(-96, ty), chalk, 1.4, true)
		draw_circle(Vector2(-102, ty), 1.6, Color(ink.r, ink.g, ink.b, 0.45))

	# Contact shadow under a taut stitch path (occlusion across the tear).
	draw_line(Vector2(-88, 8), Vector2(92, 4), Color(0.05, 0.05, 0.04, 0.32), 5.0, true)

	# Single practical lamp — dithered falloff, no bloom.
	draw_circle(Vector2(-210, -180), 90.0, lamp)
	draw_circle(Vector2(-210, -180), 36.0, Color(lamp.r, lamp.g, lamp.b, 0.22))
