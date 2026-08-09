extends Node
##
## Runtime PNG loader + shared drawing helpers for VISUAL v2.
## Loads art/ PNGs without depending on editor .import files (headless-safe).
## Paper grain is baked once per seed into a tiled ImageTexture — never thousands
## of 1×1 draw_rect calls per frame (see docs/AUDIT/PERFORMANCE.md §1).
##

const GRAIN_TILE: int = 256
const GRAIN_STEP: int = 6
const GRAIN_DENSITY: float = 0.18

var _cache: Dictionary = {}
var _grain_cache: Dictionary = {}  ## seed (int) -> ImageTexture


func _ready() -> void:
	# Warm the seeds used by chamber + menu so the first draw never bakes mid-frame.
	for s in [3, 11, 19, 42]:
		grain_texture(int(s))


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


func grain_texture(seed: int = 7) -> ImageTexture:
	## Pre-bake Field Ledger ink speckles for a seed. Opacity is applied at draw time.
	if _grain_cache.has(seed):
		return _grain_cache[seed]
	var img := Image.create(GRAIN_TILE, GRAIN_TILE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var ink: Color = Palette.INK_SOFT
	var speck := Color(ink.r, ink.g, ink.b, 1.0)
	var y: int = 0
	while y < GRAIN_TILE:
		var x: int = 0
		while x < GRAIN_TILE:
			if rng.randf() < GRAIN_DENSITY:
				img.set_pixel(x, y, speck)
			x += GRAIN_STEP
		y += GRAIN_STEP
	var tex: ImageTexture = ImageTexture.create_from_image(img)
	_grain_cache[seed] = tex
	return tex


func has_baked_grain(seed: int = 7) -> bool:
	return _grain_cache.has(seed) and _grain_cache[seed] != null


func baked_grain_seed_count() -> int:
	return _grain_cache.size()


func draw_paper_grain(canvas: CanvasItem, rect: Rect2, seed: int = 7, opacity: float = 0.07) -> void:
	## One tiled blit per grain layer — keeps the Field Ledger paper look without
	## regenerating ~4.7k canvas rects every frame.
	if rect.size.x < 1.0 or rect.size.y < 1.0:
		return
	var tex: ImageTexture = grain_texture(seed)
	if tex == null:
		return
	var mod := Color(1, 1, 1, opacity)
	var tw: float = float(tex.get_width())
	var th: float = float(tex.get_height())
	var y: float = rect.position.y
	while y < rect.end.y - 0.001:
		var x: float = rect.position.x
		var h: float = minf(th, rect.end.y - y)
		while x < rect.end.x - 0.001:
			var w: float = minf(tw, rect.end.x - x)
			canvas.draw_texture_rect_region(
				tex,
				Rect2(x, y, w, h),
				Rect2(0.0, 0.0, w, h),
				mod
			)
			x += tw
		y += th


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
