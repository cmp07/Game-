extends CharacterBody2D
## Weaver presence in the void — light silhouette, not a workshop figure.

@export var speed: float = 220.0

var _facing: float = 0.0
var _moving: bool = false


func _ready() -> void:
	if has_node("Body"):
		$Body.visible = false
	if has_node("Label"):
		$Label.visible = false
		$Label.text = ""
	queue_redraw()


func _physics_process(_delta: float) -> void:
	var typing := false
	var parent_void := get_parent()
	if parent_void != null and parent_void.has_node("%WordEdit"):
		var edit: LineEdit = parent_void.get_node("%WordEdit")
		typing = edit.has_focus()
	var dir := Vector2.ZERO
	if not typing:
		dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	move_and_slide()
	_moving = dir.length_squared() > 0.01
	if _moving:
		_facing = dir.angle()
	queue_redraw()


func _draw() -> void:
	var ink := Color(0.90, 0.92, 0.96, 0.95)
	var coat := Color(0.55, 0.60, 0.70, 1.0)
	var coat_lit := Color(0.78, 0.82, 0.90, 1.0)
	var strap := Color(0.72, 0.42, 0.28, 0.75)
	var shadow := Color(0.02, 0.03, 0.05, 0.4)
	var facing := Vector2.from_angle(_facing)
	var side := Vector2(-facing.y, facing.x)

	_draw_ellipse(Vector2(3, 14), Vector2(16, 7), shadow)

	draw_colored_polygon(PackedVector2Array([
		Vector2(-8, 10) + side * 2.0, Vector2(-2, 16), Vector2(-10, 16),
	]), ink)
	draw_colored_polygon(PackedVector2Array([
		Vector2(8, 10) - side * 2.0, Vector2(10, 16), Vector2(2, 16),
	]), ink)

	var body := PackedVector2Array([
		Vector2(0, -18) + facing * 2.0,
		Vector2(11, -6) + side * 3.0,
		Vector2(10, 12),
		Vector2(-10, 12),
		Vector2(-11, -6) - side * 3.0,
	])
	draw_colored_polygon(body, coat)
	var closed := PackedVector2Array(body)
	closed.append(body[0])
	draw_polyline(closed, ink, 1.4, true)
	draw_line(Vector2(0, -10), Vector2(0, 8), Color(ink.r, ink.g, ink.b, 0.45), 1.1, true)

	draw_colored_polygon(PackedVector2Array([
		Vector2(6, -2) + side * 4.0,
		Vector2(16, 0) + side * 4.0,
		Vector2(15, 10) + side * 3.0,
		Vector2(5, 9) + side * 3.0,
	]), coat_lit)
	draw_line(Vector2(-4, -12), Vector2(12, 2) + side * 3.0, strap, 1.6, true)

	draw_colored_polygon(PackedVector2Array([
		Vector2(-6, -26) + facing,
		Vector2(6, -26) + facing,
		Vector2(7, -16),
		Vector2(-7, -16),
	]), Color(0.82, 0.84, 0.90, 1.0))
	draw_rect(Rect2(Vector2(-6, -26) + facing, Vector2(12, 10)), ink, false, 1.2)

	if has_node("/root/Loom") and int(Loom.thread_count) > 0 and not Loom.structure_built:
		var hand := Vector2(10, 2) + facing * 8.0
		draw_line(hand, hand + facing * 14.0, ink, 2.2, true)
		var tip := hand + facing * 14.0
		draw_colored_polygon(PackedVector2Array([
			tip + Vector2(0, -3), tip + Vector2(3, 0), tip + Vector2(0, 3), tip + Vector2(-3, 0),
		]), Color(0.92, 0.90, 0.84, 0.95))


func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(14):
		var a: float = TAU * float(i) / 14.0
		pts.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(pts, color)
