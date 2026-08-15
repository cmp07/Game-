extends Node2D
## Full-window starry black void — shared visual identity with Lattice void_boot.


func _ready() -> void:
	z_index = -8
	queue_redraw()


func _draw() -> void:
	var far := Color(0.020, 0.023, 0.039, 1.0)
	var near := Color(0.047, 0.063, 0.094, 1.0)
	var star := Color(0.953, 0.925, 0.855, 1.0)
	draw_rect(Rect2(-2400, -1800, 6400, 4800), far, true)
	_draw_ellipse(Vector2(640, 380), Vector2(520, 320), near)
	var rng := RandomNumberGenerator.new()
	rng.seed = 17
	for i in range(86):
		var p := Vector2(rng.randf_range(-400.0, 1680.0), rng.randf_range(-280.0, 1000.0))
		var a: float = rng.randf_range(0.18, 0.72)
		draw_circle(p, rng.randf_range(0.6, 1.7), Color(star.r, star.g, star.b, a))
	rng.seed = 91
	for j in range(18):
		var q := Vector2(rng.randf_range(40.0, 1240.0), rng.randf_range(30.0, 690.0))
		draw_circle(q, rng.randf_range(1.4, 2.2), Color(star.r, star.g, star.b, 0.85))


func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(28):
		var a: float = TAU * float(i) / 28.0
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, color)
