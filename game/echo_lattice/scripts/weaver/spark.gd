extends Node2D
##
## One drifting spark — kiln copper mote, not neon rarity sparkle.
##

var _pulse_t: float = 0.0
var _bright: float = 1.0


func _ready() -> void:
	z_index = 5
	set_process(false)
	queue_redraw()


func set_pulse(t: float, bright: float = 1.0) -> void:
	_pulse_t = t
	_bright = bright
	queue_redraw()


func _draw() -> void:
	var breath: float = 0.85 + 0.15 * sin(_pulse_t * 2.4)
	var core := Color(0.769, 0.643, 0.416, 0.95 * breath * _bright)
	var halo := Color(0.545, 0.227, 0.122, 0.22 * breath * _bright)
	var tip := Color(0.953, 0.925, 0.855, 0.55 * breath)
	# Soft contact — one halo, not bloom stack.
	draw_circle(Vector2.ZERO, 10.0 * breath, halo)
	draw_circle(Vector2.ZERO, 4.2 * breath, core)
	draw_circle(Vector2(0.5, -0.8), 1.6, tip)
