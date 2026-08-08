extends Control
## Procedurally drawn lattice art — a subtle animated backdrop used on the main
## menu, win, and lose screens. Cheap to render and looks intentional.

@export var node_count: int = 7
@export var accent: Color = Color(0.486275, 0.976471, 1.0, 1.0)
@export var accent_secondary: Color = Color(0.663, 0.522, 1.0, 1.0)
@export var line_alpha: float = 0.28

var _time: float = 0.0
var _rng: RandomNumberGenerator


func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	_rng.seed = 91_234
	set_process(true)


func _process(delta: float) -> void:
	if Accessibility.reduce_motion():
		return
	_time += delta
	queue_redraw()


func _draw() -> void:
	var s := size
	if s.x <= 0 or s.y <= 0:
		return
	var center := s * 0.5
	var radius := minf(s.x, s.y) * 0.42

	# Concentric rings for depth cues.
	for i in range(3):
		var r := radius * (0.55 + 0.18 * i) + sin(_time * 0.3 + i) * 4.0
		draw_arc(center, r, 0.0, TAU, 48, Color(accent, 0.18 - 0.04 * i), 1.5, true)

	# Lattice nodes on a jittered ring.
	var points: Array[Vector2] = []
	for i in range(node_count):
		var a := TAU * i / node_count + _time * 0.08
		var jitter := _rng.randfn(0.0, 1.5)
		var p := center + Vector2.RIGHT.rotated(a) * (radius + jitter)
		points.append(p)

	# Edges — draw pairs based on a triangular sweep.
	for i in range(points.size()):
		for j in range(i + 1, points.size()):
			var a := points[i]
			var b := points[j]
			var w := 1.0
			var c := accent if (i + j) % 2 == 0 else accent_secondary
			c.a = line_alpha * (0.5 + 0.5 * sin(_time * 0.5 + i * 0.7 + j * 0.3))
			draw_line(a, b, c, w, true)

	for i in range(points.size()):
		var p := points[i]
		draw_circle(p, 5.0, Color(accent, 0.85))
		draw_arc(p, 9.0, 0.0, TAU, 24, Color(accent, 0.4), 1.0, true)

	# Central sigil.
	draw_circle(center, 6.0, Color(1, 1, 1, 0.9))
	draw_arc(center, 14.0, 0.0, TAU, 32, Color(accent_secondary, 0.7), 1.5, true)
