extends Node
## Small helper autoload for lightweight UI SFX with graceful fallbacks.
##
## We intentionally do not ship audio assets in this UI scaffold — sound design
## is the next slice. Every method is safe to call; if no stream is registered
## for the tag we silently no-op so the UI stays wired up.

const BUS_UI := "UI"
const BUS_SFX := "SFX"
const BUS_MUSIC := "Music"

var _streams: Dictionary = {}
var _players: Dictionary = {}


func _ready() -> void:
	for tag in ["nav", "confirm", "cancel", "rewrite_ping", "win", "lose", "tick"]:
		var p := AudioStreamPlayer.new()
		p.name = "P_%s" % tag
		p.bus = BUS_UI
		add_child(p)
		_players[tag] = p


func play(tag: String) -> void:
	if not _players.has(tag):
		return
	var stream: AudioStream = _streams.get(tag)
	if stream == null:
		return
	var p: AudioStreamPlayer = _players[tag]
	p.stream = stream
	p.play()


func register(tag: String, stream: AudioStream, bus := BUS_UI) -> void:
	_streams[tag] = stream
	if _players.has(tag):
		(_players[tag] as AudioStreamPlayer).bus = bus
