extends Control
##
## Options + save management. Deliberately narrow while the game is
## in the meta-shell milestone; volume + display toggles + a wipe.
##

const MetaUIScript := preload("res://scripts/meta_ui.gd")

const MAIN_MENU_SCENE := "res://scenes/meta/main_menu.tscn"


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()


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
	col.add_theme_constant_override("separation", 16)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(col)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", MetaUIScript.GAP)
	col.add_child(header)
	header.add_child(MetaUIScript.make_title("OPTIONS"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	var back := MetaUIScript.make_button("BACK  (Esc)")
	back.custom_minimum_size = Vector2(160, 36)
	back.pressed.connect(func(): get_tree().change_scene_to_file(MAIN_MENU_SCENE))
	header.add_child(back)

	var audio_panel := MetaUIScript.make_panel()
	col.add_child(audio_panel)
	var audio := VBoxContainer.new()
	audio.add_theme_constant_override("separation", 8)
	audio_panel.add_child(audio)
	audio.add_child(MetaUIScript.make_label("AUDIO", 14, MetaUIScript.MUTED_TEXT_COLOR))
	audio.add_child(_slider("Master", "master_volume"))
	audio.add_child(_slider("Music", "music_volume"))
	audio.add_child(_slider("SFX", "sfx_volume"))

	var display_panel := MetaUIScript.make_panel()
	col.add_child(display_panel)
	var disp := VBoxContainer.new()
	disp.add_theme_constant_override("separation", 8)
	display_panel.add_child(disp)
	disp.add_child(MetaUIScript.make_label("DISPLAY / ACCESSIBILITY", 14, MetaUIScript.MUTED_TEXT_COLOR))
	disp.add_child(_checkbox("Fullscreen", "fullscreen"))
	disp.add_child(_checkbox("Reduce motion", "reduce_motion"))
	disp.add_child(_checkbox("Screen shake", "screen_shake"))

	var save_panel := MetaUIScript.make_panel(Color(0.16, 0.10, 0.10))
	col.add_child(save_panel)
	var sp := VBoxContainer.new()
	sp.add_theme_constant_override("separation", 8)
	save_panel.add_child(sp)
	sp.add_child(MetaUIScript.make_label("SAVE MANAGEMENT", 14, MetaUIScript.MUTED_TEXT_COLOR))
	sp.add_child(MetaUIScript.make_subtitle("Save at  %s" % SaveService.SAVE_PATH))
	sp.add_child(MetaUIScript.make_subtitle("Version  %d   Runs kept  %d / %d" % [
		int(SaveService.data.get("version", 0)),
		SaveService.run_history().size(),
		SaveService.RUN_HISTORY_CAP,
	]))

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", MetaUIScript.GAP)
	sp.add_child(buttons)

	var force_save := MetaUIScript.make_button("SAVE NOW")
	force_save.pressed.connect(func(): SaveService.save_to_disk(true))
	buttons.add_child(force_save)

	var wipe := MetaUIScript.make_button("WIPE SAVE")
	wipe.pressed.connect(_on_wipe_pressed)
	buttons.add_child(wipe)


func _slider(label: String, key: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", MetaUIScript.GAP)
	var l := MetaUIScript.make_label(label, 14)
	l.custom_minimum_size = Vector2(120, 0)
	row.add_child(l)
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = float(SaveService.get_setting(key, 1.0))
	s.custom_minimum_size = Vector2(240, 24)
	s.value_changed.connect(func(v): SaveService.set_setting(key, float(v)))
	row.add_child(s)
	var v := MetaUIScript.make_label("%d%%" % int(round(s.value * 100.0)), 14, MetaUIScript.MUTED_TEXT_COLOR)
	row.add_child(v)
	s.value_changed.connect(func(nv): v.text = "%d%%" % int(round(nv * 100.0)))
	return row


func _checkbox(label: String, key: String) -> Control:
	var cb := CheckBox.new()
	cb.text = label
	cb.button_pressed = bool(SaveService.get_setting(key, false))
	cb.toggled.connect(func(pressed): SaveService.set_setting(key, pressed))
	return cb


func _on_wipe_pressed() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.dialog_text = "Wipe save?\n\nThis erases unlocks, stats, and run history. Cannot be undone."
	dialog.title = "Confirm wipe"
	dialog.confirmed.connect(func():
		SaveService.wipe(true)
		_build_ui()
	)
	add_child(dialog)
	dialog.popup_centered()
