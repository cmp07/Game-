extends CanvasLayer
## Subtitle stub overlay for Echo Lattice system lines (no spoken dialogue in MVP).
## Wire narrative / rewrite / habit cues through show_line(id) or show_text().

signal line_shown(id: String, text: String)
signal line_cleared()

const STUB_LINES := {
	"rewrite_begin": "The lattice rewrites from your path.",
	"rewrite_mirror": "Your trail folds into walls.",
	"rewrite_rotate": "The corridor turns with your habits.",
	"checkpoint": "Checkpoint — buffer sealed.",
	"habit_warn_loop": "Looping path — the lattice will thicken here.",
	"habit_warn_dash": "Straight-line habit detected.",
	"key_taken": "Key resonance acquired.",
	"exit_open": "Exit unlatched.",
	"ghost_assist": "Ghost path revealed once.",
	"undo": "Step withdrawn.",
	"fail_soft": "Chamber resets. Fossils remain as warning.",
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
	var text := str(STUB_LINES.get(id, id))
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
	_panel.self_modulate = Color(1, 1, 1, 1.0 if bg else 0.0)
