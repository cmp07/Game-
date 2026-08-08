extends Control

const MetaUIScript := preload("res://scripts/meta_ui.gd")
const ChamberCatalogScript := preload("res://scripts/chamber_catalog.gd")

const MAIN_MENU_SCENE := "res://scenes/meta/main_menu.tscn"


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	SaveService.stats_updated.connect(_build_ui)


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
	header.add_child(MetaUIScript.make_title("STATS"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	var back := MetaUIScript.make_button("BACK  (Esc)")
	back.custom_minimum_size = Vector2(160, 36)
	back.pressed.connect(func(): get_tree().change_scene_to_file(MAIN_MENU_SCENE))
	header.add_child(back)

	var stats := SaveService.stats()
	var totals_panel := MetaUIScript.make_panel(MetaUIScript.PANEL_ACCENT_COLOR)
	col.add_child(totals_panel)
	var totals := GridContainer.new()
	totals.columns = 4
	totals.add_theme_constant_override("h_separation", 24)
	totals.add_theme_constant_override("v_separation", 8)
	totals_panel.add_child(totals)

	_add_stat(totals, "Runs started", str(int(stats.get("runs_started", 0))))
	_add_stat(totals, "Runs completed", str(int(stats.get("runs_completed", 0))))
	_add_stat(totals, "Deaths", str(int(stats.get("runs_failed", 0))))
	_add_stat(totals, "Abandoned", str(int(stats.get("runs_abandoned", 0))))
	_add_stat(totals, "Total time", MetaUIScript.format_duration(float(stats.get("total_time_sec", 0.0))))
	_add_stat(totals, "Daily streak", "%d (best %d)" % [
		int(stats.get("daily_streak_current", 0)),
		int(stats.get("daily_streak_best", 0)),
	])
	_add_stat(totals, "Last daily", String(stats.get("last_daily_date", "--")))
	_add_stat(totals, "Chambers unlocked", "%d / %d" % [
		SaveService.unlocked_chambers().size(),
		ChamberCatalogScript.all().size(),
	])

	col.add_child(MetaUIScript.make_label("PER-CHAMBER", 16, MetaUIScript.MUTED_TEXT_COLOR))

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(scroll)

	var table_panel := MetaUIScript.make_panel()
	scroll.add_child(table_panel)
	var table := GridContainer.new()
	table.columns = 5
	table.add_theme_constant_override("h_separation", 24)
	table.add_theme_constant_override("v_separation", 6)
	table_panel.add_child(table)

	_add_header_cell(table, "Chamber")
	_add_header_cell(table, "Clears")
	_add_header_cell(table, "Deaths")
	_add_header_cell(table, "Best time")
	_add_header_cell(table, "Par")

	for chamber in ChamberCatalogScript.all():
		var id := String(chamber.get("id", ""))
		var clears := int((stats.get("clears_per_chamber", {}) as Dictionary).get(id, 0))
		var deaths := int((stats.get("deaths_per_chamber", {}) as Dictionary).get(id, 0))
		var best := float((stats.get("best_time_per_chamber", {}) as Dictionary).get(id, 0.0))
		table.add_child(MetaUIScript.make_label(String(chamber.get("display_name", "?")), 14))
		table.add_child(MetaUIScript.make_label(str(clears), 14))
		table.add_child(MetaUIScript.make_label(str(deaths), 14))
		table.add_child(MetaUIScript.make_label(MetaUIScript.format_duration(best), 14))
		table.add_child(MetaUIScript.make_label(MetaUIScript.format_duration(float(chamber.get("par_time_sec", 0))), 14, MetaUIScript.MUTED_TEXT_COLOR))


func _add_stat(parent: Container, label: String, value: String) -> void:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.add_child(MetaUIScript.make_label(label, 12, MetaUIScript.MUTED_TEXT_COLOR))
	col.add_child(MetaUIScript.make_label(value, 22))
	parent.add_child(col)


func _add_header_cell(parent: Container, text: String) -> void:
	parent.add_child(MetaUIScript.make_label(text, 12, MetaUIScript.ACCENT_COLOR))
