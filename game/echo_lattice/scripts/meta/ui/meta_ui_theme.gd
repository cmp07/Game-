class_name MetaUiTheme
extends RefCounted
## Shared META v2 UI tokens (cold lattice, single amber accent).


const BG := Color(0.06, 0.07, 0.09, 1)
const PANEL := Color(0.10, 0.12, 0.15, 1)
const TEXT := Color(0.86, 0.88, 0.90, 1)
const MUTED := Color(0.55, 0.60, 0.64, 1)
const ACCENT := Color(0.92, 0.72, 0.28, 1)
const GOOD := Color(0.45, 0.78, 0.62, 1)
const BAD := Color(0.85, 0.40, 0.38, 1)


static func apply_root(control: Control) -> void:
	control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


static func make_label(text: String, size: int = 16, color: Color = TEXT) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


static func make_button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 40)
	return b


static func make_scroll() -> ScrollContainer:
	var s := ScrollContainer.new()
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return s


static func stars_text(n: int) -> String:
	if n <= 0:
		return "—"
	return "★".repeat(clampi(n, 1, 3))
