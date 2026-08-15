extends Node2D
## Span Structure across the void — luminous geometry that fills creation. No shed posts.

signal request_spawn_fragment(kind: String, at: Vector2)

@onready var _beam: Polygon2D = $Beam
@onready var _stitch: Line2D = $Stitch
@onready var _posts: Node2D = $Posts

var emit_interval: float = 3.5
var _elapsed: float = 0.0
var _seated: bool = false


func _ready() -> void:
	if has_node("Label"):
		$Label.visible = false
		$Label.text = ""
	modulate.a = 0.0
	scale = Vector2(0.85, 0.85)
	var structure: Dictionary = Loom.recipes.get("structure", {})
	emit_interval = float(structure.get("emit_interval_sec", 3.5))
	add_to_group("structures")
	# Hide timber posts — structure is light geometry now.
	if _posts:
		_posts.visible = false
	queue_redraw()


func _draw() -> void:
	var light := Color(0.92, 0.90, 0.84, 1.0)
	var geo := Color(0.70, 0.78, 0.90, 1.0)
	var shadow := Color(0.02, 0.03, 0.05, 0.4)
	# Soft contact under the span.
	draw_colored_polygon(PackedVector2Array([
		Vector2(-170, 10), Vector2(174, 6), Vector2(168, 28), Vector2(-176, 32),
	]), shadow)
	# Lattice ribs — evolving geometry, not warp threads on a loom.
	for i in range(6):
		var x: float = -100.0 + float(i) * 40.0
		draw_line(Vector2(x, -22), Vector2(x * 0.94, 18), Color(geo.r, geo.g, geo.b, 0.45), 1.2, true)
	draw_line(Vector2(-120, -4), Vector2(120, -2), Color(light.r, light.g, light.b, 0.55), 1.4, true)
	# Quiet kiln tick — ≤5%.
	draw_line(Vector2(40, -10), Vector2(70, -8), Color(0.72, 0.42, 0.28, 0.65), 2.0, true)
	# End nodes as diamonds, not nail circles.
	var l := PackedVector2Array([Vector2(-155, -28), Vector2(-148, -22), Vector2(-155, -16), Vector2(-162, -22)])
	var r := PackedVector2Array([Vector2(155, -28), Vector2(162, -22), Vector2(155, -16), Vector2(148, -22)])
	draw_colored_polygon(l, geo)
	draw_colored_polygon(r, light)


func _process(delta: float) -> void:
	if not _seated:
		return
	_elapsed += delta
	if _elapsed >= emit_interval:
		_elapsed = 0.0
		var kind := Loom.emit_from_structure(global_position)
		if kind != "":
			var offset := Vector2(randf_range(-90, 90), randf_range(40, 90))
			request_spawn_fragment.emit(kind, global_position + offset)


func play_seat() -> void:
	## Crease → lift → seat. Quiet weight — no portal, no bloom.
	var rest_y: float = position.y
	modulate.a = 0.4
	scale = Vector2(1.05, 0.74)
	position.y = rest_y + 8.0
	if _stitch:
		_stitch.width = 1.2
		_stitch.default_color = Color(0.92, 0.90, 0.84, 0.85)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate:a", 1.0, 0.16)
	tw.parallel().tween_property(self, "scale", Vector2(1.02, 1.06), 0.22)
	tw.parallel().tween_property(self, "position:y", rest_y - 8.0, 0.22)
	tw.tween_property(self, "scale", Vector2.ONE, 0.26)
	tw.parallel().tween_property(self, "position:y", rest_y, 0.26)
	if _stitch:
		tw.parallel().tween_property(_stitch, "width", 3.2, 0.26)
		tw.parallel().tween_property(_stitch, "default_color", Color(0.88, 0.90, 0.96, 1), 0.26)
	if _beam:
		tw.parallel().tween_property(_beam, "color", Color(0.72, 0.78, 0.90, 0.92), 0.26)
	tw.tween_callback(func() -> void: _seated = true)
