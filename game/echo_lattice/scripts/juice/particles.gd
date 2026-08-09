class_name JuiceParticles
extends RefCounted
## Pooled particles: dot / ring / glyph. Port of Vite render/particles.ts.

const MathScript = preload("res://scripts/juice/juice_math.gd")

const POOL_SIZE: int = 800

enum Kind { DOT, RING, GLYPH }

var _pool: Array = []
var _cursor: int = 0


func _init() -> void:
	_pool.resize(POOL_SIZE)
	for i in range(POOL_SIZE):
		_pool[i] = _dead_particle()


func clear() -> void:
	for i in range(POOL_SIZE):
		_pool[i]["alive"] = false


func spawn_dot(opts: Dictionary) -> void:
	var p: Dictionary = _next()
	p["alive"] = true
	p["kind"] = Kind.DOT
	_apply(p, opts)
	p["drag"] = float(opts.get("drag", 2.0))
	p["max_life"] = float(opts.get("max_life", 0.5))
	p["life"] = p["max_life"]
	p["size"] = float(opts.get("size", 2.0))
	p["size_grow"] = float(opts.get("size_grow", 0.0))
	p["rot"] = 0.0
	p["vrot"] = 0.0
	p["color"] = opts.get("color", Color(0.86, 0.90, 1.0))
	p["glow"] = float(opts.get("glow", 1.0))


func spawn_ring(opts: Dictionary) -> void:
	var p: Dictionary = _next()
	p["alive"] = true
	p["kind"] = Kind.RING
	_apply(p, opts)
	p["vx"] = 0.0
	p["vy"] = 0.0
	p["drag"] = 0.0
	p["max_life"] = float(opts.get("max_life", 0.6))
	p["life"] = p["max_life"]
	p["size"] = float(opts.get("size", 4.0))
	p["size_grow"] = float(opts.get("size_grow", 180.0))
	p["rot"] = 0.0
	p["vrot"] = 0.0
	p["color"] = opts.get("color", Color(0.70, 0.86, 1.0))
	p["glow"] = float(opts.get("glow", 0.9))


func spawn_glyph(opts: Dictionary) -> void:
	var p: Dictionary = _next()
	p["alive"] = true
	p["kind"] = Kind.GLYPH
	_apply(p, opts)
	p["drag"] = float(opts.get("drag", 1.2))
	p["max_life"] = float(opts.get("max_life", 0.7))
	p["life"] = p["max_life"]
	p["size"] = float(opts.get("size", 4.0))
	p["size_grow"] = float(opts.get("size_grow", -4.0))
	p["rot"] = randf() * TAU
	p["vrot"] = randf_range(-6.0, 6.0)
	p["color"] = opts.get("color", Color(0.78, 0.94, 1.0))
	p["glow"] = float(opts.get("glow", 1.0))


func burst_sparks(x: float, y: float, n: int, speed: float, color: Color = Color(0.90, 0.94, 1.0)) -> void:
	for i in range(n):
		var a: float = randf() * TAU
		var s: float = randf_range(speed * 0.5, speed)
		spawn_dot({
			"x": x, "y": y,
			"vx": cos(a) * s, "vy": sin(a) * s,
			"max_life": randf_range(0.3, 0.6),
			"size": randf_range(1.4, 2.6),
			"size_grow": -3.0,
			"drag": 3.0,
			"color": color,
			"glow": 1.0,
		})


func burst_echo(x: float, y: float, color: Color = Color(0.67, 0.90, 1.0)) -> void:
	for i in range(5):
		var a: float = randf() * TAU
		var s: float = randf_range(40.0, 110.0)
		spawn_glyph({
			"x": x, "y": y,
			"vx": cos(a) * s, "vy": sin(a) * s,
			"max_life": randf_range(0.35, 0.7),
			"size": randf_range(3.0, 5.0),
			"color": color,
		})
	spawn_ring({
		"x": x, "y": y,
		"size": 3.0,
		"size_grow": 130.0,
		"max_life": 0.4,
		"color": color,
	})


func update(dt: float) -> void:
	for i in range(POOL_SIZE):
		var p: Dictionary = _pool[i]
		if not p["alive"]:
			continue
		p["life"] = float(p["life"]) - dt
		if float(p["life"]) <= 0.0:
			p["alive"] = false
			continue
		var drag: float = float(p["drag"])
		var d: float = exp(-drag * dt)
		p["vx"] = float(p["vx"]) * d
		p["vy"] = float(p["vy"]) * d
		p["x"] = float(p["x"]) + float(p["vx"]) * dt
		p["y"] = float(p["y"]) + float(p["vy"]) * dt
		p["rot"] = float(p["rot"]) + float(p["vrot"]) * dt
		p["size"] = maxf(0.0, float(p["size"]) + float(p["size_grow"]) * dt)


func draw_on(ci: CanvasItem) -> void:
	for i in range(POOL_SIZE):
		var p: Dictionary = _pool[i]
		if not p["alive"]:
			continue
		var t: float = MathScript.clampf01(float(p["life"]) / maxf(0.0001, float(p["max_life"])))
		var fade: float = (t / 0.2 if t < 0.2 else 1.0) * (0.85 * t + 0.15)
		var a: float = fade * float(p["glow"])
		var col: Color = p["color"]
		col.a = a
		var pos := Vector2(float(p["x"]), float(p["y"]))
		var size: float = float(p["size"])
		match int(p["kind"]):
			Kind.DOT:
				var soft := col
				soft.a = a * 0.35
				ci.draw_circle(pos, size * 3.0, soft)
				var core := col
				core.a = a * 0.95
				ci.draw_circle(pos, size, core)
			Kind.RING:
				ci.draw_arc(pos, maxf(0.5, size), 0.0, TAU, 48, col, maxf(0.5, 2.0 * t), true)
			Kind.GLYPH:
				var half: float = size * 0.5
				var pts := PackedVector2Array([
					pos + Vector2(-half, -half).rotated(float(p["rot"])),
					pos + Vector2(half, -half).rotated(float(p["rot"])),
					pos + Vector2(half, half).rotated(float(p["rot"])),
					pos + Vector2(-half, half).rotated(float(p["rot"])),
				])
				ci.draw_colored_polygon(pts, col)
				var edge := col
				edge.a = a * 0.6
				ci.draw_polyline(pts + PackedVector2Array([pts[0]]), edge, 1.0, true)


func alive_count() -> int:
	var n := 0
	for i in range(POOL_SIZE):
		if _pool[i]["alive"]:
			n += 1
	return n


func _apply(p: Dictionary, opts: Dictionary) -> void:
	p["x"] = float(opts.get("x", 0.0))
	p["y"] = float(opts.get("y", 0.0))
	p["vx"] = float(opts.get("vx", 0.0))
	p["vy"] = float(opts.get("vy", 0.0))


func _next() -> Dictionary:
	for i in range(POOL_SIZE):
		_cursor = (_cursor + 1) % POOL_SIZE
		if not _pool[_cursor]["alive"]:
			return _pool[_cursor]
	return _pool[_cursor]


func _dead_particle() -> Dictionary:
	return {
		"alive": false,
		"kind": Kind.DOT,
		"x": 0.0, "y": 0.0, "vx": 0.0, "vy": 0.0,
		"drag": 0.0, "life": 0.0, "max_life": 0.0,
		"size": 0.0, "size_grow": 0.0, "rot": 0.0, "vrot": 0.0,
		"color": Color.WHITE, "glow": 1.0,
	}
