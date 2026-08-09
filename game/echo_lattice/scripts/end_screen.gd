extends Control
##
## Wing Colophon — end-of-wing / end-of-daily / demo-complete ledger leaf.
## Demo builds surface a single wishlist CTA (no late-act spoilers).
##

signal restart_pressed()
signal menu_pressed()
signal wishlist_pressed()

@onready var stats_label: Label = %Stats
@onready var restart_button: Button = %RestartButton
@onready var menu_button: Button = %MenuButton
@onready var title_label: Label = $VBox/Title
@onready var tagline_label: Label = $VBox/Tagline
@onready var footer_label: Label = $Footer

var _wishlist_button: Button = null
var _folio_label: Label = null


func _ready() -> void:
	_hide_flat_chrome()
	_localize_chrome()
	_ensure_folio_mark()
	_apply_ledger_type()
	restart_button.pressed.connect(func(): emit_signal("restart_pressed"))
	menu_button.pressed.connect(func(): emit_signal("menu_pressed"))
	restart_button.focus_mode = Control.FOCUS_ALL
	menu_button.focus_mode = Control.FOCUS_ALL
	if DemoBuild.is_demo():
		_configure_demo_end()
	else:
		menu_button.grab_focus()
	stats_label.text = _summary()
	if has_node("/root/AudioDirector"):
		AudioDirector.on_wing_clear()
	if has_node("/root/LocaleManager"):
		LocaleManager.locale_changed.connect(_on_locale_changed)
	set_process_unhandled_input(true)
	queue_redraw()


func _hide_flat_chrome() -> void:
	var bg := get_node_or_null("Background")
	if bg:
		bg.visible = false
	var accent := get_node_or_null("AccentBar")
	if accent:
		accent.visible = false


func _draw() -> void:
	var vp: Vector2 = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, vp), Palette.PAPER_MARGIN, true)
	if has_node("/root/ArtKit"):
		ArtKit.draw_paper_grain(self, Rect2(Vector2.ZERO, vp), 7, 0.055)
	var plate := Rect2(vp.x * 0.16, vp.y * 0.10, vp.x * 0.68, vp.y * 0.72)
	draw_rect(Rect2(plate.position + Vector2(6, 8), plate.size), Palette.PAPER_SHADOW, true)
	draw_rect(plate, Palette.PAPER_BONE, true)
	if has_node("/root/ArtKit"):
		ArtKit.draw_ledger_grid(self, plate, 28)
		ArtKit.draw_paper_grain(self, plate, 19, 0.07)
	draw_rect(plate, Palette.INK_SOFT, false, 2.0)
	draw_rect(plate.grow(-4.0), Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.45), false, 1.0)
	# Binder holes — colophon as bound page.
	for i in range(4):
		var hy: float = plate.position.y + 40.0 + float(i) * ((plate.size.y - 80.0) / 3.0)
		draw_circle(Vector2(plate.position.x + 16.0, hy), 3.5, Palette.INK_SOFT)
		draw_circle(Vector2(plate.position.x + 16.0, hy), 1.8, Palette.PAPER_BONE)
	draw_line(
		plate.position + Vector2(32, 40),
		plate.position + Vector2(plate.size.x - 28, 40),
		Palette.INK_SOFT,
		1.0
	)
	draw_rect(Rect2(plate.position.x, plate.end.y - 6.0, plate.size.x, 6.0), Palette.RUST_FOSSIL, true)


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
	stats_label.text = _summary()


func _unhandled_input(event: InputEvent) -> void:
	## B / Start → menu. A activates the focused Button via Godot ui_accept.
	if event.is_action_pressed("pause_menu"):
		emit_signal("menu_pressed")
		get_viewport().set_input_as_handled()


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


func _ensure_folio_mark() -> void:
	if _folio_label != null:
		return
	var vbox: Node = restart_button.get_parent()
	if vbox == null:
		return
	_folio_label = Label.new()
	_folio_label.name = "FolioMark"
	_folio_label.text = tr("end.folio_mark")
	_folio_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_folio_label.add_theme_font_size_override("font_size", 12)
	_folio_label.add_theme_color_override("font_color", Palette.SLATE_TEAL)
	vbox.add_child(_folio_label)
	vbox.move_child(_folio_label, 0)


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
	for b in [restart_button, menu_button]:
		b.flat = true
		b.add_theme_color_override("font_color", Palette.INK_BLACK)
		b.add_theme_color_override("font_hover_color", Palette.SLATE_TEAL)
		b.add_theme_color_override("font_focus_color", Palette.RUST_FOSSIL)


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
	if has_node("/root/LedgerType"):
		LedgerType.apply_to_control(_wishlist_button, "display", 22)
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
	var dom: String = GameState.dominant_habit()
	var hand: String = GameState.habit_hand_id()
	var hand_label: String = hand
	var key := "habit.hand_%s" % hand
	var t: String = tr(key)
	if t != key:
		hand_label = t
	elif has_node("/root/LocaleManager"):
		hand_label = LocaleManager.habit_label(dom)
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
		header, beat, ids.size(), stars, total_best, hand_label,
	]
