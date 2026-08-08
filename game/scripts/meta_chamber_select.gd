extends Control
##
## Chamber Select screen. Renders one card per catalog entry with
## unlock gating and a "Start" action.
##

const MetaUIScript := preload("res://scripts/meta_ui.gd")
const ChamberCatalogScript := preload("res://scripts/chamber_catalog.gd")

const MAIN_MENU_SCENE := "res://scenes/meta/main_menu.tscn"


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	SaveService.save_updated.connect(_build_ui)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_meta_back"):
		get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _build_ui() -> void:
	for c in get_children():
		c.queue_free()

	var bg := ColorRect.new()
	bg.color = MetaUIScript.BG_COLOR
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_bottom", 32)
	add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 20)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(col)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", MetaUIScript.GAP)
	col.add_child(header)
	header.add_child(MetaUIScript.make_title("CHAMBER SELECT"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	var back := MetaUIScript.make_button("BACK  (Esc)")
	back.custom_minimum_size = Vector2(160, 36)
	back.pressed.connect(func(): get_tree().change_scene_to_file(MAIN_MENU_SCENE))
	header.add_child(back)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	col.add_child(scroll)

	var grid := VBoxContainer.new()
	grid.add_theme_constant_override("separation", MetaUIScript.GAP)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grid)

	for chamber in ChamberCatalogScript.all():
		grid.add_child(_build_card(chamber))


func _build_card(chamber: Dictionary) -> Control:
	var available: bool = ChamberCatalogScript.is_available(String(chamber.get("id", "")), SaveService)
	var already_unlocked: bool = SaveService.is_chamber_unlocked(String(chamber.get("id", "")))
	var color := MetaUIScript.PANEL_COLOR if available else Color(0.09, 0.10, 0.12)
	var panel := MetaUIScript.make_panel(color)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	panel.add_child(row)

	var meta := VBoxContainer.new()
	meta.add_theme_constant_override("separation", 4)
	meta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(meta)

	var difficulty := int(chamber.get("difficulty", 1))
	var diff_str := "*".repeat(difficulty) + "-".repeat(5 - difficulty)
	var title_color: Color = MetaUIScript.TEXT_COLOR if available else MetaUIScript.MUTED_TEXT_COLOR
	meta.add_child(MetaUIScript.make_label(String(chamber.get("display_name", "?")), 22, title_color))
	meta.add_child(MetaUIScript.make_subtitle(String(chamber.get("subtitle", ""))))
	meta.add_child(MetaUIScript.make_subtitle("Difficulty  [%s]   Par  %s   Tags  %s" % [
		diff_str,
		MetaUIScript.format_duration(float(chamber.get("par_time_sec", 0))),
		", ".join(chamber.get("tags", [])),
	]))

	var stats := SaveService.stats()
	var clears := int((stats.get("clears_per_chamber", {}) as Dictionary).get(String(chamber.get("id", "")), 0))
	var deaths := int((stats.get("deaths_per_chamber", {}) as Dictionary).get(String(chamber.get("id", "")), 0))
	var best := float((stats.get("best_time_per_chamber", {}) as Dictionary).get(String(chamber.get("id", "")), 0.0))
	meta.add_child(MetaUIScript.make_subtitle("Clears %d   Deaths %d   Best %s" % [
		clears, deaths, MetaUIScript.format_duration(best),
	]))
	if not available:
		meta.add_child(MetaUIScript.make_label(ChamberCatalogScript.unlock_hint(String(chamber.get("id", ""))), 13, MetaUIScript.WARN_COLOR))
	elif not already_unlocked:
		meta.add_child(MetaUIScript.make_label("NEW: available", 13, MetaUIScript.GOOD_COLOR))

	var actions := VBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	row.add_child(actions)

	var start := MetaUIScript.make_button("START", available)
	start.pressed.connect(_on_start_pressed.bind(String(chamber.get("id", ""))))
	actions.add_child(start)

	return panel


func _on_start_pressed(chamber_id: String) -> void:
	if not ChamberCatalogScript.is_available(chamber_id, SaveService):
		return
	# Standard runs use a fresh seed each time.
	var seed := int(Time.get_unix_time_from_system()) ^ randi()
	GameSession.start_run(chamber_id, seed, "standard")
