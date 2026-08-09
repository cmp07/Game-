extends Node
## Central accessibility facade for Echo Lattice.
## Autoload name: AccessibilityService
## Depends on SettingsStore; applies UI scale to the root window.

signal colorblind_changed()
signal flash_policy_changed()
signal shake_policy_changed()
signal subtitle_policy_changed()
signal assist_policy_changed()
signal ui_scale_changed(scale: float)

## Alias kept for older callers / docs.
signal fossil_style_changed()

var _store: Node = null


func _ready() -> void:
	_store = _resolve_store()
	if _store != null and _store.has_signal("settings_changed"):
		_store.settings_changed.connect(_on_settings_changed)
	if _store != null and _store.has_signal("settings_reloaded"):
		_store.settings_reloaded.connect(_emit_all)
	call_deferred("apply_ui_scale")


func colorblind_mode() -> FossilPalette.Mode:
	var id := str(_get("accessibility", "colorblind_mode", "default"))
	# v1 key fallback
	if id == "default" and str(_get("accessibility", "fossil_palette", "")) != "":
		var legacy := str(_get("accessibility", "fossil_palette", "default"))
		if legacy != "default":
			id = legacy
	return FossilPalette.mode_from_string(id)


func set_colorblind_mode(mode: FossilPalette.Mode) -> void:
	_set("accessibility", "colorblind_mode", FossilPalette.mode_to_string(mode))
	colorblind_changed.emit()
	fossil_style_changed.emit()


## Back-compat aliases used by earlier a11y package.
func fossil_mode() -> FossilPalette.Mode:
	return colorblind_mode()


func set_fossil_mode(mode: FossilPalette.Mode) -> void:
	set_colorblind_mode(mode)


func fossil_use_patterns() -> bool:
	return bool(_get("accessibility", "fossil_use_patterns", true))


func set_fossil_use_patterns(enabled: bool) -> void:
	_set("accessibility", "fossil_use_patterns", enabled)
	colorblind_changed.emit()
	fossil_style_changed.emit()


func fossil_style(role: FossilPalette.FossilRole) -> Dictionary:
	return FossilPalette.style_for(colorblind_mode(), role, fossil_use_patterns())


func role_color(role: FossilPalette.FossilRole) -> Color:
	return FossilPalette.color_for(colorblind_mode(), role)


func reduce_flash() -> bool:
	return bool(_get("accessibility", "reduce_flash", false))


func set_reduce_flash(enabled: bool) -> void:
	_set("accessibility", "reduce_flash", enabled)
	flash_policy_changed.emit()


func flash_max_intensity() -> float:
	if reduce_flash():
		return minf(float(_get("accessibility", "flash_max_intensity", 1.0)), 0.25)
	return clampf(float(_get("accessibility", "flash_max_intensity", 1.0)), 0.0, 1.0)


func set_flash_max_intensity(value: float) -> void:
	_set("accessibility", "flash_max_intensity", clampf(value, 0.0, 1.0))
	flash_policy_changed.emit()


func screen_shake_enabled() -> bool:
	if reduce_motion():
		return false
	return bool(_get("accessibility", "screen_shake_enabled", true))


func set_screen_shake_enabled(enabled: bool) -> void:
	_set("accessibility", "screen_shake_enabled", enabled)
	shake_policy_changed.emit()


func screen_shake_intensity() -> float:
	if not screen_shake_enabled():
		return 0.0
	return clampf(float(_get("accessibility", "screen_shake_intensity", 1.0)), 0.0, 1.0)


func set_screen_shake_intensity(value: float) -> void:
	_set("accessibility", "screen_shake_intensity", clampf(value, 0.0, 1.0))
	shake_policy_changed.emit()


func subtitles_enabled() -> bool:
	return bool(_get("accessibility", "subtitles_enabled", true))


func set_subtitles_enabled(enabled: bool) -> void:
	_set("accessibility", "subtitles_enabled", enabled)
	subtitle_policy_changed.emit()


func subtitle_size() -> String:
	return str(_get("accessibility", "subtitle_size", "medium"))


func set_subtitle_size(size_id: String) -> void:
	_set("accessibility", "subtitle_size", size_id)
	subtitle_policy_changed.emit()


func subtitle_background() -> bool:
	return bool(_get("accessibility", "subtitle_background", true))


func ui_scale() -> float:
	return clampf(float(_get("accessibility", "ui_scale", 1.0)), 0.85, 1.5)


func set_ui_scale(value: float) -> void:
	var s := clampf(value, 0.85, 1.5)
	_set("accessibility", "ui_scale", s)
	apply_ui_scale()
	ui_scale_changed.emit(s)


func apply_ui_scale() -> void:
	var s := ui_scale()
	# content_scale_factor keeps layout readable on Steam Deck / 1080p / 4K.
	if DisplayServer.get_name() == "headless":
		return
	get_tree().root.content_scale_factor = s


func show_ghost_path_once_enabled() -> bool:
	return bool(_get("accessibility", "show_ghost_path_once", false))


func set_show_ghost_path_once_enabled(enabled: bool) -> void:
	_set("accessibility", "show_ghost_path_once", enabled)
	assist_policy_changed.emit()


func hold_to_walk() -> bool:
	return bool(_get("accessibility", "hold_to_walk", false))


func set_hold_to_walk(enabled: bool) -> void:
	_set("accessibility", "hold_to_walk", enabled)
	assist_policy_changed.emit()


func reduce_motion() -> bool:
	return bool(_get("accessibility", "reduce_motion", false))


func set_reduce_motion(enabled: bool) -> void:
	_set("accessibility", "reduce_motion", enabled)
	flash_policy_changed.emit()
	shake_policy_changed.emit()


func accessibility_snapshot() -> Dictionary:
	return {
		"colorblind_mode": FossilPalette.mode_to_string(colorblind_mode()),
		"fossil_palette": FossilPalette.mode_to_string(colorblind_mode()),
		"fossil_use_patterns": fossil_use_patterns(),
		"reduce_flash": reduce_flash(),
		"flash_max_intensity": flash_max_intensity(),
		"screen_shake_enabled": screen_shake_enabled(),
		"screen_shake_intensity": screen_shake_intensity(),
		"subtitles_enabled": subtitles_enabled(),
		"subtitle_size": subtitle_size(),
		"subtitle_background": subtitle_background(),
		"ui_scale": ui_scale(),
		"show_ghost_path_once": show_ghost_path_once_enabled(),
		"hold_to_walk": hold_to_walk(),
		"reduce_motion": reduce_motion(),
	}


func _on_settings_changed(section: String, key: String, _value: Variant) -> void:
	if section != "accessibility":
		return
	match key:
		"colorblind_mode", "fossil_palette", "fossil_use_patterns":
			colorblind_changed.emit()
			fossil_style_changed.emit()
		"reduce_flash", "flash_max_intensity", "reduce_motion":
			flash_policy_changed.emit()
			if key == "reduce_motion":
				shake_policy_changed.emit()
		"screen_shake_enabled", "screen_shake_intensity":
			shake_policy_changed.emit()
		"subtitles_enabled", "subtitle_size", "subtitle_background":
			subtitle_policy_changed.emit()
		"ui_scale":
			apply_ui_scale()
			ui_scale_changed.emit(ui_scale())
		"show_ghost_path_once", "hold_to_walk":
			assist_policy_changed.emit()


func _emit_all() -> void:
	colorblind_changed.emit()
	fossil_style_changed.emit()
	flash_policy_changed.emit()
	shake_policy_changed.emit()
	subtitle_policy_changed.emit()
	assist_policy_changed.emit()
	apply_ui_scale()
	ui_scale_changed.emit(ui_scale())


func _resolve_store() -> Node:
	if has_node("/root/SettingsStore"):
		return get_node("/root/SettingsStore")
	var tree := get_tree()
	if tree != null and tree.root != null:
		return tree.root.get_node_or_null("SettingsStore")
	return null


func _get(section: String, key: String, fallback: Variant) -> Variant:
	if _store != null and _store.has_method("get_value"):
		return _store.call("get_value", section, key, fallback)
	return fallback


func _set(section: String, key: String, value: Variant) -> void:
	if _store != null and _store.has_method("set_value"):
		_store.call("set_value", section, key, value, true)
