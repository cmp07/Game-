extends Node2D
##
## Playable first minutes — boot into VOID (no East Post Gap shed, no Yard Folio).
## One drifting spark. Player moves. Type a word → the void answers.
## Camera COVER-fills the window.
##

signal menu_requested
signal world_changed(word: String)

const FIELD_SIZE := Vector2(1280, 720)
const FIELD_CENTER := Vector2(640, 360)
const FILL_OVERSCAN := 1.04

const SPARK_WANDER := 38.0
const SPARK_SPEED := 22.0

@onready var _player: CharacterBody2D = %Player
@onready var _camera: Camera2D = $Camera2D
@onready var _spark: Node2D = %Spark
@onready var _prompt: Label = %Prompt
@onready var _word_edit: LineEdit = %WordEdit
@onready var _begin_layer: CanvasLayer = %BeginGate
@onready var _begin_button: Button = %BeginButton
@onready var _void_art: Node2D = %VoidArt
@onready var _named_mark: Label = %NamedMark

var _t: float = 0.0
var _spark_origin: Vector2 = Vector2(640, 300)
var _spark_phase: float = 0.0
var _named_word: String = ""
var _world_answered: bool = false
var _gate_open: bool = false
var _surface_strength: float = 0.0
var _lamp_strength: float = 0.12


func _ready() -> void:
	_spark_origin = _spark.position
	_spark_phase = randf() * TAU
	_style_chrome()
	_bind_playfield_camera()
	_fill_window_with_field()
	_word_edit.text_submitted.connect(_on_word_submitted)
	_begin_button.pressed.connect(_on_begin_pressed)
	_close_begin_gate()
	_prompt.text = "A spark drifts. Walk. Type a word. Press Enter."
	_named_mark.text = ""
	_named_mark.visible = false
	if has_node("/root/Loom") and Loom.has_method("reset"):
		# First minutes stay off the shed teaching field.
		Loom.reset()
	set_process(true)


func _style_chrome() -> void:
	var ink := Color(0.86, 0.82, 0.74, 0.88)
	_prompt.add_theme_color_override("font_color", ink)
	_named_mark.add_theme_color_override("font_color", Color(0.953, 0.925, 0.855, 0.92))
	if has_node("/root/LedgerType"):
		var face: Font = LedgerType.font_for_role("ui")
		if face != null:
			_prompt.add_theme_font_override("font", face)
			_named_mark.add_theme_font_override("font", face)
			_word_edit.add_theme_font_override("font", face)
			_begin_button.add_theme_font_override("font", face)
	_word_edit.add_theme_color_override("font_color", Color(0.91, 0.875, 0.784, 1.0))
	_word_edit.add_theme_color_override("font_placeholder_color", Color(0.55, 0.50, 0.42, 0.7))
	_word_edit.placeholder_text = "type a word…"
	_word_edit.caret_blink = true
	_word_edit.max_length = 24
	_begin_button.text = "Begin"


func _process(delta: float) -> void:
	_t += delta
	_drift_spark(delta)
	if _world_answered:
		_surface_strength = minf(1.0, _surface_strength + delta * 0.55)
		_lamp_strength = minf(0.42, _lamp_strength + delta * 0.18)
	if _void_art != null and _void_art.has_method("set_answer"):
		_void_art.call("set_answer", _surface_strength, _lamp_strength, _named_word)
	if _void_art != null:
		_void_art.queue_redraw()


func _drift_spark(delta: float) -> void:
	if _spark == null:
		return
	_spark_phase += delta * 0.55
	var drift := Vector2(
		sin(_spark_phase) * SPARK_WANDER,
		cos(_spark_phase * 0.73) * (SPARK_WANDER * 0.62)
	)
	var target: Vector2 = _spark_origin + drift
	if _world_answered and _named_mark.visible:
		# Settles toward the named chalk after the void answers.
		target = target.lerp(_named_mark.position + Vector2(0, -28), _surface_strength)
	_spark.position = _spark.position.move_toward(target, SPARK_SPEED * delta * 3.2)
	if _spark.has_method("set_pulse"):
		_spark.call("set_pulse", _t, 1.0 + _surface_strength * 0.8)


func _unhandled_input(event: InputEvent) -> void:
	if _gate_open:
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause_menu"):
		_open_begin_gate()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo:
		# Focus the word field on letter keys so typing always works.
		if not _word_edit.has_focus() and _is_typeable_key(event):
			_word_edit.grab_focus()


func _is_typeable_key(event: InputEventKey) -> bool:
	var code: int = event.unicode
	if code >= 32 and code < 127:
		return true
	return event.keycode >= KEY_A and event.keycode <= KEY_Z


func _on_word_submitted(text: String) -> void:
	var word: String = text.strip_edges()
	if word.is_empty():
		_prompt.text = "Speak one word into the void."
		return
	_apply_world_answer(word)
	_word_edit.clear()
	_word_edit.release_focus()


func _apply_world_answer(word: String) -> void:
	_named_word = word
	_world_answered = true
	_named_mark.text = word
	_named_mark.visible = true
	_named_mark.position = Vector2(FIELD_CENTER.x - 80.0, FIELD_CENTER.y + 40.0)
	_spark_origin = Vector2(FIELD_CENTER.x, FIELD_CENTER.y - 20.0)
	var lower := word.to_lower()
	if lower in ["span", "bridge", "plank", "beam"]:
		_prompt.text = "The void takes a span. The spark holds the seam."
		_lamp_strength = maxf(_lamp_strength, 0.22)
	elif lower in ["light", "lamp", "fire", "ember"]:
		_prompt.text = "Warmth gathers. The spark brightens the drop."
		_lamp_strength = 0.38
	elif lower in ["home", "yard", "shed", "room"]:
		_prompt.text = "A floor remembers itself underfoot."
		_surface_strength = maxf(_surface_strength, 0.35)
	else:
		_prompt.text = "“%s” — the void answers. Walk the new edge." % word
	world_changed.emit(word)
	if _void_art != null:
		_void_art.queue_redraw()


func _open_begin_gate() -> void:
	_gate_open = true
	_begin_layer.visible = true
	_word_edit.editable = false
	_word_edit.release_focus()
	_begin_button.grab_focus()


func _close_begin_gate() -> void:
	_gate_open = false
	_begin_layer.visible = false
	_word_edit.editable = true


func _on_begin_pressed() -> void:
	_close_begin_gate()
	_reset_void()
	_prompt.text = "A spark drifts. Walk. Type a word. Press Enter."


func _reset_void() -> void:
	_named_word = ""
	_world_answered = false
	_surface_strength = 0.0
	_lamp_strength = 0.12
	_named_mark.text = ""
	_named_mark.visible = false
	_spark_origin = Vector2(640, 300)
	_spark.position = _spark_origin
	_word_edit.clear()
	if _player != null:
		_player.position = Vector2(420, 400)
	if _void_art != null and _void_art.has_method("set_answer"):
		_void_art.call("set_answer", 0.0, _lamp_strength, "")
		_void_art.queue_redraw()


func _bind_playfield_camera() -> void:
	var vp: Viewport = get_viewport()
	if vp != null and not vp.size_changed.is_connected(_on_viewport_size_changed):
		vp.size_changed.connect(_on_viewport_size_changed)


func _on_viewport_size_changed() -> void:
	_fill_window_with_field()


func _fill_window_with_field(look: Vector2 = FIELD_CENTER) -> void:
	## COVER the window with the void plane — no cream gutters, no folio rails.
	if _camera == null:
		return
	var vp: Vector2 = get_viewport().get_visible_rect().size
	if vp.x < 8.0 or vp.y < 8.0:
		vp = Vector2(960, 560)
	var zoom: float = maxf(vp.x / FIELD_SIZE.x, vp.y / FIELD_SIZE.y) * FILL_OVERSCAN
	zoom = maxf(zoom, 0.01)
	var vis: Vector2 = vp / zoom
	var cx: float = look.x
	var cy: float = look.y
	if vis.x >= FIELD_SIZE.x:
		cx = FIELD_CENTER.x
	else:
		var hx: float = vis.x * 0.5
		cx = clampf(look.x, hx, FIELD_SIZE.x - hx)
	if vis.y >= FIELD_SIZE.y:
		cy = FIELD_CENTER.y
	else:
		var hy: float = vis.y * 0.5
		cy = clampf(look.y, hy, FIELD_SIZE.y - hy)
	_camera.enabled = true
	_camera.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
	_camera.position = Vector2(cx, cy)
	_camera.zoom = Vector2(zoom, zoom)


## Headless / CI: type a word and confirm the void answered.
func debug_speak_word(word: String) -> bool:
	_apply_world_answer(word)
	return _world_answered and _named_word == word


func has_answered() -> bool:
	return _world_answered


func _run_void_selftest() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if not debug_speak_word("span"):
		push_error("void_boot selftest: speak failed")
		return
	for _i in range(6):
		await get_tree().process_frame
	print("void_boot selftest: OK word=%s answered=%s" % [_named_word, str(_world_answered)])
