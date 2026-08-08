extends Window
## Settings dialog. Uses a Window subresource so it can pop over any screen
## (main menu, pause menu, win/lose) without needing its own scene stack.

@onready var _tabs: TabContainer = %Tabs

# Video
@onready var _window_mode: OptionButton = %WindowMode
@onready var _resolution: OptionButton = %Resolution
@onready var _vsync: OptionButton = %Vsync
@onready var _max_fps: OptionButton = %MaxFps
@onready var _ui_scale: HSlider = %UiScale
@onready var _ui_scale_value: Label = %UiScaleValue
@onready var _reduce_motion: CheckButton = %ReduceMotion
@onready var _screen_shake: CheckButton = %ScreenShake
@onready var _high_contrast: CheckButton = %HighContrast

# Audio
@onready var _master: HSlider = %Master
@onready var _master_val: Label = %MasterValue
@onready var _music: HSlider = %Music
@onready var _music_val: Label = %MusicValue
@onready var _sfx: HSlider = %Sfx
@onready var _sfx_val: Label = %SfxValue
@onready var _ui_bus: HSlider = %UiBus
@onready var _ui_bus_val: Label = %UiBusValue
@onready var _mute: CheckButton = %Mute

# Accessibility
@onready var _font_scale: HSlider = %FontScale
@onready var _font_scale_val: Label = %FontScaleValue
@onready var _colorblind: OptionButton = %Colorblind
@onready var _dyslexic: CheckButton = %Dyslexic
@onready var _subtitle_size: HSlider = %SubtitleSize
@onready var _subtitle_val: Label = %SubtitleValue

# Keybinds
@onready var _keybinds_list: VBoxContainer = %KeybindsList
const KeybindRowScene := preload("res://ui/KeybindRow.tscn")

@onready var _reset_btn: Button = %ResetBtn
@onready var _close_btn: Button = %CloseBtn


func _ready() -> void:
	# Populate option lists.
	_window_mode.clear()
	_window_mode.add_item("Windowed", 0)
	_window_mode.add_item("Borderless Fullscreen", 1)
	_window_mode.add_item("Exclusive Fullscreen", 2)

	_resolution.clear()
	for i in Settings.RESOLUTIONS.size():
		var r: Vector2i = Settings.RESOLUTIONS[i]
		_resolution.add_item("%d × %d" % [r.x, r.y], i)

	_vsync.clear()
	_vsync.add_item("Off", 0)
	_vsync.add_item("On", 1)
	_vsync.add_item("Adaptive", 2)

	_max_fps.clear()
	for label in [["Unlimited", 0], ["30", 30], ["60", 60], ["90", 90], ["120", 120], ["144", 144], ["240", 240]]:
		_max_fps.add_item(label[0], int(label[1]))

	_colorblind.clear()
	_colorblind.add_item("Off", 0)
	_colorblind.add_item("Deuteranopia", 1)
	_colorblind.add_item("Protanopia", 2)
	_colorblind.add_item("Tritanopia", 3)

	_hydrate_from_settings()

	# Wire signals.
	_window_mode.item_selected.connect(func(i): Settings.set_value("video", "window_mode", int(_window_mode.get_item_id(i))))
	_resolution.item_selected.connect(func(i): Settings.set_value("video", "resolution_index", int(_resolution.get_item_id(i))))
	_vsync.item_selected.connect(func(i): Settings.set_value("video", "vsync", int(_vsync.get_item_id(i))))
	_max_fps.item_selected.connect(func(i): Settings.set_value("video", "max_fps", int(_max_fps.get_item_id(i))))

	_ui_scale.value_changed.connect(func(v):
		Settings.set_value("video", "ui_scale", v)
		_ui_scale_value.text = "%d%%" % int(round(v * 100.0))
	)
	_reduce_motion.toggled.connect(func(v): Settings.set_value("video", "reduce_motion", v))
	_screen_shake.toggled.connect(func(v): Settings.set_value("video", "screen_shake", v))
	_high_contrast.toggled.connect(func(v): Settings.set_value("video", "high_contrast", v))

	_master.value_changed.connect(func(v):
		Settings.set_value("audio", "master", v); _master_val.text = _pct(v))
	_music.value_changed.connect(func(v):
		Settings.set_value("audio", "music", v); _music_val.text = _pct(v))
	_sfx.value_changed.connect(func(v):
		Settings.set_value("audio", "sfx", v); _sfx_val.text = _pct(v))
	_ui_bus.value_changed.connect(func(v):
		Settings.set_value("audio", "ui", v); _ui_bus_val.text = _pct(v))
	_mute.toggled.connect(func(v): Settings.set_value("audio", "mute", v))

	_font_scale.value_changed.connect(func(v):
		Settings.set_value("accessibility", "font_scale", v)
		_font_scale_val.text = "%d%%" % int(round(v * 100.0))
	)
	_colorblind.item_selected.connect(func(i): Settings.set_value("accessibility", "colorblind_mode", int(_colorblind.get_item_id(i))))
	_dyslexic.toggled.connect(func(v): Settings.set_value("accessibility", "dyslexic_font", v))
	_subtitle_size.value_changed.connect(func(v):
		Settings.set_value("accessibility", "subtitle_size", v)
		_subtitle_val.text = "%d%%" % int(round(v * 100.0))
	)

	_populate_keybinds()

	_reset_btn.pressed.connect(_on_reset)
	_close_btn.pressed.connect(_on_close)

	close_requested.connect(_on_close)
	# Focus the first control after popup.
	call_deferred("_focus_first")


func _pct(v: float) -> String:
	return "%d%%" % int(round(v * 100.0))


func _hydrate_from_settings() -> void:
	_select_by_id(_window_mode, int(Settings.get_value("video", "window_mode")))
	_select_by_id(_resolution, int(Settings.get_value("video", "resolution_index")))
	_select_by_id(_vsync, int(Settings.get_value("video", "vsync")))
	_select_by_id(_max_fps, int(Settings.get_value("video", "max_fps")))
	_ui_scale.value = float(Settings.get_value("video", "ui_scale"))
	_ui_scale_value.text = _pct(_ui_scale.value)
	_reduce_motion.button_pressed = bool(Settings.get_value("video", "reduce_motion"))
	_screen_shake.button_pressed = bool(Settings.get_value("video", "screen_shake"))
	_high_contrast.button_pressed = bool(Settings.get_value("video", "high_contrast"))

	_master.value = float(Settings.get_value("audio", "master")); _master_val.text = _pct(_master.value)
	_music.value = float(Settings.get_value("audio", "music")); _music_val.text = _pct(_music.value)
	_sfx.value = float(Settings.get_value("audio", "sfx")); _sfx_val.text = _pct(_sfx.value)
	_ui_bus.value = float(Settings.get_value("audio", "ui")); _ui_bus_val.text = _pct(_ui_bus.value)
	_mute.button_pressed = bool(Settings.get_value("audio", "mute"))

	_font_scale.value = float(Settings.get_value("accessibility", "font_scale"))
	_font_scale_val.text = _pct(_font_scale.value)
	_select_by_id(_colorblind, int(Settings.get_value("accessibility", "colorblind_mode")))
	_dyslexic.button_pressed = bool(Settings.get_value("accessibility", "dyslexic_font"))
	_subtitle_size.value = float(Settings.get_value("accessibility", "subtitle_size"))
	_subtitle_val.text = _pct(_subtitle_size.value)


func _select_by_id(opt: OptionButton, id: int) -> void:
	for i in range(opt.item_count):
		if opt.get_item_id(i) == id:
			opt.select(i)
			return
	if opt.item_count > 0:
		opt.select(0)


func _populate_keybinds() -> void:
	for child in _keybinds_list.get_children():
		child.queue_free()
	for action in Settings.REBINDABLE_ACTIONS:
		var row: HBoxContainer = KeybindRowScene.instantiate()
		_keybinds_list.add_child(row)
		row.setup(action)


func _on_reset() -> void:
	Settings.reset_to_defaults()
	_hydrate_from_settings()
	_populate_keybinds()


func _on_close() -> void:
	Settings.save()
	Audio.play("cancel")
	queue_free()


func _focus_first() -> void:
	_window_mode.grab_focus()
