extends Node2D
## Span Structure across the void — seats, then emits Fragments (loop close).

signal request_spawn_fragment(kind: String, at: Vector2)

@onready var _beam: Polygon2D = $Beam
@onready var _stitch: Line2D = $Stitch
@onready var _label: Label = $Label
@onready var _posts: Node2D = $Posts

var emit_interval: float = 3.5
var _elapsed: float = 0.0
var _seated: bool = false


func _ready() -> void:
	_label.text = "Span Structure"
	modulate.a = 0.0
	scale = Vector2(0.85, 0.85)
	var structure: Dictionary = Loom.recipes.get("structure", {})
	emit_interval = float(structure.get("emit_interval_sec", 3.5))
	add_to_group("structures")


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
		_stitch.default_color = Color(0.953, 0.925, 0.855, 0.85)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate:a", 1.0, 0.16)
	tw.parallel().tween_property(self, "scale", Vector2(1.02, 1.06), 0.22)
	tw.parallel().tween_property(self, "position:y", rest_y - 8.0, 0.22)
	tw.tween_property(self, "scale", Vector2.ONE, 0.26)
	tw.parallel().tween_property(self, "position:y", rest_y, 0.26)
	if _stitch:
		tw.parallel().tween_property(_stitch, "width", 3.2, 0.26)
		tw.parallel().tween_property(_stitch, "default_color", Color(0.11, 0.094, 0.078, 1), 0.26)
	if _beam:
		tw.parallel().tween_property(_beam, "color", Color(0.42, 0.325, 0.251, 1), 0.26)
	tw.tween_callback(func() -> void: _seated = true)
