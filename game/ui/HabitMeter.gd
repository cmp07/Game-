extends Control
## HabitMeter — a vertical 0..100 gauge with a "readable window" band.
## Pulses gently when the value moves; flashes red when the value leaves the
## readable window.

@export var target_low: float = 35.0
@export var target_high: float = 65.0
@export var accent: Color = Color(0.486275, 0.976471, 1.0, 1)
@export var warn: Color = Color(1, 0.716, 0.298, 1)
@export var bad: Color = Color(1, 0.478, 0.541, 1)
@export var track: Color = Color(0.109804, 0.145098, 0.211765, 1)
@export var band: Color = Color(0.486275, 0.976471, 1.0, 0.16)

@onready var _label_value: Label = %Value
@onready var _label_caption: Label = %Caption
@onready var _bar: Control = %Bar

var _value: float = 50.0
var _flash: float = 0.0


func _ready() -> void:
	GameState.habit_changed.connect(_on_habit_changed)
	_value = GameState.habit
	_bar.queue_redraw()
	_refresh_labels()
	_bar.draw.connect(_draw_bar)


func _on_habit_changed(v: float, delta: float) -> void:
	_value = v
	if delta != 0.0 and not Accessibility.reduce_motion():
		_flash = clampf(_flash + minf(1.0, absf(delta) * 0.1), 0.0, 1.0)
	_refresh_labels()
	_bar.queue_redraw()


func _process(delta: float) -> void:
	if _flash > 0.0:
		_flash = maxf(0.0, _flash - delta * 2.0)
		_bar.queue_redraw()


func _refresh_labels() -> void:
	_label_value.text = "%d" % int(round(_value))
	if _value < target_low:
		_label_caption.text = "BRITTLE"
		_label_caption.modulate = warn
	elif _value > target_high:
		_label_caption.text = "OSSIFIED"
		_label_caption.modulate = bad
	else:
		_label_caption.text = "STEADY"
		_label_caption.modulate = accent


func _draw_bar() -> void:
	var s := _bar.size
	if s.x <= 0 or s.y <= 0:
		return
	var track_rect := Rect2(Vector2.ZERO, s)
	_bar.draw_rect(track_rect, track, true)
	_bar.draw_rect(track_rect, Color(0.168627, 0.227451, 0.333333, 1), false, 1.0)

	# Readable window band.
	var band_top := s.y * (1.0 - target_high / 100.0)
	var band_bottom := s.y * (1.0 - target_low / 100.0)
	_bar.draw_rect(Rect2(Vector2(1, band_top), Vector2(s.x - 2, band_bottom - band_top)), band, true)

	# Fill height.
	var v := clampf(_value / 100.0, 0.0, 1.0)
	var fill_h := s.y * v
	var fill_top := s.y - fill_h
	var color := _fill_color()
	color.a = 0.9
	_bar.draw_rect(Rect2(Vector2(2, fill_top), Vector2(s.x - 4, fill_h)), color, true)

	# Highlight scanline.
	_bar.draw_line(Vector2(0, fill_top), Vector2(s.x, fill_top), Color(color, 1.0), 2.0, true)

	# Flash overlay.
	if _flash > 0.0:
		var flash_color := Color(1, 1, 1, _flash * 0.35)
		_bar.draw_rect(track_rect, flash_color, true)

	# Target markers.
	for target: float in [target_low, target_high]:
		var y: float = s.y * (1.0 - target / 100.0)
		_bar.draw_line(Vector2(-4, y), Vector2(s.x + 4, y), Color(1, 1, 1, 0.35), 1.0, true)


func _fill_color() -> Color:
	if _value < target_low: return warn
	if _value > target_high: return bad
	return accent
