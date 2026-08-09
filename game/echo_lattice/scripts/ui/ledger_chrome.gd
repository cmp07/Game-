extends RefCounted
class_name LedgerChrome
##
## Shared Field Ledger shell chrome — index actions, paper plates, folio marks.
## Nodes may remain Godot Controls under the hood; look must never read as stock UI.
## Cadmium is reserved for rewrite warn — never used for focus / selection chrome.
##

## ART_DIRECTION_V3 §3.2 + MENU_TYPE_SYSTEM — published title-page type @ ~1080p.
## Premium composition: brand owns the plane; actions are Medium (never mono).
const TYPE_BRAND := 92
const TYPE_TAGLINE := 24
const TYPE_BLURB := 17
const TYPE_DECK := 17
const TYPE_INDEX_PRIMARY := 24
const TYPE_INDEX := 20
const TYPE_ACTION := 20
const TYPE_ACTION_PRIMARY := 24
const TYPE_META := 13
const TYPE_FOLIO := 12
const TYPE_MICRO := 12
const TYPE_SEED := 13
const TYPE_CARD_HEADER := 14
const BRAND_RULE_W := 4.0
const BRAND_RULE_LEN := 560.0
## Selection baseline budget — text advance, not full-row chrome (MENU_TYPE_SYSTEM §4).
const SELECT_RULE_PAD := 6.0
const SELECT_RULE_MAX := 240.0


static func title_type_scale(page_h: float = 720.0) -> Dictionary:
	## Prefer LedgerType role scale; keep local fallback for early boot / tests.
	var lt = _ledger_type()
	if lt != null and lt.has_method("title_role_scale"):
		return lt.title_role_scale(page_h)
	var compact: bool = page_h < 700.0
	if compact:
		return {
			"brand": 64,
			"tagline": 18,
			"blurb": 14,
			"deck": 14,
			"index_primary": 17,
			"index": 15,
			"action": 15,
			"action_primary": 17,
			"action_disabled": 15,
			"meta": 11,
			"folio": 10,
			"micro": 10,
			"seed": 11,
			"card_header": 11,
			"rule_w": 2.8,
			"rule_len": 280.0,
			"seal_r": 96.0,
			"row_h": 26.0,
			"primary_h": 32.0,
			"row_sep": 4,
		}
	return {
		"brand": TYPE_BRAND,
		"tagline": TYPE_TAGLINE,
		"blurb": TYPE_BLURB,
		"deck": TYPE_DECK,
		"index_primary": TYPE_INDEX_PRIMARY,
		"index": TYPE_INDEX,
		"action": TYPE_ACTION,
		"action_primary": TYPE_ACTION_PRIMARY,
		"action_disabled": TYPE_ACTION,
		"meta": TYPE_META,
		"folio": TYPE_FOLIO,
		"micro": TYPE_MICRO,
		"seed": TYPE_SEED,
		"card_header": TYPE_CARD_HEADER,
		"rule_w": BRAND_RULE_W,
		"rule_len": BRAND_RULE_LEN,
		"seal_r": 118.0,
		"row_h": 48.0,
		"primary_h": 56.0,
		"row_sep": 12,
	}


static func style_index_button(btn: Button, primary: bool = false, font_size: int = -1) -> void:
	if btn == null:
		return
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
	btn.add_theme_color_override(
		"font_disabled_color",
		Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.32)
	)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.focus_mode = Control.FOCUS_ALL
	btn.flat = true
	var lt = _ledger_type()
	var role := "action_disabled" if btn.disabled else "action"
	var px: int = font_size
	if px < 0 and lt != null and lt.has_method("role_size"):
		px = int(lt.role_size(role, 1080.0, primary))
	elif px < 0:
		px = TYPE_INDEX_PRIMARY if primary else TYPE_INDEX
	## Actions = IBM Plex Sans Condensed Medium — NEVER mono (MENU_TYPE_SYSTEM §1).
	if lt != null and lt.has_method("apply_role"):
		lt.apply_role(btn, role, 1080.0, primary)
		if px > 0:
			btn.add_theme_font_size_override("font_size", px)
	elif lt != null and lt.has_method("apply_to_control"):
		lt.apply_to_control(btn, "action", px)
	else:
		btn.add_theme_font_size_override("font_size", px)


static func _ledger_type() -> Node:
	var loop := Engine.get_main_loop()
	if loop == null or not (loop is SceneTree):
		return null
	return (loop as SceneTree).root.get_node_or_null("/root/LedgerType")


static func paper_plate_style(deep: bool = false) -> StyleBoxFlat:
	var plate := StyleBoxFlat.new()
	plate.bg_color = Palette.PAPER_DEEP if deep else Palette.PAPER_BONE
	plate.border_color = Palette.INK_SOFT
	plate.set_border_width_all(2)
	plate.shadow_size = 0
	plate.corner_radius_top_left = 0
	plate.corner_radius_top_right = 0
	plate.corner_radius_bottom_left = 0
	plate.corner_radius_bottom_right = 0
	plate.content_margin_left = 16
	plate.content_margin_right = 16
	plate.content_margin_top = 12
	plate.content_margin_bottom = 12
	return plate


static func paper_wash_color(alpha: float = 0.92) -> Color:
	return Color(Palette.PAPER_MARGIN.r, Palette.PAPER_MARGIN.g, Palette.PAPER_MARGIN.b, alpha)


static func style_ink_label(lbl: Label, color: Color = Palette.INK_BLACK, size: int = 14) -> void:
	if lbl == null:
		return
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_font_size_override("font_size", size)
	var lt = _ledger_type()
	## Meta may use mono at ≤13 px; Micro band ≤12 stays mono (MENU_TYPE_SYSTEM §1).
	if lt != null and lt.has_method("apply_role") and size <= 13:
		var role := "micro" if size <= 12 else "meta"
		if lt.has_method("role_face"):
			var face: String = lt.role_face(role, size)
			lt.apply_to_control(lbl, face, size)
		else:
			lt.apply_to_control(lbl, "mono", size)
	elif lt != null and lt.has_method("apply_to_control"):
		lt.apply_to_control(lbl, "mono" if size <= 13 else "body", size)


static func style_folio_slider(slider: HSlider) -> void:
	if slider == null:
		return
	var track := StyleBoxFlat.new()
	track.bg_color = Palette.PAPER_DEEP
	track.border_color = Palette.INK_SOFT
	track.set_border_width_all(1)
	track.content_margin_top = 4
	track.content_margin_bottom = 4
	track.shadow_size = 0
	var grab := StyleBoxFlat.new()
	grab.bg_color = Palette.INK_BLACK
	grab.set_corner_radius_all(0)
	grab.content_margin_left = 4
	grab.content_margin_right = 4
	grab.content_margin_top = 6
	grab.content_margin_bottom = 6
	slider.add_theme_stylebox_override("slider", track)
	slider.add_theme_stylebox_override("grabber_area", StyleBoxEmpty.new())
	slider.add_theme_stylebox_override("grabber_area_highlight", StyleBoxEmpty.new())
	slider.add_theme_stylebox_override("grabber", grab)
	slider.add_theme_stylebox_override("grabber_highlight", grab)


static func style_folio_option(option: OptionButton) -> void:
	if option == null:
		return
	var empty := StyleBoxEmpty.new()
	option.add_theme_stylebox_override("normal", empty)
	option.add_theme_stylebox_override("pressed", empty)
	option.add_theme_stylebox_override("hover", empty)
	option.add_theme_stylebox_override("focus", empty)
	option.add_theme_color_override("font_color", Palette.INK_BLACK)
	option.add_theme_color_override("font_hover_color", Palette.SLATE_TEAL)
	option.add_theme_color_override("font_pressed_color", Palette.RUST_FOSSIL)
	option.add_theme_color_override("font_focus_color", Palette.RUST_FOSSIL)


static func style_folio_check(check: BaseButton) -> void:
	if check == null:
		return
	check.add_theme_color_override("font_color", Palette.INK_SOFT)
	check.add_theme_color_override("font_hover_color", Palette.SLATE_TEAL)
	check.add_theme_color_override("font_pressed_color", Palette.RUST_FOSSIL)
	check.add_theme_color_override("font_focus_color", Palette.RUST_FOSSIL)


static func draw_index_underlines(
	host: CanvasItem,
	buttons: Array,
	global_origin: Vector2,
	focus_progress: float = 1.0
) -> void:
	## Selection = small solid ink tick + refined rust baseline under text width.
	## Idle rows stay clean — quiet type only (no underlines, no circle bullets).
	## Hover = slate baseline, no tick. Cadmium reserved. No dashed / jagged rules.
	var prog: float = clampf(focus_progress, 0.0, 1.0)
	var eased: float = 1.0 - (1.0 - prog) * (1.0 - prog)
	for btn in buttons:
		if btn == null or not (btn is Control):
			continue
		var c: Control = btn
		if not c.visible:
			continue
		var r: Rect2 = c.get_global_rect()
		var local_pos: Vector2 = r.position - global_origin
		var focused: bool = c.has_focus()
		var hovered: bool = c is BaseButton and (c as BaseButton).is_hovered()
		var disabled: bool = c is BaseButton and (c as BaseButton).disabled
		if disabled or (not focused and not hovered):
			continue
		var baseline_w: float = _selection_baseline_width(c, r.size.x)
		var y: float = local_pos.y + r.size.y - 5.0
		if focused:
			var w: float = baseline_w * eased
			_draw_selection_baseline(
				host,
				Vector2(local_pos.x, y),
				w,
				2.25,
				Palette.RUST_FOSSIL
			)
			if eased > 0.55:
				var tick_a: float = clampf((eased - 0.55) / 0.45, 0.0, 1.0)
				# Small solid ink tick (filled square) — never a hollow circle bullet.
				var tick_c := Color(
					Palette.INK_BLACK.r, Palette.INK_BLACK.g, Palette.INK_BLACK.b, tick_a * 0.95
				)
				var tick_p := Vector2(local_pos.x - 16.0, local_pos.y + r.size.y * 0.50)
				host.draw_rect(Rect2(tick_p.x - 2.0, tick_p.y - 2.0, 4.0, 4.0), tick_c, true)
		elif hovered:
			_draw_selection_baseline(
				host,
				Vector2(local_pos.x, y),
				baseline_w,
				1.6,
				Palette.SLATE_TEAL
			)


static func _selection_baseline_width(control: Control, row_w: float) -> float:
	## Baseline follows label advance — never a full-row chrome bar.
	var text_w: float = 0.0
	if control is BaseButton:
		var label: String = (control as BaseButton).text
		var font: Font = control.get_theme_font("font")
		var fsize: int = control.get_theme_font_size("font_size")
		if font != null and label != "":
			text_w = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize).x
	if text_w < 8.0:
		text_w = minf(row_w * 0.45, SELECT_RULE_MAX)
	return clampf(text_w + SELECT_RULE_PAD, 24.0, minf(row_w - 8.0, SELECT_RULE_MAX))


static func _draw_selection_baseline(
	host: CanvasItem,
	origin: Vector2,
	width: float,
	thickness: float,
	color: Color
) -> void:
	## Single refined continuous baseline — solid rect, never dashed / jagged.
	if width < 1.0:
		return
	var tw: float = maxf(1.5, thickness)
	var core := Color(color.r, color.g, color.b, color.a * 0.98)
	host.draw_rect(Rect2(origin.x, origin.y, width, tw), core, true)


static func _draw_ink_rule(
	host: CanvasItem,
	origin: Vector2,
	width: float,
	thickness: float,
	color: Color,
	_seed: int = 0
) -> void:
	## Compat alias — boutique Field Index uses continuous selection baseline.
	_draw_selection_baseline(host, origin, width, thickness, color)


static func wire_vertical_focus(buttons: Array) -> void:
	var live: Array = []
	for btn in buttons:
		if btn != null and btn is Control:
			var c: Control = btn
			if c.visible and not (c is BaseButton and (c as BaseButton).disabled):
				live.append(c)
	for i in range(live.size()):
		var cur: Control = live[i]
		var prev: Control = live[(i - 1 + live.size()) % live.size()]
		var next: Control = live[(i + 1) % live.size()]
		cur.focus_neighbor_top = cur.get_path_to(prev)
		cur.focus_neighbor_bottom = cur.get_path_to(next)
		cur.focus_neighbor_left = cur.get_path_to(cur)
		cur.focus_neighbor_right = cur.get_path_to(cur)
		cur.focus_previous = cur.get_path_to(prev)
		cur.focus_next = cur.get_path_to(next)


## Premium Field Index feel — select / hover / confirm only (no layout).
## Pair with AudioDirector.arm_ui_feel() after grab_focus so open stays silent.
static func wire_index_feel(buttons: Array) -> void:
	for btn in buttons:
		if btn == null or not (btn is BaseButton):
			continue
		var b: BaseButton = btn
		if bool(b.get_meta("_ledger_feel_wired", false)):
			continue
		b.set_meta("_ledger_feel_wired", true)
		b.focus_entered.connect(func(): _on_index_focus(b))
		b.mouse_entered.connect(func(): _on_index_hover(b))
		b.pressed.connect(func(): _on_index_confirm(b))


static func _director() -> Node:
	var tree := Engine.get_main_loop()
	if tree == null or not (tree is SceneTree):
		return null
	return (tree as SceneTree).root.get_node_or_null("/root/AudioDirector")


static func _on_index_focus(btn: BaseButton) -> void:
	if btn == null or btn.disabled or not btn.visible:
		return
	var director := _director()
	if director != null and director.has_method("on_ui_select"):
		director.call("on_ui_select")


static func _on_index_hover(btn: BaseButton) -> void:
	if btn == null or btn.disabled or not btn.visible:
		return
	if btn.has_focus():
		return
	var director := _director()
	if director != null and director.has_method("on_ui_hover"):
		director.call("on_ui_hover")


static func _on_index_confirm(btn: BaseButton) -> void:
	if btn == null or btn.disabled:
		return
	var director := _director()
	if director != null and director.has_method("on_ui_confirm"):
		director.call("on_ui_confirm")
