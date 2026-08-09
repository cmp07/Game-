extends Control
##
## Chamber scene root — Chamber + HUD.
##

signal chamber_won(chamber_id: int, moves: int)
signal menu_requested()

const SETTINGS_SCENE: PackedScene = preload("res://scenes/ui/settings_menu.tscn")

@onready var chamber_node: Node2D = %Chamber
@onready var title_label: Label = %ChamberTitle
@onready var caption_label: Label = %Caption
@onready var moves_label: Label = %MovesLabel
@onready var habit_label: Label = %HabitLabel
@onready var restart_button: Button = %RestartButton
@onready var settings_button: Button = %SettingsButton
@onready var menu_button: Button = %MenuButton

var _glyph_device: int = -1
var _settings_overlay: Control = null


func _ready() -> void:
	restart_button.text = tr("hud.restart")
	menu_button.text = tr("hud.menu")
	restart_button.pressed.connect(func(): chamber_node.reset_chamber())
	settings_button.pressed.connect(_open_settings)
	menu_button.pressed.connect(func(): emit_signal("menu_requested"))
	chamber_node.chamber_won.connect(_on_chamber_won)
	chamber_node.moves_changed.connect(_on_moves_changed)
	chamber_node.caption_changed.connect(_on_caption_changed)
	## Keep D-Pad on movement — HUD chrome is clickable but not focus-stealing.
	restart_button.focus_mode = Control.FOCUS_NONE
	if settings_button:
		settings_button.focus_mode = Control.FOCUS_NONE
		settings_button.text = tr("menu.settings")
	menu_button.focus_mode = Control.FOCUS_NONE
	if has_node("/root/LocaleManager"):
		LocaleManager.locale_changed.connect(_on_locale_changed)
	_refresh_glyph_labels()
	_style_ledger_chrome()
	_refresh_title()
	_on_moves_changed(0)
	var data: Dictionary = ChamberBook.get_chamber(GameState.current_chamber)
	_on_caption_changed(_localized_caption(data))
	set_process(true)
	_glyph_device = InputGlyphs.last_device if has_node("/root/InputGlyphs") else -1


func _on_locale_changed(_locale: String) -> void:
	# Mid-run language switch must refresh HUD chrome, not only the next move event.
	_refresh_glyph_labels()
	if settings_button:
		settings_button.text = tr("menu.settings")
	_refresh_title()
	_on_moves_changed(chamber_node.move_count if chamber_node else 0)
	var data: Dictionary = ChamberBook.get_chamber(GameState.current_chamber)
	_on_caption_changed(_localized_caption(data))


func _process(_delta: float) -> void:
	if not has_node("/root/InputGlyphs"):
		return
	if InputGlyphs.last_device != _glyph_device:
		_glyph_device = InputGlyphs.last_device
		_refresh_glyph_labels()


func _refresh_glyph_labels() -> void:
	if has_node("/root/InputGlyphs"):
		restart_button.text = InputGlyphs.restart_button_text()
		menu_button.text = InputGlyphs.menu_button_text()
	else:
		restart_button.text = tr("hud.restart")
		menu_button.text = tr("hud.menu")


func _open_settings() -> void:
	if _settings_overlay == null:
		_settings_overlay = SETTINGS_SCENE.instantiate()
		add_child(_settings_overlay)
	_settings_overlay.open_menu()


func _style_ledger_chrome() -> void:
	## Top/bottom bars read as printed page margins, not glass HUD.
	var paper := StyleBoxFlat.new()
	paper.bg_color = Palette.PAPER_BONE
	paper.border_color = Palette.INK_SOFT
	paper.set_border_width_all(0)
	paper.border_width_bottom = 1
	var top: PanelContainer = get_node_or_null("TopBar")
	if top:
		top.add_theme_stylebox_override("panel", paper)
	var paper2 := StyleBoxFlat.new()
	paper2.bg_color = Palette.PAPER_BONE
	paper2.border_color = Palette.INK_SOFT
	paper2.border_width_top = 1
	var bottom: PanelContainer = get_node_or_null("BottomBar")
	if bottom:
		bottom.add_theme_stylebox_override("panel", paper2)


func _refresh_title() -> void:
	var idx: int = GameState.current_chamber
	var data: Dictionary = ChamberBook.get_chamber(idx)
	var mode_tag: String = ""
	if GameState.run_mode == "daily":
		mode_tag = tr("hud.daily_tag") % GameState.daily_label
	title_label.text = "%s / %s — %s%s" % [
		GameState.run_progress_index() + 1,
		GameState.chambers_in_run(),
		_localized_title(data),
		mode_tag,
	]


func _localized_title(data: Dictionary) -> String:
	var cid: String = str(data.get("content_id", data.get("id", "")))
	var fallback: String = str(data.get("title", ""))
	if has_node("/root/LocaleManager") and cid != "":
		return LocaleManager.translate_chamber_title(cid, fallback)
	return fallback


func _localized_caption(data: Dictionary) -> String:
	var cid: String = str(data.get("content_id", data.get("id", "")))
	var fallback: String = str(data.get("caption", ""))
	if has_node("/root/LocaleManager") and cid != "":
		return LocaleManager.translate_chamber_caption(cid, fallback)
	return fallback


func _on_chamber_won(chamber_id: int, moves: int) -> void:
	emit_signal("chamber_won", chamber_id, moves)


func _on_moves_changed(moves: int) -> void:
	moves_label.text = tr("hud.moves") % moves
	habit_label.text = tr("hud.habit") % _habit_summary()


func _on_caption_changed(text: String) -> void:
	# Chamber emits the English caption from content JSON; re-localize by id.
	var data: Dictionary = ChamberBook.get_chamber(GameState.current_chamber)
	var localized: String = _localized_caption(data)
	caption_label.text = localized if localized != "" else text


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_echo():
		return
	if event.is_action_pressed("pause_menu"):
		# Flush any mid-slam fossils before leaving so Continue cannot softlock.
		if chamber_node != null and chamber_node.has_method("is_rewrite_locking"):
			if chamber_node.is_rewrite_locking() and chamber_node.has_method("_flush_pending_echoes"):
				chamber_node._flush_pending_echoes()
		emit_signal("menu_requested")


func _habit_summary() -> String:
	var hp: Dictionary = GameState.habit_profile
	var total: int = int(hp.get("up", 0)) + int(hp.get("down", 0)) + int(hp.get("left", 0)) + int(hp.get("right", 0))
	if total <= 0:
		return tr("hud.habit_unwritten")
	var dom: String = GameState.dominant_habit()
	var dom_label: String = dom
	if has_node("/root/LocaleManager"):
		dom_label = LocaleManager.habit_label(dom)
	var dv: int = int(hp.get(dom, 0))
	var pct: int = int(round(float(dv) / float(total) * 100.0))
	return tr("hud.habit_leaning_pct") % [dom_label, pct]
