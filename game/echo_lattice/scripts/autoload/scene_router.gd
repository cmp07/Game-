extends Node
##
## SceneRouter
##
## Centralised scene transitions. Gameplay code asks SceneRouter to go to a
## chamber; SceneRouter handles fade-out, `change_scene_to_file`, and fade-in
## against a full-screen ColorRect it owns.
##
## Keeping this out of Main.tscn means the router survives scene changes
## (it's an autoload) and its overlay stays on top of whatever scene loads.
##

@export var fade_seconds: float = 0.35
@export var fade_color: Color = Color(0, 0, 0, 1)

const CHAMBER_SCENES: Dictionary = {
	&"chamber_prime": "res://scenes/chamber/chamber.tscn",
}

var _overlay_layer: CanvasLayer
var _overlay_rect: ColorRect
var _busy: bool = false


func _ready() -> void:
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.layer = 128
	add_child(_overlay_layer)
	_overlay_rect = ColorRect.new()
	_overlay_rect.color = fade_color
	_overlay_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay_rect.anchor_right = 1.0
	_overlay_rect.anchor_bottom = 1.0
	_overlay_rect.modulate.a = 0.0
	_overlay_layer.add_child(_overlay_rect)


func go_to_chamber(chamber_id: StringName) -> void:
	if _busy:
		return
	if not CHAMBER_SCENES.has(chamber_id):
		push_warning("SceneRouter: unknown chamber id %s" % chamber_id)
		return
	_busy = true
	var from_id: StringName = GameState.current_chamber_id
	EventBus.lattice_shifted.emit(from_id, chamber_id)
	await _fade(1.0)
	var err := get_tree().change_scene_to_file(CHAMBER_SCENES[chamber_id])
	if err != OK:
		push_error("SceneRouter: failed to load %s (err=%d)" % [chamber_id, err])
	await _fade(0.0)
	_busy = false


func go_to_scene(path: String) -> void:
	if _busy:
		return
	_busy = true
	await _fade(1.0)
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("SceneRouter: failed to load %s (err=%d)" % [path, err])
	await _fade(0.0)
	_busy = false


func _fade(target_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(_overlay_rect, "modulate:a", target_alpha, fade_seconds)
	await tween.finished
