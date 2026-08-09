extends RefCounted
class_name LedgerChrome
##
## Shared Field Ledger shell chrome — index actions, paper plates, folio marks.
## Nodes may remain Godot Controls under the hood; look must never read as stock UI.
## Cadmium is reserved for rewrite warn — never used for focus / selection chrome.
##


static func style_index_button(btn: Button, primary: bool = false) -> void:
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
	# Vendor type stack when LedgerType is alive (ART_DIRECTION_V3 §3).
	if Engine.get_main_loop() != null:
		var root := Engine.get_main_loop().root if Engine.get_main_loop() is SceneTree else null
		if root != null and root.has_node("/root/LedgerType"):
			var lt: Node = root.get_node("/root/LedgerType")
			if lt != null and lt.has_method("apply_to_control"):
				lt.apply_to_control(btn, "display", 20 if primary else 18)


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
	if Engine.get_main_loop() != null:
		var root := Engine.get_main_loop().root if Engine.get_main_loop() is SceneTree else null
		if root != null and root.has_node("/root/LedgerType"):
			var lt: Node = root.get_node("/root/LedgerType")
			if lt != null and lt.has_method("apply_to_control"):
				lt.apply_to_control(lbl, "mono" if size <= 12 else "body", size)


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
	## Selection = rust ink underline (draw-in). Hover = slate. Idle = soft hairline.
	## Cadmium reserved — never used here.
	var prog: float = clampf(focus_progress, 0.0, 1.0)
	# EaseOut for underline draw (UI_DIEGETIC_V3 §7).
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
		var max_w: float = minf(r.size.x - 4.0, 220.0)
		if focused and not disabled:
			var w: float = max_w * eased
			host.draw_rect(
				Rect2(local_pos.x, local_pos.y + r.size.y - 4.0, w, 2.0),
				Palette.RUST_FOSSIL,
				true
			)
			# Selection tick — small ink reserve mark left of the row (not cadmium).
			if eased > 0.55:
				var tick_a: float = clampf((eased - 0.55) / 0.45, 0.0, 1.0)
				var tick_c := Color(
					Palette.RUST_FOSSIL.r, Palette.RUST_FOSSIL.g, Palette.RUST_FOSSIL.b, tick_a
				)
				host.draw_circle(
					Vector2(local_pos.x - 10.0, local_pos.y + r.size.y * 0.55),
					2.2,
					tick_c
				)
		elif hovered and not disabled:
			host.draw_rect(
				Rect2(local_pos.x, local_pos.y + r.size.y - 4.0, max_w, 2.0),
				Palette.SLATE_TEAL,
				true
			)
		elif disabled:
			# Elegant disabled: hairline fades rather than a loud strike-through.
			host.draw_rect(
				Rect2(local_pos.x, local_pos.y + r.size.y - 3.0, minf(max_w, 120.0), 1.0),
				Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.22),
				true
			)
		else:
			host.draw_rect(
				Rect2(local_pos.x, local_pos.y + r.size.y - 4.0, minf(max_w, 180.0), 1.0),
				Palette.INK_SOFT,
				true
			)


static func wire_vertical_focus(buttons: Array) -> void:
	var live: Array = []
	for btn in buttons:
		if btn != null and btn is Control:
			var c: Control = btn
			# Disabled rows stay visible (elegant ink fade) but leave the focus ring.
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
