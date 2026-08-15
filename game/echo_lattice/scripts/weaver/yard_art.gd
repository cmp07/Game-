extends Node2D
##
## True void substrate for East Post Gap — deep black with depth.
## Geometry and first light grow from player acts. Not a shed. Not timber.
## Never purple nebula / circle-loot on flat black.
##

## 0 = empty void · 1 = creation filled the field
var fill_level: float = 0.0
## Ambient first-light strength (rises with recover / combine / weave)
var first_light: float = 0.07
var _pulse: float = 0.0


func _ready() -> void:
	z_index = -2
	set_process(true)
	queue_redraw()


func set_creation_state(fill: float, light: float) -> void:
	fill_level = clampf(fill, 0.0, 1.0)
	first_light = clampf(light, 0.0, 1.0)
	queue_redraw()


func _process(delta: float) -> void:
	_pulse += delta
	# Idle redraw only while light is waking — quiet once fully dark or seated.
	if first_light > 0.05 and fill_level < 0.98 and int(_pulse * 6.0) % 2 == 0:
		queue_redraw()


func _draw() -> void:
	var void_far := Color(0.015, 0.018, 0.028, 1.0)
	var void_mid := Color(0.035, 0.042, 0.058, 1.0)
	var void_near := Color(0.055, 0.065, 0.085, 1.0)
	var rim := Color(0.090, 0.105, 0.130, 0.55)
	var light := Color(0.90, 0.88, 0.82, first_light * 0.55)
	var geo := Color(0.72, 0.78, 0.86, 0.22 + fill_level * 0.55)
	var geo_bright := Color(0.92, 0.90, 0.84, 0.15 + fill_level * 0.45)

	# Depth wells — authored value steps, not a flat black bag.
	_draw_ellipse(Vector2(640, 360), Vector2(780, 420), void_far)
	_draw_ellipse(Vector2(640, 370), Vector2(520, 300), void_mid)
	_draw_ellipse(Vector2(640, 360), Vector2(300, 190), void_near)

	# Soft horizon bands — sell depth without architecture.
	for i in range(5):
		var t: float = float(i) / 4.0
		var y: float = lerpf(80.0, 640.0, t)
		var a: float = 0.04 + (1.0 - t) * 0.06
		draw_line(Vector2(40, y), Vector2(1240, y + sin(t * 3.0) * 4.0), Color(rim.r, rim.g, rim.b, a), 1.0, true)

	# First light — single soft ember, grows with creation (no bloom stack).
	var lx := 640.0
	var ly := 300.0 - fill_level * 20.0
	var r0: float = 28.0 + first_light * 90.0
	draw_circle(Vector2(lx, ly), r0 * 2.4, Color(light.r, light.g, light.b, first_light * 0.08))
	draw_circle(Vector2(lx, ly), r0 * 1.2, Color(light.r, light.g, light.b, first_light * 0.14))
	draw_circle(Vector2(lx, ly), r0 * 0.35, Color(light.r, light.g, light.b, first_light * 0.35))

	# Evolving geometry from player acts — seeds → ribs → lattice.
	_draw_creation_geometry(geo, geo_bright)


func _draw_creation_geometry(geo: Color, geo_bright: Color) -> void:
	if fill_level < 0.02:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 17

	# Recover phase — sparse angular seeds (not discs).
	var seed_n: int = clampi(int(fill_level * 10.0), 1, 8)
	for i in range(seed_n):
		var ang: float = float(i) * TAU / float(seed_n) + _pulse * 0.08
		var rad: float = 120.0 + float(i) * 38.0
		var p := Vector2(640, 360) + Vector2(cos(ang), sin(ang) * 0.72) * rad
		var s: float = 4.0 + fill_level * 6.0
		var diamond := PackedVector2Array([
			p + Vector2(0, -s), p + Vector2(s * 0.7, 0),
			p + Vector2(0, s), p + Vector2(-s * 0.7, 0),
		])
		draw_colored_polygon(diamond, Color(geo.r, geo.g, geo.b, 0.35 + fill_level * 0.4))

	# Thread phase — luminous ribs across the void.
	if fill_level >= 0.28:
		var taut := PackedVector2Array([
			Vector2(220, 380), Vector2(480, 340 + sin(_pulse) * 2.0),
			Vector2(640, 332), Vector2(800, 342), Vector2(1060, 372),
		])
		draw_polyline(taut, Color(geo_bright.r, geo_bright.g, geo_bright.b, 0.35 + fill_level * 0.4), 1.6 + fill_level * 2.0, true)
		# Secondary echo rib.
		var echo := PackedVector2Array([
			Vector2(260, 430), Vector2(640, 410), Vector2(1020, 428),
		])
		draw_polyline(echo, Color(geo.r, geo.g, geo.b, 0.18 + fill_level * 0.25), 1.1, true)

	# Structure phase — lattice fills the void.
	if fill_level >= 0.72:
		var lattice_a: float = (fill_level - 0.72) / 0.28
		for i in range(7):
			var x: float = 280.0 + float(i) * 110.0
			draw_line(
				Vector2(x, 160.0),
				Vector2(x + (x - 640.0) * -0.08, 560.0),
				Color(geo.r, geo.g, geo.b, 0.12 + lattice_a * 0.35),
				1.0 + lattice_a,
				true
			)
		for j in range(5):
			var y: float = 200.0 + float(j) * 80.0
			draw_line(
				Vector2(200, y),
				Vector2(1080, y + sin(float(j) + _pulse * 0.2) * 3.0),
				Color(geo_bright.r, geo_bright.g, geo_bright.b, 0.08 + lattice_a * 0.28),
				1.0,
				true
			)
		# Settled span mass — luminous geometry, not a plank.
		var span := PackedVector2Array([
			Vector2(300, 330), Vector2(980, 322), Vector2(990, 358), Vector2(290, 368),
		])
		draw_colored_polygon(span, Color(geo_bright.r, geo_bright.g, geo_bright.b, 0.18 + lattice_a * 0.4))


func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(28):
		var a: float = TAU * float(i) / 28.0
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, color)
