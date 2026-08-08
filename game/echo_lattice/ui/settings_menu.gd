extends Control
## Echo Lattice settings menu — accessibility + remappable input completeness surface.

signal closed()

@onready var _fossil_option: OptionButton = %FossilPaletteOption
@onready var _pattern_check: CheckButton = %FossilPatternsCheck
@onready var _reduce_flash_check: CheckButton = %ReduceFlashCheck
@onready var _shake_check: CheckButton = %ScreenShakeCheck
@onready var _shake_slider: HSlider = %ShakeIntensitySlider
@onready var _subtitles_check: CheckButton = %SubtitlesCheck
@onready var _subtitle_size: OptionButton = %SubtitleSizeOption
@onready var _ghost_assist_check: CheckButton = %GhostAssistCheck
@onready var _reduce_motion_check: CheckButton = %ReduceMotionCheck
@onready var _hold_walk_check: CheckButton = %HoldToWalkCheck
@onready var _bindings_list: VBoxContainer = %BindingsList
@onready var _status: Label = %StatusLabel

var _a11y: Node
var _remap: Node
var _store: Node
var _rebind_buttons: Dictionary = {}


func _ready() -> void:
	_a11y = get_node_or_null("/root/AccessibilityService")
	_remap = get_node_or_null("/root/ActionRemap")
	_store = get_node_or_null("/root/SettingsStore")
	_populate_static_options()
	_load_from_services()
	_build_binding_rows()
	visibility_changed.connect(_on_visibility_changed)


func open_menu() -> void:
	visible = true
	_load_from_services()
	_refresh_binding_labels()


func close_menu() -> void:
	visible = false
	closed.emit()


func _populate_static_options() -> void:
	_fossil_option.clear()
	for id in FossilPalette.all_mode_ids():
		var mode := FossilPalette.mode_from_string(id)
		_fossil_option.add_item(FossilPalette.display_name(mode))
		_fossil_option.set_item_metadata(_fossil_option.item_count - 1, id)
	_subtitle_size.clear()
	for size_id in ["small", "medium", "large"]:
		_subtitle_size.add_item(size_id.capitalize())
		_subtitle_size.set_item_metadata(_subtitle_size.item_count - 1, size_id)


func _load_from_services() -> void:
	if _a11y == null:
		return
	var snap: Dictionary = _a11y.accessibility_snapshot()
	_select_option_by_meta(_fossil_option, str(snap.get("fossil_palette", "default")))
	_pattern_check.button_pressed = bool(snap.get("fossil_use_patterns", true))
	_reduce_flash_check.button_pressed = bool(snap.get("reduce_flash", false))
	_shake_check.button_pressed = bool(_store_get("accessibility", "screen_shake_enabled", true))
	_shake_slider.value = float(_store_get("accessibility", "screen_shake_intensity", 1.0))
	_subtitles_check.button_pressed = bool(snap.get("subtitles_enabled", true))
	_select_option_by_meta(_subtitle_size, str(snap.get("subtitle_size", "medium")))
	_ghost_assist_check.button_pressed = bool(snap.get("show_ghost_path_once", false))
	_reduce_motion_check.button_pressed = bool(snap.get("reduce_motion", false))
	_hold_walk_check.button_pressed = bool(snap.get("hold_to_walk", false))
	_shake_slider.editable = _shake_check.button_pressed and not _reduce_motion_check.button_pressed


func _build_binding_rows() -> void:
	for child in _bindings_list.get_children():
		child.queue_free()
	_rebind_buttons.clear()
	var actions: PackedStringArray = [
		"move_north", "move_east", "move_south", "move_west",
		"interact", "undo", "pause", "ghost_assist",
	]
	if _remap != null and "ACTIONS" in _remap:
		actions = _remap.ACTIONS
	for action in actions:
		if action in ["confirm", "cancel"]:
			continue
		var row := HBoxContainer.new()
		var name_l := Label.new()
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if _remap != null and _remap.has_method("action_display_name"):
			name_l.text = str(_remap.action_display_name(action))
		else:
			name_l.text = action
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
	btn.text = "Press key… (Esc cancel)"
	_status.text = "Rebinding %s" % action
	_remap.start_rebind(action)
	if not _remap.bindings_changed.is_connected(_on_bindings_changed):
		_remap.bindings_changed.connect(_on_bindings_changed)


func _on_bindings_changed() -> void:
	_refresh_binding_labels()
	_status.text = "Bindings saved."


func _on_visibility_changed() -> void:
	if visible:
		_load_from_services()


func _on_fossil_selected(index: int) -> void:
	var id := str(_fossil_option.get_item_metadata(index))
	if _a11y:
		_a11y.set_fossil_mode(FossilPalette.mode_from_string(id))
	_status.text = "Fossil palette: %s" % id


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


func _on_ghost_assist_toggled(pressed: bool) -> void:
	if _a11y:
		_a11y.set_show_ghost_path_once_enabled(pressed)


func _on_reduce_motion_toggled(pressed: bool) -> void:
	if _a11y:
		_a11y.set_reduce_motion(pressed)
	_shake_slider.editable = _shake_check.button_pressed and not pressed


func _on_hold_walk_toggled(pressed: bool) -> void:
	_store_set("accessibility", "hold_to_walk", pressed)


func _on_reset_accessibility() -> void:
	if _store != null and _store.has_method("reset_section"):
		_store.reset_section("accessibility")
	_load_from_services()
	_status.text = "Accessibility reset to defaults."


func _on_reset_bindings() -> void:
	if _remap != null and _remap.has_method("reset_to_defaults"):
		_remap.reset_to_defaults()
	_refresh_binding_labels()
	_status.text = "Input bindings reset."


func _on_close_pressed() -> void:
	close_menu()


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
