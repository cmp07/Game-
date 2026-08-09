extends Control
##
## Pause · Field Index — interrupt a chamber without dumping to title.
## Paper wash over live chamber page; index-card actions only.
##

signal resume_pressed()
signal restart_pressed()
signal instruments_pressed()
signal abandon_pressed()

const SETTINGS_SCENE: PackedScene = preload("res://scenes/ui/settings_menu.tscn")

var _resume_button: Button
var _restart_button: Button
var _instruments_button: Button
var _abandon_button: Button
var _meta_label: Label
var _settings_overlay: Control = null
var _open: bool = false
var _slot_t: float = 0.0
var _reduce_motion: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_card()
	if has_node("/root/LocaleManager"):
		LocaleManager.locale_changed.connect(func(_l): _localize())
	_localize()
	set_process(false)


func _build_card() -> void:
	var col := VBoxContainer.new()
	col.name = "CardColumn"
	col.set_anchors_preset(Control.PRESET_CENTER)
	col.offset_left = -140.0
	col.offset_top = -120.0
	col.offset_right = 140.0
	col.offset_bottom = 140.0
	col.add_theme_constant_override("separation", 8)
	add_child(col)

	# Leave headroom for drawn folio title + double rule.
	var head := Control.new()
	head.custom_minimum_size = Vector2(0, 28)
	col.add_child(head)

	_meta_label = Label.new()
	_meta_label.name = "MetaLabel"
	_meta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_meta_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	LedgerChrome.style_ink_label(_meta_label, Palette.SLATE_TEAL, 12)
	col.add_child(_meta_label)

	_resume_button = _make_action("ResumeButton")
	_restart_button = _make_action("RestartButton")
	_instruments_button = _make_action("InstrumentsButton")
	_abandon_button = _make_action("AbandonButton")
	col.add_child(_resume_button)
	col.add_child(_restart_button)
	col.add_child(_instruments_button)
	col.add_child(_abandon_button)

	_resume_button.pressed.connect(_on_resume)
	_restart_button.pressed.connect(_on_restart)
	_instruments_button.pressed.connect(_on_instruments)
	_abandon_button.pressed.connect(_on_abandon)


func _make_action(node_name: String) -> Button:
	var btn := Button.new()
	btn.name = node_name
	btn.custom_minimum_size = Vector2(260, 34)
	LedgerChrome.style_index_button(btn, node_name == "ResumeButton")
	return btn


func open_pause() -> void:
	_refresh_meta()
	_localize()
	visible = true
	_open = true
	_slot_t = 0.0
	_reduce_motion = false
	if has_node("/root/AccessibilityService"):
		var snap: Dictionary = AccessibilityService.accessibility_snapshot()
		_reduce_motion = bool(snap.get("reduce_motion", false))
	get_tree().paused = true
	LedgerChrome.wire_vertical_focus([
		_resume_button, _restart_button, _instruments_button, _abandon_button,
	])
	_resume_button.grab_focus()
	set_process(not _reduce_motion)
	queue_redraw()
	if has_node("/root/AudioDirector"):
		AudioDirector.fire("ui.click")


func close_pause(unpause_tree: bool = true) -> void:
	visible = false
	_open = false
	set_process(false)
	if unpause_tree:
		get_tree().paused = false


func is_open() -> bool:
	return _open


func _localize() -> void:
	if _resume_button:
		_resume_button.text = tr("pause.resume")
	if _restart_button:
		_restart_button.text = tr("pause.restart")
	if _instruments_button:
		_instruments_button.text = tr("pause.instruments")
	if _abandon_button:
		_abandon_button.text = tr("pause.abandon")
	_refresh_meta()
	queue_redraw()


func _refresh_meta() -> void:
	if _meta_label == null:
		return
	var data: Dictionary = ChamberBook.get_chamber(GameState.current_chamber)
	var title: String = str(data.get("title", ""))
	var cid: String = str(data.get("content_id", data.get("id", "")))
	if has_node("/root/LocaleManager") and cid != "":
		title = LocaleManager.translate_chamber_title(cid, title)
	_meta_label.text = tr("pause.meta") % [title, GameState.seed_display_string()]


func _process(delta: float) -> void:
	if not _open or _reduce_motion:
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

	# Chamber desaturates one step via paper wash — world stays legible (no glass blur).
	draw_rect(Rect2(Vector2.ZERO, vp), LedgerChrome.paper_wash_color(0.78), true)
	ArtKit.draw_paper_grain(self, Rect2(Vector2.ZERO, vp), 5, 0.05)

	var slot: float = 1.0
	if not _reduce_motion:
		slot = clampf(_slot_t / 0.16, 0.0, 1.0)
	var y_off: float = (1.0 - slot) * 6.0

	var card := Rect2(vp.x * 0.5 - 160.0, vp.y * 0.5 - 150.0 + y_off, 320.0, 300.0)
	var shadow := Palette.PAPER_SHADOW
	shadow.a *= slot
	draw_rect(Rect2(card.position + Vector2(3, 4), card.size), shadow, true)
	var bone := Palette.PAPER_BONE
	bone.a = slot
	draw_rect(card, bone, true)
	draw_rect(card, Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, slot), false, 1.5)
	draw_rect(card.grow(-3.0), Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.4 * slot), false, 1.0)

	for i in range(4):
		var hy: float = card.position.y + 36.0 + float(i) * 60.0
		draw_circle(Vector2(card.position.x + 12.0, hy), 3.5, Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, slot))
		draw_circle(Vector2(card.position.x + 12.0, hy), 1.8, bone)

	draw_line(card.position + Vector2(22, 34), card.position + Vector2(card.size.x - 16, 34), Palette.INK_SOFT, 1.0)
	draw_line(card.position + Vector2(22, 38), card.position + Vector2(card.size.x - 16, 38), Palette.INK_SOFT, 1.0)
	draw_string(
		ThemeDB.fallback_font,
		card.position + Vector2(26, 26),
		tr("pause.title"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12,
		Color(Palette.SLATE_TEAL.r, Palette.SLATE_TEAL.g, Palette.SLATE_TEAL.b, slot)
	)

	# Live buffer ribbon under the card.
	var fill: int = mini(GameState.move_ring.size(), 30)
	var bx: float = card.position.x + 22.0
	var by: float = card.end.y - 28.0
	draw_string(
		ThemeDB.fallback_font,
		Vector2(bx, by - 4.0),
		tr("menu.buffer"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 10,
		Color(Palette.SLATE_TEAL.r, Palette.SLATE_TEAL.g, Palette.SLATE_TEAL.b, slot)
	)
	for i in range(30):
		var cell := Rect2(bx + 56.0 + float(i) * 7.0, by - 2.0, 5.0, 10.0)
		if i < fill:
			draw_rect(cell, Color(Palette.INK_BLACK.r, Palette.INK_BLACK.g, Palette.INK_BLACK.b, slot), true)
		else:
			draw_rect(cell, Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.55 * slot), false, 1.0)

	LedgerChrome.draw_index_underlines(
		self,
		[_resume_button, _restart_button, _instruments_button, _abandon_button],
		global_position
	)


func _unhandled_input(event: InputEvent) -> void:
	if not _open or not visible:
		return
	if _settings_overlay != null and _settings_overlay.visible:
		return
	if event.is_action_pressed("pause_menu") or event.is_action_pressed("ui_cancel"):
		_on_resume()
		get_viewport().set_input_as_handled()


func _on_resume() -> void:
	close_pause(true)
	resume_pressed.emit()


func _on_restart() -> void:
	close_pause(true)
	restart_pressed.emit()


func _on_instruments() -> void:
	if _settings_overlay == null:
		_settings_overlay = SETTINGS_SCENE.instantiate()
		_settings_overlay.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		add_child(_settings_overlay)
		_settings_overlay.closed.connect(_on_settings_closed)
	# Keep tree paused; hide pause card while folio is open.
	visible = false
	_settings_overlay.open_menu()
	if has_node("/root/AudioDirector"):
		AudioDirector.fire("ui.click")


func _on_settings_closed() -> void:
	if not _open:
		return
	visible = true
	_resume_button.grab_focus()
	queue_redraw()


func _on_abandon() -> void:
	close_pause(true)
	abandon_pressed.emit()
