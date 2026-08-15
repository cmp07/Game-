extends Area2D
## Collectible craft atom. Family silhouettes — never default discs/orbs.

@export var family: String = "Span"
@export var accent: Color = Color(0.42, 0.33, 0.22, 1)

@onready var _poly: Polygon2D = $Poly
@onready var _label: Label = $Label
@onready var _glow: Polygon2D = $Glow

var _player_inside: bool = false
var _taken: bool = false
var auto_collect: bool = true


func _enter_tree() -> void:
	if has_node("Poly"):
		$Poly.visible = false
	if has_node("Glow"):
		$Glow.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_pulse_in()
	queue_redraw()


func _draw() -> void:
	var ink := Color(0.110, 0.094, 0.078, 1.0)
	var body: Color = accent
	if family == "Anchor":
		var post := PackedVector2Array([
			Vector2(-5, -18), Vector2(5, -18), Vector2(5, -3),
			Vector2(16, -3), Vector2(16, 5), Vector2(5, 5),
			Vector2(5, 18), Vector2(-5, 18), Vector2(-5, 5),
			Vector2(-16, 5), Vector2(-16, -3), Vector2(-5, -3),
		])
		draw_colored_polygon(post, body)
		var closed := PackedVector2Array(post)
		closed.append(post[0])
		draw_polyline(closed, ink, 1.4, true)
	else:
		var plank := PackedVector2Array([
			Vector2(-20, -7), Vector2(18, -5), Vector2(22, 7), Vector2(-16, 9),
		])
		draw_colored_polygon(plank, body)
		var closed2 := PackedVector2Array(plank)
		closed2.append(plank[0])
		draw_polyline(closed2, ink, 1.4, true)
		draw_line(Vector2(-10, -2), Vector2(12, 0), ink, 1.0, true)


## Photo / staging helper — remove without adding to inventory.
func debug_despawn() -> void:
	_taken = true
	monitoring = false
	queue_free()


func set_auto_collect(enabled: bool) -> void:
	auto_collect = enabled


func _pulse_in() -> void:
	scale = Vector2(0.2, 0.2)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.35)


func _process(_delta: float) -> void:
	if _taken:
		return
	if _player_inside and (
		Input.is_action_just_pressed("interact")
		or Input.is_action_just_pressed("recover")
		or Input.is_action_just_pressed("confirm")
	):
		_try_collect()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		# Auto-collect on touch for the stub — E still works if needed.
		if auto_collect:
			_try_collect()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false


func _try_collect() -> void:
	if _taken:
		return
	if not Loom.add_fragment(family):
		return
	_taken = true
	monitoring = false
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "scale", Vector2(0.05, 0.05), 0.2)
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	tw.chain().tween_callback(queue_free)
