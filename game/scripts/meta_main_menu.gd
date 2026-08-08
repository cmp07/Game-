extends Control
##
## Root of the Echo Lattice meta shell. Hosts the top-level nav:
## Continue / Chambers / Daily / Stats / Run History / Options / Quit.
##

const MetaUIScript := preload("res://scripts/meta_ui.gd")
const ChamberCatalogScript := preload("res://scripts/chamber_catalog.gd")

const CHAMBER_SELECT_SCENE := "res://scenes/meta/chamber_select.tscn"
const DAILY_SCENE := "res://scenes/meta/daily_screen.tscn"
const STATS_SCENE := "res://scenes/meta/stats_screen.tscn"
const RUN_HISTORY_SCENE := "res://scenes/meta/run_history.tscn"
const OPTIONS_SCENE := "res://scenes/meta/options_screen.tscn"


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	SaveService.save_updated.connect(_refresh)


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
	margin.add_theme_constant_override("margin_top", 48)
	margin.add_theme_constant_override("margin_bottom", 48)
	add_child(margin)

	var root := HBoxContainer.new()
	root.add_theme_constant_override("separation", 32)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(root)

	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", MetaUIScript.GAP)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 2.0
	root.add_child(left)

	left.add_child(MetaUIScript.make_title("ECHO LATTICE"))
	left.add_child(MetaUIScript.make_subtitle("A short tension vignette. Meta shell v%d." % SaveService.SAVE_VERSION))

	var nav_panel := MetaUIScript.make_panel()
	left.add_child(nav_panel)
	var nav := VBoxContainer.new()
	nav.add_theme_constant_override("separation", MetaUIScript.GAP)
	nav_panel.add_child(nav)

	if SaveService.has_active_run():
		var b_continue := MetaUIScript.make_button("CONTINUE RUN")
		b_continue.pressed.connect(_on_continue_pressed)
		nav.add_child(b_continue)
	else:
		var b_quick := MetaUIScript.make_button("QUICK RUN")
		b_quick.pressed.connect(_on_quick_run_pressed)
		nav.add_child(b_quick)

	var b_ch := MetaUIScript.make_button("CHAMBER SELECT")
	b_ch.pressed.connect(func(): get_tree().change_scene_to_file(CHAMBER_SELECT_SCENE))
	nav.add_child(b_ch)

	var b_daily := MetaUIScript.make_button("DAILY CHALLENGE")
	b_daily.pressed.connect(func(): get_tree().change_scene_to_file(DAILY_SCENE))
	nav.add_child(b_daily)

	var b_stats := MetaUIScript.make_button("STATS")
	b_stats.pressed.connect(func(): get_tree().change_scene_to_file(STATS_SCENE))
	nav.add_child(b_stats)

	var b_hist := MetaUIScript.make_button("RUN HISTORY")
	b_hist.pressed.connect(func(): get_tree().change_scene_to_file(RUN_HISTORY_SCENE))
	nav.add_child(b_hist)

	var b_opts := MetaUIScript.make_button("OPTIONS")
	b_opts.pressed.connect(func(): get_tree().change_scene_to_file(OPTIONS_SCENE))
	nav.add_child(b_opts)

	var b_quit := MetaUIScript.make_button("QUIT")
	b_quit.pressed.connect(_on_quit_pressed)
	nav.add_child(b_quit)

	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", MetaUIScript.GAP)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 3.0
	root.add_child(right)
	right.add_child(_build_summary_panel())
	right.add_child(_build_daily_panel())


func _build_summary_panel() -> Control:
	var p := MetaUIScript.make_panel(MetaUIScript.PANEL_ACCENT_COLOR)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", MetaUIScript.GAP)
	p.add_child(col)

	col.add_child(MetaUIScript.make_label("PROFILE", 14, MetaUIScript.MUTED_TEXT_COLOR))
	var name := String(SaveService.data.get("profile", {}).get("name", "Operator"))
	col.add_child(MetaUIScript.make_label(name, 24))

	var stats := SaveService.stats()
	var unlocked := SaveService.unlocked_chambers().size()
	var total := ChamberCatalogScript.all().size()

	col.add_child(_kv("Runs completed", str(int(stats.get("runs_completed", 0)))))
	col.add_child(_kv("Runs failed", str(int(stats.get("runs_failed", 0)))))
	col.add_child(_kv("Chambers unlocked", "%d / %d" % [unlocked, total]))
	col.add_child(_kv("Total time", MetaUIScript.format_duration(float(stats.get("total_time_sec", 0.0)))))
	col.add_child(_kv("Daily streak", "%d (best %d)" % [
		int(stats.get("daily_streak_current", 0)),
		int(stats.get("daily_streak_best", 0)),
	]))
	return p


func _build_daily_panel() -> Control:
	var p := MetaUIScript.make_panel()
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", MetaUIScript.GAP)
	p.add_child(col)

	col.add_child(MetaUIScript.make_label("TODAY'S DAILY", 14, MetaUIScript.MUTED_TEXT_COLOR))
	col.add_child(MetaUIScript.make_label(SaveService.daily_datestamp(), 22))
	col.add_child(MetaUIScript.make_subtitle("Seed  " + MetaUIScript.short_seed(SaveService.daily_seed())))
	var status_color: Color = MetaUIScript.GOOD_COLOR if SaveService.has_played_today() else MetaUIScript.ACCENT_COLOR
	var status_text: String = "Already played today" if SaveService.has_played_today() else "Not played yet"
	col.add_child(MetaUIScript.make_label(status_text, 14, status_color))
	return p


func _kv(k: String, v: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", MetaUIScript.GAP)
	var kl := MetaUIScript.make_label(k, 14, MetaUIScript.MUTED_TEXT_COLOR)
	kl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var vl := MetaUIScript.make_label(v, 14)
	row.add_child(kl)
	row.add_child(vl)
	return row


func _refresh() -> void:
	_build_ui()


func _on_quick_run_pressed() -> void:
	var chambers := ChamberCatalogScript.all()
	if chambers.is_empty():
		return
	var seed := int(Time.get_unix_time_from_system()) ^ randi()
	GameSession.start_run(String(chambers[0].get("id", "ec_01_boot")), seed, "standard")


func _on_continue_pressed() -> void:
	var run := SaveService.active_run()
	if run.is_empty():
		return
	GameSession.start_run(
		String(run.get("chamber_id", "ec_01_boot")),
		int(run.get("seed", 0)),
		String(run.get("mode", "standard")),
	)


func _on_quit_pressed() -> void:
	SaveService.save_to_disk(true)
	get_tree().quit()
