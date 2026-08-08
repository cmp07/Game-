extends Node
## Accessibility singleton.
##
## Central place to apply reader-friendly overrides across the entire tree:
##   - Font scale (0.85 .. 1.5) — grows every default font on the active theme
##     without touching per-control overrides that scenes may set.
##   - UI scale — root `content_scale_factor` for global HUD growth.
##   - Reduce motion — components query this to skip parallax/shake/wobble.
##   - High contrast — swaps the active theme for a stronger palette variant.
##   - Colorblind mode / subtitle scale — surfaced as signals for now, gameplay
##     systems will consume them when they land.
##
## Everything here is safe to call before Settings finishes loading — we cache
## and lazily re-apply once the tree is ready.

signal font_scale_changed(scale: float)
signal ui_scale_changed(scale: float)
signal reduce_motion_changed(enabled: bool)
signal high_contrast_changed(enabled: bool)
signal colorblind_mode_changed(mode: int)

const NORMAL_THEME := preload("res://resources/theme/echo_lattice_theme.tres")
const HIGH_CONTRAST_THEME := preload("res://resources/theme/echo_lattice_theme_high_contrast.tres")

var _font_scale: float = 1.0
var _ui_scale: float = 1.0
var _reduce_motion: bool = false
var _high_contrast: bool = false
var _dyslexic_font: bool = false
var _colorblind_mode: int = 0
var _subtitle_scale: float = 1.0

# Snapshot of each theme's default font size so we can rescale idempotently.
var _base_default_font_size: Dictionary = {}


func _ready() -> void:
	_snapshot_theme(NORMAL_THEME)
	_snapshot_theme(HIGH_CONTRAST_THEME)
	call_deferred("_reapply_all")


func set_font_scale(scale: float) -> void:
	_font_scale = clampf(scale, 0.75, 1.75)
	_apply_font_scale()
	font_scale_changed.emit(_font_scale)


func set_ui_scale(scale: float) -> void:
	_ui_scale = clampf(scale, 0.75, 1.75)
	if is_inside_tree():
		get_tree().root.content_scale_factor = _ui_scale
	ui_scale_changed.emit(_ui_scale)


func set_reduce_motion(enabled: bool) -> void:
	_reduce_motion = enabled
	reduce_motion_changed.emit(enabled)


func set_high_contrast(enabled: bool) -> void:
	_high_contrast = enabled
	_apply_active_theme()
	high_contrast_changed.emit(enabled)


func set_dyslexic_font(_enabled: bool) -> void:
	# Stub — hook up to swap fonts once we ship a dyslexic-friendly face.
	_dyslexic_font = _enabled


func set_colorblind_mode(mode: int) -> void:
	_colorblind_mode = mode
	colorblind_mode_changed.emit(mode)


func set_subtitle_scale(scale: float) -> void:
	_subtitle_scale = clampf(scale, 0.75, 2.0)


func font_scale() -> float: return _font_scale
func ui_scale() -> float: return _ui_scale
func reduce_motion() -> bool: return _reduce_motion
func high_contrast() -> bool: return _high_contrast
func dyslexic_font() -> bool: return _dyslexic_font
func colorblind_mode() -> int: return _colorblind_mode
func subtitle_scale() -> float: return _subtitle_scale


func active_theme() -> Theme:
	return HIGH_CONTRAST_THEME if _high_contrast else NORMAL_THEME


func _reapply_all() -> void:
	if is_inside_tree():
		get_tree().root.content_scale_factor = _ui_scale
	_apply_font_scale()
	_apply_active_theme()


func _apply_font_scale() -> void:
	for theme in [NORMAL_THEME, HIGH_CONTRAST_THEME]:
		var base: int = _base_default_font_size.get(theme, 18)
		var scaled := int(round(base * _font_scale))
		theme.default_font_size = scaled
		# Rescale each type-specific font_size we know about.
		for type_name in ["Label", "Button", "OptionButton", "CheckButton", "CheckBox", "LineEdit", "RichTextLabel", "TabContainer"]:
			var key := "%s::font_size" % type_name
			if not _base_default_font_size.has(key):
				continue
			var b: int = _base_default_font_size[key]
			theme.set_font_size("font_size", type_name, int(round(b * _font_scale)))


func _apply_active_theme() -> void:
	if not is_inside_tree():
		return
	var root := get_tree().root
	root.theme = active_theme()


func _snapshot_theme(theme: Theme) -> void:
	_base_default_font_size[theme] = theme.default_font_size if theme.default_font_size > 0 else 18
	for type_name in ["Label", "Button", "OptionButton", "CheckButton", "CheckBox", "LineEdit", "RichTextLabel", "TabContainer"]:
		if theme.has_font_size("font_size", type_name):
			_base_default_font_size["%s::font_size" % type_name] = theme.get_font_size("font_size", type_name)
