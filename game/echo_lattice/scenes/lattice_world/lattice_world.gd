class_name LatticeWorld
extends Node3D
##
## The meta-world that holds all chambers and the graph between them.
##
## In the scaffold, LatticeWorld:
##  1. Instances the currently-active Chamber under itself.
##  2. Spawns the Player and places it at the Chamber's spawn point.
##  3. Listens for habit_recorded events and, when a chamber's resonance
##     threshold is reached, spawns an Echo inside the current chamber.
##
## The graph itself is data-driven via `nodes`, a list of LatticeNode
## Resources authored in the editor. The scaffold ships a single node
## (chamber_prime) so play/test is not blocked on content.
##

const PlayerScene := preload("res://scenes/player/player.tscn")
const ChamberScene := preload("res://scenes/chamber/chamber.tscn")

@export var nodes: Array[LatticeNode] = []
@export var starting_node: StringName = &"chamber_prime"
@export var resonance_threshold: int = 3

var _current_chamber: Chamber = null
var _player: Player = null


func _ready() -> void:
	EventBus.habit_recorded.connect(_on_habit_recorded)
	_spawn_chamber(starting_node)
	_spawn_player()


func current_chamber() -> Chamber:
	return _current_chamber


func player() -> Player:
	return _player


func find_node(id: StringName) -> LatticeNode:
	for n in nodes:
		if n != null and n.id == id:
			return n
	return null


func _spawn_chamber(_id: StringName) -> void:
	## The scaffold only ships one chamber prefab; when the graph grows,
	## look up `id` in `nodes` and instance the matching scene.
	if _current_chamber != null and is_instance_valid(_current_chamber):
		_current_chamber.queue_free()
	var chamber := ChamberScene.instantiate() as Chamber
	add_child(chamber)
	_current_chamber = chamber


func _spawn_player() -> void:
	if _player != null and is_instance_valid(_player):
		return
	var p := PlayerScene.instantiate() as Player
	add_child(p)
	_player = p
	if _current_chamber != null:
		p.global_transform = _current_chamber.spawn_transform()


func _on_habit_recorded(kind: StringName, payload: Dictionary) -> void:
	if _current_chamber == null:
		return
	var lattice_node := find_node(_current_chamber.chamber_id)
	if lattice_node == null:
		return
	if not lattice_node.resonant_habits.has(kind):
		return
	if HabitTracker.count_of(kind) < resonance_threshold:
		return
	_spawn_echo(kind, payload)


func _spawn_echo(kind: StringName, payload: Dictionary) -> void:
	var echo := Echo.new()
	echo.kind = kind
	echo.payload = payload
	_current_chamber.add_child(echo)
	if _player != null:
		echo.global_position = _player.global_position + Vector3(0, 0.5, 0)
	echo.replay()
