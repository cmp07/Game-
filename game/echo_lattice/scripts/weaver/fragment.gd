extends Area2D
## Collectible material atom. Walk over + E (or auto-pickup on overlap).

@export var family: String = "Span"
@export var accent: Color = Color(0.42, 0.33, 0.22, 1)

@onready var _poly: Polygon2D = $Poly
@onready var _label: Label = $Label
@onready var _glow: Polygon2D = $Glow

var _player_inside: bool = false
var _taken: bool = false


func _ready() -> void:
	_label.text = family
	_poly.color = accent
	_glow.color = Color(accent.r, accent.g, accent.b, 0.22)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_pulse_in()


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
