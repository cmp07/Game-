extends Node
class_name MetaUI
##
## Shared UI helpers for the meta menu. Keeps every screen's
## color/typography choices in one place so future re-skinning is
## a single-file change.
##

const BG_COLOR := Color(0.06, 0.07, 0.09)
const PANEL_COLOR := Color(0.11, 0.13, 0.17)
const PANEL_ACCENT_COLOR := Color(0.14, 0.18, 0.24)
const TEXT_COLOR := Color(0.90, 0.94, 0.98)
const MUTED_TEXT_COLOR := Color(0.55, 0.62, 0.70)
const ACCENT_COLOR := Color(0.49, 0.82, 0.99)  # #7dd3fc
const WARN_COLOR := Color(0.98, 0.65, 0.30)
const BAD_COLOR := Color(0.95, 0.42, 0.42)
const GOOD_COLOR := Color(0.52, 0.85, 0.62)

const PAD := 16
const GAP := 12


static func make_panel(color: Color = PANEL_COLOR) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	sb.content_margin_left = PAD
	sb.content_margin_right = PAD
	sb.content_margin_top = PAD
	sb.content_margin_bottom = PAD
	p.add_theme_stylebox_override("panel", sb)
	return p


static func make_label(text: String, size: int = 16, color: Color = TEXT_COLOR) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


static func make_title(text: String) -> Label:
	return make_label(text, 32, ACCENT_COLOR)


static func make_subtitle(text: String) -> Label:
	return make_label(text, 14, MUTED_TEXT_COLOR)


static func make_button(text: String, enabled: bool = true) -> Button:
	var b := Button.new()
	b.text = text
	b.disabled = not enabled
	b.custom_minimum_size = Vector2(220, 40)
	b.add_theme_font_size_override("font_size", 16)
	return b


static func format_duration(sec: float) -> String:
	if sec <= 0.0 or is_inf(sec) or is_nan(sec):
		return "--:--"
	var total := int(round(sec))
	var m := total / 60
	var s := total % 60
	if m >= 60:
		var h := m / 60
		m = m % 60
		return "%d:%02d:%02d" % [h, m, s]
	return "%d:%02d" % [m, s]


static func short_seed(seed: int) -> String:
	# Hex-ish short form so different daily seeds are visually
	# distinguishable without dumping full 64-bit ints.
	var v: int = seed & 0xffffffff
	return "%08X" % v
