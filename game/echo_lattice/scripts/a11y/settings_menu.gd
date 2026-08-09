extends Control
## Echo Lattice settings — language, audio, accessibility, remaps, support.

signal closed()

@onready var _language_option: OptionButton = %LanguageOption
@onready var _master_vol: HSlider = %MasterVolSlider
@onready var _sfx_vol: HSlider = %SfxVolSlider
@onready var _music_vol: HSlider = %MusicVolSlider
@onready var _pa_vol: HSlider = %PaVolSlider
@onready var _colorblind_option: OptionButton = %ColorblindOption
@onready var _pattern_check: CheckButton = %FossilPatternsCheck
@onready var _reduce_flash_check: CheckButton = %ReduceFlashCheck
@onready var _shake_check: CheckButton = %ScreenShakeCheck
@onready var _shake_slider: HSlider = %ShakeIntensitySlider
@onready var _subtitles_check: CheckButton = %SubtitlesCheck
@onready var _subtitle_size: OptionButton = %SubtitleSizeOption
@onready var _subtitle_bg_check: CheckButton = %SubtitleBackgroundCheck
@onready var _ui_scale_slider: HSlider = %UiScaleSlider
@onready var _ui_scale_value: Label = %UiScaleValue
@onready var _ghost_assist_check: CheckButton = %GhostAssistCheck
@onready var _reduce_motion_check: CheckButton = %ReduceMotionCheck
@onready var _hold_walk_check: CheckButton = %HoldToWalkCheck
@onready var _bindings_list: VBoxContainer = %BindingsList
@onready var _build_id_label: Label = %BuildIdLabel
@onready var _status: Label = %StatusLabel

var _a11y: Node
var _remap: Node
var _store: Node
var _locale: Node
var _rebind_buttons: Dictionary = {}
var _loading: bool = false


func _ready() -> void:
	_a11y = get_node_or_null("/root/AccessibilityService")
	_remap = get_node_or_null("/root/ActionRemap")
	_store = get_node_or_null("/root/SettingsStore")
	_locale = get_node_or_null("/root/LocaleManager")
	_populate_static_options()
	_load_from_services()
	_build_binding_rows()
	visibility_changed.connect(_on_visibility_changed)
	if not visible:
		# Instantiated as overlay — start hidden unless opened.
		pass


func open_menu() -> void:
	visible = true
	# Localized chrome title key (settings panel header may be static in tscn).
	var _title_tr := tr("settings.title")
	if _status:
		_status.text = _title_tr
	_load_from_services()
	_refresh_binding_labels()
	if _language_option:
		_language_option.grab_focus()
	elif _colorblind_option:
		_colorblind_option.grab_focus()


func close_menu() -> void:
	visible = false
	closed.emit()


func _populate_static_options() -> void:
	_language_option.clear()
	_language_option.add_item(tr("locale.system"))
	_language_option.set_item_metadata(0, "system")
	_language_option.add_item(tr("locale.en"))
	_language_option.set_item_metadata(1, "en")
	_language_option.add_item(tr("locale.zh_Hans"))
	_language_option.set_item_metadata(2, "zh_Hans")
	_colorblind_option.clear()
	for id in FossilPalette.all_mode_ids():
		var mode := FossilPalette.mode_from_string(id)
		_colorblind_option.add_item(FossilPalette.display_name(mode))
		_colorblind_option.set_item_metadata(_colorblind_option.item_count - 1, id)
	_subtitle_size.clear()
	for size_id in ["small", "medium", "large"]:
		_subtitle_size.add_item(size_id.capitalize())
		_subtitle_size.set_item_metadata(_subtitle_size.item_count - 1, size_id)


func _load_from_services() -> void:
	_loading = true
	var locale_code := str(_store_get("locale", "code", "system"))
	_select_option_by_meta(_language_option, locale_code)
	_master_vol.value = float(_store_get("audio", "master_volume", 1.0))
	_sfx_vol.value = float(_store_get("audio", "sfx_volume", 1.0))
	_music_vol.value = float(_store_get("audio", "music_volume", 0.8))
	_pa_vol.value = float(_store_get("audio", "pa_volume", 1.0))
	var hook := get_node_or_null("/root/CrashLogHook")
	var build := str(ProjectSettings.get_setting("application/config/version", "dev"))
	if hook != null and "build_id" in hook:
		build = str(hook.build_id)
	_build_id_label.text = "Build: %s" % build
	if _a11y == null:
		_loading = false
		return
	var snap: Dictionary = _a11y.accessibility_snapshot()
	_select_option_by_meta(_colorblind_option, str(snap.get("colorblind_mode", "default")))
	_pattern_check.button_pressed = bool(snap.get("fossil_use_patterns", true))
	_reduce_flash_check.button_pressed = bool(snap.get("reduce_flash", false))
	_shake_check.button_pressed = bool(_store_get("accessibility", "screen_shake_enabled", false))
	_shake_slider.value = float(_store_get("accessibility", "screen_shake_intensity", 0.35))
	_subtitles_check.button_pressed = bool(snap.get("subtitles_enabled", true))
	_select_option_by_meta(_subtitle_size, str(snap.get("subtitle_size", "medium")))
	if _subtitle_bg_check:
		_subtitle_bg_check.button_pressed = bool(snap.get("subtitle_background", true))
	_ui_scale_slider.value = float(snap.get("ui_scale", 1.0))
	_ui_scale_value.text = "%.2f×" % float(snap.get("ui_scale", 1.0))
	_ghost_assist_check.button_pressed = bool(snap.get("show_ghost_path_once", false))
	_reduce_motion_check.button_pressed = bool(snap.get("reduce_motion", false))
	_hold_walk_check.button_pressed = bool(snap.get("hold_to_walk", false))
	_shake_slider.editable = _shake_check.button_pressed and not _reduce_motion_check.button_pressed
	_loading = false


func _build_binding_rows() -> void:
	for child in _bindings_list.get_children():
		child.queue_free()
	_rebind_buttons.clear()
	var actions: PackedStringArray = [
		"move_up", "move_down", "move_left", "move_right",
		"undo", "restart", "pause_menu", "ghost_assist",
	]
	if _remap != null and "ACTIONS" in _remap:
		actions = _remap.ACTIONS
	for action in actions:
		if action == "confirm":
			continue
		var row := HBoxContainer.new()
		var name_l := Label.new()
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if _remap != null and _remap.has_method("action_display_name"):
			name_l.text = str(_remap.action_display_name(action))
		else:
			name_l.text = action
		name_l.add_theme_color_override("font_color", Color("#3A342C"))
		var btn := Button.new()
		btn.text = _labels_for(action)
		btn.pressed.connect(_on_rebind_pressed.bind(action, btn))
		row.add_child(name_l)
		row.add_child(btn)
		_bindings_list.add_child(row)
		_rebind_buttons[action] = btn


func _refresh_binding_labels() -> void:
	for action in _rebind_buttons.keys():
		(_rebind_buttons[action] as Button).text = _labels_for(str(action))


func _labels_for(action: String) -> String:
	if _remap != null and _remap.has_method("get_binding_labels"):
		var labels: PackedStringArray = _remap.get_binding_labels(action)
		return ", ".join(labels) if labels.size() > 0 else "—"
	return "—"


func _on_rebind_pressed(action: String, btn: Button) -> void:
	if _remap == null:
		return
	btn.text = tr("settings.rebind_prompt")
	_status.text = "Rebinding %s" % action
	_remap.start_rebind(action)
	if not _remap.bindings_changed.is_connected(_on_bindings_changed):
		_remap.bindings_changed.connect(_on_bindings_changed)


func _on_bindings_changed() -> void:
	_refresh_binding_labels()
	_status.text = tr("settings.bindings_saved")


func _on_visibility_changed() -> void:
	if visible:
		_load_from_services()


func _on_language_selected(index: int) -> void:
	if _loading:
		return
	var code := str(_language_option.get_item_metadata(index))
	if _locale != null and _locale.has_method("apply_locale"):
		_locale.apply_locale(code, true)
	else:
		_store_set("locale", "code", code)
	_status.text = tr("locale.language") + ": " + _language_option.get_item_text(index)


func _on_master_vol_changed(value: float) -> void:
	if _loading:
		return
	_store_set("audio", "master_volume", value)


func _on_sfx_vol_changed(value: float) -> void:
	if _loading:
		return
	_store_set("audio", "sfx_volume", value)


func _on_music_vol_changed(value: float) -> void:
	if _loading:
		return
	_store_set("audio", "music_volume", value)


func _on_pa_vol_changed(value: float) -> void:
	if _loading:
		return
	_store_set("audio", "pa_volume", value)


func _on_colorblind_selected(index: int) -> void:
	var id := str(_colorblind_option.get_item_metadata(index))
	if _a11y:
		_a11y.set_colorblind_mode(FossilPalette.mode_from_string(id))
	_status.text = "Colorblind mode: %s" % id


func _on_patterns_toggled(pressed: bool) -> void:
	if _a11y:
		_a11y.set_fossil_use_patterns(pressed)


func _on_reduce_flash_toggled(pressed: bool) -> void:
	if _a11y:
		_a11y.set_reduce_flash(pressed)


func _on_shake_toggled(pressed: bool) -> void:
	if _a11y:
		_a11y.set_screen_shake_enabled(pressed)
	_shake_slider.editable = pressed and not _reduce_motion_check.button_pressed


func _on_shake_intensity_changed(value: float) -> void:
	if _a11y:
		_a11y.set_screen_shake_intensity(value)


func _on_subtitles_toggled(pressed: bool) -> void:
	if _a11y:
		_a11y.set_subtitles_enabled(pressed)


func _on_subtitle_size_selected(index: int) -> void:
	var id := str(_subtitle_size.get_item_metadata(index))
	if _a11y:
		_a11y.set_subtitle_size(id)



func _on_subtitle_background_toggled(pressed: bool) -> void:
	if _loading:
		return
	if _a11y != null and _a11y.has_method("set_subtitle_background"):
		_a11y.call("set_subtitle_background", pressed)
	else:
		_store_set("accessibility", "subtitle_background", pressed)

func _on_ui_scale_changed(value: float) -> void:
	_ui_scale_value.text = "%.2f×" % value
	if _a11y:
		_a11y.set_ui_scale(value)


func _on_ghost_assist_toggled(pressed: bool) -> void:
	if _a11y:
		_a11y.set_show_ghost_path_once_enabled(pressed)


func _on_reduce_motion_toggled(pressed: bool) -> void:
	if _a11y:
		_a11y.set_reduce_motion(pressed)
	_shake_slider.editable = _shake_check.button_pressed and not pressed


func _on_hold_walk_toggled(pressed: bool) -> void:
	if _a11y and _a11y.has_method("set_hold_to_walk"):
		_a11y.set_hold_to_walk(pressed)
	else:
		_store_set("accessibility", "hold_to_walk", pressed)


func _on_export_crash_pack() -> void:
	var hook := get_node_or_null("/root/CrashLogHook")
	if hook == null or not hook.has_method("export_crash_pack"):
		_status.text = "Crash log hook unavailable."
		return
	var dest := ProjectSettings.globalize_path("user://")
	var path: String = hook.export_crash_pack(dest, false)
	_status.text = "Crash pack: %s" % path


func _on_reset_accessibility() -> void:
	if _store != null and _store.has_method("reset_section"):
		_store.reset_section("accessibility")
	if _a11y != null and _a11y.has_method("apply_ui_scale"):
		_a11y.apply_ui_scale()
	_load_from_services()
	_status.text = tr("settings.a11y_reset")


func _on_reset_bindings() -> void:
	if _remap != null and _remap.has_method("reset_to_defaults"):
		_remap.reset_to_defaults()
	_refresh_binding_labels()
	_status.text = "Input bindings reset."


func _on_close_pressed() -> void:
	close_menu()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause_menu") or event.is_action_pressed("ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()


func _select_option_by_meta(option: OptionButton, meta: String) -> void:
	for i in option.item_count:
		if str(option.get_item_metadata(i)) == meta:
			option.select(i)
			return
	if option.item_count > 0:
		option.select(0)


func _store_get(section: String, key: String, fallback: Variant) -> Variant:
	if _store != null and _store.has_method("get_value"):
		return _store.get_value(section, key, fallback)
	return fallback


func _store_set(section: String, key: String, value: Variant) -> void:
	if _store != null and _store.has_method("set_value"):
		_store.set_value(section, key, value)
