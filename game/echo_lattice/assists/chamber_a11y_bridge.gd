class_name ChamberA11yBridge
extends Node
## Drop into a chamber scene to wire a11y assists + fossil styling helpers.

signal fossil_styles_ready(styles: Dictionary)
signal ghost_path_painted(path: Array)

@export var chamber_id: String = "chamber_00"

var flash_gate: FlashGate
var ghost_assist: GhostPathAssist
var _a11y: Node
var _subtitles: Node


func _ready() -> void:
	_a11y = get_node_or_null("/root/AccessibilityService")
	flash_gate = FlashGate.new(_a11y)
	ghost_assist = GhostPathAssist.new(_a11y)
	ghost_assist.begin_chamber(chamber_id)
	_subtitles = get_tree().root.find_child("SubtitleOverlay", true, false)
	if _a11y != null and _a11y.has_signal("fossil_style_changed"):
		_a11y.fossil_style_changed.connect(_emit_fossil_styles)
	_emit_fossil_styles()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ghost_assist"):
		# Path is supplied by chamber solver via set_meta or sibling API.
		var path: Array = get_meta("ghost_path_cells", [])
		if ghost_assist.try_reveal(path):
			ghost_path_painted.emit(path)
			_subtitle("ghost_assist")
		get_viewport().set_input_as_handled()


func on_checkpoint_rewrite() -> void:
	flash_gate.request_rewrite_flash()
	_subtitle("rewrite_begin")


func fossil_styles() -> Dictionary:
	if _a11y == null:
		return {}
	var roles := [
		FossilPalette.FossilRole.FRESH,
		FossilPalette.FossilRole.WARM,
		FossilPalette.FossilRole.COLD,
		FossilPalette.FossilRole.GHOST,
		FossilPalette.FossilRole.OVERUSE,
		FossilPalette.FossilRole.CHECKPOINT,
	]
	var out := {}
	for role in roles:
		out[role] = _a11y.fossil_style(role)
	return out


func _emit_fossil_styles() -> void:
	fossil_styles_ready.emit(fossil_styles())


func _subtitle(id: String) -> void:
	if _subtitles != null and _subtitles.has_method("show_line"):
		_subtitles.call("show_line", id)
