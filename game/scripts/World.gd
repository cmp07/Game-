extends Node2D
## World background — animated lattice grid. Cheap, decorative, respectful of
## the "reduce motion" accessibility toggle.

@export var accent: Color = Color(0.486275, 0.976471, 1.0, 0.14)
@export var accent2: Color = Color(0.663, 0.522, 1.0, 0.10)
@export var grid_size: Vector2 = Vector2(80, 80)

var _time: float = 0.0


func _ready() -> void:
	set_process(true)


func _process(delta: float) -> void:
	if not Accessibility.reduce_motion():
		_time += delta
		queue_redraw()


func _draw() -> void:
	var vp := get_viewport_rect()
	var s := vp.size
	# Diagonal grid.
	var step := grid_size
	var offset := Vector2(fmod(_time * 12.0, step.x), fmod(_time * 8.0, step.y))
	for x in range(-1, int(s.x / step.x) + 3):
		var xp := x * step.x - offset.x
		var col := accent if x % 2 == 0 else accent2
		draw_line(Vector2(xp, 0), Vector2(xp, s.y), col, 1.0, true)
	for y in range(-1, int(s.y / step.y) + 3):
		var yp := y * step.y - offset.y
		var col := accent2 if y % 2 == 0 else accent
		draw_line(Vector2(0, yp), Vector2(s.x, yp), col, 1.0, true)
	# Big soft radial glow at the center.
	var center := s * 0.5
	for r in [220.0, 300.0, 400.0]:
		draw_arc(center, r, 0.0, TAU, 96, Color(accent, 0.06), 2.0, true)
