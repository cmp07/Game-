extends Node2D
## Placeholder Structure that seats across the void after a Thread is woven.

@onready var _beam: Polygon2D = $Beam
@onready var _stitch: Line2D = $Stitch
@onready var _label: Label = $Label
@onready var _posts: Node2D = $Posts


func _ready() -> void:
	_label.text = "Span Structure"
	modulate.a = 0.0
	scale = Vector2(0.85, 0.85)


func play_seat() -> void:
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.45)
	tw.tween_property(self, "scale", Vector2.ONE, 0.55)
	# Tension climb on the stitch line.
	_stitch.width = 1.0
	tw.tween_property(_stitch, "width", 5.0, 0.5)
	tw.tween_property(_beam, "color", Color(0.38, 0.3, 0.2, 1), 0.5)
