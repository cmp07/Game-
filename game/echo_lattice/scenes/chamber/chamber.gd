class_name Chamber
extends Node3D
##
## A single explorable room.
##
## Chambers are self-contained scenes. On enter/exit they announce themselves
## through EventBus so LatticeWorld can react (spawn echoes, shift lighting).
## The scaffold ships one geometry: a 12x4x12 box with a floor, four walls,
## and a ceiling — enough to walk around while art is being made.
##

@export var chamber_id: StringName = &"chamber_prime"
@export var spawn_point_path: NodePath = ^"Spawn"

@onready var _spawn_point: Node3D = get_node_or_null(spawn_point_path)


func _ready() -> void:
	add_to_group(&"chamber")
	EventBus.chamber_entered.emit(chamber_id)
	call_deferred(&"_place_player_at_spawn")


func _exit_tree() -> void:
	EventBus.chamber_exited.emit(chamber_id)


func spawn_transform() -> Transform3D:
	return _spawn_point.global_transform if _spawn_point != null else global_transform


func _place_player_at_spawn() -> void:
	if _spawn_point == null:
		return
	var players := get_tree().get_nodes_in_group(&"player")
	if players.is_empty():
		return
	var p := players[0]
	if p is Node3D:
		(p as Node3D).global_transform = _spawn_point.global_transform
