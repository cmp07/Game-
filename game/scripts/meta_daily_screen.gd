extends Control
##
## Daily Challenge screen. Deterministic per UTC date; picks the
## chamber from the same seed so different days rotate.
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
	header.add_child(MetaUIScript.make_title("DAILY CHALLENGE"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	var back := MetaUIScript.make_button("BACK  (Esc)")
	back.custom_minimum_size = Vector2(160, 36)
	back.pressed.connect(func(): get_tree().change_scene_to_file(MAIN_MENU_SCENE))
	header.add_child(back)

	var date := SaveService.daily_datestamp()
	var seed := SaveService.daily_seed()
	var chamber_id := _pick_daily_chamber(seed)
	var chamber := ChamberCatalogScript.get_by_id(chamber_id)
	var already_played := SaveService.has_played_today()

	var panel := MetaUIScript.make_panel(MetaUIScript.PANEL_ACCENT_COLOR)
	col.add_child(panel)
	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 12)
	panel.add_child(inner)
	inner.add_child(MetaUIScript.make_label(date, 40))
	inner.add_child(MetaUIScript.make_subtitle("Seed  " + MetaUIScript.short_seed(seed)))
	inner.add_child(MetaUIScript.make_label(String(chamber.get("display_name", "?")), 22, MetaUIScript.ACCENT_COLOR))
	inner.add_child(MetaUIScript.make_subtitle(String(chamber.get("subtitle", ""))))

	var stats := SaveService.stats()
	inner.add_child(MetaUIScript.make_label(
		"Streak  %d   Best  %d" % [
			int(stats.get("daily_streak_current", 0)),
			int(stats.get("daily_streak_best", 0)),
		],
		16,
	))

	if already_played:
		inner.add_child(MetaUIScript.make_label(
			"You've already recorded a daily run for %s (%s). Come back tomorrow." % [date, String(stats.get("last_daily_outcome", "?"))],
			14,
			MetaUIScript.MUTED_TEXT_COLOR,
		))
	else:
		inner.add_child(MetaUIScript.make_label("One attempt per UTC day. Result locks the streak.", 14, MetaUIScript.WARN_COLOR))

	var start := MetaUIScript.make_button("START DAILY", not already_played)
	start.pressed.connect(_on_start_pressed.bind(chamber_id, seed))
	inner.add_child(start)


func _pick_daily_chamber(seed: int) -> String:
	var all := ChamberCatalogScript.all()
	if all.is_empty():
		return ""
	# Only rotate through chambers the player has actually unlocked
	# so the daily is never gated behind content they can't reach.
	var pool: Array[String] = []
	for c in all:
		var id := String(c.get("id", ""))
		if SaveService.is_chamber_unlocked(id):
			pool.append(id)
	if pool.is_empty():
		pool.append(String(all[0].get("id", "")))
	var idx: int = int(abs(seed)) % pool.size()
	return pool[idx]


func _on_start_pressed(chamber_id: String, seed: int) -> void:
	if SaveService.has_played_today():
		return
	GameSession.start_run(chamber_id, seed, "daily")
