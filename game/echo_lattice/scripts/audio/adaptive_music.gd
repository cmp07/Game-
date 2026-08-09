extends Node
## Layered Music-bus intensity driven by habit solidification + rewrite tension.
## Stems are Ledger Cell motif transforms (AUDIO v3); gates/API from AUDIO v2 bible §5–§7.

signal intensity_changed(intensity: float)
signal layers_changed(gains: Dictionary)

@export var smooth_seconds: float = 0.35
@export var rewrite_pulse_seconds: float = 0.6
@export var layer_fade_seconds: float = 0.3
@export var l0_path: String = SfxCatalog.MUSIC_L0
@export var l1_path: String = SfxCatalog.MUSIC_L1
@export var l2_path: String = SfxCatalog.MUSIC_L2
@export var l3_path: String = SfxCatalog.MUSIC_L3

## Habit solidification (0..1) — rises as dominant bias / fossils accumulate.
var habit_solidify: float = 0.0
## Rewrite proximity / fail pressure component (0..1).
var rewrite_tension: float = 0.0

var music_intensity: float = 0.0
var _target: float = 0.0
var _pulse_timer: float = 0.0
var _max_intensity: float = 1.0
var _paused_duck: bool = false

var _players: Dictionary = {} # layer -> AudioStreamPlayer
var _layer_gains: Dictionary = {
	"L0": 1.0,
	"L1": 0.0,
	"L2": 0.0,
	"L3": 0.0,
}
var _layer_base_db: Dictionary = {
	"L0": -7.0,
	"L1": -10.0,
	"L2": -11.0,
	"L3": -9.0,
}


func _ready() -> void:
	_players["L0"] = _make_layer_player(l0_path, "L0")
	_players["L1"] = _make_layer_player(l1_path, "L1")
	_players["L2"] = _make_layer_player(l2_path, "L2")
	_players["L3"] = _make_layer_player(l3_path, "L3")
	_apply_layer_gains(true)


func _process(delta: float) -> void:
	if _pulse_timer > 0.0:
		_pulse_timer = maxf(0.0, _pulse_timer - delta)
	_recompute_target()
	var rate := 1.0 - exp(-delta / maxf(0.01, smooth_seconds))
	music_intensity = lerpf(music_intensity, _effective_target(), rate)
	_apply_layer_gains(false)
	intensity_changed.emit(music_intensity)


## Combined habit tension used by footsteps / UI meters.
func get_habit_tension() -> float:
	return clampf(0.55 * habit_solidify + 0.45 * rewrite_tension, 0.0, 1.0)


## Call when HabitSignature / solidify metrics update (0..1).
func set_habit_solidify(amount: float) -> void:
	habit_solidify = clampf(amount, 0.0, 1.0)


## Call from game core when move-buffer rewrite tension updates (0..1).
func set_habit_tension(t: float) -> void:
	# Back-compat name from AUDIO v1: treat as rewrite tension component.
	rewrite_tension = clampf(t, 0.0, 1.0)


func set_rewrite_tension(t: float) -> void:
	rewrite_tension = clampf(t, 0.0, 1.0)


## Applied by SilenceDirector — early chambers cap intensity (silence feature).
func set_max_intensity(max_i: float) -> void:
	_max_intensity = clampf(max_i, 0.0, 1.0)


func pulse_rewrite() -> void:
	_pulse_timer = rewrite_pulse_seconds
	rewrite_tension = maxf(rewrite_tension, 0.85)


func on_chamber_win() -> void:
	_pulse_timer = 0.0
	rewrite_tension = minf(rewrite_tension, 0.15)
	# Keep a whisper of solidify so queue-next fanfare sits on warm bed, not void.
	habit_solidify = minf(habit_solidify, 0.35)


func on_death_reset() -> void:
	_pulse_timer = 0.0
	rewrite_tension = 0.0
	music_intensity = 0.0


func set_paused(paused: bool) -> void:
	_paused_duck = paused
	_apply_layer_gains(true)


func get_layer_gains() -> Dictionary:
	return _layer_gains.duplicate()


func compute_solidify_from_metrics(
	dominant_bias: float,
	repetition_score: float,
	fossil_density: float,
	rewrite_count_norm: float,
) -> float:
	return clampf(
		0.40 * dominant_bias
		+ 0.30 * repetition_score
		+ 0.20 * fossil_density
		+ 0.10 * rewrite_count_norm,
		0.0,
		1.0,
	)


func _recompute_target() -> void:
	# Addiction curve: solidify dominates the bed; rewrite tension pulls L3.
	_target = clampf(0.65 * habit_solidify + 0.35 * rewrite_tension, 0.0, 1.0)


func _effective_target() -> float:
	var t := _target
	if _pulse_timer > 0.0:
		t = maxf(t, 0.9)
	return minf(t, _max_intensity)


func _make_layer_player(path: String, layer: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = "Music"
	p.volume_db = -80.0
	add_child(p)
	var stream := _load_stream(path)
	if stream == null and layer == "L0":
		stream = _load_stream(SfxCatalog.MUSIC_BED)
	if stream != null:
		if stream is AudioStreamOggVorbis:
			(stream as AudioStreamOggVorbis).loop = true
		elif stream is AudioStreamWAV:
			(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
		p.stream = stream
		p.play()
	return p


func _apply_layer_gains(immediate: bool) -> void:
	var i := music_intensity
	# When silence-capped to 0, mute all layers including L0 (feature, not a bug).
	if _max_intensity <= 0.001:
		_layer_gains["L0"] = 0.0
		_layer_gains["L1"] = 0.0
		_layer_gains["L2"] = 0.0
		_layer_gains["L3"] = 0.0
	else:
		_layer_gains["L0"] = 1.0
		_layer_gains["L1"] = clampf((i - 0.25) / 0.35, 0.0, 1.0)
		_layer_gains["L2"] = clampf((i - 0.55) / 0.25, 0.0, 1.0)
		_layer_gains["L3"] = clampf((i - 0.80) / 0.20, 0.0, 1.0)

	for layer in _players.keys():
		var player: AudioStreamPlayer = _players[layer]
		if player == null:
			continue
		var gain: float = float(_layer_gains[layer])
		var base: float = float(_layer_base_db[layer])
		var target_db := -80.0 if gain <= 0.001 else base + linear_to_db(maxf(gain, 0.001))
		if _paused_duck and target_db > -79.0:
			target_db -= 8.0
		if immediate:
			player.volume_db = target_db
		else:
			player.volume_db = lerpf(player.volume_db, target_db, 1.0 - exp(-get_process_delta_time() / maxf(0.01, layer_fade_seconds)))
		if gain > 0.001 and not player.playing and player.stream != null:
			player.play()
	layers_changed.emit(_layer_gains.duplicate())


func _load_stream(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		return load(path) as AudioStream
	if path.ends_with(".ogg"):
		var wav_path := path.get_basename() + ".wav"
		if ResourceLoader.exists(wav_path):
			return load(wav_path) as AudioStream
	return null
