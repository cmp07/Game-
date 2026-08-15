extends Node2D
##
## Shed-yard substrate in field space: canvas, timber decks, posts, seated loom,
## one-lamp wash. Drawn under craft objects. Never purple void, never cream folio.
##

func _ready() -> void:
	z_index = -2
	set_process(false)
	queue_redraw()


func _draw() -> void:
	var page_deep := Color(0.824, 0.769, 0.643, 1.0)
	var timber := Color(0.420, 0.325, 0.251, 1.0)
	var timber_dark := Color(0.322, 0.243, 0.188, 1.0)
	var timber_lit := Color(0.510, 0.400, 0.290, 1.0)
	var ink := Color(0.110, 0.094, 0.078, 0.72)
	var chalk := Color(0.953, 0.925, 0.855, 0.42)
	var shed_air := Color(0.165, 0.180, 0.173, 1.0)
	var lamp := Color(0.769, 0.643, 0.416, 0.16)
	var rust := Color(0.545, 0.227, 0.122, 0.55)

	# Worn walk ellipses on both decks (Ground shader supplies the page).
	_draw_ellipse(Vector2(280, 430), Vector2(170, 70), Color(page_deep.r, page_deep.g, page_deep.b, 0.55))
	_draw_ellipse(Vector2(1000, 430), Vector2(160, 68), Color(page_deep.r, page_deep.g, page_deep.b, 0.5))

	_draw_timber_deck(40.0, 530.0, 80.0, 640.0, timber, timber_dark, timber_lit, ink, true)
	_draw_timber_deck(750.0, 1240.0, 80.0, 640.0, timber, timber_dark, timber_lit, ink, false)

	# Shed posts holding the yard — grounded mass, not UI ticks.
	_draw_post(Vector2(96, 120), timber_dark, ink)
	_draw_post(Vector2(1184, 124), timber_dark, ink)
	_draw_post(Vector2(110, 600), timber_dark, ink)
	_draw_post(Vector2(1170, 596), timber_dark, ink)

	# Seated loom on the right deck — warp + beam, quiet workshop furniture.
	_draw_loom(Vector2(1088, 248), timber_dark, ink, chalk)

	# Single practical lamp (world-space wash; dithered edge, no bloom).
	draw_circle(Vector2(300, 150), 210.0, lamp)
	draw_circle(Vector2(300, 150), 96.0, Color(lamp.r, lamp.g, lamp.b, 0.22))
	draw_circle(Vector2(300, 150), 28.0, Color(0.769, 0.643, 0.416, 0.18))
	_dither_ring(Vector2(300, 150), 96.0, 210.0, Color(0.769, 0.643, 0.416, 0.08))

	# Survey ticks / failed-span scars toward the tear.
	for i in range(5):
		var y: float = 140.0 + float(i) * 90.0
		draw_line(Vector2(508, y), Vector2(528, y), chalk, 1.6, true)
		draw_circle(Vector2(518, y), 2.0, Color(ink.r, ink.g, ink.b, 0.4))
		draw_line(Vector2(752, y + 8.0), Vector2(772, y + 8.0), chalk, 1.5, true)

	# Nail holes from a prior span.
	var nails := PackedVector2Array([
		Vector2(522, 210), Vector2(526, 330), Vector2(514, 470),
		Vector2(758, 224), Vector2(766, 360), Vector2(754, 500),
	])
	for p in nails:
		draw_circle(p, 2.4, shed_air)
		draw_arc(p, 3.2, 0.0, TAU, 8, ink, 1.0, true)

	# Rust tick on one post — kiln accent ≤5%.
	draw_line(Vector2(96, 148), Vector2(96, 168), rust, 2.0, true)

	# Fiber whiskers on the canvas margin.
	var rng := RandomNumberGenerator.new()
	rng.seed = 41
	for i in range(18):
		var x: float = rng.randf_range(20.0, 1260.0)
		draw_line(Vector2(x, 12.0), Vector2(x + rng.randf_range(-6.0, 6.0), rng.randf_range(16.0, 28.0)), ink, 1.0, true)


func _draw_timber_deck(
		x0: float, x1: float, y0: float, y1: float,
		timber: Color, timber_dark: Color, timber_lit: Color, ink: Color,
		left_side: bool
) -> void:
	var board_h := 26.0
	var y: float = y0
	var n := 0
	while y < y1:
		var h: float = minf(board_h, y1 - y)
		var tint: Color = timber if (n % 2 == 0) else timber_dark
		if n % 5 == 0:
			tint = timber_lit
		var inner_x: float = x1 if left_side else x0
		# Deckle the gap edge so boards don't meet in a perfect cut.
		var jag: float = sin(y * 0.07) * 10.0 + cos(y * 0.13) * 6.0
		if left_side:
			inner_x = x1 + jag
		else:
			inner_x = x0 + jag
		var poly := PackedVector2Array([
			Vector2(x0, y), Vector2(inner_x, y + 1.0),
			Vector2(inner_x, y + h), Vector2(x0, y + h - 1.0),
		])
		if not left_side:
			poly = PackedVector2Array([
				Vector2(inner_x, y), Vector2(x1, y + 1.0),
				Vector2(x1, y + h), Vector2(inner_x, y + h - 1.0),
			])
		draw_colored_polygon(poly, tint)
		draw_line(Vector2(x0 if left_side else inner_x, y + h), Vector2(inner_x if left_side else x1, y + h), Color(ink.r, ink.g, ink.b, 0.35), 1.2, true)
		# End grain at the tear.
		var ex: float = inner_x
		draw_line(Vector2(ex, y + 3.0), Vector2(ex, y + h - 3.0), Color(ink.r, ink.g, ink.b, 0.55), 2.0, true)
		for k in range(3):
			var gy: float = y + 6.0 + float(k) * (h / 4.0)
			draw_line(Vector2(ex - 5.0, gy), Vector2(ex + 5.0, gy), Color(ink.r, ink.g, ink.b, 0.28), 1.0, true)
		y += board_h
		n += 1


func _draw_post(at: Vector2, timber_dark: Color, ink: Color) -> void:
	var body := PackedVector2Array([
		at + Vector2(-9, -22), at + Vector2(9, -22),
		at + Vector2(11, 28), at + Vector2(-11, 28),
	])
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-6, 26), at + Vector2(14, 30), at + Vector2(12, 36), at + Vector2(-10, 34),
	]), Color(0.05, 0.05, 0.04, 0.28))
	draw_colored_polygon(body, timber_dark)
	var closed := PackedVector2Array(body)
	closed.append(body[0])
	draw_polyline(closed, ink, 1.3, true)
	draw_line(at + Vector2(-6, -8), at + Vector2(6, -8), ink, 1.1, true)


func _draw_loom(at: Vector2, timber_dark: Color, ink: Color, chalk: Color) -> void:
	# Uprights
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-42, -48), at + Vector2(-32, -48), at + Vector2(-30, 40), at + Vector2(-44, 40),
	]), timber_dark)
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(32, -48), at + Vector2(42, -48), at + Vector2(44, 40), at + Vector2(30, 40),
	]), timber_dark)
	# Beam
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-46, -52), at + Vector2(46, -50), at + Vector2(44, -38), at + Vector2(-48, -40),
	]), Color(0.38, 0.29, 0.22, 1.0))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-8, 26), at + Vector2(22, 30), at + Vector2(18, 36), at + Vector2(-14, 34),
	]), Color(0.05, 0.05, 0.04, 0.26))
	for i in range(7):
		var t: float = float(i) / 6.0
		var x: float = lerpf(-28.0, 28.0, t)
		draw_line(at + Vector2(x, -38), at + Vector2(x * 0.9, 28), Color(ink.r, ink.g, ink.b, 0.55), 1.15, true)
	draw_line(at + Vector2(-30, 8), at + Vector2(30, 10), chalk, 1.2, true)


func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(18):
		var a: float = TAU * float(i) / 18.0
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, color)


func _dither_ring(center: Vector2, inner: float, outer: float, color: Color) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in range(90):
		var a: float = rng.randf() * TAU
		var r: float = rng.randf_range(inner, outer)
		var p := center + Vector2(cos(a), sin(a)) * r
		if int(p.x + p.y * 3.0) % 3 == 0:
			draw_rect(Rect2(p, Vector2(2, 2)), color, true)
