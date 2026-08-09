extends RefCounted
class_name LedgerChrome
##
## Shared Field Ledger shell chrome — index actions, paper plates, folio marks.
## Nodes may remain Godot Controls under the hood; look must never read as stock UI.
##

## ART_DIRECTION_V3 §3.2 — title-page type scale (px @ ~1080p reference).
## Brand is the hero signal; meta/seed never compete with brand size.
const TYPE_BRAND := 72
const TYPE_TAGLINE := 20
const TYPE_BLURB := 15
const TYPE_INDEX_PRIMARY := 18
const TYPE_INDEX := 16
const TYPE_META := 12
const TYPE_FOLIO := 11
const TYPE_SEED := 12
const TYPE_CARD_HEADER := 12
const BRAND_RULE_W := 3.0
const BRAND_RULE_LEN := 440.0


static func title_type_scale(page_h: float = 720.0) -> Dictionary:
	## Compact (Deck / short page) vs full title-card scale.
	var compact: bool = page_h < 700.0
	if compact:
		return {
			"brand": 56,
			"tagline": 18,
			"blurb": 14,
			"index_primary": 17,
			"index": 15,
			"meta": 11,
			"folio": 10,
			"seed": 11,
			"card_header": 11,
			"rule_w": 2.0,
			"rule_len": 340.0,
		}
	return {
		"brand": TYPE_BRAND,
		"tagline": TYPE_TAGLINE,
		"blurb": TYPE_BLURB,
		"index_primary": TYPE_INDEX_PRIMARY,
		"index": TYPE_INDEX,
		"meta": TYPE_META,
		"folio": TYPE_FOLIO,
		"seed": TYPE_SEED,
		"card_header": TYPE_CARD_HEADER,
		"rule_w": BRAND_RULE_W,
		"rule_len": BRAND_RULE_LEN,
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
		Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.35)
	)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.focus_mode = Control.FOCUS_ALL
	btn.flat = true
	var px: int = font_size
	if px < 0:
		px = TYPE_INDEX_PRIMARY if primary else TYPE_INDEX
	var lt = _ledger_type()
	if lt != null and lt.has_method("apply_to_control"):
		lt.apply_to_control(btn, "display", px)
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


static func draw_index_underlines(host: CanvasItem, buttons: Array, global_origin: Vector2) -> void:
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
		if focused:
			host.draw_rect(
				Rect2(local_pos.x, local_pos.y + r.size.y - 4, minf(r.size.x, 220.0), 2.0),
				Palette.RUST_FOSSIL,
				true
			)
		elif hovered and not disabled:
			host.draw_rect(
				Rect2(local_pos.x, local_pos.y + r.size.y - 4, minf(r.size.x, 220.0), 2.0),
				Palette.SLATE_TEAL,
				true
			)
		elif not disabled:
			host.draw_rect(
				Rect2(local_pos.x, local_pos.y + r.size.y - 4, minf(r.size.x, 180.0), 1.0),
				Palette.INK_SOFT,
				true
			)


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
