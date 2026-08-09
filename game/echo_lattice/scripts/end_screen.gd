extends Control
##
## Wing Colophon — campaign / daily / endless / demo close.
## Ledger close, not slice branding. Soft CTA into Museum of Selves.
##

signal restart_pressed()
signal menu_pressed()
signal wishlist_pressed()
signal museum_pressed()

@onready var stats_label: Label = %Stats
@onready var restart_button: Button = %RestartButton
@onready var menu_button: Button = %MenuButton
@onready var title_label: Label = $VBox/Title
@onready var tagline_label: Label = $VBox/Tagline
@onready var footer_label: Label = $Footer

var _wishlist_button: Button = null
var _museum_button: Button = null
var _folio_label: Label = null


func _ready() -> void:
	_ensure_folio_mark()
	_localize_chrome()
	restart_button.pressed.connect(func(): emit_signal("restart_pressed"))
	menu_button.pressed.connect(func(): emit_signal("menu_pressed"))
	restart_button.focus_mode = Control.FOCUS_ALL
	menu_button.focus_mode = Control.FOCUS_ALL
	_style_index_actions()
	_apply_ledger_type()
	_ensure_museum_cta()
	if DemoBuild.is_demo():
		_configure_demo_end()
	else:
		if _museum_button != null:
			_museum_button.grab_focus()
		else:
			menu_button.grab_focus()
	stats_label.text = _summary()
	if has_node("/root/AudioDirector"):
		AudioDirector.on_wing_clear()
	if has_node("/root/LocaleManager"):
		LocaleManager.locale_changed.connect(_on_locale_changed)
	set_process(true)
	set_process_unhandled_input(true)
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _on_locale_changed(_locale: String) -> void:
	_localize_chrome()
	if _folio_label:
		_folio_label.text = tr("end.folio_mark")
	if DemoBuild.is_demo():
		title_label.text = tr("end.demo_title")
		tagline_label.text = tr("end.demo_tagline")
		restart_button.text = tr("end.demo_replay")
		if DemoBuild.wishlist_cta_enabled():
			footer_label.text = tr("end.demo_footer")
			if _wishlist_button != null:
				_wishlist_button.text = tr("menu.wishlist")
		else:
			footer_label.text = tr("end.demo_footer_no_wishlist")
			if _wishlist_button != null:
				_wishlist_button.visible = false
	if _museum_button != null:
		_museum_button.text = tr("end.museum")
	stats_label.text = _summary()


func _unhandled_input(event: InputEvent) -> void:
	## B / Start → menu. A activates the focused Button via Godot ui_accept.
	if event.is_action_pressed("pause_menu"):
		emit_signal("menu_pressed")
		get_viewport().set_input_as_handled()


func _ensure_folio_mark() -> void:
	if _folio_label != null:
		return
	_folio_label = Label.new()
	_folio_label.name = "FolioMark"
	_folio_label.text = tr("end.folio_mark")
	_folio_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_folio_label.add_theme_font_size_override("font_size", 12)
	_folio_label.add_theme_color_override("font_color", Palette.SLATE_TEAL)
	_folio_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_folio_label.offset_left = 56.0
	_folio_label.offset_top = 36.0
	_folio_label.offset_right = -56.0
	_folio_label.offset_bottom = 56.0
	_folio_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_folio_label)
	move_child(_folio_label, 0)


func _localize_chrome() -> void:
	var title: Label = get_node_or_null("VBox/Title")
	var tagline: Label = get_node_or_null("VBox/Tagline")
	var footer: Label = get_node_or_null("Footer")
	if title:
		title.text = tr("end.title")
	if tagline:
		tagline.text = tr("end.tagline")
	if footer:
		footer.text = tr("end.footer")
	restart_button.text = tr("end.new_run")
	menu_button.text = tr("end.menu")


func _apply_ledger_type() -> void:
	if not has_node("/root/LedgerType"):
		return
	LedgerType.apply_to_control(title_label, "display", 52)
	LedgerType.apply_to_control(tagline_label, "display", 18)
	LedgerType.apply_to_control(stats_label, "body", 15)
	LedgerType.apply_to_control(footer_label, "mono", 12)
	LedgerType.apply_to_control(restart_button, "display", 20)
	LedgerType.apply_to_control(menu_button, "body", 16)
	if _folio_label:
		LedgerType.apply_to_control(_folio_label, "mono", 12)
	if _museum_button:
		LedgerType.apply_to_control(_museum_button, "body", 16)


func _style_index_actions() -> void:
	for btn in [restart_button, menu_button]:
		if btn == null:
			continue
		btn.flat = true
		btn.add_theme_color_override("font_color", Palette.INK_BLACK)
		btn.add_theme_color_override("font_hover_color", Palette.SLATE_TEAL)
		btn.add_theme_color_override("font_focus_color", Palette.RUST_FOSSIL)
		btn.add_theme_color_override("font_pressed_color", Palette.RUST_FOSSIL)


func _ensure_museum_cta() -> void:
	if _museum_button != null or DemoBuild.is_demo():
		return
	_museum_button = Button.new()
	_museum_button.name = "MuseumButton"
	_museum_button.unique_name_in_owner = true
	_museum_button.custom_minimum_size = Vector2(360, 48)
	_museum_button.text = tr("end.museum")
	_museum_button.flat = true
	_museum_button.add_theme_font_size_override("font_size", 20)
	_museum_button.add_theme_color_override("font_color", Palette.RUST_FOSSIL)
	_museum_button.add_theme_color_override("font_hover_color", Palette.SLATE_TEAL)
	_museum_button.add_theme_color_override("font_focus_color", Palette.RUST_FOSSIL)
	_museum_button.focus_mode = Control.FOCUS_ALL
	var vbox: Node = restart_button.get_parent()
	vbox.add_child(_museum_button)
	vbox.move_child(_museum_button, restart_button.get_index())
	_museum_button.pressed.connect(func(): emit_signal("museum_pressed"))


func _configure_demo_end() -> void:
	title_label.text = tr("end.demo_title")
	tagline_label.text = tr("end.demo_tagline")
	restart_button.text = tr("end.demo_replay")
	if not DemoBuild.wishlist_cta_enabled():
		footer_label.text = tr("end.demo_footer_no_wishlist")
		menu_button.grab_focus()
		return
	footer_label.text = tr("end.demo_footer")
	_wishlist_button = Button.new()
	_wishlist_button.name = "WishlistButton"
	_wishlist_button.unique_name_in_owner = true
	_wishlist_button.custom_minimum_size = Vector2(360, 48)
	_wishlist_button.text = tr("menu.wishlist")
	_wishlist_button.flat = true
	_wishlist_button.add_theme_font_size_override("font_size", 22)
	_wishlist_button.add_theme_color_override("font_color", Palette.RUST_FOSSIL)
	_wishlist_button.add_theme_color_override("font_hover_color", Palette.SLATE_TEAL)
	_wishlist_button.add_theme_color_override("font_focus_color", Palette.RUST_FOSSIL)
	var vbox: Node = restart_button.get_parent()
	vbox.add_child(_wishlist_button)
	vbox.move_child(_wishlist_button, restart_button.get_index())
	_wishlist_button.pressed.connect(func():
		emit_signal("wishlist_pressed")
		DemoBuild.open_wishlist()
	)
	_wishlist_button.grab_focus()


func _summary() -> String:
	var total_best: int = 0
	var beat: int = 0
	var stars: int = 0
	var ids: Array = GameState.run_queue if GameState.run_queue.size() > 0 else range(ChamberBook.chamber_count())
	for i in ids:
		var idx: int = int(i)
		if GameState.best_moves.has(idx):
			total_best += int(GameState.best_moves[idx])
			beat += 1
		stars += int(GameState.best_stars.get(idx, 0))
	var hand_line: String = _handwriting_line()
	var header: String = tr("end.header_wing")
	if DemoBuild.is_demo():
		header = tr("end.header_demo")
	elif GameState.run_mode == "daily":
		if GameState.daily_friend_code != "":
			header = tr("end.header_daily_code") % [GameState.daily_label, GameState.daily_friend_code]
		else:
			header = tr("end.header_daily") % GameState.daily_label
	elif GameState.run_mode == "endless":
		header = tr("end.header_endless") % [GameState.endless_label, GameState.endless_depth]
	return tr("end.summary") % [
		header, beat, ids.size(), stars, total_best, hand_line,
	]


func _handwriting_line() -> String:
	if not GameState.is_habit_identity_visible():
		return tr("hud.habit_sealed")
	var hp: Dictionary = GameState.habit_profile
	var total: int = int(hp.get("up", 0)) + int(hp.get("down", 0)) + int(hp.get("left", 0)) + int(hp.get("right", 0))
	if total <= 0:
		return tr("hud.habit_unwritten")
	var dom: String = GameState.dominant_habit()
	var dom_label: String = dom
	if has_node("/root/LocaleManager"):
		dom_label = LocaleManager.habit_label(dom)
	var hand_id: String = GameState.habit_hand_id()
	var hand_key := "habit.hand_%s" % hand_id
	var hand: String = tr(hand_key)
	if hand == hand_key:
		hand = hand_id
	return tr("hud.habit_identity") % [dom_label, hand]


func _draw() -> void:
	var vp: Vector2 = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size

	draw_rect(Rect2(Vector2.ZERO, vp), Palette.PAPER_MARGIN, true)
	ArtKit.draw_paper_grain(self, Rect2(Vector2.ZERO, vp), 5, 0.05)

	var page := Rect2(48, 28, vp.x - 96, vp.y - 56)
	draw_rect(Rect2(page.position + Vector2(5, 7), page.size), Palette.PAPER_SHADOW, true)
	draw_rect(page, Palette.PAPER_BONE, true)
	ArtKit.draw_ledger_grid(self, page, 24)
	ArtKit.draw_paper_grain(self, page, 17, 0.06)
	draw_rect(page, Palette.INK_SOFT, false, 2.0)
	draw_rect(page.grow(-3.0), Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.45), false, 1.0)

	for i in range(5):
		var hy: float = page.position.y + 40.0 + float(i) * ((page.size.y - 80.0) / 4.0)
		draw_circle(Vector2(page.position.x + 16.0, hy), 4.0, Palette.INK_SOFT)
		draw_circle(Vector2(page.position.x + 16.0, hy), 2.2, Palette.PAPER_BONE)

	var rule_y: float = page.position.y + 44.0
	draw_line(Vector2(page.position.x + 36.0, rule_y), Vector2(page.end.x - 24.0, rule_y), Palette.INK_SOFT, 1.0)
	draw_line(Vector2(page.position.x + 36.0, rule_y + 4.0), Vector2(page.end.x - 24.0, rule_y + 4.0), Palette.INK_SOFT, 1.0)
	draw_rect(Rect2(page.end.x - 40.0, page.position.y + 18.0, 18.0, 3.0), Palette.RUST_FOSSIL, true)

	_draw_button_underlines()


func _draw_button_underlines() -> void:
	var buttons: Array = []
	if _wishlist_button != null:
		buttons.append(_wishlist_button)
	if _museum_button != null:
		buttons.append(_museum_button)
	buttons.append(restart_button)
	buttons.append(menu_button)
	for btn in buttons:
		if btn == null or not is_instance_valid(btn) or not btn.visible:
			continue
		var r: Rect2 = btn.get_global_rect()
		var local_pos: Vector2 = r.position - global_position
		var focused: bool = btn.has_focus()
		var hovered: bool = btn.is_hovered()
		if focused:
			draw_rect(Rect2(local_pos.x, local_pos.y + r.size.y - 4, minf(r.size.x, 220.0), 2.0), Palette.RUST_FOSSIL, true)
		elif hovered and not btn.disabled:
			draw_rect(Rect2(local_pos.x, local_pos.y + r.size.y - 4, minf(r.size.x, 200.0), 2.0), Palette.SLATE_TEAL, true)
		elif not btn.disabled:
			draw_rect(Rect2(local_pos.x, local_pos.y + r.size.y - 4, minf(r.size.x, 160.0), 1.0), Palette.INK_SOFT, true)
