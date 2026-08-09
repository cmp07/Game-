extends Node
## Silence as a feature: early Induction chambers keep Music near zero so
## footsteps, ghost, and PA carry the fantasy. See [06_AUDIO_BIBLE] §7.

signal silence_cap_changed(max_intensity: float)

@export var catalog_path: String = AudioEvents.CATALOG_PATH

var _events: AudioEvents = AudioEvents.new()
var _chamber_index: int = 0
var _max_intensity: float = 0.0
var _force_silence: bool = false


func _ready() -> void:
	_events.load_catalog(catalog_path)
	set_chamber_index(0)


func set_chamber_index(index: int) -> void:
	_chamber_index = maxi(0, index)
	_recompute()


func set_force_silence(enabled: bool) -> void:
	_force_silence = enabled
	_recompute()


func get_max_intensity() -> float:
	return _max_intensity


func get_chamber_index() -> int:
	return _chamber_index


func is_silent_chamber() -> bool:
	return _max_intensity <= 0.001


func clamp_intensity(raw: float) -> float:
	return clampf(raw, 0.0, _max_intensity)


func _recompute() -> void:
	if _force_silence:
		_max_intensity = 0.0
	else:
		_max_intensity = _events.max_intensity_for_chamber(_chamber_index)
	silence_cap_changed.emit(_max_intensity)
