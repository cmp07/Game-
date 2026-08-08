class_name Main
extends Node
##
## Root scene.
##
## Main owns nothing gameplay-facing directly. It just wires LatticeWorld
## and UICanvas together and hands control to the autoloads. Keeping this
## thin means the entry scene rarely needs to change — new features grow
## as their own scenes/systems, not by piling nodes here.
##

@onready var _lattice_world: LatticeWorld = $LatticeWorld
@onready var _ui: UICanvas = $UICanvas


func _ready() -> void:
	EchoLog.info("main", "Echo Lattice booted, run_id=%d" % GameState.run_id)
	EventBus.ui_message_requested.emit("Echo Lattice", 2.5)


func lattice_world() -> LatticeWorld:
	return _lattice_world


func ui() -> UICanvas:
	return _ui
