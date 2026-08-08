class_name Player
extends CharacterBody3D
##
## First-person Player controller.
##
## Movement is deliberately restrained (walk, crouch, short jump) — this is
## a tension vignette, not a mover-shooter. Anything expressive lives in
## Interact (E) and the systems that listen for it.
##
## Every relevant action also fires EventBus.habit_recorded so HabitTracker
## can turn behaviour into future echoes.
##

@export_group("Movement")
@export var walk_speed: float = 3.4
@export var crouch_speed: float = 1.7
@export var acceleration: float = 12.0
@export var friction: float = 14.0
@export var jump_velocity: float = 4.2

@export_group("Look")
@export var mouse_sensitivity: float = 0.0022
@export var pitch_limit_deg: float = 88.0

@export_group("Interaction")
@export var interact_range: float = 2.4

@onready var _yaw: Node3D = $Yaw
@onready var _pitch: Node3D = $Yaw/Pitch
@onready var _camera: Camera3D = $Yaw/Pitch/Camera3D
@onready var _interact_ray: RayCast3D = $Yaw/Pitch/Camera3D/InteractRay

var _focused_interactable: Node = null
var _is_crouching: bool = false


func _ready() -> void:
	add_to_group(&"player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventBus.player_spawned.emit(self)


func _exit_tree() -> void:
	EventBus.player_despawned.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion := event as InputEventMouseMotion
		_yaw.rotate_y(-motion.relative.x * mouse_sensitivity)
		_pitch.rotate_x(-motion.relative.y * mouse_sensitivity)
		var limit := deg_to_rad(pitch_limit_deg)
		_pitch.rotation.x = clamp(_pitch.rotation.x, -limit, limit)
	elif event.is_action_pressed(&"pause"):
		GameState.toggle_pause()
	elif event.is_action_pressed(&"interact"):
		_try_interact()


func _physics_process(delta: float) -> void:
	_apply_movement(delta)
	_update_focus()
	EventBus.player_moved.emit(global_position, velocity)


func _apply_movement(delta: float) -> void:
	var input_dir := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	var wish := Vector3(input_dir.x, 0.0, input_dir.y)
	wish = _yaw.transform.basis * wish
	wish.y = 0.0
	wish = wish.normalized() if wish.length() > 0.0 else Vector3.ZERO

	_is_crouching = Input.is_action_pressed(&"crouch")
	var target_speed := crouch_speed if _is_crouching else walk_speed
	var target_velocity := wish * target_speed

	var horizontal := Vector3(velocity.x, 0.0, velocity.z)
	if wish.length() > 0.0:
		horizontal = horizontal.move_toward(target_velocity, acceleration * delta)
	else:
		horizontal = horizontal.move_toward(Vector3.ZERO, friction * delta)

	velocity.x = horizontal.x
	velocity.z = horizontal.z

	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity", 9.81) * delta
	elif Input.is_action_just_pressed(&"jump"):
		velocity.y = jump_velocity
		HabitTracker.record(&"jumped", {"pos": global_position})

	move_and_slide()


func _update_focus() -> void:
	if _interact_ray == null:
		return
	var new_target: Node = null
	if _interact_ray.is_colliding():
		var col := _interact_ray.get_collider()
		if col is Node and col.is_in_group(&"interactable"):
			new_target = col
	if new_target == _focused_interactable:
		return
	if _focused_interactable != null:
		EventBus.interactable_unfocused.emit(_focused_interactable)
	_focused_interactable = new_target
	if _focused_interactable != null:
		EventBus.interactable_focused.emit(_focused_interactable)


func _try_interact() -> void:
	if _focused_interactable == null:
		return
	EventBus.interactable_used.emit(_focused_interactable, self)
	HabitTracker.record(&"interacted", {
		"target": String(_focused_interactable.name),
		"chamber": String(GameState.current_chamber_id),
	})
