extends Area2D
## Collectible craft atom. T-post / plank silhouettes with weight — never labeled stamps.

@export var family: String = "Span"
@export var accent: Color = Color(0.42, 0.33, 0.22, 1)

var _player_inside: bool = false
var _taken: bool = false
var auto_collect: bool = true


func _enter_tree() -> void:
	if has_node("Poly"):
		$Poly.visible = false
	if has_node("Glow"):
		$Glow.visible = false
	if has_node("Label"):
		$Label.visible = false
		$Label.text = ""
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_pulse_in()
	queue_redraw()


func _draw() -> void:
	var ink := Color(0.110, 0.094, 0.078, 1.0)
	var body: Color = accent
	var shadow := Color(0.05, 0.04, 0.03, 0.32)
	if family == "Anchor":
		# T-post / stake — grounded mass, stamped port as a punched hole.
		draw_colored_polygon(PackedVector2Array([
			Vector2(-4, 16), Vector2(18, 20), Vector2(16, 26), Vector2(-10, 22),
		]), shadow)
		var post := PackedVector2Array([
			Vector2(-6, -22), Vector2(6, -22), Vector2(6, -4),
			Vector2(20, -4), Vector2(20, 6), Vector2(6, 6),
			Vector2(6, 22), Vector2(-6, 22), Vector2(-6, 6),
			Vector2(-20, 6), Vector2(-20, -4), Vector2(-6, -4),
		])
		draw_colored_polygon(post, body)
		var closed := PackedVector2Array(post)
		closed.append(post[0])
		draw_polyline(closed, ink, 1.6, true)
		draw_line(Vector2(-14, 0), Vector2(14, 0), Color(ink.r, ink.g, ink.b, 0.45), 1.0, true)
		draw_circle(Vector2(0, -10), 2.4, Color(0.165, 0.180, 0.173, 1.0))
		draw_arc(Vector2(0, -10), 3.2, 0.0, TAU, 10, ink, 1.1, true)
	else:
		# Span plank — length reads, end grain, one contact shadow.
		draw_colored_polygon(PackedVector2Array([
			Vector2(-18, 6), Vector2(24, 10), Vector2(22, 18), Vector2(-22, 14),
		]), shadow)
		var plank := PackedVector2Array([
			Vector2(-26, -9), Vector2(24, -6), Vector2(28, 9), Vector2(-22, 12),
		])
		draw_colored_polygon(plank, body)
		var closed2 := PackedVector2Array(plank)
		closed2.append(plank[0])
		draw_polyline(closed2, ink, 1.6, true)
		draw_line(Vector2(-14, -2), Vector2(16, 1), ink, 1.1, true)
		draw_line(Vector2(-10, 4), Vector2(18, 6), Color(ink.r, ink.g, ink.b, 0.4), 1.0, true)
		for k in range(3):
			var gy: float = -4.0 + float(k) * 5.0
			draw_line(Vector2(24, gy), Vector2(28, gy + 2.0), ink, 1.0, true)
		# Stamped capacity tick — not a word label.
		draw_rect(Rect2(-6, -3, 7, 5), Color(ink.r, ink.g, ink.b, 0.55), false, 1.1)


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
