extends Node
##
## AudioBus
##
## Thin wrapper around Godot's AudioServer buses plus a one-shot player pool
## for sfx. Music playback owns a dedicated stream player so it can crossfade
## without allocating.
##
## The tension vignette premise means audio matters a lot; we set up the
## right buses up front instead of piling everything on `Master`.
##

const MASTER := &"Master"
const MUSIC := &"Music"
const SFX := &"SFX"
const AMBIENCE := &"Ambience"
const UI := &"UI"

@export var one_shot_pool_size: int = 8

var _music_player: AudioStreamPlayer
var _one_shots: Array[AudioStreamPlayer] = []
var _one_shot_cursor: int = 0


func _ready() -> void:
	_ensure_buses()
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = MUSIC
	add_child(_music_player)
	for i in one_shot_pool_size:
		var p := AudioStreamPlayer.new()
		p.name = "OneShot%d" % i
		p.bus = SFX
		add_child(p)
		_one_shots.append(p)


func play_music(stream: AudioStream, fade_in_s: float = 0.5) -> void:
	if stream == null:
		return
	_music_player.stream = stream
	_music_player.volume_db = -80.0 if fade_in_s > 0.0 else 0.0
	_music_player.play()
	if fade_in_s > 0.0:
		var tween := create_tween()
		tween.tween_property(_music_player, "volume_db", 0.0, fade_in_s)


func stop_music(fade_out_s: float = 0.5) -> void:
	if not _music_player.playing:
		return
	if fade_out_s <= 0.0:
		_music_player.stop()
		return
	var tween := create_tween()
	tween.tween_property(_music_player, "volume_db", -80.0, fade_out_s)
	tween.tween_callback(Callable(_music_player, "stop"))


func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if stream == null or _one_shots.is_empty():
		return
	var player := _one_shots[_one_shot_cursor]
	_one_shot_cursor = (_one_shot_cursor + 1) % _one_shots.size()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()


func set_bus_db(bus: StringName, db: float) -> void:
	var idx := AudioServer.get_bus_index(bus)
	if idx < 0:
		return
	AudioServer.set_bus_volume_db(idx, db)


func _ensure_buses() -> void:
	for bus in [MUSIC, SFX, AMBIENCE, UI]:
		if AudioServer.get_bus_index(bus) < 0:
			var idx := AudioServer.get_bus_count()
			AudioServer.add_bus(idx)
			AudioServer.set_bus_name(idx, bus)
			AudioServer.set_bus_send(idx, MASTER)
