extends Area2D
## Collectible craft atom. Angular light geometry — never labeled stamps, never disc loot.

@export var family: String = "Span"
@export var accent: Color = Color(0.82, 0.84, 0.90, 1)

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
	var ink := Color(0.92, 0.94, 0.98, 0.85)
	var body: Color = accent
	var shadow := Color(0.02, 0.03, 0.05, 0.45)
	if family == "Anchor":
		# Anchor stake — angular mass, punched port as a diamond (not a disc).
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
		draw_polyline(closed, ink, 1.5, true)
		draw_line(Vector2(-14, 0), Vector2(14, 0), Color(ink.r, ink.g, ink.b, 0.45), 1.0, true)
		var port := PackedVector2Array([
			Vector2(0, -14), Vector2(3.5, -10), Vector2(0, -6), Vector2(-3.5, -10),
		])
		draw_colored_polygon(port, Color(0.02, 0.025, 0.04, 1.0))
		draw_polyline(PackedVector2Array([port[0], port[1], port[2], port[3], port[0]]), ink, 1.0, true)
	else:
		# Span shard — length reads as light geometry, not a timber plank.
		draw_colored_polygon(PackedVector2Array([
			Vector2(-18, 6), Vector2(24, 10), Vector2(22, 18), Vector2(-22, 14),
		]), shadow)
		var shard := PackedVector2Array([
			Vector2(-26, -6), Vector2(22, -10), Vector2(30, 2), Vector2(20, 12), Vector2(-20, 10),
		])
		draw_colored_polygon(shard, body)
		var closed2 := PackedVector2Array(shard)
		closed2.append(shard[0])
		draw_polyline(closed2, ink, 1.5, true)
		draw_line(Vector2(-14, -2), Vector2(16, -1), ink, 1.1, true)
		draw_line(Vector2(-10, 4), Vector2(18, 5), Color(ink.r, ink.g, ink.b, 0.4), 1.0, true)
		# Capacity tick — not a word label.
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
