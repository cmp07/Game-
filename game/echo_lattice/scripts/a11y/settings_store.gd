extends Node
## Persists Echo Lattice player settings (accessibility, audio, input).
## Autoload name: SettingsStore

signal settings_changed(section: String, key: String, value: Variant)
signal settings_reloaded()

const SETTINGS_PATH := "user://echo_lattice_settings.json"
const DEFAULTS_RES := "res://config/default_settings.json"

var _data: Dictionary = {}
var _defaults: Dictionary = {}


func _ready() -> void:
	_defaults = _load_json_file(DEFAULTS_RES)
	if _defaults.is_empty():
		_defaults = _builtin_defaults()
	load_settings()


func get_value(section: String, key: String, fallback: Variant = null) -> Variant:
	if _data.has(section) and (_data[section] as Dictionary).has(key):
		return (_data[section] as Dictionary)[key]
	if _defaults.has(section) and (_defaults[section] as Dictionary).has(key):
		return (_defaults[section] as Dictionary)[key]
	return fallback


func set_value(section: String, key: String, value: Variant, save_now: bool = true) -> void:
	if not _data.has(section):
		_data[section] = {}
	(_data[section] as Dictionary)[key] = value
	settings_changed.emit(section, key, value)
	if save_now:
		save_settings()


func get_section(section: String) -> Dictionary:
	var out: Dictionary = {}
	if _defaults.has(section):
		out = (_defaults[section] as Dictionary).duplicate(true)
	if _data.has(section):
		out.merge(_data[section] as Dictionary, true)
	return out


func reset_section(section: String) -> void:
	if _defaults.has(section):
		_data[section] = (_defaults[section] as Dictionary).duplicate(true)
	elif _data.has(section):
		_data.erase(section)
	settings_reloaded.emit()
	save_settings()


func reset_all() -> void:
	_data = _defaults.duplicate(true)
	settings_reloaded.emit()
	save_settings()


func load_settings() -> void:
	var loaded := _load_json_file(SETTINGS_PATH)
	if loaded.is_empty():
		_data = _defaults.duplicate(true)
	else:
		_data = _defaults.duplicate(true)
		_deep_merge(_data, loaded)
		_migrate_v1_to_v2()
	settings_reloaded.emit()


func save_settings() -> bool:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("SettingsStore: cannot write %s" % SETTINGS_PATH)
		return false
	file.store_string(JSON.stringify(_data, "\t"))
	return true


func export_dict() -> Dictionary:
	return _data.duplicate(true)


func _migrate_v1_to_v2() -> void:
	## Prior a11y package used fossil_palette + move_north naming.
	var a11y: Dictionary = _data.get("accessibility", {}) as Dictionary
	if a11y.has("fossil_palette") and not a11y.has("colorblind_mode"):
		a11y["colorblind_mode"] = a11y["fossil_palette"]
	if not a11y.has("ui_scale"):
		a11y["ui_scale"] = 1.0
	_data["accessibility"] = a11y
	var binds: Dictionary = _data.get("input_bindings", {}) as Dictionary
	var aliases := {
		"move_north": "move_up",
		"move_south": "move_down",
		"move_west": "move_left",
		"move_east": "move_right",
		"pause": "pause_menu",
	}
	for old_k in aliases.keys():
		if binds.has(old_k) and not binds.has(aliases[old_k]):
			binds[aliases[old_k]] = binds[old_k]
	_data["input_bindings"] = binds
	_data["version"] = 2


func _load_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


func _deep_merge(dst: Dictionary, src: Dictionary) -> void:
	for key in src.keys():
		if src[key] is Dictionary and dst.has(key) and dst[key] is Dictionary:
			_deep_merge(dst[key], src[key])
		else:
			dst[key] = src[key]


func _builtin_defaults() -> Dictionary:
	return {
		"version": 2,
		"accessibility": {
			"colorblind_mode": "default",
			"fossil_use_patterns": true,
			"reduce_flash": false,
			"flash_max_intensity": 1.0,
			"screen_shake_enabled": false,
			"screen_shake_intensity": 0.35,
			"subtitles_enabled": true,
			"subtitle_size": "medium",
			"subtitle_background": true,
			"ui_scale": 1.0,
			"show_ghost_path_once": false,
			"hold_to_walk": false,
			"reduce_motion": false,
		},
		"audio": {
			"master_volume": 1.0,
			"sfx_volume": 1.0,
			"music_volume": 0.8,
			"pa_volume": 1.0,
		},
		"input_bindings": {
			"move_up": ["W", "Up"],
			"move_down": ["S", "Down"],
			"move_left": ["A", "Left"],
			"move_right": ["D", "Right"],
			"undo": ["Z"],
			"restart": ["R"],
			"pause_menu": ["Escape"],
			"confirm": ["Enter", "Space"],
			"ghost_assist": ["G"],
		},
	}
