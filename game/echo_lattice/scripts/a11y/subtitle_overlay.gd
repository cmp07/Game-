extends CanvasLayer
## Subtitle overlay for PA / rewrite / system lines (no spoken dialogue).
## Toggle + size come from AccessibilityService.
## Copy lives in locale/echo_lattice.csv under subtitle.<id>.

signal line_shown(id: String, text: String)
signal line_cleared()

## Stub ids → catalog keys (subtitle.<id>). Values are English fallbacks only.
const STUB_LINES := {
	"rewrite_begin": "The lattice rewrites from your path.",
	"rewrite_mirror": "Your trail folds into walls.",
	"rewrite_rotate": "The corridor turns with your habits.",
	"rewrite_thicken": "Habits solidify where you stepped.",
	"checkpoint": "Checkpoint — buffer sealed.",
	"habit_warn_loop": "Looping path — the lattice will thicken here.",
	"habit_warn_dash": "Straight-line habit detected.",
	"ghost_assist": "Ghost path revealed once.",
	"undo": "Step withdrawn.",
	"win": "Chamber clear.",
	"pa.ghost.floor": "Floor chalk noted.",
	"pa.ghost.race": "Past-self chalk on the page — optional race.",
	"pa.checkpoint.armed": "Checkpoint — buffer armed.",
	"pa.rewrite.fired": "Rewrite committed.",
	"pa.rewrite.matched": "It matches you.",
	"pa.undo.hint": "Undo clears a step.",
	"pa.boot.lattice_online": "Lattice online.",
	"pa.wing.clear": "Wing clear.",
	"tutorial_buffer": "Your last moves leave fossils behind you.",
}

@onready var _label: Label = %SubtitleLabel
@onready var _panel: PanelContainer = %SubtitlePanel

var _a11y: Node = null
var _hide_timer: Timer


func _ready() -> void:
	layer = 100
	_a11y = get_node_or_null("/root/AccessibilityService")
	_hide_timer = Timer.new()
	_hide_timer.one_shot = true
	add_child(_hide_timer)
	_hide_timer.timeout.connect(clear)
	if _a11y != null and _a11y.has_signal("subtitle_policy_changed"):
		_a11y.subtitle_policy_changed.connect(_apply_style)
	_apply_style()
	clear()


func show_line(id: String, duration: float = 2.4) -> void:
	var key := "subtitle.%s" % id
	var translated := tr(key)
	var text := translated if translated != key else str(STUB_LINES.get(id, id))
	show_text(text, duration, id)


func show_text(text: String, duration: float = 2.4, id: String = "") -> void:
	if not _enabled():
		return
	_apply_style()
	_label.text = text
	_panel.visible = true
	line_shown.emit(id, text)
	_hide_timer.start(duration)


func clear() -> void:
	_panel.visible = false
	_label.text = ""
	line_cleared.emit()


func stub_catalog() -> Dictionary:
	return STUB_LINES.duplicate()


func _enabled() -> bool:
	if _a11y != null and _a11y.has_method("subtitles_enabled"):
		return bool(_a11y.call("subtitles_enabled"))
	return true


func _apply_style() -> void:
	if _label == null or _panel == null:
		return
	var size_id := "medium"
	var bg := true
	if _a11y != null:
		if _a11y.has_method("subtitle_size"):
			size_id = str(_a11y.call("subtitle_size"))
		if _a11y.has_method("subtitle_background"):
			bg = bool(_a11y.call("subtitle_background"))
	var font_size := 18
	match size_id:
		"small":
			font_size = 14
		"large":
			font_size = 26
		_:
			font_size = 18
	_label.add_theme_font_size_override("font_size", font_size)
	_label.add_theme_color_override("font_color", Color("#EFE6D2"))
	_panel.self_modulate = Color(1, 1, 1, 1.0 if bg else 0.0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.078, 0.071, 0.063, 0.82 if bg else 0.0)
	style.set_corner_radius_all(2)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	_panel.add_theme_stylebox_override("panel", style)
