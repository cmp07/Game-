extends Node2D
##
## Full-window VOID plane — shed-air drop, not purple cosmos, not East Post Gap shed.
## After a spoken word, a faint paper surface and lamp wash answer underfoot.
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
	# Cool shed-air void — never pure #000, never purple.
	var shed_air := Color(0.145, 0.158, 0.152, 1.0)
	var shed_deep := Color(0.110, 0.122, 0.118, 1.0)
	var ink := Color(0.110, 0.094, 0.078, 0.55)
	var chalk := Color(0.953, 0.925, 0.855, 0.28)
	var page := Color(0.824, 0.769, 0.643, 0.0)
	page.a = 0.18 + _surface * 0.62
	var lamp := Color(0.769, 0.643, 0.416, _lamp * 0.55)
	var rust := Color(0.545, 0.227, 0.122, 0.35 + _surface * 0.25)

	draw_rect(Rect2(0, 0, 1280, 720), shed_air, true)
	# Soft depth wells — physical drop, not starfield.
	_draw_ellipse(Vector2(640, 360), Vector2(420, 260), shed_deep)
	_draw_ellipse(Vector2(640, 380), Vector2(260, 160), Color(0.09, 0.10, 0.095, 0.85))

	# Dust motes in the drop (atmosphere ≤2%).
	var rng := RandomNumberGenerator.new()
	rng.seed = 17
	for i in range(14):
		var p := Vector2(rng.randf_range(80.0, 1200.0), rng.randf_range(60.0, 660.0))
		draw_circle(p, rng.randf_range(0.8, 1.6), Color(chalk.r, chalk.g, chalk.b, 0.12))

	if _surface > 0.02:
		# Answered surface — torn paper island, not a shed deck.
		var island := PackedVector2Array([
			Vector2(340, 250), Vector2(920, 240), Vector2(980, 420),
			Vector2(900, 560), Vector2(400, 570), Vector2(300, 400),
		])
		var fill := Color(page.r, page.g, page.b, page.a)
		draw_colored_polygon(island, fill)
		# Torn edge whiskers.
		for i in range(island.size()):
			var a: Vector2 = island[i]
			var b: Vector2 = island[(i + 1) % island.size()]
			draw_line(a, b, Color(ink.r, ink.g, ink.b, 0.55 + _surface * 0.3), 2.0, true)
			var mid: Vector2 = (a + b) * 0.5
			var n: Vector2 = (b - a).orthogonal().normalized()
			draw_line(mid, mid + n * (6.0 + float(i % 3) * 3.0), ink, 1.1, true)
		# Survey ticks on the new edge.
		for i in range(4):
			var x: float = 420.0 + float(i) * 110.0
			draw_line(Vector2(x, 255), Vector2(x + 14, 255), chalk, 1.5, true)

	# Single practical wash — kiln warmth, no bloom stack.
	draw_circle(Vector2(520, 220), 180.0, lamp)
	draw_circle(Vector2(520, 220), 70.0, Color(lamp.r, lamp.g, lamp.b, lamp.a * 1.4))
	if _surface > 0.4:
		draw_line(Vector2(500, 360), Vector2(780, 360), rust, 1.6, true)


func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(28):
		var a: float = TAU * float(i) / 28.0
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, color)
