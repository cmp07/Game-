extends Node
## High-level AUDIO v3 facade for gameplay.
## Fire structured events; wires AdaptiveMusic, SilenceDirector, and PA.
## Rewrite events play multi-stage slam phrases (~0.90s); see AUDIO_V3.md.

signal event_fired(event_id: String, payload: Dictionary)

@export var catalog_path: String = AudioEvents.CATALOG_PATH

## Premium menu feel — authored rests between UI ticks (AUDIO_V3 P3 / §6.4).
const UI_ARM_DELAY_MS: int = 120
const UI_SELECT_GAP_MS: int = 95
const UI_HOVER_GAP_MS: int = 160
const UI_HOVER_AFTER_SELECT_MS: int = 200

var _events: AudioEvents = AudioEvents.new()
var _rng := RandomNumberGenerator.new()
var _follow_up_timer: SceneTreeTimer
var _ui_feel_armed_msec: int = 0
var _last_ui_feel_msec: int = 0
var _last_ui_feel_kind: String = ""


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


func on_fail_reset() -> void:
	## Chamber restart / habit-death recovery — dry institutional cue, not cartoon.
	fire("fail.reset")


## Arm after shell open / grab_focus so cold boot and overlay open stay silent.
func arm_ui_feel(delay_ms: int = UI_ARM_DELAY_MS) -> void:
	_ui_feel_armed_msec = Time.get_ticks_msec() + maxi(0, delay_ms)


func on_ui_select() -> void:
	## Focus move — paper/ink selection tick; silence between navigations.
	if not _ui_feel_ready():
		return
	if not _ui_gap_ok(UI_SELECT_GAP_MS):
		return
	fire("ui.select")
	_mark_ui_feel("select")


func on_ui_hover() -> void:
	## Mouse hover whisper — skip when noisy (recent select/confirm or gap).
	if not _ui_feel_ready():
		return
	if not _ui_gap_ok(UI_HOVER_GAP_MS):
		return
	if _last_ui_feel_kind == "select":
		if Time.get_ticks_msec() - _last_ui_feel_msec < UI_HOVER_AFTER_SELECT_MS:
			return
	fire("ui.hover")
	_mark_ui_feel("hover")


func on_ui_confirm() -> void:
	## IndexAction activate — soft ledger confirm stinger (catalog ui.click).
	fire("ui.click")
	_mark_ui_feel("confirm")


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


func _ui_feel_ready() -> bool:
	return Time.get_ticks_msec() >= _ui_feel_armed_msec


func _ui_gap_ok(min_gap_ms: int) -> bool:
	if _last_ui_feel_msec <= 0:
		return true
	return Time.get_ticks_msec() - _last_ui_feel_msec >= min_gap_ms


func _mark_ui_feel(kind: String) -> void:
	_last_ui_feel_msec = Time.get_ticks_msec()
	_last_ui_feel_kind = kind


func _audio_manager() -> Node:
	return get_node_or_null("/root/AudioManager")


func _adaptive_music() -> Node:
	return get_node_or_null("/root/AdaptiveMusic")


func _silence_director() -> Node:
	return get_node_or_null("/root/SilenceDirector")


func _pa_announcer() -> Node:
	return get_node_or_null("/root/PaAnnouncer")
