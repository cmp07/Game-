extends Node
## SceneRouter — the single source of truth for screen transitions.
##
## Screens declare intent by calling one of the public helpers below; the
## router handles the fade, pause bookkeeping, and target scene load. This
## keeps individual screens ignorant of each other and makes swapping scenes
## a one-line change.

signal transition_started(from: Node, target: String)
signal transition_finished(target: String)

const SCENE_BOOT := "res://scenes/boot/Boot.tscn"
const SCENE_MAIN_MENU := "res://scenes/menus/MainMenu.tscn"
const SCENE_GAME := "res://scenes/game/Game.tscn"
const SCENE_CREDITS := "res://scenes/menus/Credits.tscn"

const FADE_DURATION := 0.35

var _fader: ColorRect
var _transitioning: bool = false


func _ready() -> void:
	_fader = ColorRect.new()
	_fader.color = Color(0.02, 0.03, 0.05, 0.0)
	_fader.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fader.anchor_right = 1.0
	_fader.anchor_bottom = 1.0
	_fader.z_index = 4096
	_fader.process_mode = Node.PROCESS_MODE_ALWAYS
	# Add as a CanvasLayer so it's always on top of the current scene tree.
	var layer := CanvasLayer.new()
	layer.layer = 128
	layer.name = "SceneRouterOverlay"
	add_child(layer)
	layer.add_child(_fader)


func go_to_main_menu() -> void: change_scene(SCENE_MAIN_MENU)
func go_to_game() -> void: change_scene(SCENE_GAME)
func go_to_credits() -> void: change_scene(SCENE_CREDITS)


func change_scene(scene_path: String) -> void:
	if _transitioning:
		return
	_transitioning = true
	transition_started.emit(get_tree().current_scene, scene_path)
	_fader.color.a = 0.0
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_fader, "color:a", 1.0, FADE_DURATION * 0.6).set_ease(Tween.EASE_IN)
	await tw.finished
	# Ensure any lingering pause state is cleared before the next scene loads.
	get_tree().paused = false
	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_warning("Scene change failed: %s -> %s" % [err, scene_path])
	await get_tree().process_frame
	var tw2 := create_tween()
	tw2.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw2.tween_property(_fader, "color:a", 0.0, FADE_DURATION).set_ease(Tween.EASE_OUT)
	await tw2.finished
	_transitioning = false
	transition_finished.emit(scene_path)


func quit_to_desktop() -> void:
	if _transitioning:
		return
	_transitioning = true
	var tw := create_tween()
	tw.tween_property(_fader, "color:a", 1.0, FADE_DURATION).set_ease(Tween.EASE_IN)
	await tw.finished
	get_tree().quit()
