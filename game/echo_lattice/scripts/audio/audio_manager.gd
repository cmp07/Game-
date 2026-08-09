extends Node
## Autoload: route one-shots to SFX / UI / PA buses with optional Music ducking.
## Register as AudioManager once project.godot exists.

signal sfx_played(path: String)
signal ui_played(path: String)
signal pa_played(path: String)
signal event_played(event_id: String)

@export var sfx_polyphony: int = 10
@export var pa_polyphony: int = 3
@export var catalog_path: String = AudioEvents.CATALOG_PATH

var _sfx_players: Array[AudioStreamPlayer] = []
var _pa_players: Array[AudioStreamPlayer] = []
var _ui_player: AudioStreamPlayer
var _sfx_index: int = 0
var _pa_index: int = 0
var _events: AudioEvents = AudioEvents.new()
var _music_duck_left_ms: float = 0.0
var _music_duck_db: float = 0.0
var _base_music_bus_db: float = -6.0


func _ready() -> void:
	_events.load_catalog(catalog_path)
	for i in sfx_polyphony:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)
	for i in pa_polyphony:
		var p := AudioStreamPlayer.new()
		p.bus = "PA"
		add_child(p)
		_pa_players.append(p)
	_ui_player = AudioStreamPlayer.new()
	_ui_player.bus = "UI"
	add_child(_ui_player)
	var music_idx := AudioServer.get_bus_index("Music")
	if music_idx >= 0:
		_base_music_bus_db = AudioServer.get_bus_volume_db(music_idx)


func _process(delta: float) -> void:
	if _music_duck_left_ms <= 0.0:
		return
	_music_duck_left_ms = maxf(0.0, _music_duck_left_ms - delta * 1000.0)
	var music_idx := AudioServer.get_bus_index("Music")
	if music_idx < 0:
		return
	if _music_duck_left_ms <= 0.0:
		AudioServer.set_bus_volume_db(music_idx, _base_music_bus_db)
	else:
		AudioServer.set_bus_volume_db(music_idx, _base_music_bus_db + _music_duck_db)


func play_sfx(path: String, pitch_scale: float = 1.0, volume_db: float = 0.0) -> void:
	_play_on_pool(_sfx_players, "_sfx_index", "SFX", path, pitch_scale, volume_db)
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


func play_pa(path: String, pitch_scale: float = 1.0, volume_db: float = 0.0) -> void:
	_play_on_pool(_pa_players, "_pa_index", "PA", path, pitch_scale, volume_db)
	pa_played.emit(path)


func play_event(event_id: String, pitch_scale: float = 1.0, volume_db: float = 0.0) -> Dictionary:
	var ev := _events.get_event(event_id)
	if ev.is_empty():
		push_warning("AudioManager: unknown event %s" % event_id)
		return {}
	var path := str(ev.get("stream", ""))
	var bus := str(ev.get("bus", "SFX"))
	match bus:
		"UI":
			play_ui(path, pitch_scale)
		"PA":
			play_pa(path, pitch_scale, volume_db)
		_:
			play_sfx(path, pitch_scale, volume_db)
	if ev.has("duck_music_db"):
		duck_music(float(ev.get("duck_music_db", 0.0)), float(ev.get("duck_ms", 300.0)))
	event_played.emit(event_id)
	return ev


func duck_music(db: float, ms: float) -> void:
	_music_duck_db = db
	_music_duck_left_ms = maxf(_music_duck_left_ms, ms)
	var music_idx := AudioServer.get_bus_index("Music")
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, _base_music_bus_db + db)


func set_bus_linear(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		push_warning("AudioManager: unknown bus %s" % bus_name)
		return
	var db := linear_to_db(clampf(linear, 0.0001, 1.0))
	AudioServer.set_bus_volume_db(idx, db)
	if bus_name == "Music":
		_base_music_bus_db = db


func get_bus_linear(bus_name: String) -> float:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return 0.0
	return db_to_linear(AudioServer.get_bus_volume_db(idx))


func get_catalog() -> AudioEvents:
	return _events


func _play_on_pool(
	pool: Array[AudioStreamPlayer],
	index_field: String,
	bus: String,
	path: String,
	pitch_scale: float,
	volume_db: float,
) -> void:
	var stream := _load_stream(path)
	if stream == null:
		push_warning("AudioManager: missing %s %s" % [bus, path])
		return
	var idx: int = get(index_field)
	var player := pool[idx]
	set(index_field, (idx + 1) % pool.size())
	player.bus = bus
	player.stream = stream
	player.pitch_scale = pitch_scale
	player.volume_db = volume_db
	player.play()


func _load_stream(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		return load(path) as AudioStream
	if path.ends_with(".ogg"):
		var wav_path := path.get_basename() + ".wav"
		if ResourceLoader.exists(wav_path):
			return load(wav_path) as AudioStream
	# Headless / pre-import: allow FileAccess WAV load via AudioStreamWAV if present on disk.
	var abs_path := ProjectSettings.globalize_path(path) if path.begins_with("res://") else path
	if abs_path.ends_with(".ogg"):
		abs_path = abs_path.get_basename() + ".wav"
	if FileAccess.file_exists(abs_path) and abs_path.ends_with(".wav"):
		return _load_wav_file(abs_path)
	return null


func _load_wav_file(abs_path: String) -> AudioStream:
	# Optional runtime path for tools; editor import is preferred in shipping builds.
	if not ClassDB.class_exists("AudioStreamWAV"):
		return null
	var f := FileAccess.open(abs_path, FileAccess.READ)
	if f == null:
		return null
	var bytes := f.get_buffer(f.get_length())
	var stream := AudioStreamWAV.new()
	# Skip 44-byte PCM header for our generator output.
	if bytes.size() > 44:
		stream.data = bytes.slice(44)
		stream.format = AudioStreamWAV.FORMAT_16_BITS
		stream.mix_rate = 44100
		stream.stereo = false
		return stream
	return null
