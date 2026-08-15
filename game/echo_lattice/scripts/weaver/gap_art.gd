extends Node2D
##
## True void well at East Post Gap — deep black with depth + first light.
## Evolving geometry fills from player acts. Not a shed. Not board ends. Not workshop air.
##

var fill_level: float = 0.0
var first_light: float = 0.08
var _pulse: float = 0.0


func _ready() -> void:
	z_index = 1
	set_process(true)
	queue_redraw()


func set_creation_state(fill: float, light: float) -> void:
	fill_level = clampf(fill, 0.0, 1.0)
	first_light = clampf(light, 0.0, 1.0)
	queue_redraw()


func _process(delta: float) -> void:
	_pulse += delta
	if first_light > 0.05 and fill_level < 0.98 and int(_pulse * 5.0) % 2 == 0:
		queue_redraw()


func _draw() -> void:
	var void_far := Color(0.012, 0.014, 0.022, 1.0)
	var void_mid := Color(0.028, 0.034, 0.048, 1.0)
	var void_deep := Color(0.008, 0.010, 0.016, 1.0)
	var rim := Color(0.14, 0.16, 0.20, 0.55)
	var light := Color(0.92, 0.90, 0.84, 1.0)
	var geo := Color(0.78, 0.84, 0.92, 0.55)

	# Depth planes into true void (value steps toward black — not a dark rectangle).
	draw_colored_polygon(PackedVector2Array([
		Vector2(-140, -270), Vector2(140, -258), Vector2(150, 268), Vector2(-150, 278),
	]), void_far)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-95, -210), Vector2(98, -198), Vector2(108, 210), Vector2(-102, 222),
	]), void_mid)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-52, -150), Vector2(56, -140), Vector2(62, 152), Vector2(-58, 162),
	]), void_deep)

	# Soft rim — geometric, not frayed board ends.
	draw_polyline(PackedVector2Array([
		Vector2(-118, -240), Vector2(-70, -120), Vector2(-110, -4),
		Vector2(-78, 100), Vector2(-120, 240),
	]), rim, 1.4, true)
	draw_polyline(PackedVector2Array([
		Vector2(118, -230), Vector2(74, -100), Vector2(112, 4),
		Vector2(82, 110), Vector2(122, 232),
	]), rim, 1.4, true)

	# First light ember in the well.
	var la: float = first_light
	draw_circle(Vector2(0, -10), 54.0 + la * 40.0, Color(light.r, light.g, light.b, la * 0.06))
	draw_circle(Vector2(0, -10), 22.0 + la * 18.0, Color(light.r, light.g, light.b, la * 0.12))
	draw_circle(Vector2(0, -10), 5.0 + la * 4.0, Color(light.r, light.g, light.b, 0.2 + la * 0.45))

	# Dust motes as depth scale (sparse points — not Fragment orbs).
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for i in range(8):
		var p := Vector2(rng.randf_range(-40.0, 40.0), rng.randf_range(-110.0, 130.0))
		draw_rect(Rect2(p, Vector2(1.2, 1.2)), Color(light.r, light.g, light.b, 0.12 + la * 0.15), true)

	# Geometry grows into the void as the player creates.
	if fill_level >= 0.15:
		var n: int = clampi(int(fill_level * 12.0), 2, 10)
		for i in range(n):
			var t: float = float(i) / float(maxi(n - 1, 1))
			var y: float = lerpf(-180.0, 180.0, t)
			var reach: float = 18.0 + fill_level * 70.0
			var wobble: float = sin(t * 9.0 + _pulse * 0.4) * 6.0
			draw_line(Vector2(-90.0 + wobble, y), Vector2(-90.0 + reach, y * 0.15), Color(geo.r, geo.g, geo.b, 0.2 + fill_level * 0.4), 1.2, true)
			draw_line(Vector2(90.0 - wobble, y), Vector2(90.0 - reach, y * 0.15), Color(geo.r, geo.g, geo.b, 0.2 + fill_level * 0.4), 1.2, true)

	if fill_level >= 0.45:
		# Bridging filament — light geometry, not timber.
		draw_line(Vector2(-100, 8), Vector2(100, 2), Color(light.r, light.g, light.b, 0.25 + fill_level * 0.45), 1.5 + fill_level * 2.0, true)
		draw_line(Vector2(-80, 22), Vector2(80, 18), Color(geo.r, geo.g, geo.b, 0.15 + fill_level * 0.25), 1.0, true)

	if fill_level >= 0.85:
		# Settled mesh plate inside the well.
		var mesh := PackedVector2Array([
			Vector2(-110, -16), Vector2(110, -22), Vector2(118, 28), Vector2(-116, 32),
		])
		draw_colored_polygon(mesh, Color(geo.r, geo.g, geo.b, 0.22 + (fill_level - 0.85) * 1.2))
		for k in range(4):
			var x: float = -70.0 + float(k) * 46.0
			draw_line(Vector2(x, -14), Vector2(x * 0.92, 24), Color(light.r, light.g, light.b, 0.35), 1.1, true)
