extends CharacterBody2D
## Simple top-down mover for the Yard / field stub.

@export var speed: float = 220.0

@onready var _body: Polygon2D = $Body
@onready var _label: Label = $Label


func _ready() -> void:
	_label.text = "you"


func _physics_process(_delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	move_and_slide()
	if dir.length_squared() > 0.01:
		_body.rotation = dir.angle() + PI * 0.5
