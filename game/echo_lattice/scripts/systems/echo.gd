class_name Echo
extends Node3D
##
## Runtime instance of a played-back habit.
##
## LatticeWorld spawns an Echo when the player enters a chamber whose
## resonant_habits threshold is met. Concrete visual/audio behaviour is
## implemented by subclassing this node or attaching a sub-scene, so this
## base type only carries data and a common lifecycle.
##

signal expired(echo: Echo)

@export var kind: StringName = &""
@export var payload: Dictionary = {}
@export var lifetime_s: float = 10.0

var _elapsed_s: float = 0.0


func _ready() -> void:
	EventBus.echo_spawned.emit(self)


func _process(delta: float) -> void:
	_elapsed_s += delta
	if _elapsed_s >= lifetime_s:
		expired.emit(self)
		queue_free()


func replay() -> void:
	## Subclasses implement the actual playback (audio cue, ghost figure,
	## light flicker). Base class just re-fires the bus signal so listeners
	## can react.
	EventBus.echo_replayed.emit(kind, payload)
