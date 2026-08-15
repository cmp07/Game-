extends Node2D
## Diegetic chalk utterance in the void — typed (or stub-spoken) words become matter.
## Not a command console. No shed UI.

const SpokenMatterScript := preload("res://scripts/speak/spoken_matter.gd")
const LexiconScript := preload("res://scripts/speak/utterance_lexicon.gd")
const VoiceStubScript := preload("res://scripts/speak/voice_stub.gd")

@onready var _utter_label: Label = %UtterLabel
@onready var _whisper: Label = %Whisper
@onready var _cursor_mark: Polygon2D = %CursorMark
@onready var _matter_root: Node2D = %MatterRoot
@onready var _void_fill: Polygon2D = %VoidFill
@onready var _fray: Line2D = %FrayEdge
@onready var _dust: CPUParticles2D = %Dust

var _lexicon: RefCounted
var _voice: Node
var _buffer: String = ""
var _listening: bool = false
var _matters: Array = []
var _rng := RandomNumberGenerator.new()
var _cursor_t: float = 0.0
var _selftest: bool = false


func _ready() -> void:
	_rng.randomize()
	_lexicon = LexiconScript.new()
	_lexicon.load_default()
	_voice = VoiceStubScript.new()
	add_child(_voice)
	_voice.configure(_lexicon)
	_voice.listening_changed.connect(_on_listening_changed)
	_voice.phrase_ready.connect(_on_voice_phrase)
	_buffer = ""
	_refresh_utter()
	_whisper.text = "Type into the void. Enter seats the word. Hold Tab to speak (stub)."
	var args := OS.get_cmdline_user_args()
	if args.has("--void-speak-selftest") or args.has("--speak-selftest"):
		_selftest = true
		await _run_selftest()


func _process(delta: float) -> void:
	_cursor_t += delta
	if _cursor_mark:
		_cursor_mark.modulate.a = 0.35 + 0.45 * (0.5 + 0.5 * sin(_cursor_t * 6.0))
		_cursor_mark.rotation = sin(_cursor_t * 1.4) * 0.08
	if _listening and Input.is_action_just_released("speak_stub"):
		_finish_voice()


func _unhandled_input(event: InputEvent) -> void:
	if _voice != null and _voice.is_busy() and not (event is InputEventKey and event.is_released()):
		if event is InputEventKey and event.pressed and not event.echo:
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("speak_stub"):
		_begin_voice()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):
		if not _buffer.is_empty():
			_buffer = ""
			_refresh_utter()
		else:
			get_tree().change_scene_to_file("res://scenes/main.tscn")
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER:
			_commit_utterance()
			get_viewport().set_input_as_handled()
			return
		if key.keycode == KEY_BACKSPACE:
			if _buffer.length() > 0:
				_buffer = _buffer.substr(0, _buffer.length() - 1)
				_refresh_utter()
			get_viewport().set_input_as_handled()
			return
		var ch := char(key.unicode)
		if _is_utter_char(ch):
			if _buffer.length() < 48:
				_buffer += ch
				_refresh_utter()
			get_viewport().set_input_as_handled()


func _is_utter_char(ch: String) -> bool:
	if ch.is_empty():
		return false
	var c := ch.unicode_at(0)
	return (c >= 65 and c <= 90) or (c >= 97 and c <= 122) or (c >= 48 and c <= 57) or c == 32 or c == 45 or c == 39


func _refresh_utter() -> void:
	if _buffer.is_empty():
		_utter_label.text = "· · ·"
		_utter_label.modulate.a = 0.4
	else:
		_utter_label.text = _buffer
		_utter_label.modulate.a = 1.0


func _commit_utterance() -> void:
	var text := _buffer.strip_edges()
	_buffer = ""
	_refresh_utter()
	if text.is_empty():
		return
	_spawn_from_text(text)


func _spawn_from_text(text: String) -> void:
	var hit: Dictionary = _lexicon.classify(text)
	if hit.is_empty():
		return
	var kind_s := str(hit.get("kind", "fragment"))
	var label := str(hit.get("label", text))
	var source := str(hit.get("source_word", text))
	var matter_kind: int = SpokenMatterScript.KIND_FRAGMENT
	var accent := Color(0.45, 0.36, 0.24, 1)
	match kind_s:
		"thread":
			matter_kind = SpokenMatterScript.KIND_THREAD
			accent = Color(0.72, 0.47, 0.28, 1)
			_whisper.text = "A %s Thread frays into being." % label
		"law":
			matter_kind = SpokenMatterScript.KIND_LAW
			accent = Color(0.32, 0.28, 0.22, 1)
			_whisper.text = "Law seats: %s." % label.to_upper()
		_:
			matter_kind = SpokenMatterScript.KIND_FRAGMENT
			accent = _accent_for_fragment(label)
			_whisper.text = "Fragment · %s settles in the void." % label
	var matter: Node2D = SpokenMatterScript.new()
	_matter_root.add_child(matter)
	var at := Vector2(
		_rng.randf_range(280.0, 1000.0),
		_rng.randf_range(200.0, 520.0)
	)
	if _matters.size() < 3:
		at = Vector2(640.0, 360.0) + Vector2(_rng.randf_range(-120.0, 120.0), _rng.randf_range(-80.0, 80.0))
	matter.position = at
	matter.setup(matter_kind, label, source, accent)
	_matters.append(matter)
	if matter_kind == SpokenMatterScript.KIND_THREAD:
		var anchor: Node2D = _nearest_fragment(matter)
		if anchor != null:
			matter.link_thread_to(anchor)
	elif matter_kind == SpokenMatterScript.KIND_LAW:
		_pulse_void()
	_chalk_burst(at)


func _accent_for_fragment(label: String) -> Color:
	match label:
		"Anchor":
			return Color(0.30, 0.27, 0.22, 1)
		"Span":
			return Color(0.50, 0.38, 0.24, 1)
		_:
			return Color(0.42, 0.34, 0.24, 1)


func _nearest_fragment(from_matter: Node2D) -> Node2D:
	var best: Node2D = null
	var best_d := 1e12
	for m in _matters:
		if m == from_matter or not is_instance_valid(m):
			continue
		if int(m.kind) != SpokenMatterScript.KIND_FRAGMENT:
			continue
		var d: float = from_matter.position.distance_to(m.position)
		if d < best_d:
			best_d = d
			best = m
	return best


func _pulse_void() -> void:
	if _void_fill == null:
		return
	var base := _void_fill.color
	var tw := create_tween()
	tw.tween_property(_void_fill, "color", Color(base.r * 1.15, base.g * 1.1, base.b * 0.95, base.a), 0.18)
	tw.tween_property(_void_fill, "color", base, 0.35)


func _chalk_burst(at: Vector2) -> void:
	if _dust == null:
		return
	_dust.global_position = at
	_dust.restart()


func _begin_voice() -> void:
	if _voice.is_busy():
		return
	_listening = true
	_voice.begin_listen()
	_whisper.text = "Listening… (release Tab)"
	_utter_label.text = "◌ listening"
	_utter_label.modulate.a = 0.7


func _finish_voice() -> void:
	if not _listening:
		return
	_listening = false
	var phrase: String = _voice.complete_listen()
	if phrase.is_empty():
		return
	_whisper.text = "Voice stub → “%s”" % phrase
	await _voice.typewrite_into(Callable(self, "_set_buffer_live"), phrase, get_tree())
	_commit_utterance()


func _set_buffer_live(text: String) -> void:
	_buffer = text
	_refresh_utter()


func _on_listening_changed(active: bool) -> void:
	_listening = active
	if active:
		_cursor_mark.color = Color(0.72, 0.47, 0.28, 0.85)
	else:
		_cursor_mark.color = Color(0.86, 0.78, 0.62, 0.8)


func _on_voice_phrase(_text: String) -> void:
	pass


func matter_count() -> int:
	return _matters.size()


func counts_by_kind() -> Dictionary:
	var out := {"fragment": 0, "thread": 0, "law": 0}
	for m in _matters:
		if not is_instance_valid(m):
			continue
		match int(m.kind):
			SpokenMatterScript.KIND_FRAGMENT:
				out["fragment"] += 1
			SpokenMatterScript.KIND_THREAD:
				out["thread"] += 1
			SpokenMatterScript.KIND_LAW:
				out["law"] += 1
	return out


func _run_selftest() -> void:
	print("== Weaver void speak/type selftest ==")
	var phrases := ["anchor", "span", "brace", "hold", "timber"]
	for p in phrases:
		_spawn_from_text(p)
		await get_tree().create_timer(0.15).timeout
	var counts := counts_by_kind()
	var ok: bool = (
		matter_count() >= 5
		and int(counts["fragment"]) >= 2
		and int(counts["thread"]) >= 1
		and int(counts["law"]) >= 1
	)
	print("void-speak-selftest: matters=%d counts=%s ok=%s" % [matter_count(), str(counts), str(ok)])
	var args := OS.get_cmdline_user_args()
	if args.has("--screenshot"):
		await get_tree().process_frame
		await get_tree().process_frame
		var out_dir := ProjectSettings.globalize_path("res://").path_join("../../docs/WEAVER/media")
		DirAccess.make_dir_recursive_absolute(out_dir)
		var img: Image = get_viewport().get_texture().get_image()
		if img != null:
			var path := out_dir.path_join("void_speak_spike.png")
			img.save_png(path)
			print("void-speak-selftest: wrote %s" % path)
	get_tree().quit(0 if ok else 1)
