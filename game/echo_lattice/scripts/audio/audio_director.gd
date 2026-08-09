extends Node
## High-level AUDIO v2 facade for gameplay.
## Fire structured events; wires AdaptiveMusic, SilenceDirector, and PA.

signal event_fired(event_id: String, payload: Dictionary)

@export var catalog_path: String = AudioEvents.CATALOG_PATH

var _events: AudioEvents = AudioEvents.new()
var _rng := RandomNumberGenerator.new()
var _follow_up_timer: SceneTreeTimer


func _ready() -> void:
	_rng.randomize()
	_events.load_catalog(catalog_path)
	_wire_silence()


func fire(event_id: String, params: Dictionary = {}) -> void:
	var ev := _events.get_event(event_id)
	if ev.is_empty():
		push_warning("AudioDirector: unknown event %s" % event_id)
		return

	var pitch := float(params.get("pitch_scale", 1.0))
	if ev.has("pitch_jitter"):
		var j := float(ev["pitch_jitter"])
		pitch *= _rng.randf_range(1.0 - j, 1.0 + j)
	if ev.has("habit_pitch_lerp"):
		var habit_t := float(params.get("habit_tension", _habit_tension()))
		var lerp_pair: Array = ev["habit_pitch_lerp"]
		if lerp_pair.size() >= 2:
			pitch *= lerpf(float(lerp_pair[0]), float(lerp_pair[1]), clampf(habit_t, 0.0, 1.0))

	var manager := _audio_manager()
	if manager:
		manager.play_event(event_id, pitch, float(params.get("volume_db", 0.0)))

	_handle_music_hook(str(ev.get("music_hook", "")), params)
	_schedule_follow_up(ev)
	event_fired.emit(event_id, params)


func on_footstep(blocked: bool = false, habit_tension: float = -1.0) -> void:
	var t := habit_tension if habit_tension >= 0.0 else _habit_tension()
	if blocked:
		fire("sfx.footstep_blocked", {"habit_tension": t})
	else:
		fire("sfx.footstep", {"habit_tension": t})


func on_rewrite_warn(habit_tension: float = -1.0) -> void:
	var t := habit_tension if habit_tension >= 0.0 else _habit_tension()
	fire("sfx.rewrite_warn", {"habit_tension": t})


func on_rewrite(operator_name: String = "") -> void:
	var event_id := _events.rewrite_event_id(operator_name)
	fire(event_id, {"operator": operator_name})
	var music := _adaptive_music()
	if music:
		music.pulse_rewrite()


func on_chamber_won(queue_next: bool = true) -> void:
	if queue_next:
		# Resolve + open-loop sting (catalog follow_up → win.queue_next).
		fire("win.chamber")
	else:
		fire("win.fanfare")


func on_wing_clear() -> void:
	fire("win.wing")
	fire("pa.wing_clear")
	var music := _adaptive_music()
	if music:
		music.on_chamber_win()


func on_pa_line(line_id: String) -> void:
	var pa := _pa_announcer()
	if pa and pa.has_method("play_line"):
		pa.play_line(line_id)
	else:
		fire("pa.attention")


func set_chamber(chamber_index: int) -> void:
	var silence := _silence_director()
	if silence:
		silence.set_chamber_index(chamber_index)
	_sync_silence_cap()


func set_habit_solidify(amount: float) -> void:
	var music := _adaptive_music()
	if music:
		music.set_habit_solidify(amount)


func set_rewrite_tension(amount: float) -> void:
	var music := _adaptive_music()
	if music:
		music.set_rewrite_tension(amount)


## Convenience: update both solidify + rewrite components from gameplay metrics.
func update_habit_audio(
	dominant_bias: float,
	repetition_score: float,
	fossil_density: float,
	rewrite_count_norm: float,
	rewrite_proximity: float,
) -> void:
	var music = _adaptive_music()
	if music == null:
		return
	var solidify: float = float(music.compute_solidify_from_metrics(
		dominant_bias, repetition_score, fossil_density, rewrite_count_norm
	))
	music.set_habit_solidify(solidify)
	music.set_rewrite_tension(rewrite_proximity)


func get_catalog() -> AudioEvents:
	return _events


func _schedule_follow_up(ev: Dictionary) -> void:
	if not ev.has("follow_up"):
		return
	var follow := str(ev["follow_up"])
	var delay_ms := float(ev.get("follow_up_delay_ms", 0.0))
	if delay_ms <= 0.0:
		fire(follow)
		return
	if get_tree() == null:
		return
	_follow_up_timer = get_tree().create_timer(delay_ms / 1000.0)
	_follow_up_timer.timeout.connect(func(): fire(follow), CONNECT_ONE_SHOT)


func _handle_music_hook(hook: String, _params: Dictionary) -> void:
	if hook.is_empty():
		return
	var music := _adaptive_music()
	if music == null:
		return
	match hook:
		"on_chamber_win":
			music.on_chamber_win()
		"pulse_rewrite":
			music.pulse_rewrite()
		"on_death_reset":
			music.on_death_reset()


func _wire_silence() -> void:
	var silence := _silence_director()
	if silence and not silence.silence_cap_changed.is_connected(_on_silence_cap):
		silence.silence_cap_changed.connect(_on_silence_cap)
	_sync_silence_cap()


func _on_silence_cap(max_intensity: float) -> void:
	var music := _adaptive_music()
	if music:
		music.set_max_intensity(max_intensity)


func _sync_silence_cap() -> void:
	var silence := _silence_director()
	var music := _adaptive_music()
	if silence and music:
		music.set_max_intensity(silence.get_max_intensity())


func _habit_tension() -> float:
	var music := _adaptive_music()
	if music:
		return music.get_habit_tension()
	return 0.0


func _audio_manager() -> Node:
	return get_node_or_null("/root/AudioManager")


func _adaptive_music() -> Node:
	return get_node_or_null("/root/AdaptiveMusic")


func _silence_director() -> Node:
	return get_node_or_null("/root/SilenceDirector")


func _pa_announcer() -> Node:
	return get_node_or_null("/root/PaAnnouncer")
