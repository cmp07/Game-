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
	## Cool-neutral desk / lightbox under the ledger page (ART_DIRECTION_V3 §2.1 layer 0).
	## Barely cooler than paper_bone; blotter edges sell desk depth — never cyan neon / void.
	if vp.x < 1.0 or vp.y < 1.0:
		return
	canvas.draw_rect(Rect2(Vector2.ZERO, vp), Palette.PAPER_MARGIN, true)
	# Cooler blotter wash at the extreme margins (desk under lightbox).
	var cool := Palette.PAPER_MARGIN.darkened(0.045)
	cool.b = minf(1.0, cool.b + 0.018)
	cool.a = 1.0
	var strip_h: float = maxf(10.0, vp.y * 0.018)
	var strip_w: float = maxf(10.0, vp.x * 0.012)
	canvas.draw_rect(Rect2(0.0, 0.0, vp.x, strip_h), Color(cool.r, cool.g, cool.b, 0.55), true)
	canvas.draw_rect(Rect2(0.0, vp.y - strip_h, vp.x, strip_h), Color(cool.r, cool.g, cool.b, 0.42), true)
	canvas.draw_rect(Rect2(0.0, 0.0, strip_w, vp.y), Color(cool.r, cool.g, cool.b, 0.28), true)
	canvas.draw_rect(Rect2(vp.x - strip_w, 0.0, strip_w, vp.y), Color(cool.r, cool.g, cool.b, 0.28), true)
	# Ambient desk vignette — ink-soft multiply toward corners only. No bloom / purple.
	# Keep strength modest so footer QA does not read vignette as BUFFER ink.
	draw_desk_vignette(canvas, vp, 0.07)
	if grain_a > 0.001:
		draw_paper_grain(canvas, Rect2(Vector2.ZERO, vp), grain_seed, grain_a)


func draw_desk_vignette(canvas: CanvasItem, vp: Vector2, strength: float = 0.11) -> void:
	## Soft corner falloff into the blotter — reads as desk lamp, not UI dim.
	## ART_DIRECTION_V3 §4.1: ±4% value drift; never crush to black.
	if vp.x < 1.0 or vp.y < 1.0 or strength < 0.001:
		return
	var a: float = clampf(strength, 0.0, 0.16)
	var ink := Palette.INK_BLACK
	# Layered inset bands approximate a radial vignette without shaders/bloom.
	var bands: Array = [
		[0.00, a * 0.40],
		[0.04, a * 0.22],
		[0.08, a * 0.10],
	]
	for band in bands:
		var inset: float = float(band[0])
		var ba: float = float(band[1])
		var m: float = minf(vp.x, vp.y)
		var ix: float = m * inset
		# Bias vignette to side/top; keep bottom thin so title footer stays bone.
		var iy_top: float = m * inset
		var iy_bot: float = m * inset * 0.45
		var c := Color(ink.r, ink.g, ink.b, ba)
		canvas.draw_rect(Rect2(0.0, 0.0, vp.x, iy_top), c, true)
		canvas.draw_rect(Rect2(0.0, vp.y - iy_bot, vp.x, iy_bot), c, true)
		canvas.draw_rect(Rect2(0.0, iy_top, ix, vp.y - iy_top - iy_bot), c, true)
		canvas.draw_rect(Rect2(vp.x - ix, iy_top, ix, vp.y - iy_top - iy_bot), c, true)


func draw_fiber_streaks(
	canvas: CanvasItem,
	rect: Rect2,
	seed: int = 7,
	opacity: float = 0.045,
	count: int = 28
) -> void:
	## Print-shop fiber residue on stock — sparse ink_soft strands, never noise fog.
	if rect.size.x < 8.0 or rect.size.y < 8.0 or opacity < 0.001:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var n: int = maxi(4, count)
	for _i in range(n):
		var x0: float = rect.position.x + rng.randf() * rect.size.x
		var y0: float = rect.position.y + rng.randf() * rect.size.y
		var length: float = rng.randf_range(10.0, 42.0)
		var ang: float = rng.randf_range(-0.35, 0.35)  # mostly horizontal fiber
		var a: float = opacity * rng.randf_range(0.35, 1.0)
		var c := Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, a)
		var x1: float = x0 + cos(ang) * length
		var y1: float = y0 + sin(ang) * length
		canvas.draw_line(Vector2(x0, y0), Vector2(x1, y1), c, 1.0, true)


func draw_letterpress_rule(
	canvas: CanvasItem,
	a: Vector2,
	b: Vector2,
	color: Color = Palette.INK_SOFT,
	width: float = 1.0,
	seed: int = 3
) -> void:
	## Letterpress crush on chrome rules — 0–1 px edge tremor, never glow.
	var delta: Vector2 = b - a
	var length: float = delta.length()
	if length < 1.0:
		return
	var dir: Vector2 = delta / length
	var nrm := Vector2(-dir.y, dir.x)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var step: float = 7.0
	var t: float = 0.0
	var prev: Vector2 = a
	while t < length:
		t = minf(t + step, length)
		var tremor: float = rng.randf_range(-0.7, 0.7)
		var nxt: Vector2 = a + dir * t + nrm * tremor
		canvas.draw_line(prev, nxt, color, width, true)
		prev = nxt


func draw_oxide_flecks(
	canvas: CanvasItem,
	rect: Rect2,
	seed: int = 21,
	count: int = 6,
	alpha: float = 0.55
) -> void:
	## Iron-oxide accents — matte dust near joins / brand rules. Emissive = 0.
	if rect.size.x < 4.0 or rect.size.y < 4.0:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	for _i in range(maxi(1, count)):
		var p := Vector2(
			rect.position.x + rng.randf() * rect.size.x,
			rect.position.y + rng.randf() * rect.size.y
		)
		var r: float = rng.randf_range(1.1, 2.4)
		var c: Color = Palette.RUST_FOSSIL if rng.randf() > 0.35 else Palette.RUST_DEEP
		canvas.draw_circle(p, r, Color(c.r, c.g, c.b, alpha * rng.randf_range(0.4, 1.0)))


func draw_ledger_page(
	canvas: CanvasItem,
	page: Rect2,
	opts: Dictionary = {}
) -> void:
	## Shared page substrate for chamber + menu (V3 page anatomy, CPU path).
	## opts: shadow_off, grain_seed, grain_a, major_cell, rule_w, spine, double_rule, alpha, skip_grain
	var shadow_off: Vector2 = opts.get("shadow_off", Vector2(5, 7))
	var grain_seed: int = int(opts.get("grain_seed", 42))
	var grain_a: float = float(opts.get("grain_a", 0.08))
	var major_cell: int = int(opts.get("major_cell", 16))
	var rule_w: float = float(opts.get("rule_w", 2.0))
	var spine: bool = bool(opts.get("spine", false))
	var double_rule: bool = bool(opts.get("double_rule", true))
	var alpha: float = float(opts.get("alpha", 1.0))
	var skip_grain: bool = bool(opts.get("skip_grain", false))

	var shadow := Palette.PAPER_SHADOW
	shadow.a *= alpha
	canvas.draw_rect(Rect2(page.position + shadow_off, page.size), shadow, true)
	var bone := Palette.PAPER_BONE
	bone.a = alpha
	canvas.draw_rect(page, bone, true)
	if spine:
		var spine_c := Palette.PAPER_DEEP
		spine_c.a = alpha
		var spine_r := Rect2(page.position, Vector2(14.0, page.size.y))
		canvas.draw_rect(spine_r, spine_c, true)
		canvas.draw_line(
			page.position + Vector2(14.0, 0.0),
			page.position + Vector2(14.0, page.size.y),
			Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.55 * alpha),
			1.0
		)
	if alpha >= 0.99:
		draw_page_fiber_grid(canvas, page, major_cell)
		draw_fiber_streaks(canvas, page, grain_seed + 5, 0.028 * alpha, 36)
	if not skip_grain and grain_a > 0.001:
		draw_paper_grain(canvas, page, grain_seed, grain_a * alpha)
	# Letterpress outer rule — tremor sells print crush, not a UI stroke.
	var rule_c := Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, alpha)
	draw_letterpress_rule(
		canvas, page.position, page.position + Vector2(page.size.x, 0.0), rule_c, rule_w, grain_seed
	)
	draw_letterpress_rule(
		canvas,
		page.position + Vector2(page.size.x, 0.0),
		page.end,
		rule_c,
		rule_w,
		grain_seed + 1
	)
	draw_letterpress_rule(
		canvas,
		page.end,
		page.position + Vector2(0.0, page.size.y),
		rule_c,
		rule_w,
		grain_seed + 2
	)
	draw_letterpress_rule(
		canvas,
		page.position + Vector2(0.0, page.size.y),
		page.position,
		rule_c,
		rule_w,
		grain_seed + 3
	)
	if double_rule:
		var inner_c := Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.5 * alpha)
		var inner: Rect2 = page.grow(-3.0)
		draw_letterpress_rule(
			canvas, inner.position, inner.position + Vector2(inner.size.x, 0.0), inner_c, 1.0, grain_seed + 7
		)
		draw_letterpress_rule(
			canvas, inner.position + Vector2(inner.size.x, 0.0), inner.end, inner_c, 1.0, grain_seed + 8
		)
		draw_letterpress_rule(
			canvas, inner.end, inner.position + Vector2(0.0, inner.size.y), inner_c, 1.0, grain_seed + 9
		)
		draw_letterpress_rule(
			canvas, inner.position + Vector2(0.0, inner.size.y), inner.position, inner_c, 1.0, grain_seed + 10
		)


func draw_index_card(canvas: CanvasItem, card: Rect2, opts: Dictionary = {}) -> void:
	## Physical Field Index plate (ART_DIRECTION_V3 §6.1).
	## Layered contact shadow + thickness + fiber stock + binder clip/holes (restore-rich).
	## opts: alpha, shadow_off, grain_seed, grain_a, binder_holes, header_rules, deep_backer,
	##       skip_grain, thickness, oxide_accents, binder_clip, fiber_a
	if card.size.x < 2.0 or card.size.y < 2.0:
		return
	var alpha: float = float(opts.get("alpha", 1.0))
	var shadow_off: Vector2 = opts.get("shadow_off", Vector2(7, 10))
	var grain_seed: int = int(opts.get("grain_seed", 11))
	var grain_a: float = float(opts.get("grain_a", 0.055))
	var binder_holes: int = int(opts.get("binder_holes", 5))
	var header_rules: bool = bool(opts.get("header_rules", true))
	var deep_backer: bool = bool(opts.get("deep_backer", true))
	var skip_grain: bool = bool(opts.get("skip_grain", false))
	var thickness: float = float(opts.get("thickness", 3.5))
	var oxide_accents: bool = bool(opts.get("oxide_accents", true))
	var binder_clip: bool = bool(opts.get("binder_clip", true))
	var fiber_a: float = float(opts.get("fiber_a", 0.055))

	# Soft outer contact wash, then ink-soft multiply stack — card as object.
	# Keep α modest so contact reads as lift, not a dark slab under the plate.
	var wash := Palette.PAPER_SHADOW
	wash.a = 0.10 * alpha
	canvas.draw_rect(Rect2(card.position + Vector2(10, 14), card.size + Vector2(6, 6)), wash, true)
	var shadow_layers: Array = [
		[shadow_off + Vector2(2, 3), 0.08],
		[shadow_off, 0.16],
		[shadow_off * 0.55, 0.10],
	]
	for layer in shadow_layers:
		var off: Vector2 = layer[0]
		var sa: float = float(layer[1]) * alpha
		var shadow := Color(
			Palette.INK_BLACK.r, Palette.INK_BLACK.g, Palette.INK_BLACK.b, sa
		)
		canvas.draw_rect(Rect2(card.position + off, card.size), shadow, true)
	if deep_backer:
		# Cardstock thickness: deep face peeking past the bone plate.
		var deep := Palette.PAPER_DEEP
		deep.a = alpha
		var thick: float = clampf(thickness, 2.0, 5.0)
		canvas.draw_rect(Rect2(card.position + Vector2(thick, thick), card.size), deep, true)
		var deep2 := Palette.PAPER_DEEP.darkened(0.06)
		deep2.a = 0.55 * alpha
		canvas.draw_rect(
			Rect2(card.position + Vector2(thick + 2.0, thick + 2.0), card.size - Vector2(2, 2)),
			deep2,
			true
		)
		# Right + bottom edge bevel (letterpress wall feel on chrome).
		var edge := Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.35 * alpha)
		canvas.draw_rect(
			Rect2(card.end.x, card.position.y + thick, thick, card.size.y),
			Color(Palette.PAPER_DEEP.r, Palette.PAPER_DEEP.g, Palette.PAPER_DEEP.b, alpha),
			true
		)
		canvas.draw_rect(
			Rect2(card.position.x + thick, card.end.y, card.size.x, thick),
			Color(Palette.PAPER_DEEP.r, Palette.PAPER_DEEP.g, Palette.PAPER_DEEP.b, alpha),
			true
		)
		canvas.draw_line(
			Vector2(card.end.x + thick * 0.35, card.position.y + thick),
			Vector2(card.end.x + thick * 0.35, card.end.y + thick * 0.35),
			edge,
			1.0
		)
	var bone := Palette.PAPER_BONE
	bone.a = alpha
	canvas.draw_rect(card, bone, true)
	# Warm face wash so the plate reads as stock, not clinical void.
	var face_warm := Palette.PAPER_DEEP
	face_warm.a = 0.18 * alpha
	canvas.draw_rect(card.grow(-2.0), face_warm, true)
	if not skip_grain and grain_a > 0.001:
		draw_paper_grain(canvas, card, grain_seed, grain_a * alpha)
	# Micro fiber grid + vertical stock + print-shop streaks.
	var fiber: Color = Palette.INK_SOFT
	fiber.a = fiber_a * alpha
	var fy: float = card.position.y + 8.0
	while fy < card.end.y - 8.0:
		canvas.draw_line(Vector2(card.position.x + 8.0, fy), Vector2(card.end.x - 8.0, fy), fiber, 1.0)
		fy += 4.0
	var fiber_v: Color = Palette.INK_SOFT
	fiber_v.a = fiber_a * 0.45 * alpha
	var fx: float = card.position.x + 28.0
	while fx < card.end.x - 12.0:
		canvas.draw_line(Vector2(fx, card.position.y + 10.0), Vector2(fx, card.end.y - 10.0), fiber_v, 1.0)
		fx += 28.0
	draw_fiber_streaks(canvas, card.grow(-6.0), grain_seed + 3, 0.04 * alpha, 18)
	var border := Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, alpha)
	# Continuous plate edge first (enclosure / screenshot QA), then letterpress tremor.
	canvas.draw_rect(card, border, false, 1.5)
	draw_letterpress_rule(
		canvas, card.position, card.position + Vector2(card.size.x, 0.0), border, 1.5, grain_seed + 11
	)
	draw_letterpress_rule(
		canvas, card.position + Vector2(card.size.x, 0.0), card.end, border, 1.5, grain_seed + 12
	)
	draw_letterpress_rule(
		canvas, card.end, card.position + Vector2(0.0, card.size.y), border, 1.5, grain_seed + 13
	)
	draw_letterpress_rule(
		canvas, card.position + Vector2(0.0, card.size.y), card.position, border, 1.5, grain_seed + 14
	)
	var inner_b := Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.45 * alpha)
	var inner_card: Rect2 = card.grow(-3.0)
	draw_letterpress_rule(
		canvas,
		inner_card.position,
		inner_card.position + Vector2(inner_card.size.x, 0.0),
		inner_b,
		1.0,
		grain_seed + 15
	)
	draw_letterpress_rule(
		canvas, inner_card.position + Vector2(inner_card.size.x, 0.0), inner_card.end, inner_b, 1.0, grain_seed + 16
	)
	draw_letterpress_rule(
		canvas, inner_card.end, inner_card.position + Vector2(0.0, inner_card.size.y), inner_b, 1.0, grain_seed + 17
	)
	draw_letterpress_rule(
		canvas, inner_card.position + Vector2(0.0, inner_card.size.y), inner_card.position, inner_b, 1.0, grain_seed + 18
	)
	if oxide_accents:
		draw_oxide_flecks(
			canvas,
			Rect2(card.position + Vector2(18, 8), Vector2(card.size.x - 36, 10)),
			grain_seed + 29,
			4,
			0.45 * alpha
		)
	if binder_holes > 0:
		var hole_step: float = maxf(48.0, (card.size.y - 64.0) / float(maxi(1, binder_holes - 1)))
		for i in range(binder_holes):
			var hy: float = card.position.y + 36.0 + float(i) * hole_step
			if hy > card.end.y - 28.0:
				break
			# Punched hole: ink ring + paper show-through + oxide kiss.
			canvas.draw_circle(
				Vector2(card.position.x + 14.0, hy),
				4.2,
				Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, alpha)
			)
			canvas.draw_circle(Vector2(card.position.x + 14.0, hy), 2.2, bone)
			canvas.draw_circle(
				Vector2(card.position.x + 14.6, hy + 0.6),
				1.4,
				Color(Palette.PAPER_SHADOW.r, Palette.PAPER_SHADOW.g, Palette.PAPER_SHADOW.b, 0.35 * alpha)
			)
			if i % 2 == 0:
				canvas.draw_circle(
					Vector2(card.position.x + 16.5, hy + 1.2),
					1.0,
					Color(Palette.RUST_FOSSIL.r, Palette.RUST_FOSSIL.g, Palette.RUST_FOSSIL.b, 0.35 * alpha)
				)
	if header_rules:
		draw_letterpress_rule(
			canvas,
			card.position + Vector2(26, 38),
			card.position + Vector2(card.size.x - 18, 38),
			Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, alpha),
			1.5,
			grain_seed + 21
		)
		draw_letterpress_rule(
			canvas,
			card.position + Vector2(26, 43),
			card.position + Vector2(card.size.x - 18, 43),
			Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, alpha),
			1.0,
			grain_seed + 22
		)
	if binder_clip:
		draw_binder_clip(canvas, Vector2(card.position.x + card.size.x * 0.5, card.position.y - 2.0), alpha)


func draw_binder_clip(canvas: CanvasItem, tip: Vector2, alpha: float = 1.0) -> void:
	## Etched binder clip at the top edge of an index card — stamp, not chrome photo.
	var ink := Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.92 * alpha)
	var fill := Color(Palette.PAPER_DEEP.r, Palette.PAPER_DEEP.g, Palette.PAPER_DEEP.b, 0.95 * alpha)
	var w: float = 54.0
	var h: float = 22.0
	var r := Rect2(tip.x - w * 0.5, tip.y - h + 4.0, w, h)
	canvas.draw_rect(r, fill, true)
	canvas.draw_rect(r, ink, false, 1.5)
	canvas.draw_line(
		Vector2(r.position.x + 8.0, r.position.y + 8.0),
		Vector2(r.end.x - 8.0, r.position.y + 8.0),
		ink,
		1.5
	)
	canvas.draw_line(
		Vector2(r.position.x + 10.0, r.position.y + 14.0),
		Vector2(r.end.x - 10.0, r.position.y + 14.0),
		Color(ink.r, ink.g, ink.b, 0.7 * alpha),
		1.0
	)
	canvas.draw_line(Vector2(tip.x - 10.0, tip.y + 2.0), Vector2(tip.x - 10.0, tip.y + 14.0), ink, 1.5)
	canvas.draw_line(Vector2(tip.x + 10.0, tip.y + 2.0), Vector2(tip.x + 10.0, tip.y + 14.0), ink, 1.5)


func draw_seal_stamp(canvas: CanvasItem, center: Vector2, radius: float = 28.0, opts: Dictionary = {}) -> void:
	## Letterpress / rubber-stamp plate (ART_DIRECTION_V3 §2.2 / §8.1 stamp_ink CPU path).
	## Imperfect rubber ink on a rectangular plate — habit-maze silhouette, not a UI ring.
	## No giant dashed circles; no watermark caption inside the plate.
	var rot_deg: float = float(opts.get("rot_deg", -3.5))
	var ink: Color = opts.get("color", Palette.SLATE_TEAL)
	var alpha: float = float(opts.get("alpha", 0.82))
	var seed: int = int(opts.get("seed", 17))
	var plate_w: float = float(opts.get("plate_w", radius * 2.05))
	var plate_h: float = float(opts.get("plate_h", radius * 2.05))
	var hero: bool = bool(opts.get("hero", false))
	var maze: bool = bool(opts.get("maze", true))
	var rust_accent: bool = bool(opts.get("rust_accent", true))
	var caption: String = str(opts.get("caption", ""))
	var font: Font = opts.get("font", null)
	var font_size: int = int(opts.get("font_size", 11))
	if radius < 4.0 or alpha < 0.01:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var rot: float = deg_to_rad(rot_deg)
	var hw: float = plate_w * 0.5
	var hh: float = plate_h * 0.5
	# Soft crush shadow under the plate — pressed into stock, not a glow halo.
	var shadow := Color(
		Palette.PAPER_SHADOW.r,
		Palette.PAPER_SHADOW.g,
		Palette.PAPER_SHADOW.b,
		0.20 * alpha
	)
	_draw_seal_plate_fill(
		canvas,
		center + Vector2(2.5, 3.0).rotated(rot),
		hw + 1.5,
		hh + 1.5,
		rot,
		shadow
	)
	# Faint ink wash on the plate face (uneven pressure, never solid fill).
	if hero:
		for k in range(4):
			var blot_c := Color(ink.r, ink.g, ink.b, alpha * rng.randf_range(0.04, 0.10))
			var blot_p := center + Vector2(
				rng.randf_range(-hw * 0.55, hw * 0.55),
				rng.randf_range(-hh * 0.55, hh * 0.55)
			).rotated(rot)
			canvas.draw_circle(blot_p, radius * rng.randf_range(0.06, 0.14), blot_c)
	# Double plate border — outer heavy, inner hairline — with ink breaks.
	_draw_seal_plate_frame(canvas, center, hw, hh, rot, ink, alpha, 2.8 if hero else 2.1, rng)
	_draw_seal_plate_frame(
		canvas,
		center,
		hw - (5.0 if hero else 3.5),
		hh - (5.0 if hero else 3.5),
		rot,
		ink,
		alpha * 0.72,
		1.15 if hero else 1.0,
		rng
	)
	# Corner registration marks — small ticks outside the plate (surveyor die grammar).
	var tick_out: float = 7.0 if hero else 4.5
	var tick_in: float = 3.0 if hero else 2.0
	var corners: Array = [
		Vector2(-hw, -hh), Vector2(hw, -hh), Vector2(-hw, hh), Vector2(hw, hh),
	]
	for corner in corners:
		var c0: Vector2 = center + (corner as Vector2).rotated(rot)
		var outward: Vector2 = (corner as Vector2).sign() * tick_out
		var inward: Vector2 = (-(corner as Vector2).sign()) * tick_in
		var j: Vector2 = Vector2(rng.randf_range(-0.35, 0.35), rng.randf_range(-0.35, 0.35))
		var tc := Color(ink.r, ink.g, ink.b, alpha * 0.80)
		# Outboard crop marks.
		canvas.draw_line(c0 + j, c0 + Vector2(outward.x, 0.0) + j, tc, 1.15, true)
		canvas.draw_line(c0 + j, c0 + Vector2(0.0, outward.y) + j, tc, 1.15, true)
		# Short inboard bites so the die corner registers.
		canvas.draw_line(c0 + j, c0 + Vector2(inward.x, 0.0) + j, tc, 1.0, true)
		canvas.draw_line(c0 + j, c0 + Vector2(0.0, inward.y) + j, tc, 1.0, true)
	if maze:
		draw_habit_maze_mark(canvas, center, minf(hw, hh) * 0.78, {
			"rot_deg": rot_deg,
			"color": ink,
			"alpha": alpha,
			"seed": seed + 7,
			"rust_accent": rust_accent,
			"hero": hero,
		})
	# Optional caption sits under the plate — never a watermark inside the seal.
	if caption != "" and font != null:
		var tw: float = font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var cap_off := Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-0.4, 0.6))
		var cap_pos: Vector2 = center + Vector2(-tw * 0.5, hh + font_size + 6.0) + cap_off
		canvas.draw_string(
			font,
			cap_pos,
			caption,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size,
			Color(ink.r, ink.g, ink.b, alpha * 0.85)
		)


func draw_habit_maze_mark(canvas: CanvasItem, center: Vector2, half: float, opts: Dictionary = {}) -> void:
	## Habit-maze silhouette as crisp ink geometry — readable at brand / boot scale.
	## Ruling-pen wall segments + one spare rust fossil cell. Not a chunky pixel blob.
	var rot_deg: float = float(opts.get("rot_deg", 0.0))
	var ink: Color = opts.get("color", Palette.SLATE_TEAL)
	var alpha: float = float(opts.get("alpha", 0.9))
	var seed: int = int(opts.get("seed", 24))
	var rust_accent: bool = bool(opts.get("rust_accent", true))
	var hero: bool = bool(opts.get("hero", false))
	if half < 4.0 or alpha < 0.01:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var rot: float = deg_to_rad(rot_deg)
	# 6-unit lattice — interior walls only (plate frame is the die edge; no triple border).
	var n: float = 6.0
	var cell: float = (half * 2.0) / n
	var origin: Vector2 = Vector2(-half, -half)
	var stroke: float = maxf(1.35, cell * (0.14 if hero else 0.18))
	var ink_c := Color(ink.r, ink.g, ink.b, alpha * 0.96)
	# Horizontal wall runs: [x0, x1, y] — interior only.
	var h_runs: Array = [
		Vector3(1, 5, 2), Vector3(0, 2, 4), Vector3(4, 6, 4), Vector3(2, 4, 5),
	]
	# Vertical wall runs: [y0, y1, x]
	var v_runs: Array = [
		Vector3(1, 4, 2), Vector3(2, 6, 4), Vector3(0, 3, 5), Vector3(4, 6, 3),
	]
	for run in h_runs:
		var a_local := origin + Vector2(run.x * cell, run.z * cell)
		var b_local := origin + Vector2(run.y * cell, run.z * cell)
		_draw_rotated_ink_run(canvas, center, a_local, b_local, rot, ink_c, stroke, rng)
	for run in v_runs:
		var a_local := origin + Vector2(run.z * cell, run.x * cell)
		var b_local := origin + Vector2(run.z * cell, run.y * cell)
		_draw_rotated_ink_run(canvas, center, a_local, b_local, rot, ink_c, stroke, rng)
	# Single rust fossil cell — habit calcified (spare accent, never a fill flood).
	if rust_accent:
		var fossil_cell := Vector2(3.0, 2.0)
		var pad: float = cell * 0.22
		var rect := Rect2(
			origin + fossil_cell * cell + Vector2(pad, pad),
			Vector2(cell - pad * 2.0, cell - pad * 2.0)
		)
		rect.position += Vector2(rng.randf_range(-0.3, 0.3), rng.randf_range(-0.3, 0.3))
		var rust := Color(Palette.RUST_FOSSIL.r, Palette.RUST_FOSSIL.g, Palette.RUST_FOSSIL.b, alpha * 0.88)
		_draw_rotated_rect(canvas, center, rect, rot, rust, true)
	# Habit path — dashed chalk through open corridors (graphite, not glow).
	var path: Array = [
		Vector2(1.0, 1.0), Vector2(1.0, 3.0), Vector2(3.0, 3.0), Vector2(3.0, 5.0), Vector2(5.0, 5.0),
	]
	var chalk := Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, alpha * 0.50)
	for i in range(path.size() - 1):
		var a_local: Vector2 = origin + (path[i] as Vector2) * cell
		var b_local: Vector2 = origin + (path[i + 1] as Vector2) * cell
		_draw_rotated_dashed(
			canvas,
			center,
			a_local,
			b_local,
			rot,
			chalk,
			1.2 if hero else 1.0,
			2.6,
			2.2
		)


func _draw_rotated_ink_run(
	canvas: CanvasItem,
	center: Vector2,
	a_local: Vector2,
	b_local: Vector2,
	rot: float,
	ink: Color,
	width: float,
	rng: RandomNumberGenerator
) -> void:
	## Segmented letterpress stroke with imperfect rubber-ink pressure.
	var a: Vector2 = center + a_local.rotated(rot)
	var b: Vector2 = center + b_local.rotated(rot)
	var delta: Vector2 = b - a
	var length: float = delta.length()
	if length < 0.001:
		return
	var dir: Vector2 = delta / length
	var segs: int = maxi(3, int(length / 6.0))
	for i in range(segs):
		if rng.randf() < 0.05:
			continue
		var pressure: float = 1.0
		if rng.randf() < 0.14:
			pressure = rng.randf_range(0.55, 0.85)
		var t0: float = length * float(i) / float(segs)
		var t1: float = length * float(i + 1) / float(segs)
		var c := Color(ink.r, ink.g, ink.b, ink.a * pressure)
		canvas.draw_line(a + dir * t0, a + dir * t1, c, width * rng.randf_range(0.92, 1.12), true)


func _draw_seal_plate_fill(
	canvas: CanvasItem,
	center: Vector2,
	hw: float,
	hh: float,
	rot: float,
	color: Color
) -> void:
	var rect := Rect2(Vector2(-hw, -hh), Vector2(hw * 2.0, hh * 2.0))
	_draw_rotated_rect(canvas, center, rect, rot, color, true)


func _draw_seal_plate_frame(
	canvas: CanvasItem,
	center: Vector2,
	hw: float,
	hh: float,
	rot: float,
	ink: Color,
	alpha: float,
	width: float,
	rng: RandomNumberGenerator
) -> void:
	## Continuous plate edge with sparse ink-pressure fades — letterpress, not a dashed UI ring.
	var edges: Array = [
		[Vector2(-hw, -hh), Vector2(hw, -hh)],
		[Vector2(hw, -hh), Vector2(hw, hh)],
		[Vector2(hw, hh), Vector2(-hw, hh)],
		[Vector2(-hw, hh), Vector2(-hw, -hh)],
	]
	for edge in edges:
		var a: Vector2 = edge[0]
		var b: Vector2 = edge[1]
		var delta: Vector2 = b - a
		var length: float = delta.length()
		if length < 0.001:
			continue
		var dir: Vector2 = delta / length
		var segs: int = maxi(8, int(length / 5.0))
		for i in range(segs):
			# Rare skips only — plate must read as a solid stamp die, not dashes.
			if rng.randf() < 0.04:
				continue
			var pressure: float = 1.0
			if rng.randf() < 0.12:
				pressure = rng.randf_range(0.55, 0.82)
			var t0: float = length * float(i) / float(segs)
			var t1: float = length * float(i + 1) / float(segs)
			var p0: Vector2 = center + (a + dir * t0).rotated(rot)
			var p1: Vector2 = center + (a + dir * t1).rotated(rot)
			var c := Color(ink.r, ink.g, ink.b, alpha * pressure)
			canvas.draw_line(p0, p1, c, width * rng.randf_range(0.92, 1.12), true)


func _draw_rotated_rect(
	canvas: CanvasItem,
	center: Vector2,
	local_rect: Rect2,
	rot: float,
	color: Color,
	filled: bool
) -> void:
	var pts := PackedVector2Array([
		center + local_rect.position.rotated(rot),
		center + (local_rect.position + Vector2(local_rect.size.x, 0.0)).rotated(rot),
		center + (local_rect.position + local_rect.size).rotated(rot),
		center + (local_rect.position + Vector2(0.0, local_rect.size.y)).rotated(rot),
	])
	if filled:
		canvas.draw_colored_polygon(pts, color)
	else:
		for i in range(4):
			canvas.draw_line(pts[i], pts[(i + 1) % 4], color, 1.0, true)


func _draw_rotated_dashed(
	canvas: CanvasItem,
	center: Vector2,
	a_local: Vector2,
	b_local: Vector2,
	rot: float,
	color: Color,
	width: float,
	dash: float,
	gap: float
) -> void:
	var a: Vector2 = center + a_local.rotated(rot)
	var b: Vector2 = center + b_local.rotated(rot)
	draw_dashed_line(canvas, a, b, color, width, dash, gap)


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
