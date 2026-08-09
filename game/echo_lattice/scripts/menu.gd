extends Control
##
## Main menu — dense Field Ledger craft (boutique title shell).
## Type roles: MENU_TYPE_SYSTEM.md via LedgerType (Bold brand / Medium actions).
## Open folio @ 1920×1080: verso ~52% (ECHO LATTICE hero + gameplay film plate)
## | spine | recto ~42% (Field Index, compact action block). Explicit anchors — never hope.
## Zero chamber HUD. Selection = ink rule + rust tick. No glass / glow / purple / cadmium.
## Left visual anchor = diegetic gameplay preview (not a static empty maze).
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
const PREVIEW_SCRIPT: Script = preload("res://scripts/ui/menu_gameplay_preview.gd")

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
var _settings_overlay: Control = null
var _colophon_overlay: Control = null
var _wishlist_button: Button = null
var _card_slot_t: float = 0.0
var _focus_underline_t: float = 1.0
var _last_focused: Control = null
var _handoff_from_boot: bool = false
var _gameplay_preview: Control = null

## Film-plate chrome + focus underline do not need a full 60 Hz canvas rebuild.
const AMBIENT_REDRAW_HZ: float = 15.0
var _redraw_accum: float = 0.0

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

	_ensure_gameplay_preview()
	# Cold boot / screenshot / selftest: Field Index must be fully inked in frame 0.
	# Only boot→menu handoff animates the paper-slot settle (mid-slot → rest).
	if _handoff_from_boot:
		_card_slot_t = 0.04
	else:
		_card_slot_t = CARD_SLOT_SEC
	set_process(true)
	_sync_field_index_layout()
	_sync_preview_layout()
	call_deferred("_sync_field_index_layout")
	call_deferred("_sync_preview_layout")
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
		_sync_preview_layout()
		queue_redraw()
	elif what == NOTIFICATION_VISIBILITY_CHANGED:
		if _gameplay_preview != null:
			if is_visible_in_tree():
				if _gameplay_preview.has_method("resume_preview"):
					_gameplay_preview.resume_preview()
			elif _gameplay_preview.has_method("pause_preview"):
				_gameplay_preview.pause_preview()
	elif what == NOTIFICATION_EXIT_TREE:
		if _gameplay_preview != null and _gameplay_preview.has_method("pause_preview"):
			_gameplay_preview.pause_preview()


## HARD COMPOSITION SPEC — fail CI if these anchors drift (see test_menu_composition_density).
## Brand column LEFT ~52%; Field Index RIGHT ~42%; spine trough takes the remainder (~6%).
## Brand leaf ~51–52%; Field Index leaf ~43–44% so the card itself lands in 40–48% of viewport.
const VERSO_FRAC: float = 0.515
const RECTO_FRAC: float = 0.435
const BRAND_MIN_PX: int = 72
const PAGE_MARGIN_X: float = 20.0
const PAGE_MARGIN_Y: float = 14.0
## Max empty (no ink/ui layout mass) fraction of the full inner page at 1920×1080.
const MAX_EMPTY_FRAC: float = 0.28
## Left-leaf (verso) pixel empty mass must stay under this (PNG CI gate).
const MAX_VERSO_EMPTY_FRAC: float = 0.22
## Blurb → film plate air — dense ledger packing (never a mid-leaf cream band).
const SPECIMEN_GAP: float = 12.0
## Gameplay film plate target height as a fraction of verso leaf height.
const PREVIEW_VERSO_FRAC: float = 0.64
const PREVIEW_VERSO_FRAC_MIN: float = 0.55
const PREVIEW_VERSO_FRAC_MAX: float = 0.70
## Field Index action pitch @ 1080p — compact block, not stretched leading.
const INDEX_ROW_H: float = 38.0
const INDEX_PRIMARY_H: float = 42.0
const INDEX_ROW_SEP: int = 4

## Chrome insets around CardColumn inside the Field Index plate.
## Top pad holds ONE Field Index title + letterpress rules (meta lives in column).
## Left pad is content-hugging (no binder-hole gutter on boutique title card).
const _INDEX_PAD_L: float = 36.0
const _INDEX_PAD_R: float = 28.0
const _INDEX_PAD_T: float = 52.0
# Extra bottom pad for selection baseline drawn below Control rects.
const _INDEX_PAD_B: float = 28.0


## Outer folio frame — paper page fills the viewport (tight desk margin, no dead void).
func _ledger_page_rect(vp: Vector2) -> Rect2:
	return Rect2(
		PAGE_MARGIN_X,
		PAGE_MARGIN_Y,
		maxf(80.0, vp.x - PAGE_MARGIN_X * 2.0),
		maxf(80.0, vp.y - PAGE_MARGIN_Y * 2.0)
	)


## Open-folio leaves — verso (brand) ~52% | spine | recto (Field Index) ~42%.
func folio_leaves(vp: Vector2 = Vector2.ZERO) -> Dictionary:
	if vp.x < 2.0:
		vp = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size
	var outer: Rect2 = _ledger_page_rect(vp)
	var left_w: float = outer.size.x * VERSO_FRAC
	var right_w: float = outer.size.x * RECTO_FRAC
	var gutter: float = maxf(14.0, outer.size.x - left_w - right_w)
	# Keep fractions exact when float noise accumulates.
	if gutter + left_w + right_w > outer.size.x:
		gutter = maxf(12.0, outer.size.x - left_w - right_w)
	var left := Rect2(outer.position.x, outer.position.y, left_w, outer.size.y)
	var right := Rect2(
		outer.end.x - right_w,
		outer.position.y,
		right_w,
		outer.size.y
	)
	var spine := Rect2(left.end.x, outer.position.y, gutter, outer.size.y)
	return {"outer": outer, "left": left, "right": right, "spine": spine}


## Recto Field Index plate — ~40–48% of viewport width, full readable height.
func field_index_card_rect(vp: Vector2 = Vector2.ZERO, y_off: float = 0.0) -> Rect2:
	if vp.x < 2.0:
		vp = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size
	var leaves: Dictionary = folio_leaves(vp)
	var right: Rect2 = leaves["right"]
	var left: Rect2 = leaves["left"]
	# Card fills the recto leaf — boutique index, not a postage stamp in a cream void.
	var side_pad: float = 12.0 if right.size.x < 420.0 else 16.0
	var top_pad: float = 16.0 if right.size.y < 700.0 else 20.0
	var bottom_pad: float = 14.0 if right.size.y < 700.0 else 18.0
	var card_x: float = right.position.x + side_pad
	var card_w: float = maxf(240.0, right.size.x - side_pad * 2.0)
	# Never spill into the verso brand leaf.
	if card_x < left.end.x + 4.0:
		card_x = left.end.x + 4.0
		card_w = maxf(220.0, right.end.x - side_pad - card_x)
	var top: float = right.position.y + top_pad + y_off
	var bottom_limit: float = right.end.y - bottom_pad
	# Full readable height — occupy the leaf, not content-min postage.
	var card_h: float = maxf(300.0, bottom_limit - top)
	return Rect2(card_x, top, card_w, card_h)


## Inner content inset: FIELD INDEX header top; actions pack the plate.
func field_index_content_rect(card: Rect2) -> Rect2:
	return Rect2(
		card.position.x + _INDEX_PAD_L,
		card.position.y + _INDEX_PAD_T,
		maxf(200.0, card.size.x - _INDEX_PAD_L - _INDEX_PAD_R),
		maxf(200.0, card.size.y - _INDEX_PAD_T - _INDEX_PAD_B)
	)


## Explicit layout rects for draw + CI density (test_menu_composition_density).
## Returns ink/ui masses so measured empty region can stay under MAX_EMPTY_FRAC.
## Verso stack (top→bottom): micro header · brand · tag · blurb · gameplay film plate.
func composition_layout(vp: Vector2 = Vector2.ZERO) -> Dictionary:
	if vp.x < 2.0:
		vp = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size
	var leaves: Dictionary = folio_leaves(vp)
	var left: Rect2 = leaves["left"]
	var right: Rect2 = leaves["right"]
	var outer: Rect2 = leaves["outer"]
	var scale: Dictionary = LedgerChrome.title_type_scale(outer.size.y)
	var brand_px: int = maxi(BRAND_MIN_PX, int(scale.get("brand", LedgerChrome.TYPE_BRAND)))
	var brand_x: float = left.position.x + 36.0
	# Compact brand stack — tight under the one-line micro header (no mid void).
	var brand_top: float = left.position.y + 56.0
	var brand_y: float = brand_top + float(brand_px)
	# Brand rule spans most of the verso — kills the cream column beside the lockup.
	var brand_w: float = minf(
		maxf(float(scale.get("rule_len", LedgerChrome.BRAND_RULE_LEN)), left.size.x * 0.78),
		left.size.x - 64.0
	)
	# Brand lockup mass (title + rust rule + tagline + serif blurb) — compacted.
	var brand_block := Rect2(
		brand_x,
		brand_top,
		brand_w,
		float(brand_px) + 62.0
	)
	var plate_x: float = brand_x - 4.0
	var plate_w: float = maxf(200.0, left.end.x - plate_x - 20.0)
	# Prominent gameplay film plate under the brand — fills remaining verso (≥55%).
	# Target band is ~55–70% of leaf height; remainder below brand is absorbed so
	# the leaf never keeps a cream foot band under the media window.
	var preview_top: float = brand_block.end.y + SPECIMEN_GAP
	var avail_h: float = maxf(200.0, left.end.y - preview_top - 14.0)
	var preview_h: float = avail_h
	var preview_plate := Rect2(plate_x, preview_top, plate_w, preview_h)
	var card: Rect2 = field_index_card_rect(vp, 0.0)
	var occupied: float = (
		brand_block.get_area()
		+ preview_plate.get_area()
		+ card.get_area()
		+ float(leaves["spine"].get_area()) * 0.35
	)
	var page_a: float = maxf(1.0, outer.get_area())
	var empty_frac: float = clampf(1.0 - occupied / page_a, 0.0, 1.0)
	# Layout verso empty — brand stack is sparse type; film plate must dominate the leaf.
	var verso_a: float = maxf(1.0, left.get_area())
	var verso_occupied: float = brand_block.get_area() + preview_plate.get_area()
	var verso_empty_frac: float = clampf(1.0 - verso_occupied / verso_a, 0.0, 1.0)
	return {
		"outer": outer,
		"left": left,
		"right": right,
		"spine": leaves["spine"],
		"brand_block": brand_block,
		"preview_plate": preview_plate,
		"field_index": card,
		"brand_px": brand_px,
		"brand_x": brand_x,
		"brand_y": brand_y,
		"empty_frac": empty_frac,
		"verso_empty_frac": verso_empty_frac,
		"verso_frac": left.size.x / maxf(1.0, outer.size.x),
		"recto_frac": right.size.x / maxf(1.0, outer.size.x),
		"index_width_frac": card.size.x / maxf(1.0, vp.x),
		"preview_verso_frac": preview_plate.size.y / maxf(1.0, left.size.y),
	}


func _slot_y_off() -> float:
	var slot: float = clampf(_card_slot_t / CARD_SLOT_SEC, 0.0, 1.0)
	# EaseOut.
	var eased: float = 1.0 - (1.0 - slot) * (1.0 - slot)
	return (1.0 - eased) * 6.0


func _slot_alpha() -> float:
	return clampf(_card_slot_t / CARD_SLOT_SEC, 0.0, 1.0)


func _style_index_actions(compact: bool = false) -> void:
	# title_type_scale / LedgerType roles: page_h < 700 = Deck compact — do not pass 720 here.
	var scale: Dictionary = LedgerChrome.title_type_scale(560.0 if compact else 1080.0)
	var idx_px: int = int(scale.get("action", scale.get("index", LedgerChrome.TYPE_INDEX)))
	var primary_px: int = int(
		scale.get("action_primary", scale.get("index_primary", LedgerChrome.TYPE_INDEX_PRIMARY))
	)
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
	## Short pages: Medium action face (never mono) + zeroed StyleBox margins.
	var face: Font = null
	if has_node("/root/LedgerType"):
		if LedgerType.has_method("font_for_role"):
			face = LedgerType.font_for_role("action", idx_px)
		else:
			face = LedgerType.font_or_fallback("action")
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


func _apply_index_row_metrics(compact: bool, fill_h: float = 0.0) -> void:
	var scale: Dictionary = LedgerChrome.title_type_scale(560.0 if compact else 1080.0)
	var row_h: float = float(scale.get("row_h", INDEX_ROW_H if not compact else 26.0))
	var primary_h: float = float(scale.get("primary_h", INDEX_PRIMARY_H if not compact else 32.0))
	# Dense craft: fixed tight pitch (~36–44px @ 1080p) — never stretch rows with air.
	if not compact:
		row_h = clampf(row_h, 36.0, 44.0)
		primary_h = clampf(primary_h, 40.0, 48.0)
	# Always pack as a compact block (upper 2/3 / optical center) — never EXPAND_FILL.
	var vflag: int = Control.SIZE_SHRINK_BEGIN
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
		btn.size_flags_vertical = vflag
		btn.add_theme_constant_override("h_separation", 0)
	if start_button:
		start_button.custom_minimum_size = Vector2(240.0, primary_h)
		start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		start_button.size_flags_vertical = vflag
	if subtitle:
		subtitle.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	if meta_label:
		meta_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN


func _field_index_block_height(compact: bool, sep: int) -> float:
	## Natural height of meta + visible actions at the dense row pitch.
	var h: float = 0.0
	var n_rows: int = 0
	if meta_label and meta_label.visible:
		h += float(meta_label.custom_minimum_size.y if meta_label.custom_minimum_size.y > 0.0 else (18.0 if compact else 22.0))
		n_rows += 1
	if subtitle and subtitle.visible:
		h += float(subtitle.custom_minimum_size.y if subtitle.custom_minimum_size.y > 0.0 else (18.0 if compact else 22.0))
		n_rows += 1
	var row_h: float = 26.0 if compact else INDEX_ROW_H
	var primary_h: float = 32.0 if compact else INDEX_PRIMARY_H
	for b in _index_action_buttons():
		if b == null:
			continue
		var btn: Button = b as Button
		if not btn.visible:
			continue
		if btn == hard_button and hard_button.disabled:
			continue
		h += primary_h if btn == start_button else row_h
		n_rows += 1
	if n_rows > 1:
		h += float(sep) * float(n_rows - 1)
	return h


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
	var y_off: float = _slot_y_off()
	var card: Rect2 = field_index_card_rect(vp, y_off)
	var inset: Rect2 = field_index_content_rect(card)
	# Dense pitch first, then pack as a compact block in the upper 2/3.
	_apply_index_row_metrics(compact, inset.size.y)
	var scale: Dictionary = LedgerChrome.title_type_scale(page.size.y)
	var sep: int = int(scale.get("row_sep", 4 if compact else INDEX_ROW_SEP))
	if not compact:
		sep = clampi(sep, 4, INDEX_ROW_SEP)
	col.add_theme_constant_override("separation", sep)
	col.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	var block_h: float = _field_index_block_height(compact, sep)
	# Compact block tight under the card title — upper 2/3 of the plate, no stretch.
	var y_pad: float = 4.0 if not compact else 0.0
	col.position = Vector2(inset.position.x, inset.position.y + y_pad)
	col.size = Vector2(inset.size.x, minf(block_h + 4.0, inset.size.y - y_pad))
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
	# Hard composition anchors @ full HD (and scaled viewports).
	var layout: Dictionary = composition_layout(vp)
	var brand_px: int = int(layout.get("brand_px", 0))
	if brand_px < BRAND_MIN_PX:
		printerr("Composition: brand_px=%d < %d" % [brand_px, BRAND_MIN_PX])
		ok = false
	var verso: float = float(layout.get("verso_frac", 0.0))
	var recto: float = float(layout.get("recto_frac", 0.0))
	if verso < 0.48 or verso > 0.56:
		printerr("Composition: verso_frac=%.3f outside 0.48–0.56" % verso)
		ok = false
	if recto < 0.38 or recto > 0.48:
		printerr("Composition: recto_frac=%.3f outside 0.38–0.48" % recto)
		ok = false
	var idx_w: float = float(layout.get("index_width_frac", 0.0))
	if idx_w < 0.38 or idx_w > 0.50:
		printerr("Composition: index_width_frac=%.3f outside 0.38–0.50" % idx_w)
		ok = false
	var empty: float = float(layout.get("empty_frac", 1.0))
	if empty > MAX_EMPTY_FRAC:
		printerr("Composition: empty_frac=%.3f > %.2f" % [empty, MAX_EMPTY_FRAC])
		ok = false
	var verso_empty: float = float(layout.get("verso_empty_frac", 1.0))
	if verso_empty > MAX_VERSO_EMPTY_FRAC:
		printerr(
			"Composition: verso_empty_frac=%.3f > %.2f" % [verso_empty, MAX_VERSO_EMPTY_FRAC]
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
		# Keep preview under Field Index chrome; grain stays a backdrop pass.
		if _gameplay_preview != null and is_instance_valid(_gameplay_preview):
			move_child(_gameplay_preview, 0)
		var chrome: Node = get_node_or_null("CardColumn")
		if chrome != null:
			move_child(chrome, get_child_count() - 1)
	else:
		PaperGrainLayer.set_visible_for(self, false)


func _ensure_gameplay_preview() -> void:
	if _gameplay_preview != null and is_instance_valid(_gameplay_preview):
		return
	_gameplay_preview = Control.new()
	_gameplay_preview.set_script(PREVIEW_SCRIPT)
	_gameplay_preview.name = "GameplayPreview"
	_gameplay_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gameplay_preview.focus_mode = Control.FOCUS_NONE
	add_child(_gameplay_preview)
	move_child(_gameplay_preview, 0)
	_sync_preview_layout()


func _sync_preview_layout() -> void:
	if _gameplay_preview == null or not is_instance_valid(_gameplay_preview):
		return
	var vp: Vector2 = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size
	var layout: Dictionary = composition_layout(vp)
	var plate: Rect2 = layout["preview_plate"]
	var media: Rect2 = ArtKit.film_plate_media_rect(plate)
	_gameplay_preview.position = media.position
	_gameplay_preview.size = media.size
	_gameplay_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE


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
		# Fresh title: wing lives once on the verso folio mark — do not restate here.
		subtitle.visible = false
		subtitle.text = ""
	_refresh_hard_button()
	var entry: Dictionary = GameState.today_daily_entry()
	var today: String = str(entry.get("date", GameState._today_label()))
	var friend_code: String = str(entry.get("friend_code", ""))
	var dbest: int = GameState.daily_best_for_today()
	var ebest: int = int(GameState.endless_best_depth)
	# Quiet header: one meta line (date · EL-#####) — never a second wing/chamber restatement.
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
	meta_label.visible = meta_label.text.strip_edges() != ""


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
	if _gameplay_preview != null and _gameplay_preview.has_method("pause_preview"):
		_gameplay_preview.pause_preview()
	if _settings_overlay == null:
		_settings_overlay = SETTINGS_SCENE.instantiate()
		add_child(_settings_overlay)
		_settings_overlay.closed.connect(func():
			if start_button:
				start_button.grab_focus()
			if _gameplay_preview != null and _gameplay_preview.has_method("resume_preview"):
				_gameplay_preview.resume_preview()
		)
	_settings_overlay.open_menu()


func _open_colophon() -> void:
	if _gameplay_preview != null and _gameplay_preview.has_method("pause_preview"):
		_gameplay_preview.pause_preview()
	if _colophon_overlay == null:
		_colophon_overlay = COLOPHON_SCENE.instantiate()
		add_child(_colophon_overlay)
		_colophon_overlay.closed.connect(func():
			if start_button:
				start_button.grab_focus()
			if _gameplay_preview != null and _gameplay_preview.has_method("resume_preview"):
				_gameplay_preview.resume_preview()
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


func _process(delta: float) -> void:
	_t += delta
	var reduce: bool = _reduce_motion()
	if reduce:
		_card_slot_t = CARD_SLOT_SEC
		_focus_underline_t = FOCUS_UNDERLINE_SEC
		if _gameplay_preview != null and _gameplay_preview.has_method("pause_preview"):
			_gameplay_preview.pause_preview()
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
	_redraw_accum += delta
	if (
		_redraw_accum >= 1.0 / AMBIENT_REDRAW_HZ
		or _card_slot_t < CARD_SLOT_SEC
		or _focus_underline_t < FOCUS_UNDERLINE_SEC
	):
		_redraw_accum = 0.0
		queue_redraw()


func _index_buttons() -> Array:
	return _index_action_buttons()


func _draw() -> void:
	var vp: Vector2 = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size

	# Lightbox desk + open folio — sharp page edges (no torn / deckled foot junk).
	ArtKit.draw_desk_margin(self, vp, 3, 0.05 if not TechArt.v3_enabled() else 0.028)
	var layout: Dictionary = composition_layout(vp)
	var outer: Rect2 = layout["outer"]
	var left: Rect2 = layout["left"]
	var spine: Rect2 = layout["spine"]
	ArtKit.draw_open_folio(self, outer, {
		"grain_seed": 19,
		"grain_a": 0.05 if not TechArt.v3_enabled() else 0.028,
		"major_cell": 32,
		"verso_frac": VERSO_FRAC,
		"recto_frac": RECTO_FRAC,
		"gutter": spine.size.x,
		"sharp_edge": true,
	})

	var scale: Dictionary = LedgerChrome.title_type_scale(outer.size.y)
	var folio_px: int = int(scale.get("folio", LedgerChrome.TYPE_FOLIO))
	var seed_px: int = int(scale.get("seed", LedgerChrome.TYPE_SEED))
	# ECHO LATTICE is the largest type on the title — never secondary to the tagline.
	var brand_px: int = int(layout["brand_px"])
	var tag_px: int = int(scale.get("tagline", LedgerChrome.TYPE_TAGLINE))
	tag_px = mini(tag_px, maxi(14, int(float(brand_px) * 0.30)))
	var blurb_px: int = int(scale.get("blurb", LedgerChrome.TYPE_BLURB))
	var rule_w: float = float(scale.get("rule_w", LedgerChrome.BRAND_RULE_W))
	var header_px: int = int(scale.get("card_header", LedgerChrome.TYPE_CARD_HEADER))

	var brand_x: float = float(layout["brand_x"])
	var brand_y: float = float(layout["brand_y"])
	var brand_block: Rect2 = layout["brand_block"]
	var preview_plate: Rect2 = layout["preview_plate"]

	# ONE quiet micro header line — FIELD LEDGER · WING I · seed. Never competes with brand.
	var micro_line: String = "%s  ·  %s" % [tr("menu.folio_mark"), tr("menu.seed_strip")]
	draw_string(
		_type("meta"),
		left.position + Vector2(28, 26),
		micro_line,
		HORIZONTAL_ALIGNMENT_LEFT, -1, mini(folio_px, seed_px), Palette.SLATE_TEAL_SOFT
	)
	draw_line(
		left.position + Vector2(28, 34),
		Vector2(left.end.x - 24.0, left.position.y + 34.0),
		Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.45),
		1.0
	)

	# Quiet ledger grid behind the brand stack — kills sterile cream without competing type.
	ArtKit.draw_page_fiber_grid(
		self,
		Rect2(left.position + Vector2(16, 40), Vector2(left.size.x - 36.0, brand_block.end.y - left.position.y - 28.0)),
		28
	)
	ArtKit.draw_fiber_streaks(
		self,
		Rect2(left.position + Vector2(16, 40), Vector2(left.size.x - 36.0, maxf(40.0, brand_block.size.y))),
		29,
		0.045,
		14
	)
	# Brand lockup — ECHO LATTICE owns the plane (Condensed Bold ≥ BRAND_MIN_PX).
	draw_string(
		_type("brand"),
		Vector2(brand_x, brand_y),
		tr("brand.title"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, brand_px, Palette.INK_BLACK
	)
	var brand_rule_len: float = brand_block.size.x
	draw_rect(
		Rect2(brand_x, brand_y + 10.0, brand_rule_len, rule_w),
		Palette.RUST_FOSSIL,
		true
	)
	ArtKit.draw_oxide_flecks(
		self,
		Rect2(brand_x, brand_y + 6.0, brand_rule_len * 0.45, 10.0),
		43,
		5,
		0.45
	)
	# Tagline / blurb — 12–20px stack rhythm under the brand rule.
	draw_string(
		_type("tagline"),
		Vector2(brand_x, brand_y + 36.0),
		tr("brand.tagline"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, tag_px, Palette.RUST_FOSSIL
	)
	draw_string(
		_type("deck"),
		Vector2(brand_x, brand_y + 58.0),
		tr("brand.blurb"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, blurb_px, Palette.INK_SOFT
	)

	# Gameplay film plate — diegetic media window; SubViewport / loop sits in the well.
	# Not a static empty maze, not YouTube chrome, no chamber HUD overlay.
	if preview_plate.size.y >= 120.0 and preview_plate.size.x >= 80.0:
		ArtKit.draw_ledger_film_plate(self, preview_plate, {
			"seed": 71,
			"alpha": 1.0,
			"label": tr("menu.seed_strip"),
			"font": _type("micro"),
			"font_size": maxi(10, seed_px - 1),
		})

	# Recto Field Index — fills ~42% width, full readable height.
	# ONE Field Index title on the card — no duplicate recto micro header.
	var y_off: float = _slot_y_off()
	var slot_a: float = _slot_alpha()
	var card: Rect2 = field_index_card_rect(vp, y_off)

	# Boutique Field Index — sharp paper, soft shadow, clip (no hollow bullet holes).
	ArtKit.draw_index_card(self, card, {
		"alpha": slot_a,
		"shadow_off": Vector2(7, 9),
		"binder_holes": 0,
		"grain_seed": 11,
		"grain_a": 0.04,
		"fiber_a": 0.03,
		"header_rules": true,
		"deep_backer": true,
		"binder_clip": true,
		"thickness": 4.0,
		"oxide_accents": false,
		"skip_grain": false,
		"ruled_stock": false,
		"sharp_edge": true,
	})
	var index_title_px: int = maxi(header_px + 6, int(scale.get("tagline", 18)) - 2)
	draw_string(
		_type("tagline"),
		card.position + Vector2(28, 28),
		tr("menu.demo_index") if DemoBuild.is_demo() else tr("menu.field_index"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, index_title_px,
		Color(Palette.INK_BLACK.r, Palette.INK_BLACK.g, Palette.INK_BLACK.b, slot_a)
	)
	draw_string(
		_type("micro"),
		Vector2(card.position.x + 28.0, card.end.y - 22.0),
		tr("menu.card_foot"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(10, folio_px),
		Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.55 * slot_a)
	)

	# Selection — solid tick + text-width rust baseline only (MENU_TYPE_SYSTEM §4).
	_draw_button_underlines(card)

	# Title shell is NOT a paused chamber — no BUFFER ribbon, no Move/Restart/Undo footer.


func _draw_button_underlines(_card: Rect2) -> void:
	var progress: float = clampf(_focus_underline_t / FOCUS_UNDERLINE_SEC, 0.0, 1.0)
	LedgerChrome.draw_index_underlines(self, _index_buttons(), global_position, progress)


func _type(role: String = "display") -> Font:
	## MENU_TYPE_SYSTEM role or face → ledger Plex stack (never ThemeDB.fallback_font).
	if has_node("/root/LedgerType"):
		match role:
			"brand", "tagline", "deck", "action", "action_disabled", "meta", "micro":
				if LedgerType.has_method("tracked_font_for_role"):
					return LedgerType.tracked_font_for_role(role, size.y if size.y > 2.0 else 1080.0)
				if LedgerType.has_method("font_for_role"):
					return LedgerType.font_for_role(role)
		return LedgerType.font_or_fallback(role)
	return null
