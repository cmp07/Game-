class_name Player
extends CharacterBody2D

const RADIUS: float     = 12.0
const MAX_SPEED: float  = 220.0
const ACCEL: float      = 1600.0
const FRICTION: float   = 1800.0
const BODY_COLOR: Color = Color(0.95, 0.96, 1.00)
const RING_COLOR: Color = Color(0.55, 0.75, 1.00)

@export var input_locked: bool = false


func _ready() -> void:
	_build_body()


func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	if not input_locked:
		direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target: Vector2 = direction * MAX_SPEED
	var rate: float = ACCEL if direction != Vector2.ZERO else FRICTION
	velocity = velocity.move_toward(target, rate * delta)
	move_and_slide()


func snap_to(world_position: Vector2) -> void:
	velocity = Vector2.ZERO
	position = world_position


func _build_body() -> void:
	var col: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = RADIUS
	col.shape = circle
	add_child(col)

	var visual: Node2D = _PlayerVisual.new(RADIUS, BODY_COLOR, RING_COLOR)
	add_child(visual)


class _PlayerVisual extends Node2D:
	var _radius: float
	var _body_color: Color
	var _ring_color: Color

	func _init(radius: float, body_color: Color, ring_color: Color) -> void:
		_radius = radius
		_body_color = body_color
		_ring_color = ring_color

	func _draw() -> void:
		draw_circle(Vector2.ZERO, _radius, _body_color)
		draw_arc(Vector2.ZERO, _radius + 2.0, 0.0, TAU, 32, _ring_color, 1.5, true)
