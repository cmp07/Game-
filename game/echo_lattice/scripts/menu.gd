extends Control
##
## Main menu — VISUAL v2 Steam-hit title card + elevated loop (Daily/stars).
## Index-card on a lightbox ledger. Brand-first. No purple void.
##

signal start_new_pressed()
signal continue_pressed()
signal daily_pressed()
signal endless_pressed()
signal hard_pressed()
signal museum_pressed()
signal settings_pressed()
signal quit_pressed()
signal wishlist_pressed()

const SETTINGS_SCENE: PackedScene = preload("res://scenes/ui/settings_menu.tscn")
const COLOPHON_SCENE: PackedScene = preload("res://scenes/ui/credits_colophon.tscn")

@onready var continue_button: Button = %ContinueButton
@onready var start_button: Button = %StartButton
@onready var daily_button: Button = %DailyButton
@onready var endless_button: Button = %EndlessButton
@onready var hard_button: Button = %HardButton
@onready var museum_button: Button = %MuseumButton
@onready var settings_button: Button = %SettingsButton
@onready var colophon_button: Button = get_node_or_null("%ColophonButton")
@onready var quit_button: Button = %QuitButton
@onready var subtitle: Label = %Subtitle
@onready var meta_label: Label = %MetaLabel

var _t: float = 0.0
var _demo_path: Array = []  ## Vector2i points for ambient ghost walk
var _demo_progress: float = 0.0
var _settings_overlay: Control = null
var _colophon_overlay: Control = null
var _wishlist_button: Button = null
var _card_slot_t: float = 0.0

## Ambient chalk path does not need a full 60 Hz canvas rebuild.
const AMBIENT_REDRAW_HZ: float = 15.0
var _redraw_accum: float = 0.0
var _last_demo_step: int = -1


func _ready() -> void:
	_localize_chrome()
	if has_node("/root/LocaleManager"):
		LocaleManager.locale_changed.connect(func(_l): _localize_chrome())
	var has: bool = GameState.can_continue()
	continue_button.disabled = not has
	continue_button.modulate = Color(1, 1, 1, 1.0 if has else 0.40)
	start_button.grab_focus()

	start_button.pressed.connect(func(): emit_signal("start_new_pressed"))
	continue_button.pressed.connect(func():
		if GameState.can_continue():
			emit_signal("continue_pressed")
	)
	daily_button.pressed.connect(func(): emit_signal("daily_pressed"))
	if endless_button:
		endless_button.pressed.connect(func(): emit_signal("endless_pressed"))
	if hard_button:
		hard_button.pressed.connect(func():
			if GameState.can_start_hard_run():
				emit_signal("hard_pressed")
		)
	if museum_button:
		museum_button.pressed.connect(func(): emit_signal("museum_pressed"))
	settings_button.pressed.connect(_open_settings)
	if colophon_button:
		colophon_button.pressed.connect(_open_colophon)
	quit_button.pressed.connect(func(): emit_signal("quit_pressed"))
	# Wishlist CTA only when DemoBuild gates allow (demo + Steam + real store URL).
	if DemoBuild.wishlist_cta_enabled():
		_ensure_wishlist_button()
	elif _wishlist_button != null:
		_wishlist_button.visible = false
		_wishlist_button.queue_free()
		_wishlist_button = null

	_build_demo_path()
	_card_slot_t = 0.0
	set_process(true)
	_sync_field_index_layout()
	call_deferred("_sync_field_index_layout")
	_sync_tech_art_grain()
	var store := get_node_or_null("/root/SettingsStore")
	if store != null and store.has_signal("settings_changed"):
		if not store.settings_changed.is_connected(_on_tech_art_settings_changed):
			store.settings_changed.connect(_on_tech_art_settings_changed)
	var remap := get_node_or_null("/root/ActionRemap")
	if remap != null and remap.has_signal("bindings_changed"):
		if not remap.bindings_changed.is_connected(queue_redraw):
			remap.bindings_changed.connect(queue_redraw)
	# Restyle buttons as underlined type (art bible §6).
	LedgerChrome.style_index_button(start_button, true)
	LedgerChrome.style_index_button(continue_button, false)
	LedgerChrome.style_index_button(daily_button, false)
	if endless_button:
		LedgerChrome.style_index_button(endless_button, false)
	if hard_button:
		LedgerChrome.style_index_button(hard_button, false)
	if museum_button:
		LedgerChrome.style_index_button(museum_button, false)
	LedgerChrome.style_index_button(settings_button, false)
	if colophon_button:
		LedgerChrome.style_index_button(colophon_button, false)
	LedgerChrome.style_index_button(quit_button, false)
	if _wishlist_button != null:
		LedgerChrome.style_index_button(_wishlist_button, false)
	## Full gamepad path: vertical focus neighbors, no keyboard text entry.
	_ensure_gamepad_focus_chain()
	# Cold boot stays silent — ui.click only on confirm / navigation (QW-2).


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_sync_field_index_layout()
		queue_redraw()


## Shared page frame used by draw + Control layout (keeps Field Index diegetic).
func _ledger_page_rect(vp: Vector2) -> Rect2:
	return Rect2(40.0, 28.0, vp.x - 80.0, vp.y - 56.0)


## Drawn Field Index plate — right side of the ledger, clear of the brand lockup.
func field_index_card_rect(vp: Vector2 = Vector2.ZERO, y_off: float = 0.0) -> Rect2:
	if vp.x < 2.0:
		vp = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size
	var page: Rect2 = _ledger_page_rect(vp)
	# Brand lockup sits around page.x+48 with ~420px rust rule — keep clearance.
	# On narrow pages, leave at least ~48% of the page for the brand column.
	var brand_clear: float = page.position.x + minf(520.0, page.size.x * 0.48)
	var right_pad: float = 28.0 if page.size.x < 1100.0 else 36.0
	var card_w: float = 300.0 if page.size.x >= 1100.0 else 280.0
	var card_x: float = page.end.x - right_pad - card_w
	if card_x < brand_clear:
		card_x = brand_clear
		card_w = maxf(220.0, page.end.x - right_pad - card_x)
	# Below seed strip; above punchcard ribbon + controls hint.
	# Short pages (Deck / editor) tighten margins so index rows still fit.
	var top_pad: float = 56.0 if page.size.y < 700.0 else 70.0
	var bottom_pad: float = 52.0 if page.size.y < 700.0 else 72.0
	var top: float = page.position.y + top_pad + y_off
	var bottom: float = page.end.y - bottom_pad
	var card_h: float = maxf(280.0, bottom - top)
	return Rect2(card_x, top, card_w, card_h)


## Inner content inset: binder holes left, FIELD INDEX header top.
func field_index_content_rect(card: Rect2) -> Rect2:
	var head: float = 42.0 if card.size.y < 400.0 else 48.0
	return Rect2(
		card.position.x + 26.0,
		card.position.y + head,
		maxf(180.0, card.size.x - 40.0),
		maxf(180.0, card.size.y - head - 14.0)
	)


func _apply_index_row_metrics(compact: bool) -> void:
	var row_h: float = 26.0 if compact else 32.0
	var primary_h: float = 30.0 if compact else 36.0
	var buttons: Array = [
		continue_button, daily_button, endless_button, hard_button,
		museum_button, settings_button, colophon_button, quit_button, _wishlist_button,
	]
	for b in buttons:
		if b == null:
			continue
		(b as Button).custom_minimum_size = Vector2(200.0, row_h)
		(b as Button).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if start_button:
		start_button.custom_minimum_size = Vector2(200.0, primary_h)
		start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if subtitle:
		subtitle.add_theme_font_size_override("font_size", 12 if compact else 13)
		subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		subtitle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if meta_label:
		meta_label.add_theme_font_size_override("font_size", 11 if compact else 12)
		meta_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		meta_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL


func _sync_field_index_layout() -> void:
	var col: Control = get_node_or_null("CardColumn") as Control
	if col == null:
		return
	var vp: Vector2 = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size
	# Controls track the settled card (slot settle is draw-only polish).
	var card: Rect2 = field_index_card_rect(vp, 0.0)
	var inset: Rect2 = field_index_content_rect(card)
	var compact: bool = inset.size.y < 420.0
	_apply_index_row_metrics(compact)
	col.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	col.position = inset.position
	col.size = inset.size
	col.add_theme_constant_override("separation", 3 if compact else 6)


## Regression helper — every visible index action must sit inside the plate.
func verify_field_index_layout() -> bool:
	_sync_field_index_layout()
	var vp: Vector2 = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size
	var card: Rect2 = field_index_card_rect(vp, 0.0)
	# Grow slightly so hairline underlines / rounding do not false-fail.
	var pad: Rect2 = card.grow(2.0)
	var nodes: Array = [subtitle, meta_label, continue_button, start_button, daily_button]
	if endless_button:
		nodes.append(endless_button)
	if hard_button and hard_button.visible:
		nodes.append(hard_button)
	if museum_button:
		nodes.append(museum_button)
	nodes.append(settings_button)
	if colophon_button:
		nodes.append(colophon_button)
	nodes.append(quit_button)
	if _wishlist_button != null and _wishlist_button.visible:
		nodes.append(_wishlist_button)
	var ok := true
	for n in nodes:
		if n == null or not (n is Control):
			continue
		var c: Control = n
		if not c.visible:
			continue
		var r: Rect2 = c.get_global_rect()
		var host: Vector2 = global_position
		var local := Rect2(r.position - host, r.size)
		if not pad.encloses(local):
			printerr(
				"Field Index layout: %s at %s outside card %s" % [c.name, str(local), str(card)]
			)
			ok = false
	# Brand lockup must stay clear of the plate (no left-side clip).
	var page: Rect2 = _ledger_page_rect(vp)
	var brand_right: float = page.position.x + minf(500.0, page.size.x * 0.46)
	if card.position.x < brand_right - 0.5:
		printerr(
			"Field Index layout: card overlaps brand column (card.x=%.1f brand_right=%.1f)" % [
				card.position.x, brand_right
			]
		)
		ok = false
	return ok


func _on_tech_art_settings_changed(section: String, key: String, _value: Variant) -> void:
	if section == "graphics" and key == TechArt.SETTINGS_KEY:
		_sync_tech_art_grain()
		queue_redraw()
	elif section == "accessibility" and key == "reduce_motion":
		_sync_tech_art_grain()


func _sync_tech_art_grain() -> void:
	if TechArt.v3_enabled():
		# Menu seed offset differs from chamber page (TECH_ART_V3 §2.3).
		PaperGrainLayer.attach_to(self, 19, 0.06, Vector2(19, 7), true)
		# Keep chrome (CardColumn) above the grain pass.
		var chrome: Node = get_node_or_null("CardColumn")
		if chrome != null:
			move_child(chrome, get_child_count() - 1)
	else:
		PaperGrainLayer.set_visible_for(self, false)


func _localize_chrome() -> void:
	continue_button.text = tr("menu.continue")
	start_button.text = tr("menu.start_new")
	daily_button.text = tr("menu.daily")
	if endless_button:
		endless_button.text = tr("menu.endless")
	if hard_button:
		hard_button.text = tr("menu.hard")
	if museum_button:
		museum_button.text = tr("menu.museum")
	if settings_button:
		settings_button.text = tr("menu.settings")
	if colophon_button:
		colophon_button.text = tr("menu.colophon")
	quit_button.text = tr("menu.quit")
	if _wishlist_button != null:
		_wishlist_button.text = tr("menu.wishlist")
	_refresh_progress_copy()
	queue_redraw()


func _refresh_progress_copy() -> void:
	var has: bool = GameState.can_continue()
	var stars: int = GameState.total_stars_earned()
	if has:
		subtitle.text = tr("menu.subtitle_progress") % [
			GameState.run_progress_index() + 1,
			GameState.chambers_in_run(),
			stars,
		]
	elif DemoBuild.is_demo():
		subtitle.text = tr("menu.subtitle_demo")
	elif GameState.is_run_complete():
		subtitle.text = tr("menu.subtitle_wing_complete") % stars
	else:
		subtitle.text = tr("menu.subtitle_fresh") % ChamberBook.chamber_count()
	_refresh_hard_button()
	var entry: Dictionary = GameState.today_daily_entry()
	var today: String = str(entry.get("date", GameState._today_label()))
	var friend_code: String = str(entry.get("friend_code", ""))
	var dbest: int = GameState.daily_best_for_today()
	var ebest: int = int(GameState.endless_best_depth)
	if DemoBuild.is_demo():
		# Daily stays Act-I-scoped via ChamberBook; copy avoids full-game spoilers.
		if friend_code != "":
			meta_label.text = tr("menu.demo_daily_meta_code") % [today, friend_code, dbest]
		else:
			meta_label.text = tr("menu.demo_daily_meta") % [today, dbest]
	elif friend_code != "":
		meta_label.text = tr("menu.daily_endless_meta_code") % [today, friend_code, dbest, ebest]
	else:
		meta_label.text = tr("menu.daily_endless_meta") % [today, dbest, ebest]
	var museum_n: int = GameState.museum_count()
	if museum_n > 0:
		meta_label.text = "%s  ·  %s" % [meta_label.text, tr("menu.museum_meta") % museum_n]


func _refresh_hard_button() -> void:
	if hard_button == null:
		return
	var unlocked: Array = ChamberBook.unlocked_hard_variant_indices(GameState.completed)
	var show: bool = unlocked.size() > 0 and not DemoBuild.is_demo()
	hard_button.visible = show
	hard_button.disabled = not show
	if show:
		hard_button.text = tr("menu.hard_count") % unlocked.size()
	else:
		hard_button.text = tr("menu.hard")
	_ensure_gamepad_focus_chain()


func _open_settings() -> void:
	emit_signal("settings_pressed")
	if _settings_overlay == null:
		_settings_overlay = SETTINGS_SCENE.instantiate()
		add_child(_settings_overlay)
		_settings_overlay.closed.connect(func():
			if start_button:
				start_button.grab_focus()
		)
	_settings_overlay.open_menu()
	if has_node("/root/AudioDirector"):
		AudioDirector.fire("ui.click")


func _open_colophon() -> void:
	if _colophon_overlay == null:
		_colophon_overlay = COLOPHON_SCENE.instantiate()
		add_child(_colophon_overlay)
		_colophon_overlay.closed.connect(func():
			if start_button:
				start_button.grab_focus()
			queue_redraw()
		)
	if _colophon_overlay.has_method("open_colophon"):
		_colophon_overlay.open_colophon()


func _ensure_wishlist_button() -> void:
	if _wishlist_button != null:
		return
	_wishlist_button = Button.new()
	_wishlist_button.name = "WishlistButton"
	_wishlist_button.unique_name_in_owner = true
	_wishlist_button.custom_minimum_size = Vector2(220, 32)
	_wishlist_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_wishlist_button.text = tr("menu.wishlist")
	_wishlist_button.flat = true
	_wishlist_button.add_theme_font_size_override("font_size", 18)
	_wishlist_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var col: Node = quit_button.get_parent()
	col.add_child(_wishlist_button)
	col.move_child(_wishlist_button, quit_button.get_index())
	_wishlist_button.pressed.connect(func():
		emit_signal("wishlist_pressed")
		DemoBuild.open_wishlist()
	)
	LedgerChrome.style_index_button(_wishlist_button, false)
	_sync_field_index_layout()


func _ensure_gamepad_focus_chain() -> void:
	var order: Array = [continue_button, start_button, daily_button]
	if endless_button:
		order.append(endless_button)
	if hard_button and hard_button.visible and not hard_button.disabled:
		order.append(hard_button)
	if museum_button:
		order.append(museum_button)
	order.append(settings_button)
	if colophon_button:
		order.append(colophon_button)
	order.append(quit_button)
	if _wishlist_button != null:
		order.insert(order.size() - 1, _wishlist_button)
	LedgerChrome.wire_vertical_focus(order)


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
	if _card_slot_t < 0.18:
		_card_slot_t = minf(_card_slot_t + delta, 0.18)
	_demo_progress = fmod(_demo_progress + delta * 3.2, float(_demo_path.size()) + 8.0)
	var step: int = int(_demo_progress)
	_redraw_accum += delta
	# Redraw when the chalk path advances a cell, or at a capped ambient rate for pulse.
	if step != _last_demo_step or _redraw_accum >= 1.0 / AMBIENT_REDRAW_HZ or _card_slot_t < 0.18:
		_last_demo_step = step
		_redraw_accum = 0.0
		queue_redraw()


func _draw() -> void:
	var vp: Vector2 = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size

	# Lightbox paper.
	draw_rect(Rect2(Vector2.ZERO, vp), Palette.PAPER_MARGIN, true)
	if not TechArt.v3_enabled():
		ArtKit.draw_paper_grain(self, Rect2(Vector2.ZERO, vp), 3, 0.06)

	# Large ledger page.
	var page: Rect2 = _ledger_page_rect(vp)
	draw_rect(Rect2(page.position + Vector2(6, 8), page.size), Palette.PAPER_SHADOW, true)
	draw_rect(page, Palette.PAPER_BONE, true)
	ArtKit.draw_ledger_grid(self, page, 32)
	if not TechArt.v3_enabled():
		ArtKit.draw_paper_grain(self, page, 19, 0.07)
	draw_rect(page, Palette.INK_SOFT, false, 2.0)

	# Folio mark — small FIELD LEDGER band so the shell stays on-world.
	draw_string(
		ThemeDB.fallback_font,
		page.position + Vector2(16, 22),
		tr("menu.folio_mark"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Palette.SLATE_TEAL
	)
	draw_line(
		page.position + Vector2(16, 28),
		page.position + Vector2(page.size.x - 16, 28),
		Palette.INK_SOFT,
		1.0
	)

	# Seed header strip along top margin.
	var seed_tex: Texture2D = ArtKit.tex("res://art/ui/seed_header_256x24.png")
	if seed_tex != null:
		draw_texture_rect(seed_tex, Rect2(page.position + Vector2(16, 36), Vector2(256, 24)), false)
	draw_string(
		_type("mono"),
		page.position + Vector2(280, 54),
		tr("menu.seed_strip"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Palette.SLATE_TEAL_SOFT
	)

	# Ambient maze — fossil walls + writing chalk path (the Steam capsule beat).
	_draw_ambient_lattice(page)

	# Brand lockup — hero-level, not nav text.
	var brand_x: float = page.position.x + 48
	var brand_y: float = page.position.y + page.size.y * 0.28
	draw_string(
		_type("display"),
		Vector2(brand_x, brand_y),
		tr("brand.title"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 64, Palette.INK_BLACK
	)
	# Rust rule under the title — the brand underline.
	draw_rect(Rect2(brand_x, brand_y + 10, 420, 3), Palette.RUST_FOSSIL, true)

	draw_string(
		_type("display"),
		Vector2(brand_x, brand_y + 42),
		tr("brand.tagline"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Palette.SLATE_TEAL
	)
	draw_string(
		_type("body"),
		Vector2(brand_x, brand_y + 68),
		tr("brand.blurb"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Palette.INK_SOFT
	)

	# Index-card plate behind the button column (right side) — paper-slot settle.
	# Card geometry matches CardColumn via field_index_card_rect / _sync_field_index_layout.
	var slot: float = clampf(_card_slot_t / 0.16, 0.0, 1.0)
	var y_off: float = (1.0 - slot) * 6.0
	var card: Rect2 = field_index_card_rect(vp, y_off)
	var shadow := Palette.PAPER_SHADOW
	shadow.a *= slot
	draw_rect(Rect2(card.position + Vector2(3, 4), card.size), shadow, true)
	# paper_deep backer lift, then bone face.
	var deep := Palette.PAPER_DEEP
	deep.a = slot
	draw_rect(Rect2(card.position + Vector2(2, 2), card.size), deep, true)
	var bone := Palette.PAPER_BONE
	bone.a = slot
	draw_rect(card, bone, true)
	draw_rect(card, Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, slot), false, 1.5)
	draw_rect(card.grow(-3.0), Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.45 * slot), false, 1.0)
	# Binder holes — diegetic Field Index chrome (QW-2).
	var hole_step: float = maxf(56.0, (card.size.y - 52.0) / 5.0)
	for i in range(5):
		var hy: float = card.position.y + 28.0 + float(i) * hole_step
		if hy > card.end.y - 24.0:
			break
		draw_circle(Vector2(card.position.x + 12.0, hy), 3.5, Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, slot))
		draw_circle(Vector2(card.position.x + 12.0, hy), 1.8, bone)
	# Card header double rule.
	draw_line(card.position + Vector2(22, 34), card.position + Vector2(card.size.x - 16, 34), Palette.INK_SOFT, 1.0)
	draw_line(card.position + Vector2(22, 38), card.position + Vector2(card.size.x - 16, 38), Palette.INK_SOFT, 1.0)
	draw_string(
		_type("mono"),
		card.position + Vector2(26, 26),
		tr("menu.demo_index") if DemoBuild.is_demo() else tr("menu.field_index"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12,
		Color(Palette.SLATE_TEAL.r, Palette.SLATE_TEAL.g, Palette.SLATE_TEAL.b, slot)
	)

	# Focus underlines drawn under whichever button has focus.
	_draw_button_underlines(card)

	# Bottom punch-card ribbon.
	_draw_punchcard_ribbon(page)

	# Footer controls hint — Deck glyphs > remap labels > localized default.
	draw_string(
		_type("mono"),
		Vector2(page.position.x + 16, page.end.y - 14),
		_footer_controls_hint(),
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
	# Folding walls at the mirrored end — discrete stamp when buffer fills (no breath).
	var fill: int = int(_demo_progress) % 31
	var fold_on: bool = fill > 22
	if fold_on:
		for j in range(3):
			var fp: Vector2i = _demo_path[mini(visible - 1, _demo_path.size() - 1)]
			var mx: float = origin.x + (26 - fp.x * 0.55) * cell
			var my: float = origin.y + (fp.y - 6) * 0.55 * cell + j * cell * 0.55
			var fr := Rect2(mx, my, cell - 1, cell - 1)
			var fc := Color(Palette.RUST_FOSSIL.r, Palette.RUST_FOSSIL.g, Palette.RUST_FOSSIL.b, 0.78)
			draw_rect(fr, fc, true)


func _footer_controls_hint() -> String:
	# last_device is KEYBOARD=0 at boot — only use glyph path for gamepad / Deck.
	if has_node("/root/InputGlyphs") and InputGlyphs.using_gamepad():
		return InputGlyphs.controls_line()
	return _controls_hint()


func _controls_hint() -> String:
	var remap := get_node_or_null("/root/ActionRemap")
	if remap == null or not remap.has_method("get_binding_labels"):
		return tr("menu.controls_hint")
	var up: String = ", ".join(remap.get_binding_labels("move_up"))
	var restart: String = ", ".join(remap.get_binding_labels("restart"))
	var undo: String = ", ".join(remap.get_binding_labels("undo"))
	var pause: String = ", ".join(remap.get_binding_labels("pause_menu"))
	return tr("menu.controls_hint_remap") % [up, restart, undo, pause]


func _draw_button_underlines(_card: Rect2) -> void:
	var buttons: Array = [continue_button, start_button, daily_button]
	if endless_button:
		buttons.append(endless_button)
	if hard_button and hard_button.visible:
		buttons.append(hard_button)
	if museum_button:
		buttons.append(museum_button)
	buttons.append(settings_button)
	if colophon_button:
		buttons.append(colophon_button)
	buttons.append(quit_button)
	if _wishlist_button != null:
		buttons.insert(buttons.size() - 1, _wishlist_button)
	LedgerChrome.draw_index_underlines(self, buttons, global_position)


func _draw_punchcard_ribbon(page: Rect2) -> void:
	var y: float = page.end.y - 48
	var x: float = page.position.x + 16
	draw_string(_type("mono"), Vector2(x, y - 4), tr("menu.buffer"), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Palette.SLATE_TEAL)
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
		# Discrete warn stamp on a full buffer — no blink pulse.
		if i == 29 and (int(_demo_progress) % 31) > 28:
			tex = cells[3]
		var cell_r := Rect2(x + i * 14, y, 12, 16)
		if tex != null:
			draw_texture_rect(tex, cell_r, false)
		else:
			draw_rect(cell_r, Palette.INK_SOFT, false, 1.0)


func _type(role: String = "display") -> Font:
	if has_node("/root/LedgerType"):
		return LedgerType.font_or_fallback(role)
	return ThemeDB.fallback_font
