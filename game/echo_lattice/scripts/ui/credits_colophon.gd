extends Control
##
## Credits Colophon — quiet ledger close page from Field Index.
## Compliance stub copy; File away returns to the index.
##

signal closed()

var _body: RichTextLabel
var _file_away: Button
var _open: bool = false
var _slot_t: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	if has_node("/root/LocaleManager"):
		LocaleManager.locale_changed.connect(func(_l): _localize())
	_localize()
	set_process(false)


func _build() -> void:
	var col := VBoxContainer.new()
	col.name = "CardColumn"
	col.set_anchors_preset(Control.PRESET_CENTER)
	col.offset_left = -210.0
	col.offset_top = -180.0
	col.offset_right = 210.0
	col.offset_bottom = 190.0
	col.add_theme_constant_override("separation", 10)
	add_child(col)

	# Headroom for drawn folio mark + rust rule.
	var head := Control.new()
	head.custom_minimum_size = Vector2(0, 40)
	col.add_child(head)

	_body = RichTextLabel.new()
	_body.name = "Body"
	_body.bbcode_enabled = false
	_body.fit_content = false
	_body.scroll_active = true
	_body.custom_minimum_size = Vector2(400, 280)
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.focus_mode = Control.FOCUS_ALL
	_body.add_theme_color_override("default_color", Palette.INK_SOFT)
	_body.add_theme_font_size_override("normal_font_size", 14)
	col.add_child(_body)

	_file_away = Button.new()
	_file_away.name = "FileAwayButton"
	_file_away.custom_minimum_size = Vector2(220, 34)
	LedgerChrome.style_index_button(_file_away, true)
	_file_away.pressed.connect(close_colophon)
	col.add_child(_file_away)


func open_colophon() -> void:
	_localize()
	visible = true
	_open = true
	_slot_t = 0.0
	var reduce := false
	if has_node("/root/AccessibilityService"):
		var snap: Dictionary = AccessibilityService.accessibility_snapshot()
		reduce = bool(snap.get("reduce_motion", false))
	_file_away.grab_focus()
	set_process(not reduce)
	queue_redraw()
	if has_node("/root/AudioDirector"):
		AudioDirector.fire("ui.click")


func close_colophon() -> void:
	if not _open:
		return
	visible = false
	_open = false
	set_process(false)
	closed.emit()


func _localize() -> void:
	if _file_away:
		_file_away.text = tr("colophon.file_away")
	if _body:
		var build := str(ProjectSettings.get_setting("application/config/version", "dev"))
		var hook := get_node_or_null("/root/CrashLogHook")
		if hook != null and "build_id" in hook:
			build = str(hook.build_id)
		_body.text = "\n".join([
			tr("colophon.heading"),
			"",
			tr("colophon.blurb"),
			"",
			tr("colophon.design"),
			tr("colophon.design_body"),
			"",
			tr("colophon.engine"),
			tr("colophon.engine_body"),
			"",
			tr("colophon.fonts"),
			tr("colophon.fonts_body"),
			"",
			tr("colophon.audio"),
			tr("colophon.audio_body"),
			"",
			tr("colophon.legal"),
			tr("colophon.legal_body"),
			"",
			tr("colophon.build") % build,
		])
	queue_redraw()


func _process(delta: float) -> void:
	if not _open:
		set_process(false)
		return
	_slot_t = minf(_slot_t + delta, 0.18)
	queue_redraw()
	if _slot_t >= 0.18:
		set_process(false)


func _draw() -> void:
	var vp: Vector2 = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size

	draw_rect(Rect2(Vector2.ZERO, vp), LedgerChrome.paper_wash_color(0.94), true)
	ArtKit.draw_paper_grain(self, Rect2(Vector2.ZERO, vp), 11, 0.06)

	var slot: float = clampf(_slot_t / 0.16, 0.0, 1.0) if is_processing() or _slot_t > 0.0 else 1.0
	if _slot_t <= 0.0 and not is_processing():
		slot = 1.0
	var y_off: float = (1.0 - slot) * 6.0
	var card := Rect2(vp.x * 0.5 - 240.0, vp.y * 0.5 - 220.0 + y_off, 480.0, 420.0)
	var shadow := Palette.PAPER_SHADOW
	shadow.a *= slot
	draw_rect(Rect2(card.position + Vector2(4, 6), card.size), shadow, true)
	var deep := Palette.PAPER_DEEP
	deep.a = slot
	draw_rect(Rect2(card.position + Vector2(3, 3), card.size), deep, true)
	var bone := Palette.PAPER_BONE
	bone.a = slot
	draw_rect(card, bone, true)
	draw_rect(card, Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, slot), false, 1.5)

	draw_string(
		ThemeDB.fallback_font,
		card.position + Vector2(24, 28),
		tr("colophon.folio"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12,
		Color(Palette.SLATE_TEAL.r, Palette.SLATE_TEAL.g, Palette.SLATE_TEAL.b, slot)
	)
	draw_line(card.position + Vector2(20, 36), card.position + Vector2(card.size.x - 20, 36), Palette.INK_SOFT, 1.0)
	draw_rect(Rect2(card.position.x + 24.0, card.position.y + 48.0, 160.0, 2.0), Color(Palette.RUST_FOSSIL.r, Palette.RUST_FOSSIL.g, Palette.RUST_FOSSIL.b, slot), true)

	LedgerChrome.draw_index_underlines(self, [_file_away], global_position)


func _unhandled_input(event: InputEvent) -> void:
	if not _open or not visible:
		return
	if event.is_action_pressed("pause_menu") or event.is_action_pressed("ui_cancel"):
		close_colophon()
		get_viewport().set_input_as_handled()
