extends Control
##
## Main menu — VISUAL v2 Steam-hit title card + elevated loop (Daily/stars).
## Index-card on a lightbox ledger. Brand-first. No purple void.
##

signal start_new_pressed()
signal continue_pressed()
signal daily_pressed()
signal quit_pressed()

@onready var continue_button: Button = %ContinueButton
@onready var start_button: Button = %StartButton
@onready var daily_button: Button = %DailyButton
@onready var quit_button: Button = %QuitButton
@onready var subtitle: Label = %Subtitle
@onready var meta_label: Label = %MetaLabel

var _t: float = 0.0
var _demo_path: Array = []  ## Vector2i points for ambient ghost walk
var _demo_progress: float = 0.0


func _ready() -> void:
	var has: bool = GameState.has_progress()
	continue_button.disabled = not has
	continue_button.modulate = Color(1, 1, 1, 1.0 if has else 0.40)
	var stars: int = GameState.total_stars_earned()
	if has:
		subtitle.text = "Chamber %d of %d  ·  %d★ earned" % [
			GameState.run_progress_index() + 1,
			GameState.chambers_in_run(),
			stars,
		]
	else:
		subtitle.text = "Four Acts — %d chambers. Ink on paper." % ChamberBook.chamber_count()
	var today: String = GameState._today_label()
	var dseed: int = GameState._today_seed()
	var dbest: int = int(GameState.daily_best_stars.get(str(dseed), 0))
	meta_label.text = "Daily %s  ·  best %d★ / 15" % [today, dbest]
	start_button.grab_focus()

	start_button.pressed.connect(func(): emit_signal("start_new_pressed"))
	continue_button.pressed.connect(func():
		if has:
			emit_signal("continue_pressed")
	)
	daily_button.pressed.connect(func(): emit_signal("daily_pressed"))
	quit_button.pressed.connect(func(): emit_signal("quit_pressed"))

	_build_demo_path()
	set_process(true)
	# Restyle buttons as underlined type (art bible §6).
	_style_as_index_button(start_button, true)
	_style_as_index_button(continue_button, false)
	_style_as_index_button(daily_button, false)
	_style_as_index_button(quit_button, false)
	if has_node("/root/AudioDirector"):
		AudioDirector.fire("ui.click")


func _style_as_index_button(btn: Button, primary: bool) -> void:
	var empty := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty)
	btn.add_theme_stylebox_override("pressed", empty)
	btn.add_theme_stylebox_override("hover", empty)
	btn.add_theme_stylebox_override("focus", empty)
	btn.add_theme_stylebox_override("disabled", empty)
	btn.add_theme_color_override("font_color", Palette.INK_BLACK if primary else Palette.INK_SOFT)
	btn.add_theme_color_override("font_hover_color", Palette.SLATE_TEAL)
	btn.add_theme_color_override("font_pressed_color", Palette.RUST_FOSSIL)
	btn.add_theme_color_override("font_focus_color", Palette.RUST_FOSSIL)
	btn.add_theme_color_override("font_disabled_color", Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.35))
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT


func _build_demo_path() -> void:
	## Ambient chalk path that writes itself behind the title — the game's verb as wallpaper.
	_demo_path = [
		Vector2i(2, 10), Vector2i(3, 10), Vector2i(4, 10), Vector2i(5, 10),
		Vector2i(5, 9), Vector2i(5, 8), Vector2i(6, 8), Vector2i(7, 8),
		Vector2i(8, 8), Vector2i(8, 7), Vector2i(8, 6), Vector2i(9, 6),
		Vector2i(10, 6), Vector2i(11, 6), Vector2i(12, 6), Vector2i(12, 7),
		Vector2i(12, 8), Vector2i(13, 8), Vector2i(14, 8), Vector2i(15, 8),
		Vector2i(16, 8), Vector2i(17, 8), Vector2i(18, 8), Vector2i(19, 8),
		Vector2i(20, 8), Vector2i(21, 8), Vector2i(22, 8), Vector2i(22, 9),
		Vector2i(22, 10), Vector2i(23, 10), Vector2i(24, 10), Vector2i(25, 10),
	]


func _process(delta: float) -> void:
	_t += delta
	_demo_progress = fmod(_demo_progress + delta * 3.2, float(_demo_path.size()) + 8.0)
	queue_redraw()


func _draw() -> void:
	var vp: Vector2 = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size

	# Lightbox paper.
	draw_rect(Rect2(Vector2.ZERO, vp), Palette.PAPER_MARGIN, true)
	ArtKit.draw_paper_grain(self, Rect2(Vector2.ZERO, vp), 3, 0.06)

	# Large ledger page.
	var page := Rect2(40, 28, vp.x - 80, vp.y - 56)
	draw_rect(Rect2(page.position + Vector2(6, 8), page.size), Palette.PAPER_SHADOW, true)
	draw_rect(page, Palette.PAPER_BONE, true)
	ArtKit.draw_ledger_grid(self, page, 32)
	ArtKit.draw_paper_grain(self, page, 19, 0.07)
	draw_rect(page, Palette.INK_SOFT, false, 2.0)

	# Seed header strip along top margin.
	var seed_tex: Texture2D = ArtKit.tex("res://art/ui/seed_header_256x24.png")
	if seed_tex != null:
		draw_texture_rect(seed_tex, Rect2(page.position + Vector2(16, 10), Vector2(256, 24)), false)
	draw_string(
		ThemeDB.fallback_font,
		page.position + Vector2(280, 28),
		"SEED  A7F3 · 19C2 · B004 · EE51",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Palette.SLATE_TEAL_SOFT
	)

	# Ambient maze — fossil walls + writing chalk path (the Steam capsule beat).
	_draw_ambient_lattice(page)

	# Brand lockup — hero-level, not nav text.
	var brand_x: float = page.position.x + 48
	var brand_y: float = page.position.y + page.size.y * 0.28
	draw_string(
		ThemeDB.fallback_font,
		Vector2(brand_x, brand_y),
		"ECHO LATTICE",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 64, Palette.INK_BLACK
	)
	# Rust rule under the title — the brand underline.
	draw_rect(Rect2(brand_x, brand_y + 10, 420, 3), Palette.RUST_FOSSIL, true)

	draw_string(
		ThemeDB.fallback_font,
		Vector2(brand_x, brand_y + 42),
		"IT LEARNED YOU",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Palette.SLATE_TEAL
	)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(brand_x, brand_y + 68),
		"A labyrinth that rebuilds from your last thirty moves.",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Palette.INK_SOFT
	)

	# Index-card plate behind the button column (right side).
	var card := Rect2(page.end.x - 340, page.position.y + 90, 280, 320)
	draw_rect(Rect2(card.position + Vector2(3, 4), card.size), Palette.PAPER_SHADOW, true)
	draw_rect(card, Palette.PAPER_BONE, true)
	draw_rect(card, Palette.INK_SOFT, false, 1.5)
	# Card header rule.
	draw_line(card.position + Vector2(16, 36), card.position + Vector2(card.size.x - 16, 36), Palette.INK_SOFT, 1.0)
	draw_string(
		ThemeDB.fallback_font,
		card.position + Vector2(20, 28),
		"FIELD INDEX",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Palette.SLATE_TEAL
	)

	# Focus underlines drawn under whichever button has focus.
	_draw_button_underlines(card)

	# Bottom punch-card ribbon.
	_draw_punchcard_ribbon(page)

	# Footer controls hint.
	draw_string(
		ThemeDB.fallback_font,
		Vector2(page.position.x + 16, page.end.y - 14),
		"Move  WASD / Arrows     Restart  R     Undo  Z     Menu  Esc",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Palette.INK_SOFT
	)


func _draw_ambient_lattice(page: Rect2) -> void:
	var origin: Vector2 = page.position + Vector2(36, page.size.y * 0.52)
	var cell: float = 14.0
	# Sparse fossil walls — the maze wearing someone.
	var walls: Array = [
		Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(4, 0), Vector2i(5, 0),
		Vector2i(0, 1), Vector2i(5, 1), Vector2i(0, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(5, 2),
		Vector2i(0, 3), Vector2i(5, 3), Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(5, 4),
	]
	var fossil: Array = [Vector2i(8, 1), Vector2i(9, 1), Vector2i(9, 2), Vector2i(10, 2), Vector2i(11, 2), Vector2i(11, 3), Vector2i(12, 3)]
	for w in walls:
		var r := Rect2(origin + Vector2(w.x * cell, w.y * cell), Vector2(cell - 1, cell - 1))
		draw_rect(r, Palette.INK_BLACK, true)
	for w in fossil:
		var r2 := Rect2(origin + Vector2(w.x * cell, w.y * cell), Vector2(cell - 1, cell - 1))
		draw_rect(r2, Palette.RUST_FOSSIL, true)

	# Writing chalk path.
	var visible: int = mini(_demo_path.size(), int(_demo_progress))
	if visible < 2:
		return
	var chalk := Color(Palette.CHALK_WHITE.r, Palette.CHALK_WHITE.g, Palette.CHALK_WHITE.b, 0.75)
	for i in range(visible - 1):
		var a: Vector2i = _demo_path[i]
		var b: Vector2i = _demo_path[i + 1]
		# Map demo path into the ambient lattice space (scaled).
		var pa: Vector2 = origin + Vector2(a.x * 0.55 * cell, (a.y - 6) * 0.55 * cell)
		var pb: Vector2 = origin + Vector2(b.x * 0.55 * cell, (b.y - 6) * 0.55 * cell)
		ArtKit.draw_dashed_line(self, pa, pb, chalk, 1.5, 3.0, 2.5)
	# Folding walls appearing at the mirrored end of the path — the rewrite tease.
	var fold_a: float = 0.5 + 0.5 * sin(_t * 2.0)
	for j in range(3):
		var fp: Vector2i = _demo_path[mini(visible - 1, _demo_path.size() - 1)]
		var mx: float = origin.x + (26 - fp.x * 0.55) * cell
		var my: float = origin.y + (fp.y - 6) * 0.55 * cell + j * cell * 0.55
		var fr := Rect2(mx, my, cell - 1, cell - 1)
		var fc := Color(Palette.RUST_FOSSIL.r, Palette.RUST_FOSSIL.g, Palette.RUST_FOSSIL.b, 0.35 + 0.45 * fold_a)
		draw_rect(fr, fc, true)


func _draw_button_underlines(_card: Rect2) -> void:
	for btn in [continue_button, start_button, daily_button, quit_button]:
		if btn == null:
			continue
		var r: Rect2 = btn.get_global_rect()
		# Convert to local.
		var local_pos: Vector2 = r.position - global_position
		var focused: bool = btn.has_focus()
		var hovered: bool = btn.is_hovered()
		if focused:
			draw_rect(Rect2(local_pos.x, local_pos.y + r.size.y - 4, min(r.size.x, 200), 2), Palette.RUST_FOSSIL, true)
		elif hovered and not btn.disabled:
			draw_rect(Rect2(local_pos.x, local_pos.y + r.size.y - 4, min(r.size.x, 200), 2), Palette.SLATE_TEAL, true)
		elif not btn.disabled:
			draw_rect(Rect2(local_pos.x, local_pos.y + r.size.y - 4, min(r.size.x, 160), 1), Palette.INK_SOFT, true)


func _draw_punchcard_ribbon(page: Rect2) -> void:
	var y: float = page.end.y - 48
	var x: float = page.position.x + 16
	draw_string(ThemeDB.fallback_font, Vector2(x, y - 4), "BUFFER", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Palette.SLATE_TEAL)
	x += 64
	var cells: Array = [
		ArtKit.tex("res://art/ui/punchcard_cell_empty.png"),
		ArtKit.tex("res://art/ui/punchcard_cell_filled.png"),
		ArtKit.tex("res://art/ui/punchcard_cell_rust.png"),
		ArtKit.tex("res://art/ui/punchcard_cell_warn.png"),
	]
	for i in range(30):
		var tex: Texture2D = cells[0]
		if i < int(_demo_progress) % 31:
			tex = cells[1]
		if i > 22 and i < int(_demo_progress) % 31:
			tex = cells[2]
		if i == 29 and int(_t * 3.0) % 8 == 0:
			tex = cells[3]
		var cell_r := Rect2(x + i * 14, y, 12, 16)
		if tex != null:
			draw_texture_rect(tex, cell_r, false)
		else:
			draw_rect(cell_r, Palette.INK_SOFT, false, 1.0)
