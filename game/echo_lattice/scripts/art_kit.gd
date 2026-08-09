extends Node
##
## Runtime PNG loader + shared drawing helpers for VISUAL v2.
## Loads art/ PNGs without depending on editor .import files (headless-safe).
##

var _cache: Dictionary = {}


func tex(path: String) -> Texture2D:
	if _cache.has(path):
		return _cache[path]
	var abs_path: String = ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(path) and not FileAccess.file_exists(abs_path):
		push_warning("ArtKit missing: %s" % path)
		return null
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		f = FileAccess.open(abs_path, FileAccess.READ)
	if f == null:
		push_warning("ArtKit open failed: %s" % path)
		return null
	var buf: PackedByteArray = f.get_buffer(f.get_length())
	var img := Image.new()
	var err: Error = img.load_png_from_buffer(buf)
	if err != OK:
		push_warning("ArtKit decode failed: %s (%s)" % [path, err])
		return null
	var t: ImageTexture = ImageTexture.create_from_image(img)
	_cache[path] = t
	return t


func draw_paper_grain(canvas: CanvasItem, rect: Rect2, seed: int = 7, opacity: float = 0.07) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var step: int = 6
	var x: int = int(rect.position.x)
	var y: int = int(rect.position.y)
	var x2: int = int(rect.end.x)
	var y2: int = int(rect.end.y)
	var c: Color = Palette.INK_SOFT
	c.a = opacity
	while y < y2:
		var xx: int = x
		while xx < x2:
			if rng.randf() < 0.18:
				canvas.draw_rect(Rect2(xx, y, 1, 1), c, true)
			xx += step
		y += step


func draw_ledger_grid(canvas: CanvasItem, rect: Rect2, cell: int = 32) -> void:
	var c: Color = Palette.INK_SOFT
	c.a = 0.10
	var x: float = rect.position.x
	while x <= rect.end.x:
		canvas.draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), c, 1.0)
		x += cell
	var y: float = rect.position.y
	while y <= rect.end.y:
		canvas.draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), c, 1.0)
		y += cell


func draw_dashed_line(canvas: CanvasItem, a: Vector2, b: Vector2, color: Color, width: float = 1.0, dash: float = 5.0, gap: float = 4.0) -> void:
	var delta: Vector2 = b - a
	var length: float = delta.length()
	if length < 0.001:
		return
	var dir: Vector2 = delta / length
	var t: float = 0.0
	var draw_on := true
	while t < length:
		var seg: float = dash if draw_on else gap
		var t2: float = minf(t + seg, length)
		if draw_on:
			canvas.draw_line(a + dir * t, a + dir * t2, color, width, true)
		draw_on = not draw_on
		t = t2
