extends Node
## Stub: layered Music-bus intensity driven by rewrite / habit tension.
## See docs/ECHO_LATTICE/06_AUDIO_BIBLE.md §5.

signal intensity_changed(intensity: float)

@export var bed_path: String = "res://audio/music/bed_placeholder.ogg"
@export var smooth_seconds: float = 0.35
@export var rewrite_pulse_seconds: float = 0.6

var music_intensity: float = 0.0
var _target: float = 0.0
var _pulse_timer: float = 0.0
var _bed: AudioStreamPlayer
var _layer_gains: Dictionary = {
	"L0": 1.0,
	"L1": 0.0,
	"L2": 0.0,
	"L3": 0.0,
}


func _ready() -> void:
	_bed = AudioStreamPlayer.new()
	_bed.bus = "Music"
	_bed.volume_db = -6.0
	add_child(_bed)
	if ResourceLoader.exists(bed_path):
		_bed.stream = load(bed_path)
		_bed.play()


func _process(delta: float) -> void:
	if _pulse_timer > 0.0:
		_pulse_timer = maxf(0.0, _pulse_timer - delta)
	var rate := 1.0 - exp(-delta / maxf(0.01, smooth_seconds))
	music_intensity = lerpf(music_intensity, _effective_target(), rate)
	_apply_layer_gains()
	intensity_changed.emit(music_intensity)


## Call from game core when move-buffer habit tension updates (0..1).
func set_habit_tension(t: float) -> void:
	_target = clampf(t, 0.0, 1.0)


func pulse_rewrite() -> void:
	_pulse_timer = rewrite_pulse_seconds
	_target = maxf(_target, 0.85)


func on_chamber_win() -> void:
	_pulse_timer = 0.0
	_target = minf(_target, 0.2)


func on_death_reset() -> void:
	_pulse_timer = 0.0
	_target = 0.0
	music_intensity = 0.0


func get_layer_gains() -> Dictionary:
	return _layer_gains.duplicate()


func _effective_target() -> float:
	if _pulse_timer > 0.0:
		return maxf(_target, 0.9)
	return _target


func _apply_layer_gains() -> void:
	var i := music_intensity
	_layer_gains["L0"] = 1.0
	_layer_gains["L1"] = clampf((i - 0.25) / 0.35, 0.0, 1.0)
	_layer_gains["L2"] = clampf((i - 0.55) / 0.25, 0.0, 1.0)
	_layer_gains["L3"] = clampf((i - 0.80) / 0.20, 0.0, 1.0)
	# MVP: only one bed stream; gains are API for future stem players.
	if _bed and _bed.playing:
		var duck := lerpf(0.0, -4.0, _layer_gains["L3"])
		_bed.volume_db = -6.0 + duck
