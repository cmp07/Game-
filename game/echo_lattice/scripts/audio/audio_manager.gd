extends Node
## Autoload stub: route one-shots to SFX / UI buses.
## Register as AudioManager once project.godot exists.

signal sfx_played(path: String)
signal ui_played(path: String)

@export var sfx_polyphony: int = 8

var _sfx_players: Array[AudioStreamPlayer] = []
var _ui_player: AudioStreamPlayer
var _sfx_index: int = 0


func _ready() -> void:
	for i in sfx_polyphony:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)
	_ui_player = AudioStreamPlayer.new()
	_ui_player.bus = "UI"
	add_child(_ui_player)


func play_sfx(path: String, pitch_scale: float = 1.0, volume_db: float = 0.0) -> void:
	var stream := _load_stream(path)
	if stream == null:
		push_warning("AudioManager: missing SFX %s" % path)
		return
	var player := _sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % _sfx_players.size()
	player.stream = stream
	player.pitch_scale = pitch_scale
	player.volume_db = volume_db
	player.play()
	sfx_played.emit(path)


func play_ui(path: String, pitch_scale: float = 1.0) -> void:
	var stream := _load_stream(path)
	if stream == null:
		push_warning("AudioManager: missing UI %s" % path)
		return
	_ui_player.stream = stream
	_ui_player.pitch_scale = pitch_scale
	_ui_player.play()
	ui_played.emit(path)


func set_bus_linear(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		push_warning("AudioManager: unknown bus %s" % bus_name)
		return
	AudioServer.set_bus_volume_db(idx, linear_to_db(clampf(linear, 0.0001, 1.0)))


func get_bus_linear(bus_name: String) -> float:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return 0.0
	return db_to_linear(AudioServer.get_bus_volume_db(idx))


func _load_stream(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		return load(path) as AudioStream
	# Prefer .ogg; try .wav twin if needed.
	if path.ends_with(".ogg"):
		var wav_path := path.get_basename() + ".wav"
		if ResourceLoader.exists(wav_path):
			return load(wav_path) as AudioStream
	return null
