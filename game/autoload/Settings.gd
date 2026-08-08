extends Node
## Global settings service.
##
## Owns video, audio, and keybind values, persists them to `user://settings.cfg`,
## broadcasts changes so live UI can react without a restart, and delegates
## font/UI scaling to the Accessibility singleton.
##
## Everything here is intentionally engine-agnostic — no scene tree assumptions,
## so autoloads that come later (or dialogs opened before Ready) can still call
## into it safely.

signal settings_changed(section: String, key: String, value: Variant)
signal keybinds_changed

const CONFIG_PATH := "user://settings.cfg"

const DEFAULTS := {
	"video": {
		"window_mode": 0, # 0 = Windowed, 1 = Borderless Fullscreen, 2 = Exclusive Fullscreen
		"vsync": 1, # 0 = Off, 1 = On, 2 = Adaptive
		"max_fps": 0, # 0 = Unlimited
		"resolution_index": 3, # index into RESOLUTIONS
		"ui_scale": 1.0,
		"reduce_motion": false,
		"screen_shake": true,
		"high_contrast": false,
	},
	"audio": {
		"master": 0.9,
		"music": 0.8,
		"sfx": 0.9,
		"ui": 0.9,
		"mute": false,
	},
	"gameplay": {
		"telegraph_hold": true, # hold vs tap to confirm rewrites
		"tutorial_prompts": true,
		"language": "en",
	},
	"accessibility": {
		"font_scale": 1.0, # 0.85 .. 1.5
		"dyslexic_font": false,
		"colorblind_mode": 0, # 0 = Off, 1 = Deuteranopia, 2 = Protanopia, 3 = Tritanopia
		"subtitle_size": 1.0,
	},
	"keybinds": {},
}

const RESOLUTIONS := [
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3840, 2160),
]

const REBINDABLE_ACTIONS := [
	"ui_accept",
	"ui_cancel",
	"ui_up",
	"ui_down",
	"ui_left",
	"ui_right",
	"ui_pause",
	"game_rewrite",
	"game_hold",
	"game_reset",
]

var _data: Dictionary = {}
var _loaded := false


func _ready() -> void:
	_data = _deep_dup(DEFAULTS)
	_load_from_disk()
	_apply_all()
	_loaded = true


func get_value(section: String, key: String) -> Variant:
	if not _data.has(section):
		return null
	return _data[section].get(key, DEFAULTS.get(section, {}).get(key, null))


func set_value(section: String, key: String, value: Variant, persist := true) -> void:
	if not _data.has(section):
		_data[section] = {}
	_data[section][key] = value
	_apply_one(section, key, value)
	settings_changed.emit(section, key, value)
	if persist and _loaded:
		save()


func reset_to_defaults() -> void:
	_data = _deep_dup(DEFAULTS)
	_apply_all()
	save()
	settings_changed.emit("*", "*", null)


func save() -> void:
	var cfg := ConfigFile.new()
	for section in _data.keys():
		var block: Dictionary = _data[section]
		for key in block.keys():
			cfg.set_value(section, key, block[key])
	# Serialize keybinds separately as InputEvent arrays.
	for action in REBINDABLE_ACTIONS:
		var evs := InputMap.action_get_events(action)
		var packed: Array = []
		for e in evs:
			packed.append(_event_to_dict(e))
		cfg.set_value("keybinds", action, packed)
	var err := cfg.save(CONFIG_PATH)
	if err != OK:
		push_warning("Settings save failed: %s" % err)


func rebind_action(action: String, event: InputEvent) -> void:
	if not action in REBINDABLE_ACTIONS:
		return
	# Replace the primary keyboard/mouse binding while preserving controller ones,
	# and vice versa. Keeps gamepad+keyboard parallel.
	var kept: Array[InputEvent] = []
	for existing in InputMap.action_get_events(action):
		if _same_family(existing, event):
			continue
		kept.append(existing)
	kept.append(event)
	InputMap.action_erase_events(action)
	for e in kept:
		InputMap.action_add_event(action, e)
	keybinds_changed.emit()
	save()


func clear_action_binding(action: String, family: String) -> void:
	if not action in REBINDABLE_ACTIONS:
		return
	var kept: Array[InputEvent] = []
	for existing in InputMap.action_get_events(action):
		if _event_family(existing) != family:
			kept.append(existing)
	InputMap.action_erase_events(action)
	for e in kept:
		InputMap.action_add_event(action, e)
	keybinds_changed.emit()
	save()


func first_event_for(action: String, family := "") -> InputEvent:
	for e in InputMap.action_get_events(action):
		if family == "" or _event_family(e) == family:
			return e
	return null


static func humanize_event(event: InputEvent) -> String:
	if event == null:
		return "[unbound]"
	if event is InputEventKey:
		var k := event as InputEventKey
		var code := k.physical_keycode if k.physical_keycode != 0 else k.keycode
		return OS.get_keycode_string(code)
	if event is InputEventJoypadButton:
		return "Pad %d" % (event as InputEventJoypadButton).button_index
	if event is InputEventJoypadMotion:
		return "Axis %d" % (event as InputEventJoypadMotion).axis
	if event is InputEventMouseButton:
		return "Mouse %d" % (event as InputEventMouseButton).button_index
	return event.as_text()


func _apply_all() -> void:
	for section in _data.keys():
		var block: Dictionary = _data[section]
		for key in block.keys():
			_apply_one(section, key, block[key])
	_apply_keybinds_from_data()


func _apply_one(section: String, key: String, value: Variant) -> void:
	match section:
		"video":
			match key:
				"window_mode":
					var mode := int(value)
					match mode:
						0:
							DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
							DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
						1:
							DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
							DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
						2:
							DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
				"vsync":
					DisplayServer.window_set_vsync_mode(int(value))
				"max_fps":
					Engine.max_fps = int(value)
				"resolution_index":
					var idx := clampi(int(value), 0, RESOLUTIONS.size() - 1)
					if int(get_value("video", "window_mode")) == 0:
						DisplayServer.window_set_size(RESOLUTIONS[idx])
						_center_window()
				"ui_scale":
					Accessibility.set_ui_scale(float(value))
				"reduce_motion":
					Accessibility.set_reduce_motion(bool(value))
				"high_contrast":
					Accessibility.set_high_contrast(bool(value))
		"audio":
			_apply_audio(key, value)
		"accessibility":
			match key:
				"font_scale":
					Accessibility.set_font_scale(float(value))
				"dyslexic_font":
					Accessibility.set_dyslexic_font(bool(value))
				"colorblind_mode":
					Accessibility.set_colorblind_mode(int(value))
				"subtitle_size":
					Accessibility.set_subtitle_scale(float(value))
		_:
			pass


func _apply_audio(key: String, value: Variant) -> void:
	var bus_name := ""
	match key:
		"master": bus_name = "Master"
		"music": bus_name = "Music"
		"sfx": bus_name = "SFX"
		"ui": bus_name = "UI"
		"mute":
			var muted := bool(value)
			for b in ["Master", "Music", "SFX", "UI"]:
				var i := AudioServer.get_bus_index(b)
				if i != -1:
					AudioServer.set_bus_mute(i, muted)
			return
		_:
			return
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	var v := clampf(float(value), 0.0, 1.0)
	AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(v, 0.0001)))
	AudioServer.set_bus_mute(idx, v <= 0.001)


func _apply_keybinds_from_data() -> void:
	var kb: Dictionary = _data.get("keybinds", {})
	for action in kb.keys():
		if not action in REBINDABLE_ACTIONS:
			continue
		var packed: Array = kb[action]
		if packed.is_empty():
			continue
		var events: Array[InputEvent] = []
		for entry in packed:
			var e := _dict_to_event(entry)
			if e != null:
				events.append(e)
		if events.is_empty():
			continue
		InputMap.action_erase_events(action)
		for e in events:
			InputMap.action_add_event(action, e)
	keybinds_changed.emit()


func _load_from_disk() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(CONFIG_PATH)
	if err != OK:
		return
	for section in cfg.get_sections():
		if not _data.has(section) and section != "keybinds":
			continue
		if section == "keybinds":
			_data["keybinds"] = {}
			for key in cfg.get_section_keys(section):
				_data["keybinds"][key] = cfg.get_value(section, key)
			continue
		for key in cfg.get_section_keys(section):
			_data[section][key] = cfg.get_value(section, key)


func _center_window() -> void:
	var screen := DisplayServer.window_get_current_screen()
	var size := DisplayServer.window_get_size()
	var usable := DisplayServer.screen_get_usable_rect(screen)
	var origin := usable.position + (usable.size - size) / 2
	DisplayServer.window_set_position(origin)


func _same_family(a: InputEvent, b: InputEvent) -> bool:
	return _event_family(a) == _event_family(b)


func _event_family(e: InputEvent) -> String:
	if e is InputEventKey or e is InputEventMouseButton:
		return "kbm"
	if e is InputEventJoypadButton or e is InputEventJoypadMotion:
		return "pad"
	return "other"


func _event_to_dict(e: InputEvent) -> Dictionary:
	if e is InputEventKey:
		var k := e as InputEventKey
		return {
			"type": "key",
			"physical_keycode": k.physical_keycode,
			"keycode": k.keycode,
			"shift": k.shift_pressed,
			"ctrl": k.ctrl_pressed,
			"alt": k.alt_pressed,
			"meta": k.meta_pressed,
		}
	if e is InputEventJoypadButton:
		return {
			"type": "pad_button",
			"button": (e as InputEventJoypadButton).button_index,
		}
	if e is InputEventJoypadMotion:
		return {
			"type": "pad_axis",
			"axis": (e as InputEventJoypadMotion).axis,
			"value": (e as InputEventJoypadMotion).axis_value,
		}
	if e is InputEventMouseButton:
		return {
			"type": "mouse",
			"button": (e as InputEventMouseButton).button_index,
		}
	return {}


func _dict_to_event(d: Dictionary) -> InputEvent:
	match d.get("type", ""):
		"key":
			var k := InputEventKey.new()
			k.physical_keycode = int(d.get("physical_keycode", 0))
			k.keycode = int(d.get("keycode", 0))
			k.shift_pressed = bool(d.get("shift", false))
			k.ctrl_pressed = bool(d.get("ctrl", false))
			k.alt_pressed = bool(d.get("alt", false))
			k.meta_pressed = bool(d.get("meta", false))
			return k
		"pad_button":
			var pb := InputEventJoypadButton.new()
			pb.button_index = int(d.get("button", 0))
			return pb
		"pad_axis":
			var pa := InputEventJoypadMotion.new()
			pa.axis = int(d.get("axis", 0))
			pa.axis_value = float(d.get("value", 1.0))
			return pa
		"mouse":
			var mb := InputEventMouseButton.new()
			mb.button_index = int(d.get("button", 0))
			return mb
	return null


static func _deep_dup(d: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for k in d.keys():
		var v: Variant = d[k]
		if v is Dictionary:
			out[k] = _deep_dup(v)
		elif v is Array:
			out[k] = (v as Array).duplicate(true)
		else:
			out[k] = v
	return out
