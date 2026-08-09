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
	## Major cell grid (default 32). Prefer draw_page_fiber_grid for V3 4 px sub-grid.
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


func draw_page_fiber_grid(canvas: CanvasItem, rect: Rect2, major_cell: int = 32) -> void:
	## ART_DIRECTION_V3 §2.1 — 4 px ledger sub-grid @ ~6% + major cell accents.
	## CPU canvas only (no shader rewrite).
	var fine: Color = Palette.INK_SOFT
	fine.a = 0.06
	var step: float = 4.0
	var x: float = rect.position.x
	while x <= rect.end.x + 0.001:
		canvas.draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), fine, 1.0)
		x += step
	var y: float = rect.position.y
	while y <= rect.end.y + 0.001:
		canvas.draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), fine, 1.0)
		y += step
	if major_cell > 4:
		var major: Color = Palette.INK_SOFT
		major.a = 0.10
		x = rect.position.x
		while x <= rect.end.x + 0.001:
			canvas.draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), major, 1.0)
			x += float(major_cell)
		y = rect.position.y
		while y <= rect.end.y + 0.001:
			canvas.draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), major, 1.0)
			y += float(major_cell)


func draw_desk_margin(canvas: CanvasItem, vp: Vector2, grain_seed: int = 11, grain_a: float = 0.05) -> void:
	## Cool-neutral desk / lightbox under the ledger page (paper_margin wash).
	canvas.draw_rect(Rect2(Vector2.ZERO, vp), Palette.PAPER_MARGIN, true)
	draw_paper_grain(canvas, Rect2(Vector2.ZERO, vp), grain_seed, grain_a)


func draw_ledger_page(
	canvas: CanvasItem,
	page: Rect2,
	opts: Dictionary = {}
) -> void:
	## Shared page substrate for chamber + menu (V3 page anatomy, CPU path).
	## opts: shadow_off, grain_seed, grain_a, major_cell, rule_w, spine, double_rule
	var shadow_off: Vector2 = opts.get("shadow_off", Vector2(5, 7))
	var grain_seed: int = int(opts.get("grain_seed", 42))
	var grain_a: float = float(opts.get("grain_a", 0.08))
	var major_cell: int = int(opts.get("major_cell", 16))
	var rule_w: float = float(opts.get("rule_w", 2.0))
	var spine: bool = bool(opts.get("spine", false))
	var double_rule: bool = bool(opts.get("double_rule", true))

	canvas.draw_rect(Rect2(page.position + shadow_off, page.size), Palette.PAPER_SHADOW, true)
	canvas.draw_rect(page, Palette.PAPER_BONE, true)
	if spine:
		var spine_r := Rect2(page.position, Vector2(14.0, page.size.y))
		canvas.draw_rect(spine_r, Palette.PAPER_DEEP, true)
		canvas.draw_line(
			page.position + Vector2(14.0, 0.0),
			page.position + Vector2(14.0, page.size.y),
			Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.55),
			1.0
		)
	draw_page_fiber_grid(canvas, page, major_cell)
	draw_paper_grain(canvas, page, grain_seed, grain_a)
	canvas.draw_rect(page, Palette.INK_SOFT, false, rule_w)
	if double_rule:
		canvas.draw_rect(
			page.grow(-3.0),
			Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.5),
			false,
			1.0
		)


func draw_index_card(canvas: CanvasItem, card: Rect2, opts: Dictionary = {}) -> void:
	## Physical Field Index plate (ART_DIRECTION_V3 §6.1).
	## Contact shadow + paper_deep lift + bone face + fiber + letterpress rules +
	## binder holes. opts: alpha, shadow_off, binder_holes, grain_seed, grain_a,
	## folio_marks, ruled.
	var alpha: float = clampf(float(opts.get("alpha", 1.0)), 0.0, 1.0)
	if alpha <= 0.001:
		return
	var shadow_off: Vector2 = opts.get("shadow_off", Vector2(5, 7))
	var binder_holes: int = int(opts.get("binder_holes", 5))
	var grain_seed: int = int(opts.get("grain_seed", 23))
	var grain_a: float = float(opts.get("grain_a", 0.055))
	var folio_marks: bool = bool(opts.get("folio_marks", true))
	var ruled: bool = bool(opts.get("ruled", false))

	# Soft contact shadow (ink multiply feel — never glass glow).
	var shadow := Color(
		Palette.INK_BLACK.r, Palette.INK_BLACK.g, Palette.INK_BLACK.b, 0.22 * alpha
	)
	canvas.draw_rect(Rect2(card.position + shadow_off, card.size), shadow, true)
	# paper_deep backer — slight thickness / lift under the bone face.
	var deep := Color(Palette.PAPER_DEEP.r, Palette.PAPER_DEEP.g, Palette.PAPER_DEEP.b, alpha)
	canvas.draw_rect(Rect2(card.position + Vector2(2, 2), card.size), deep, true)
	var bone := Color(Palette.PAPER_BONE.r, Palette.PAPER_BONE.g, Palette.PAPER_BONE.b, alpha)
	canvas.draw_rect(card, bone, true)
	# Micro fiber + faint horizontal rules (index-card stock).
	draw_paper_grain(canvas, card, grain_seed, grain_a * alpha)
	if ruled:
		var rule_c := Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.08 * alpha)
		var ry: float = card.position.y + 52.0
		while ry < card.end.y - 16.0:
			canvas.draw_line(
				Vector2(card.position.x + 28.0, ry),
				Vector2(card.end.x - 14.0, ry),
				rule_c,
				1.0
			)
			ry += 28.0
	# Letterpress outer + inner hairline.
	var ink := Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, alpha)
	canvas.draw_rect(card, ink, false, 1.5)
	canvas.draw_rect(
		card.grow(-3.0),
		Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.45 * alpha),
		false,
		1.0
	)
	# Binder holes — punched stock, not skeuomorphic chrome.
	if binder_holes > 0 and card.size.y > 80.0:
		var hole_step: float = maxf(48.0, (card.size.y - 56.0) / float(maxi(binder_holes - 1, 1)))
		for i in range(binder_holes):
			var hy: float = card.position.y + 30.0 + float(i) * hole_step
			if hy > card.end.y - 22.0:
				break
			var hx: float = card.position.x + 12.0
			canvas.draw_circle(
				Vector2(hx, hy),
				3.6,
				Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.85 * alpha)
			)
			canvas.draw_circle(Vector2(hx, hy), 2.0, bone)
	# Folio registration ticks — surveyor's corner marks.
	if folio_marks:
		var tick := Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.7 * alpha)
		var tl: Vector2 = card.position + Vector2(18, 10)
		var tr: Vector2 = Vector2(card.end.x - 14.0, card.position.y + 10.0)
		canvas.draw_line(tl, tl + Vector2(10, 0), tick, 1.0)
		canvas.draw_line(tl, tl + Vector2(0, 8), tick, 1.0)
		canvas.draw_line(tr, tr + Vector2(-10, 0), tick, 1.0)
		canvas.draw_line(tr, tr + Vector2(0, 8), tick, 1.0)


func draw_letterpress_wall(
	canvas: CanvasItem,
	rect: Rect2,
	fossil: bool = false,
	paper_sides: int = 15
) -> void:
	## Fresh ink / fossil wall with letterpress squash — 1 px ink_soft hairline
	## on the paper side only (bitflags: 1=N 2=E 4=S 8=W). Avoids thickening
	## joins when two wall rects abut. CPU path — no shader rewrite.
	var fill: Color = Palette.RUST_FOSSIL if fossil else Palette.INK_BLACK
	canvas.draw_rect(rect, fill, true)
	var hair: Color = Palette.INK_SOFT
	hair.a = 0.85 if not fossil else 0.65
	var x0: float = rect.position.x
	var y0: float = rect.position.y
	var x1: float = rect.end.x
	var y1: float = rect.end.y
	if paper_sides & 1:
		canvas.draw_line(Vector2(x0, y0 - 1.0), Vector2(x1, y0 - 1.0), hair, 1.0)
	if paper_sides & 4:
		canvas.draw_line(Vector2(x0, y1 + 1.0), Vector2(x1, y1 + 1.0), hair, 1.0)
	if paper_sides & 8:
		canvas.draw_line(Vector2(x0 - 1.0, y0), Vector2(x0 - 1.0, y1), hair, 1.0)
	if paper_sides & 2:
		canvas.draw_line(Vector2(x1 + 1.0, y0), Vector2(x1 + 1.0, y1), hair, 1.0)
	if fossil:
		var seam: Color = Palette.RUST_DEEP
		canvas.draw_rect(rect.grow(-1.0), seam, false, 1.5)
	else:
		# Inner ruling-pen edge — keeps dense walls from reading as flat blobs.
		canvas.draw_rect(rect, Palette.INK_SOFT, false, 1.0)


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
