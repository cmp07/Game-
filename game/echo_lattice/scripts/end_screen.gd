extends Control
##
## End-of-slice / end-of-daily / demo-complete screen.
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


func _ready() -> void:
	_localize_chrome()
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


func _on_locale_changed(_locale: String) -> void:
	_localize_chrome()
	if DemoBuild.is_demo():
		title_label.text = tr("end.demo_title")
		tagline_label.text = tr("end.demo_tagline")
		footer_label.text = tr("end.demo_footer")
		restart_button.text = tr("end.demo_replay")
		if _wishlist_button != null:
			_wishlist_button.text = tr("menu.wishlist")
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


func _configure_demo_end() -> void:
	title_label.text = tr("end.demo_title")
	tagline_label.text = tr("end.demo_tagline")
	footer_label.text = tr("end.demo_footer")
	restart_button.text = tr("end.demo_replay")
	_wishlist_button = Button.new()
	_wishlist_button.name = "WishlistButton"
	_wishlist_button.unique_name_in_owner = true
	_wishlist_button.custom_minimum_size = Vector2(360, 48)
	_wishlist_button.text = tr("menu.wishlist")
	_wishlist_button.flat = true
	_wishlist_button.add_theme_font_size_override("font_size", 22)
	_wishlist_button.add_theme_color_override("font_color", Color(0.545, 0.227, 0.122, 1))
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
	var dom_label: String = dom
	if has_node("/root/LocaleManager"):
		dom_label = LocaleManager.habit_label(dom)
	var hp: Dictionary = GameState.habit_profile
	var header: String = tr("end.header_wing")
	if DemoBuild.is_demo():
		header = tr("end.header_demo")
	elif GameState.run_mode == "daily":
		header = tr("end.header_daily") % GameState.daily_label
	return tr("end.summary") % [
		header, beat, ids.size(), stars, total_best, dom_label,
		int(hp.get("up", 0)), int(hp.get("down", 0)),
		int(hp.get("left", 0)), int(hp.get("right", 0)),
	]
