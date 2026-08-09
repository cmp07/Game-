extends Control
##
## Main menu — premium Field Ledger title shell (menu-premium-v1 composition).
## Open folio: verso (brand + large seal + habit silhouette) | spine | recto (Field Index).
## One composed viewport — not scattered widgets. No glass / glow / purple / cadmium chrome.
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
var _demo_path: Array = []  ## Vector2i points for ambient chalk walk
var _demo_progress: float = 0.0
var _settings_overlay: Control = null
var _colophon_overlay: Control = null
var _wishlist_button: Button = null
var _card_slot_t: float = 0.0
var _focus_underline_t: float = 1.0
var _last_focused: Control = null
var _handoff_from_boot: bool = false

## Ambient chalk path does not need a full 60 Hz canvas rebuild.
const AMBIENT_REDRAW_HZ: float = 15.0
var _redraw_accum: float = 0.0
var _last_demo_step: int = -1

## Paper-slot settle (UI_DIEGETIC_V3 §7) — card Y+6 → 0 in ≤180 ms.
const CARD_SLOT_SEC: float = 0.16
## Focus underline draw-in.
const FOCUS_UNDERLINE_SEC: float = 0.08


func _ready() -> void:
	_localize_chrome()
	if has_node("/root/LocaleManager"):
		LocaleManager.locale_changed.connect(func(_l): _localize_chrome())
	var has: bool = GameState.can_continue()
	continue_button.disabled = not has
	continue_button.modulate = Color(1, 1, 1, 1.0 if has else 0.38)
	# Arm before any grab_focus so cold boot cannot chirp (QW-2 / AUDIO_V3).
	if has_node("/root/AudioDirector") and AudioDirector.has_method("arm_ui_feel"):
		AudioDirector.arm_ui_feel()
	start_button.grab_focus()
	_last_focused = start_button
	_focus_underline_t = 0.0

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
	# Boot→menu handoff starts the card mid-slot so paper continuity reads as one turn.
	_card_slot_t = 0.04 if _handoff_from_boot else 0.0
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
	_style_index_actions()
	_style_meta_as_ledger_lines()
	## Full gamepad path: vertical focus neighbors, no keyboard text entry.
	_ensure_gamepad_focus_chain()
	_wire_index_feel()
	# Cold boot stays silent — ui.select/hover only after arm window (QW-2).


## Called by Main after boot_title so the card settle continues the paper turn.
func begin_boot_handoff() -> void:
	_handoff_from_boot = true
	_card_slot_t = 0.04


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_sync_field_index_layout()
		queue_redraw()


## Outer folio frame used by draw + Control layout (keeps Field Index diegetic).
func _ledger_page_rect(vp: Vector2) -> Rect2:
	return Rect2(32.0, 22.0, vp.x - 64.0, vp.y - 44.0)


## Open-folio leaves — verso (brand) | spine | recto (Field Index).
func folio_leaves(vp: Vector2 = Vector2.ZERO) -> Dictionary:
	if vp.x < 2.0:
		vp = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size
	var outer: Rect2 = _ledger_page_rect(vp)
	var gutter: float = 30.0 if outer.size.x >= 1100.0 else 18.0
	var mid_x: float = outer.position.x + outer.size.x * 0.5
	var left := Rect2(
		outer.position.x,
		outer.position.y,
		maxf(80.0, mid_x - gutter * 0.5 - outer.position.x),
		outer.size.y
	)
	var right := Rect2(
		mid_x + gutter * 0.5,
		outer.position.y,
		maxf(80.0, outer.end.x - (mid_x + gutter * 0.5)),
		outer.size.y
	)
	var spine := Rect2(left.end.x, outer.position.y, gutter, outer.size.y)
	return {"outer": outer, "left": left, "right": right, "spine": spine}


## Chrome insets around CardColumn inside the Field Index plate.
## Top pad holds FIELD INDEX title + letterpress rules (meta lives in column).
const _INDEX_PAD_L: float = 48.0
const _INDEX_PAD_R: float = 32.0
const _INDEX_PAD_T: float = 72.0
# Extra bottom pad for ink-craft underlines drawn below Control rects.
const _INDEX_PAD_B: float = 48.0


## Recto Field Index plate — fills the right folio leaf; never a postage stamp.
func field_index_card_rect(vp: Vector2 = Vector2.ZERO, y_off: float = 0.0) -> Rect2:
	if vp.x < 2.0:
		vp = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size
	var leaves: Dictionary = folio_leaves(vp)
	var right: Rect2 = leaves["right"]
	var left: Rect2 = leaves["left"]
	# Card hugs the recto leaf — fills the right page, clears the spine.
	var side_pad: float = 22.0 if right.size.x < 420.0 else 36.0
	var top_pad: float = 28.0 if right.size.y < 700.0 else 40.0
	var bottom_pad: float = 22.0 if right.size.y < 700.0 else 28.0
	var card_x: float = right.position.x + side_pad
	var card_w: float = maxf(240.0, right.size.x - side_pad * 2.0)
	# Never spill into the verso brand leaf.
	if card_x < left.end.x + 4.0:
		card_x = left.end.x + 4.0
		card_w = maxf(220.0, right.end.x - side_pad - card_x)
	var top: float = right.position.y + top_pad + y_off
	var bottom_limit: float = right.end.y - bottom_pad
	var card_h: float = clampf(right.size.y * 0.90, 360.0, bottom_limit - top)
	var col: Control = get_node_or_null("CardColumn") as Control
	if col != null and col.get_child_count() > 0:
		var content_h: float = col.size.y
		if content_h < 8.0:
			content_h = col.get_combined_minimum_size().y
		var needed: float = content_h + _INDEX_PAD_T + _INDEX_PAD_B
		var presence: float = clampf(right.size.y * 0.88, 360.0, bottom_limit - top)
		card_h = clampf(maxf(needed, presence), 320.0, bottom_limit - top)
	else:
		card_h = minf(card_h, bottom_limit - top)
	return Rect2(card_x, top, card_w, maxf(300.0, card_h))


## Inner content inset: binder holes left, FIELD INDEX header top.
func field_index_content_rect(card: Rect2) -> Rect2:
	return Rect2(
		card.position.x + _INDEX_PAD_L,
		card.position.y + _INDEX_PAD_T,
		maxf(200.0, card.size.x - _INDEX_PAD_L - _INDEX_PAD_R),
		maxf(200.0, card.size.y - _INDEX_PAD_T - _INDEX_PAD_B)
	)


func _slot_y_off() -> float:
	var slot: float = clampf(_card_slot_t / CARD_SLOT_SEC, 0.0, 1.0)
	# EaseOut.
	var eased: float = 1.0 - (1.0 - slot) * (1.0 - slot)
	return (1.0 - eased) * 6.0


func _slot_alpha() -> float:
	return clampf(_card_slot_t / CARD_SLOT_SEC, 0.0, 1.0)


func _style_index_actions(compact: bool = false) -> void:
	# title_type_scale treats page_h < 700 as compact — do not pass 720 here.
	var scale: Dictionary = LedgerChrome.title_type_scale(560.0 if compact else 1080.0)
	var idx_px: int = int(scale.get("index", LedgerChrome.TYPE_INDEX))
	var primary_px: int = int(scale.get("index_primary", LedgerChrome.TYPE_INDEX_PRIMARY))
	LedgerChrome.style_index_button(start_button, true, primary_px)
	LedgerChrome.style_index_button(continue_button, false, idx_px)
	LedgerChrome.style_index_button(daily_button, false, idx_px)
	if endless_button:
		LedgerChrome.style_index_button(endless_button, false, idx_px)
	if hard_button:
		LedgerChrome.style_index_button(hard_button, false, idx_px)
	if museum_button:
		LedgerChrome.style_index_button(museum_button, false, idx_px)
	LedgerChrome.style_index_button(settings_button, false, idx_px)
	if colophon_button:
		LedgerChrome.style_index_button(colophon_button, false, idx_px)
	LedgerChrome.style_index_button(quit_button, false, idx_px)
	if _wishlist_button != null:
		LedgerChrome.style_index_button(_wishlist_button, false, idx_px)
	# Deck / editor short pages: keep row advance tight so the plate can hug actions.
	if compact:
		_clamp_index_button_fonts(idx_px, primary_px)


func _clamp_index_button_fonts(idx_px: int, primary_px: int) -> void:
	## Short pages: Regular face + zeroed StyleBox margins so rows stay Deck-safe.
	var face: Font = null
	if has_node("/root/LedgerType"):
		face = LedgerType.font_or_fallback("display")
	var buttons: Array = _index_action_buttons()
	for b in buttons:
		if b == null:
			continue
		var btn: Button = b as Button
		var px: int = primary_px if btn == start_button else idx_px
		if face != null:
			btn.add_theme_font_override("font", face)
		btn.add_theme_font_size_override("font_size", px)
		for state in ["normal", "pressed", "hover", "focus", "disabled"]:
			var sb := StyleBoxEmpty.new()
			sb.content_margin_left = 0
			sb.content_margin_right = 0
			sb.content_margin_top = 0
			sb.content_margin_bottom = 0
			btn.add_theme_stylebox_override(state, sb)


func _apply_index_row_metrics(compact: bool) -> void:
	var row_h: float = 26.0 if compact else 40.0
	var primary_h: float = 30.0 if compact else 48.0
	# Pack rows to the top of the Field Index plate — never vertically expand.
	var shrink_top: int = Control.SIZE_SHRINK_BEGIN
	_style_index_actions(compact)
	_style_meta_as_ledger_lines(compact)
	var buttons: Array = [
		continue_button, daily_button, endless_button, hard_button,
		museum_button, settings_button, colophon_button, quit_button, _wishlist_button,
	]
	for b in buttons:
		if b == null:
			continue
		var btn: Button = b as Button
		# Clamp after font style — content min-size can otherwise balloon past Deck budget.
		btn.custom_minimum_size = Vector2(240.0, row_h)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = shrink_top
		btn.add_theme_constant_override("h_separation", 0)
	if start_button:
		start_button.custom_minimum_size = Vector2(240.0, primary_h)
		start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		start_button.size_flags_vertical = shrink_top


func _style_meta_as_ledger_lines(compact: bool = false) -> void:
	## Quiet ledger lines inside the card header — never compete with brand.
	if subtitle:
		LedgerChrome.style_ink_label(
			subtitle,
			Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.72),
			11 if compact else 13
		)
		# Prefer single quiet lines — wrapping balloons the plate past Deck budget.
		subtitle.autowrap_mode = TextServer.AUTOWRAP_OFF
		subtitle.clip_text = true
		subtitle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		subtitle.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		subtitle.custom_minimum_size = Vector2(0, 18 if compact else 22)
	if meta_label:
		LedgerChrome.style_ink_label(
			meta_label,
			Color(Palette.SLATE_TEAL.r, Palette.SLATE_TEAL.g, Palette.SLATE_TEAL.b, 0.80),
			11 if compact else 13
		)
		meta_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		meta_label.clip_text = true
		meta_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		meta_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		meta_label.custom_minimum_size = Vector2(0, 18 if compact else 22)


func _sync_field_index_layout() -> void:
	var col: Control = get_node_or_null("CardColumn") as Control
	if col == null:
		return
	var vp: Vector2 = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size
	var page: Rect2 = _ledger_page_rect(vp)
	var compact: bool = page.size.y < 700.0
	_apply_index_row_metrics(compact)
	col.add_theme_constant_override("separation", 4 if compact else 8)
	# Place column using the shared card geometry (content-driven height + slot settle).
	var y_off: float = _slot_y_off()
	var card: Rect2 = field_index_card_rect(vp, y_off)
	var inset: Rect2 = field_index_content_rect(card)
	col.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	col.position = inset.position
	var needed: float = col.get_combined_minimum_size().y
	col.size = Vector2(inset.size.x, maxf(needed, 1.0))
	# Second pass: card height may shrink/grow once column min size is known.
	card = field_index_card_rect(vp, y_off)
	inset = field_index_content_rect(card)
	col.position = inset.position
	col.size = Vector2(inset.size.x, maxf(col.get_combined_minimum_size().y, 1.0))
	col.modulate = Color(1, 1, 1, _slot_alpha())


## Regression helper — every visible index action must sit inside the plate.
func verify_field_index_layout() -> bool:
	# Force settled slot so column + plate share one geometry during QA.
	_card_slot_t = CARD_SLOT_SEC
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
			var mins: Vector2 = c.get_combined_minimum_size()
			printerr(
				"Field Index layout: %s at %s outside card %s (min=%s font=%s)" % [
					c.name, str(local), str(card), str(mins),
					str(c.get_theme_font_size("font_size"))
				]
			)
			ok = false
	# Verso brand leaf must stay clear of the recto plate (no spine clip).
	var leaves: Dictionary = folio_leaves(vp)
	var left_leaf: Rect2 = leaves["left"]
	if card.position.x < left_leaf.end.x - 0.5:
		printerr(
			"Field Index layout: card overlaps verso leaf (card.x=%.1f left.end=%.1f)" % [
				card.position.x, left_leaf.end.x
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
		if _reduce_motion():
			_card_slot_t = CARD_SLOT_SEC
			_focus_underline_t = FOCUS_UNDERLINE_SEC


func _reduce_motion() -> bool:
	var store := get_node_or_null("/root/SettingsStore")
	if store != null and store.has_method("get_value"):
		return bool(store.get_value("accessibility", "reduce_motion", false))
	return false


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
	## Quiet diegetic header lines only — never clinical "Filed N/M 70%" chrome.
	var has: bool = GameState.can_continue()
	var stars: int = GameState.total_stars_earned()
	if has:
		subtitle.visible = true
		subtitle.text = tr("menu.subtitle_progress") % [
			GameState.run_progress_index() + 1,
			GameState.chambers_in_run(),
			stars,
		]
	elif DemoBuild.is_demo():
		subtitle.visible = true
		subtitle.text = tr("menu.subtitle_demo")
	elif GameState.is_run_complete():
		subtitle.visible = true
		subtitle.text = tr("menu.subtitle_wing_complete") % stars
	else:
		# Fresh title: keep the card header quiet — wing line alone is enough.
		subtitle.visible = true
		subtitle.text = tr("menu.subtitle_fresh") % ChamberBook.chamber_count()
	_refresh_hard_button()
	var entry: Dictionary = GameState.today_daily_entry()
	var today: String = str(entry.get("date", GameState._today_label()))
	var friend_code: String = str(entry.get("friend_code", ""))
	var dbest: int = GameState.daily_best_for_today()
	var ebest: int = int(GameState.endless_best_depth)
	# Quiet header: omit zero bests so a fresh ledger does not read as clinical stats.
	if dbest <= 0 and ebest <= 0 and not DemoBuild.is_demo():
		if friend_code != "":
			meta_label.text = tr("menu.daily_meta_quiet_code") % [today, friend_code]
		else:
			meta_label.text = tr("menu.daily_meta_quiet") % today
	elif DemoBuild.is_demo():
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
	_style_index_actions()
	_wire_index_feel()
	_sync_field_index_layout()


func _index_action_buttons() -> Array:
	var order: Array = [continue_button, start_button, daily_button]
	if endless_button:
		order.append(endless_button)
	if hard_button:
		order.append(hard_button)
	if museum_button:
		order.append(museum_button)
	order.append(settings_button)
	if colophon_button:
		order.append(colophon_button)
	order.append(quit_button)
	if _wishlist_button != null:
		order.insert(order.size() - 1, _wishlist_button)
	return order


func _wire_index_feel() -> void:
	LedgerChrome.wire_index_feel(_index_action_buttons())


func _ensure_gamepad_focus_chain() -> void:
	var order: Array = _index_action_buttons()
	var focus_order: Array = []
	for btn in order:
		if btn == null:
			continue
		if btn == hard_button and (not hard_button.visible or hard_button.disabled):
			continue
		focus_order.append(btn)
	LedgerChrome.wire_vertical_focus(focus_order)


func _build_demo_path() -> void:
	## Ambient chalk path that writes itself behind the seal — the game's verb as wallpaper.
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
	# Seed a late-path so chalk + fossil stamps fill the brand blotter on open.
	_demo_progress = 24.0


func _process(delta: float) -> void:
	_t += delta
	var reduce: bool = _reduce_motion()
	if reduce:
		_card_slot_t = CARD_SLOT_SEC
		_focus_underline_t = FOCUS_UNDERLINE_SEC
	else:
		if _card_slot_t < CARD_SLOT_SEC:
			_card_slot_t = minf(_card_slot_t + delta, CARD_SLOT_SEC)
			_sync_field_index_layout()
		if _focus_underline_t < FOCUS_UNDERLINE_SEC:
			_focus_underline_t = minf(_focus_underline_t + delta, FOCUS_UNDERLINE_SEC)
	# Selection tick — underline redraws when focus moves (no fold pulse).
	var focused: Control = get_viewport().gui_get_focus_owner() as Control
	if focused != _last_focused:
		_last_focused = focused
		if not reduce:
			_focus_underline_t = 0.0
		# Audio selection tick owned by LedgerChrome.wire_index_feel / AudioDirector.
	_demo_progress = fmod(_demo_progress + delta * 3.2, float(_demo_path.size()) + 8.0)
	var step: int = int(_demo_progress)
	_redraw_accum += delta
	if (
		step != _last_demo_step
		or _redraw_accum >= 1.0 / AMBIENT_REDRAW_HZ
		or _card_slot_t < CARD_SLOT_SEC
		or _focus_underline_t < FOCUS_UNDERLINE_SEC
	):
		_last_demo_step = step
		_redraw_accum = 0.0
		queue_redraw()


func _index_buttons() -> Array:
	return _index_action_buttons()


func _draw() -> void:
	var vp: Vector2 = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size

	# Lightbox desk + open folio — two filled leaves, spine kills the dead center void.
	ArtKit.draw_desk_margin(self, vp, 3, 0.07 if not TechArt.v3_enabled() else 0.035)
	var outer: Rect2 = _ledger_page_rect(vp)
	var leaves: Dictionary = ArtKit.draw_open_folio(self, outer, {
		"grain_seed": 19,
		"grain_a": 0.055 if not TechArt.v3_enabled() else 0.03,
		"major_cell": 32,
		"gutter": 30.0 if outer.size.x >= 1100.0 else 18.0,
	})
	var left: Rect2 = leaves["left"]
	var right: Rect2 = leaves["right"]

	var scale: Dictionary = LedgerChrome.title_type_scale(outer.size.y)
	var folio_px: int = int(scale.get("folio", LedgerChrome.TYPE_FOLIO))
	var seed_px: int = int(scale.get("seed", LedgerChrome.TYPE_SEED))
	var brand_px: int = int(scale.get("brand", LedgerChrome.TYPE_BRAND))
	var tag_px: int = int(scale.get("tagline", LedgerChrome.TYPE_TAGLINE))
	var blurb_px: int = int(scale.get("blurb", LedgerChrome.TYPE_BLURB))
	var rule_w: float = float(scale.get("rule_w", LedgerChrome.BRAND_RULE_W))
	var rule_len: float = float(scale.get("rule_len", LedgerChrome.BRAND_RULE_LEN))
	var header_px: int = int(scale.get("card_header", LedgerChrome.TYPE_CARD_HEADER))

	# Verso folio mark + seed strip — diegetic ledger, not chamber HUD.
	draw_string(
		_type("mono"),
		left.position + Vector2(28, 28),
		tr("menu.folio_mark"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, folio_px, Palette.SLATE_TEAL
	)
	ArtKit.draw_letterpress_rule(
		self,
		left.position + Vector2(28, 36),
		Vector2(left.end.x - 24.0, left.position.y + 36.0),
		Palette.INK_SOFT,
		1.5,
		19
	)
	var seed_tex: Texture2D = ArtKit.tex("res://art/ui/seed_header_256x24.png")
	if seed_tex != null:
		draw_texture_rect(seed_tex, Rect2(left.position + Vector2(28, 46), Vector2(240, 22)), false)
	draw_string(
		_type("mono"),
		left.position + Vector2(28, 86),
		tr("menu.seed_strip"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, seed_px, Palette.SLATE_TEAL_SOFT
	)

	# Brand lockup — hero of the verso leaf.
	var brand_x: float = left.position.x + 40.0
	var brand_y: float = left.position.y + left.size.y * 0.16
	draw_string(
		_type("display"),
		Vector2(brand_x, brand_y),
		tr("brand.title"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, brand_px, Palette.INK_BLACK
	)
	var brand_rule_len: float = minf(rule_len, left.end.x - brand_x - 36.0)
	ArtKit.draw_letterpress_rule(
		self,
		Vector2(brand_x, brand_y + 14.0),
		Vector2(brand_x + brand_rule_len, brand_y + 14.0),
		Palette.RUST_FOSSIL,
		rule_w,
		42
	)
	ArtKit.draw_oxide_flecks(
		self,
		Rect2(brand_x, brand_y + 10.0, brand_rule_len * 0.55, 12.0),
		43,
		6,
		0.55
	)
	draw_string(
		_type("display"),
		Vector2(brand_x, brand_y + 50),
		tr("brand.tagline"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, tag_px, Palette.SLATE_TEAL
	)
	draw_string(
		_type("body"),
		Vector2(brand_x, brand_y + 80),
		tr("brand.blurb"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, blurb_px, Palette.INK_SOFT
	)

	# Habit silhouette plate fills the verso under the brand — one visual plane, no mid-leaf void.
	var sil_top: float = brand_y + 104.0
	var sil := Rect2(
		left.position.x + 28.0,
		sil_top,
		maxf(200.0, left.size.x - 56.0),
		maxf(140.0, left.end.y - sil_top - 24.0)
	)
	if sil.size.y >= 100.0:
		draw_string(
			_type("mono"),
			Vector2(sil.position.x + 10.0, sil.position.y - 8.0),
			tr("menu.habit_silhouette"),
			HORIZONTAL_ALIGNMENT_LEFT, -1, folio_px, Palette.SLATE_TEAL
		)
		ArtKit.draw_habit_silhouette(self, sil, {
			"seed": 61,
			"progress": _demo_progress,
			"cell": 20.0 if left.size.y >= 700.0 else 13.0,
		})

	# Large surveyor seal — upper-left of the specimen so the habit maze stays visible around it.
	var seal_r: float = 168.0 if left.size.y >= 700.0 else 78.0
	seal_r = minf(seal_r, minf(sil.size.x, sil.size.y) * 0.28)
	var seal_c := Vector2(
		sil.position.x + seal_r + 36.0,
		sil.position.y + seal_r + 40.0
	)
	draw_circle(
		seal_c + Vector2(5, 6),
		seal_r + 14.0,
		Color(Palette.PAPER_SHADOW.r, Palette.PAPER_SHADOW.g, Palette.PAPER_SHADOW.b, 0.28)
	)
	# Soft bone disc so the stamp reads over local maze ink without erasing the specimen.
	draw_circle(
		seal_c,
		seal_r + 6.0,
		Color(Palette.PAPER_BONE.r, Palette.PAPER_BONE.g, Palette.PAPER_BONE.b, 0.82)
	)
	ArtKit.draw_seal_stamp(self, seal_c, seal_r, {
		"rot_deg": -6.0,
		"color": Palette.SLATE_TEAL,
		"alpha": 0.94,
		"seed": 42,
		"ring_w": 4.6,
		"caption": "FIELD",
		"font": _type("display"),
		"font_size": maxi(20, folio_px + 10),
		"hero": true,
	})
	_draw_seal_lattice(seal_c, seal_r * 0.52)
	draw_string(
		_type("mono"),
		Vector2(sil.position.x + 10.0, sil.end.y - 14.0),
		tr("menu.seal_caption"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, folio_px + 1, Palette.INK_SOFT
	)

	# Recto Field Index — fills the right leaf as one tactile object.
	var y_off: float = _slot_y_off()
	var slot_a: float = _slot_alpha()
	var card: Rect2 = field_index_card_rect(vp, y_off)
	# Quiet recto header so the right leaf also reads as a document, not a widget.
	draw_string(
		_type("mono"),
		right.position + Vector2(28, 28),
		tr("menu.recto_mark"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, folio_px, Palette.SLATE_TEAL
	)

	ArtKit.draw_index_card(self, card, {
		"alpha": slot_a,
		"shadow_off": Vector2(8, 11),
		"binder_holes": 7,
		"grain_seed": 11,
		"grain_a": 0.055,
		"fiber_a": 0.06,
		"header_rules": true,
		"deep_backer": true,
		"binder_clip": true,
		"thickness": 3.5,
		"oxide_accents": true,
		"skip_grain": false,
	})
	draw_string(
		_type("mono"),
		card.position + Vector2(32, 30),
		tr("menu.demo_index") if DemoBuild.is_demo() else tr("menu.field_index"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, header_px,
		Color(Palette.SLATE_TEAL.r, Palette.SLATE_TEAL.g, Palette.SLATE_TEAL.b, slot_a)
	)
	draw_string(
		_type("mono"),
		Vector2(card.position.x + 32.0, card.end.y - 18.0),
		tr("menu.card_foot"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(10, folio_px),
		Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.55 * slot_a)
	)

	_draw_button_underlines(card)

	# Title shell is NOT a paused chamber — no BUFFER ribbon, no Move/Restart/Undo footer.


func _draw_seal_lattice(center: Vector2, half: float) -> void:
	## Ink lattice fragment inside the surveyor seal — process-visible glyph.
	var cell: float = maxf(6.0, half / 2.6)
	var grid_origin: Vector2 = center - Vector2(cell * 2.5, cell * 2.0)
	var walls: Array = [
		Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(4, 0), Vector2i(5, 0),
		Vector2i(0, 1), Vector2i(5, 1), Vector2i(0, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(5, 2),
		Vector2i(0, 3), Vector2i(5, 3), Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4), Vector2i(5, 4),
	]
	var fossil: Array = [Vector2i(3, 0), Vector2i(3, 1), Vector2i(4, 1), Vector2i(4, 2)]
	for w in walls:
		var r := Rect2(grid_origin + Vector2(w.x * cell, w.y * cell), Vector2(cell - 1.2, cell - 1.2))
		ArtKit.draw_letterpress_wall(self, r, false, 15)
	for w in fossil:
		var r2 := Rect2(grid_origin + Vector2(w.x * cell, w.y * cell), Vector2(cell - 1.2, cell - 1.2))
		ArtKit.draw_letterpress_wall(self, r2, true, 15)


func _draw_button_underlines(_card: Rect2) -> void:
	var progress: float = clampf(_focus_underline_t / FOCUS_UNDERLINE_SEC, 0.0, 1.0)
	LedgerChrome.draw_index_underlines(self, _index_buttons(), global_position, progress)


func _type(role: String = "display") -> Font:
	if has_node("/root/LedgerType"):
		return LedgerType.font_or_fallback(role)
	return ThemeDB.fallback_font
