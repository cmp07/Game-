extends Node2D
##
## Full-window STARRY BLACK VOID — the play plane, not a cream folio page.
## Nested polygons / islands appear only as created matter after a spoken word.
##

var _surface: float = 0.0
var _lamp: float = 0.12
var _word: String = ""


func _ready() -> void:
	z_index = -2
	set_process(false)
	queue_redraw()


func set_answer(surface: float, lamp: float, word: String) -> void:
	_surface = clampf(surface, 0.0, 1.0)
	_lamp = clampf(lamp, 0.0, 1.0)
	_word = word


func _draw() -> void:
	# Overscan so COVER-zoom never reveals a cream/grey gutter.
	var far := Color(0.020, 0.023, 0.039, 1.0)
	var near := Color(0.047, 0.063, 0.094, 1.0)
	var star := Color(0.953, 0.925, 0.855, 1.0)
	draw_rect(Rect2(-2400, -1800, 6400, 4800), far, true)
	_draw_ellipse(Vector2(640, 380), Vector2(520, 320), near)
	_draw_stars(star)

	var page := Color(0.824, 0.769, 0.643, 0.0)
	page.a = 0.10 + _surface * 0.55
	var lamp := Color(0.769, 0.643, 0.416, _lamp * 0.45)
	var rust := Color(0.545, 0.227, 0.122, 0.40 + _surface * 0.25)
	var ink := Color(0.110, 0.094, 0.078, 0.70)
	var chalk := Color(0.953, 0.925, 0.855, 0.35)

	if _surface > 0.02:
		# Created matter — torn island inside the void, never a UI skin.
		var island := PackedVector2Array([
			Vector2(340, 250), Vector2(920, 240), Vector2(980, 420),
			Vector2(900, 560), Vector2(400, 570), Vector2(300, 400),
		])
		draw_colored_polygon(island, Color(page.r, page.g, page.b, page.a))
		for i in range(island.size()):
			var a: Vector2 = island[i]
			var b: Vector2 = island[(i + 1) % island.size()]
			draw_line(a, b, Color(ink.r, ink.g, ink.b, 0.55 + _surface * 0.3), 2.0, true)
			var mid: Vector2 = (a + b) * 0.5
			var n: Vector2 = (b - a).orthogonal().normalized()
			draw_line(mid, mid + n * (6.0 + float(i % 3) * 3.0), ink, 1.1, true)
		for i in range(4):
			var x: float = 420.0 + float(i) * 110.0
			draw_line(Vector2(x, 255), Vector2(x + 14, 255), chalk, 1.5, true)

	draw_circle(Vector2(520, 220), 180.0, lamp)
	draw_circle(Vector2(520, 220), 70.0, Color(lamp.r, lamp.g, lamp.b, lamp.a * 1.4))
	if _surface > 0.4:
		draw_line(Vector2(500, 360), Vector2(780, 360), rust, 1.6, true)


func _draw_stars(star: Color) -> void:
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
