extends Node2D
## One uttered word settled in the void as Fragment, Thread, or Law.

signal settled(matter: Node2D)

const KIND_FRAGMENT := 0
const KIND_THREAD := 1
const KIND_LAW := 2

var kind: int = KIND_FRAGMENT
var label: String = ""
var source_word: String = ""
var accent: Color = Color(0.45, 0.36, 0.24, 1)

var _body: Polygon2D
var _rim: Polygon2D
var _label: Label
var _pulse: float = 0.0
var _drift: Vector2 = Vector2.ZERO
var _thread_line: Line2D = null
var _linked_to: Node2D = null


func setup(p_kind: int, p_label: String, p_source: String, p_accent: Color) -> void:
	kind = p_kind
	label = p_label
	source_word = p_source
	accent = p_accent
	_build()


func link_thread_to(other: Node2D) -> void:
	_linked_to = other
	if _thread_line == null:
		_thread_line = Line2D.new()
		_thread_line.width = 2.5
		_thread_line.default_color = Color(accent.r, accent.g, accent.b, 0.65)
		_thread_line.z_index = -1
		add_child(_thread_line)
	_refresh_thread()


func _build() -> void:
	_rim = Polygon2D.new()
	_body = Polygon2D.new()
	_label = Label.new()
	add_child(_rim)
	add_child(_body)
	add_child(_label)
	match kind:
		KIND_FRAGMENT:
			_body.polygon = PackedVector2Array([-18, -12, 18, -12, 16, 14, -16, 14])
			_rim.polygon = PackedVector2Array([-26, -18, 26, -18, 24, 20, -24, 20])
			_rim.color = Color(accent.r, accent.g, accent.b, 0.22)
			_body.color = accent
			_label.text = label
		KIND_THREAD:
			_body.polygon = PackedVector2Array([-28, -4, 28, -4, 22, 6, -22, 6])
			_rim.polygon = PackedVector2Array([-34, -10, 34, -10, 28, 12, -28, 12])
			_rim.color = Color(0.72, 0.48, 0.30, 0.28)
			_body.color = Color(0.72, 0.47, 0.28, 1)
			_label.text = "%s Thread" % label
		KIND_LAW:
			_body.polygon = PackedVector2Array([-48, -10, 48, -10, 44, 14, -44, 14])
			_rim.polygon = PackedVector2Array([-56, -18, 56, -18, 52, 22, -52, 22])
			_rim.color = Color(0.35, 0.30, 0.24, 0.35)
			_body.color = Color(0.32, 0.28, 0.22, 1)
			_label.text = "LAW · %s" % label.to_upper()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 13 if kind != KIND_LAW else 15)
	_label.add_theme_color_override(
		"font_color",
		Color(0.94, 0.90, 0.82, 1)
	)
	_label.position = Vector2(-70, -10)
	_label.size = Vector2(140, 24)
	scale = Vector2(0.15, 0.15)
	modulate.a = 0.0
	_drift = Vector2(randf_range(-12.0, 12.0), randf_range(-8.0, 8.0))
	var tw := create_tween()
	tw.set_parallel(true)
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.42)
	tw.tween_property(self, "modulate:a", 1.0, 0.28)
	tw.chain().tween_callback(func() -> void: settled.emit(self))


func _process(delta: float) -> void:
	_pulse += delta
	position += _drift * delta * 0.35
	rotation = sin(_pulse * 0.7) * 0.03
	if kind == KIND_LAW:
		_rim.modulate.a = 0.55 + 0.2 * sin(_pulse * 2.0)
	_refresh_thread()


func _refresh_thread() -> void:
	if _thread_line == null or _linked_to == null or not is_instance_valid(_linked_to):
		return
	_thread_line.points = PackedVector2Array([Vector2.ZERO, to_local(_linked_to.global_position)])
