extends Node
## Central accessibility facade for Echo Lattice.
## Autoload name: AccessibilityService
## Depends on SettingsStore autoload when present; falls back to in-memory defaults.

signal fossil_style_changed()
signal flash_policy_changed()
signal shake_policy_changed()
signal subtitle_policy_changed()
signal assist_policy_changed()

var _store: Node = null


func _ready() -> void:
	_store = _resolve_store()
	if _store != null and _store.has_signal("settings_changed"):
		_store.settings_changed.connect(_on_settings_changed)
	if _store != null and _store.has_signal("settings_reloaded"):
		_store.settings_reloaded.connect(_emit_all)


func fossil_mode() -> FossilPalette.Mode:
	var id := str(_get("accessibility", "fossil_palette", "default"))
	return FossilPalette.mode_from_string(id)


func set_fossil_mode(mode: FossilPalette.Mode) -> void:
	_set("accessibility", "fossil_palette", FossilPalette.mode_to_string(mode))
	fossil_style_changed.emit()


func fossil_use_patterns() -> bool:
	return bool(_get("accessibility", "fossil_use_patterns", true))


func set_fossil_use_patterns(enabled: bool) -> void:
	_set("accessibility", "fossil_use_patterns", enabled)
	fossil_style_changed.emit()


func fossil_style(role: FossilPalette.FossilRole) -> Dictionary:
	return FossilPalette.style_for(fossil_mode(), role, fossil_use_patterns())


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


func show_ghost_path_once_enabled() -> bool:
	return bool(_get("accessibility", "show_ghost_path_once", false))


func set_show_ghost_path_once_enabled(enabled: bool) -> void:
	_set("accessibility", "show_ghost_path_once", enabled)
	assist_policy_changed.emit()


func hold_to_walk() -> bool:
	return bool(_get("accessibility", "hold_to_walk", false))


func reduce_motion() -> bool:
	return bool(_get("accessibility", "reduce_motion", false))


func set_reduce_motion(enabled: bool) -> void:
	_set("accessibility", "reduce_motion", enabled)
	flash_policy_changed.emit()
	shake_policy_changed.emit()


func accessibility_snapshot() -> Dictionary:
	return {
		"fossil_palette": FossilPalette.mode_to_string(fossil_mode()),
		"fossil_use_patterns": fossil_use_patterns(),
		"reduce_flash": reduce_flash(),
		"flash_max_intensity": flash_max_intensity(),
		"screen_shake_enabled": screen_shake_enabled(),
		"screen_shake_intensity": screen_shake_intensity(),
		"subtitles_enabled": subtitles_enabled(),
		"subtitle_size": subtitle_size(),
		"subtitle_background": subtitle_background(),
		"show_ghost_path_once": show_ghost_path_once_enabled(),
		"hold_to_walk": hold_to_walk(),
		"reduce_motion": reduce_motion(),
	}


func _on_settings_changed(section: String, key: String, _value: Variant) -> void:
	if section != "accessibility":
		return
	match key:
		"fossil_palette", "fossil_use_patterns":
			fossil_style_changed.emit()
		"reduce_flash", "flash_max_intensity", "reduce_motion":
			flash_policy_changed.emit()
			if key == "reduce_motion":
				shake_policy_changed.emit()
		"screen_shake_enabled", "screen_shake_intensity":
			shake_policy_changed.emit()
		"subtitles_enabled", "subtitle_size", "subtitle_background":
			subtitle_policy_changed.emit()
		"show_ghost_path_once":
			assist_policy_changed.emit()


func _emit_all() -> void:
	fossil_style_changed.emit()
	flash_policy_changed.emit()
	shake_policy_changed.emit()
	subtitle_policy_changed.emit()
	assist_policy_changed.emit()


func _resolve_store() -> Node:
	if Engine.has_singleton("SettingsStore"):
		return Engine.get_singleton("SettingsStore") as Node
	var tree := get_tree()
	if tree != null and tree.root != null:
		var n := tree.root.get_node_or_null("SettingsStore")
		if n != null:
			return n
	# Soft dependency: peer autoload may register later.
	if has_node("/root/SettingsStore"):
		return get_node("/root/SettingsStore")
	return null


func _get(section: String, key: String, fallback: Variant) -> Variant:
	if _store != null and _store.has_method("get_value"):
		return _store.call("get_value", section, key, fallback)
	return fallback


func _set(section: String, key: String, value: Variant) -> void:
	if _store != null and _store.has_method("set_value"):
		_store.call("set_value", section, key, value, true)
