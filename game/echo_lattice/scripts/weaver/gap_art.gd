extends Node2D
##
## Diegetic gap craft — torn edge, shed-air depth, occlusion, lamp tell.
## Local space of VoidGap. Never purple void, never circles-on-black.
##

func _ready() -> void:
	z_index = 1
	set_process(false)
	queue_redraw()


func _draw() -> void:
	var shed_air := Color(0.165, 0.180, 0.173, 1.0)
	var shed_mid := Color(0.145, 0.156, 0.152, 1.0)
	var shed_deeper := Color(0.118, 0.129, 0.125, 1.0)
	var ink := Color(0.110, 0.094, 0.078, 0.88)
	var chalk := Color(0.953, 0.925, 0.855, 0.55)
	var timber := Color(0.322, 0.243, 0.188, 1.0)
	var shadow := Color(0.05, 0.05, 0.04, 0.38)

	# Depth planes (value step, not a dark rectangle). Cooler air, never #000 / purple.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-118, -250), Vector2(122, -238), Vector2(132, 248), Vector2(-128, 258),
	]), shed_air)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-78, -200), Vector2(82, -188), Vector2(94, 200), Vector2(-88, 212),
	]), shed_mid)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-42, -150), Vector2(48, -140), Vector2(56, 152), Vector2(-50, 162),
	]), shed_deeper)

	# Occlusion under the future span path.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-96, -6), Vector2(98, -14), Vector2(102, 18), Vector2(-92, 22),
	]), shadow)

	# Splintered plank ends along both margins.
	var rng := RandomNumberGenerator.new()
	rng.seed = 19
	for i in range(16):
		var t: float = float(i) / 15.0
		var y: float = lerpf(-230.0, 236.0, t)
		var lx: float = -98.0 + sin(t * 9.0) * 14.0
		var rx: float = 96.0 + cos(t * 8.0) * 13.0
		var wlen: float = rng.randf_range(8.0, 20.0)
		draw_line(Vector2(lx, y), Vector2(lx - wlen, y + rng.randf_range(-5.0, 5.0)), ink, 1.15, true)
		draw_line(Vector2(rx, y), Vector2(rx + wlen, y + rng.randf_range(-5.0, 5.0)), ink, 1.15, true)
		if i % 3 == 0:
			var splinter := PackedVector2Array([
				Vector2(lx, y - 4.0), Vector2(lx + 6.0, y), Vector2(lx, y + 5.0), Vector2(lx - 10.0, y + 1.0),
			])
			draw_colored_polygon(splinter, timber)

	# Survey ticks + nail holes (prior failed span).
	for i in range(5):
		var ty: float = -150.0 + float(i) * 72.0
		draw_line(Vector2(-118, ty), Vector2(-100, ty), chalk, 1.5, true)
		draw_circle(Vector2(-108, ty), 1.7, Color(ink.r, ink.g, ink.b, 0.5))
		draw_circle(Vector2(108, ty + 10.0), 2.2, shed_deeper)

	# Sparse dust in the drop (scale cue, ≤2%).
	rng.seed = 3
	for i in range(10):
		var p := Vector2(rng.randf_range(-36.0, 36.0), rng.randf_range(-120.0, 140.0))
		draw_circle(p, rng.randf_range(0.8, 1.6), Color(chalk.r, chalk.g, chalk.b, 0.22))
