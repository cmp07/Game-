extends RefCounted
class_name LedgerChrome
##
## Shared Field Ledger shell chrome — index actions, paper plates, folio marks.
## Nodes may remain Godot Controls under the hood; look must never read as stock UI.
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
		Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.35)
	)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.focus_mode = Control.FOCUS_ALL
	btn.flat = true


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
	# Focus already owns the selection tick — hover is mouse-only whisper.
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
