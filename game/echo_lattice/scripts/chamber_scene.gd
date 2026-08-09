extends Control
##
## Chamber scene root — Chamber + diegetic Field Ledger HUD
## (seed header + punch-card move buffer on the page margins).
##

signal chamber_won(chamber_id: int, moves: int)
signal menu_requested()

const SETTINGS_SCENE: PackedScene = preload("res://scenes/ui/settings_menu.tscn")
const PUNCHCARD_CELLS: int = 30

@onready var chamber_node: Node2D = %Chamber
@onready var title_label: Label = %ChamberTitle
@onready var caption_label: Label = %Caption
@onready var teach_hint_label: Label = get_node_or_null("%TeachHint")
@onready var undo_hint_label: Label = get_node_or_null("%UndoHint")
@onready var moves_label: Label = %MovesLabel
@onready var habit_label: Label = %HabitLabel
@onready var restart_button: Button = %RestartButton
@onready var settings_button: Button = %SettingsButton
@onready var menu_button: Button = %MenuButton
@onready var seed_label: Label = %SeedLabel
@onready var seed_header_tex: TextureRect = %SeedHeaderTex
@onready var buffer_label: Label = %BufferLabel
@onready var punchcard_cells: HBoxContainer = %PunchcardCells

var _glyph_device: int = -1
var _settings_overlay: Control = null
var _punch_rects: Array = []  # Array[TextureRect]
var _tex_empty: Texture2D
var _tex_filled: Texture2D
var _tex_rust: Texture2D
var _tex_warn: Texture2D


func _ready() -> void:
	restart_button.text = tr("hud.restart")
	menu_button.text = tr("hud.menu")
	restart_button.pressed.connect(func(): chamber_node.reset_chamber())
	settings_button.pressed.connect(_open_settings)
	menu_button.pressed.connect(func(): emit_signal("menu_requested"))
	chamber_node.chamber_won.connect(_on_chamber_won)
	chamber_node.moves_changed.connect(_on_moves_changed)
	chamber_node.caption_changed.connect(_on_caption_changed)
	if chamber_node.has_signal("teach_hint"):
		chamber_node.teach_hint.connect(_on_teach_hint)
	if chamber_node.has_signal("undo_hint_changed"):
		chamber_node.undo_hint_changed.connect(_on_undo_hint_changed)
	## Keep D-Pad on movement — HUD chrome is clickable but not focus-stealing.
	restart_button.focus_mode = Control.FOCUS_NONE
	if settings_button:
		settings_button.focus_mode = Control.FOCUS_NONE
		settings_button.text = tr("menu.settings")
	menu_button.focus_mode = Control.FOCUS_NONE
	if has_node("/root/LocaleManager"):
		LocaleManager.locale_changed.connect(_on_locale_changed)
	_setup_ledger_hud()
	_refresh_glyph_labels()
	_style_ledger_chrome()
	_refresh_title()
	_refresh_seed_header()
	_on_moves_changed(0)
	var data: Dictionary = ChamberBook.get_chamber(GameState.current_chamber)
	_on_caption_changed(_localized_caption(data))
	set_process(true)
	_glyph_device = InputGlyphs.last_device if has_node("/root/InputGlyphs") else -1
	var remap := get_node_or_null("/root/ActionRemap")
	if remap != null and remap.has_signal("bindings_changed"):
		if not remap.bindings_changed.is_connected(_refresh_glyph_labels):
			remap.bindings_changed.connect(_refresh_glyph_labels)


func _on_locale_changed(_locale: String) -> void:
	# Mid-run language switch must refresh HUD chrome, not only the next move event.
	_refresh_glyph_labels()
	if settings_button:
		settings_button.text = tr("menu.settings")
	if buffer_label:
		buffer_label.text = tr("menu.buffer")
	_refresh_title()
	_refresh_seed_header()
	_on_moves_changed(chamber_node.move_count if chamber_node else 0)
	var data: Dictionary = ChamberBook.get_chamber(GameState.current_chamber)
	_on_caption_changed(_localized_caption(data))


func _process(_delta: float) -> void:
	if not has_node("/root/InputGlyphs"):
		return
	if InputGlyphs.last_device != _glyph_device:
		_glyph_device = InputGlyphs.last_device
		_refresh_glyph_labels()


func _setup_ledger_hud() -> void:
	_tex_empty = ArtKit.tex("res://art/ui/punchcard_cell_empty.png")
	_tex_filled = ArtKit.tex("res://art/ui/punchcard_cell_filled.png")
	_tex_rust = ArtKit.tex("res://art/ui/punchcard_cell_rust.png")
	_tex_warn = ArtKit.tex("res://art/ui/punchcard_cell_warn.png")
	if seed_header_tex:
		seed_header_tex.texture = ArtKit.tex("res://art/ui/seed_header_256x24.png")
		seed_header_tex.modulate = Color(1, 1, 1, 0.95)
	if buffer_label:
		buffer_label.text = tr("menu.buffer")
	_punch_rects.clear()
	if punchcard_cells == null:
		return
	for child in punchcard_cells.get_children():
		child.queue_free()
	for i in range(PUNCHCARD_CELLS):
		var cell := TextureRect.new()
		cell.custom_minimum_size = Vector2(12, 16)
		cell.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		cell.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cell.texture = _tex_empty
		punchcard_cells.add_child(cell)
		_punch_rects.append(cell)


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
		if GameState.daily_friend_code != "":
			mode_tag = tr("hud.daily_tag_code") % [GameState.daily_label, GameState.daily_friend_code]
		else:
			mode_tag = tr("hud.daily_tag") % GameState.daily_label
	elif GameState.run_mode == "endless":
		var pct: int = int(round(GameState.rewrite_pressure() * 100.0))
		mode_tag = tr("hud.endless_tag") % [GameState.endless_label, pct]
	elif GameState.run_mode == "hard":
		mode_tag = tr("hud.hard_tag")
	if GameState.run_mode == "endless":
		title_label.text = "%s — %s%s" % [
			tr("hud.endless_depth") % (GameState.endless_depth + 1),
			_localized_title(data),
			mode_tag,
		]
	else:
		title_label.text = "%s / %s — %s%s" % [
			GameState.run_progress_index() + 1,
			GameState.chambers_in_run(),
			_localized_title(data),
			mode_tag,
		]


func _refresh_seed_header() -> void:
	if seed_label == null:
		return
	seed_label.text = tr("hud.seed") % GameState.seed_display_string()
	seed_label.add_theme_color_override("font_color", Palette.SLATE_TEAL_SOFT)


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
	_refresh_habit_label()
	_refresh_seed_header()
	_refresh_punchcard()


func _refresh_punchcard() -> void:
	if _punch_rects.is_empty():
		return
	var filled: int = 0
	if chamber_node != null and chamber_node.has_method("buffer_fill_count"):
		filled = int(chamber_node.buffer_fill_count())
	else:
		filled = mini(GameState.move_ring.size(), PUNCHCARD_CELLS)
	filled = clampi(filled, 0, PUNCHCARD_CELLS)
	var warn: bool = filled > 0
	if chamber_node != null and chamber_node.has_method("is_rewrite_warn_active"):
		warn = warn and bool(chamber_node.is_rewrite_warn_active())
	else:
		var near_cp: int = -1
		if chamber_node != null and chamber_node.has_method("nearest_unused_checkpoint_dist"):
			near_cp = int(chamber_node.nearest_unused_checkpoint_dist())
		warn = warn and near_cp >= 0 and near_cp <= 3
	for i in range(PUNCHCARD_CELLS):
		var cell: TextureRect = _punch_rects[i]
		var tex: Texture2D = _tex_empty
		if i < filled:
			tex = _tex_filled
			# Late buffer cells pick up rust — habit pressure before rewrite.
			if filled >= 8 and i >= filled - 7:
				tex = _tex_rust
		if warn and i == filled - 1:
			tex = _tex_warn
		cell.texture = tex if tex != null else _tex_empty


func _on_caption_changed(text: String) -> void:
	# Chamber emits the English caption from content JSON; re-localize by id.
	var data: Dictionary = ChamberBook.get_chamber(GameState.current_chamber)
	var localized: String = _localized_caption(data)
	caption_label.text = localized if localized != "" else text


func _on_teach_hint(text: String) -> void:
	if teach_hint_label == null:
		return
	var trimmed: String = text.strip_edges()
	if trimmed.is_empty():
		teach_hint_label.visible = false
		teach_hint_label.text = ""
		return
	teach_hint_label.text = trimmed
	teach_hint_label.visible = true


func _on_undo_hint_changed(armed: bool) -> void:
	if undo_hint_label == null:
		return
	if not armed:
		undo_hint_label.visible = false
		undo_hint_label.text = ""
		return
	var glyph := "Z"
	if has_node("/root/InputGlyphs") and InputGlyphs.has_method("undo_label"):
		glyph = str(InputGlyphs.undo_label())
	undo_hint_label.text = tr("hud.undo_hint") % glyph
	undo_hint_label.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_echo():
		return
	if event.is_action_pressed("pause_menu"):
		# Flush any mid-slam fossils before leaving so Continue cannot softlock.
		if chamber_node != null and chamber_node.has_method("is_rewrite_locking"):
			if chamber_node.is_rewrite_locking() and chamber_node.has_method("_flush_pending_echoes"):
				chamber_node._flush_pending_echoes()
		emit_signal("menu_requested")


func _refresh_habit_label() -> void:
	## Habit identity stays sealed until a Mirror Birth moment writes the ledger.
	if not GameState.is_habit_identity_visible():
		habit_label.visible = true
		habit_label.text = tr("hud.habit") % tr("hud.habit_sealed")
		return
	habit_label.visible = true
	habit_label.text = tr("hud.habit") % _habit_summary()


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
	var hand_id: String = GameState.habit_hand_id()
	var hand_key := "habit.hand_%s" % hand_id
	var hand: String = tr(hand_key)
	if hand == hand_key:
		hand = hand_id
	return tr("hud.habit_identity_pct") % [dom_label, pct, hand]
