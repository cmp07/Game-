extends Control

const MetaUIScript := preload("res://scripts/meta_ui.gd")
const ChamberCatalogScript := preload("res://scripts/chamber_catalog.gd")

const MAIN_MENU_SCENE := "res://scenes/meta/main_menu.tscn"


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	SaveService.run_recorded.connect(func(_r): _build_ui())


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
	header.add_child(MetaUIScript.make_title("RUN HISTORY"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	var back := MetaUIScript.make_button("BACK  (Esc)")
	back.custom_minimum_size = Vector2(160, 36)
	back.pressed.connect(func(): get_tree().change_scene_to_file(MAIN_MENU_SCENE))
	header.add_child(back)

	var runs := SaveService.run_history()
	col.add_child(MetaUIScript.make_subtitle("Showing last %d run(s) (cap %d)" % [runs.size(), SaveService.RUN_HISTORY_CAP]))

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(scroll)

	var panel := MetaUIScript.make_panel()
	scroll.add_child(panel)
	var table := GridContainer.new()
	table.columns = 6
	table.add_theme_constant_override("h_separation", 20)
	table.add_theme_constant_override("v_separation", 6)
	panel.add_child(table)

	_add_header(table, "When")
	_add_header(table, "Chamber")
	_add_header(table, "Mode")
	_add_header(table, "Seed")
	_add_header(table, "Duration")
	_add_header(table, "Outcome")

	if runs.is_empty():
		var empty := MetaUIScript.make_label("No runs recorded yet.", 14, MetaUIScript.MUTED_TEXT_COLOR)
		col.add_child(empty)
		return

	for r in runs:
		var chamber := ChamberCatalogScript.get_by_id(String(r.get("chamber_id", "")))
		var name := String(chamber.get("display_name", r.get("chamber_id", "?")))
		table.add_child(MetaUIScript.make_label(String(r.get("ended_at_utc", "?")).left(19), 13))
		table.add_child(MetaUIScript.make_label(name, 13))
		table.add_child(MetaUIScript.make_label(String(r.get("mode", "?")), 13, MetaUIScript.MUTED_TEXT_COLOR))
		table.add_child(MetaUIScript.make_label(MetaUIScript.short_seed(int(r.get("seed", 0))), 13, MetaUIScript.MUTED_TEXT_COLOR))
		table.add_child(MetaUIScript.make_label(MetaUIScript.format_duration(float(r.get("duration_sec", 0.0))), 13))
		table.add_child(_outcome_label(String(r.get("outcome", ""))))


func _add_header(parent: Container, text: String) -> void:
	parent.add_child(MetaUIScript.make_label(text, 12, MetaUIScript.ACCENT_COLOR))


func _outcome_label(outcome: String) -> Label:
	var color := MetaUIScript.MUTED_TEXT_COLOR
	match outcome:
		"clear": color = MetaUIScript.GOOD_COLOR
		"death": color = MetaUIScript.BAD_COLOR
		"abandoned": color = MetaUIScript.WARN_COLOR
	return MetaUIScript.make_label(outcome, 13, color)
