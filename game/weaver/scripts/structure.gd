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
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.45)
	tw.tween_property(self, "scale", Vector2.ONE, 0.55)
	_stitch.width = 1.0
	tw.tween_property(_stitch, "width", 5.0, 0.5)
	tw.tween_property(_beam, "color", Color(0.38, 0.3, 0.2, 1), 0.5)
	tw.chain().tween_callback(func() -> void: _seated = true)
