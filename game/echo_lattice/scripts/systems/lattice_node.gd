class_name LatticeNode
extends Resource
##
## One node in the Echo Lattice graph.
##
## The lattice is a graph of chambers and the connections between them. Each
## LatticeNode has an id (matching SceneRouter.CHAMBER_SCENES), a scene path,
## and a list of neighbour ids reachable from it. LatticeWorld holds the
## graph; SceneRouter walks it.
##

@export var id: StringName = &""
@export var display_name: String = ""
@export var scene_path: String = ""
@export var neighbours: Array[StringName] = []

## Which habit kinds, when repeated, cause this node to "resonate" — i.e.
## spawn echoes when the player enters.
@export var resonant_habits: Array[StringName] = []
