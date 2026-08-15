extends Control
##
## Cold-boot stamp — STARRY BLACK VOID, then hand off to playable void minutes.
## No cream folio page. No fade-from-black through paper.
##

signal finished()

const HOLD_SEC: float = 1.15
const FADE_SEC: float = 0.22

var _t: float = 0.0
var _done: bool = false


func _ready() -> void:
	set_process(true)
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()


func _process(delta: float) -> void:
	if _done:
		return
	_t += delta
	# Allow click / confirm to skip after a short brand read.
	if _t >= 0.35 and (
		Input.is_action_just_pressed("ui_accept")
		or Input.is_action_just_pressed("ui_cancel")
		or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	):
		_finish()
		return
	if _t >= HOLD_SEC + FADE_SEC:
		_finish()
		return
	queue_redraw()


func _finish() -> void:
	if _done:
		return
	_done = true
	finished.emit()


func _draw() -> void:
	var vp: Vector2 = size
	if vp.x < 2.0:
		vp = get_viewport_rect().size

	var fade: float = 1.0
	if _t > HOLD_SEC:
		fade = clampf(1.0 - (_t - HOLD_SEC) / FADE_SEC, 0.0, 1.0)

	var far := Color(0.020, 0.023, 0.039, 1.0)
	draw_rect(Rect2(Vector2.ZERO, vp), far, true)
	_draw_stars(vp, fade)

	var y_lift: float = (1.0 - fade) * -10.0
	var brand_x: float = vp.x * 0.12
	var brand_y: float = vp.y * 0.46 + y_lift
	var title_c := Color(0.94, 0.90, 0.82, fade)
	var rust := Color(0.545, 0.227, 0.122, fade)
	var tag := Color(0.78, 0.74, 0.66, 0.88 * fade)
	var wing := Color(0.70, 0.66, 0.58, 0.85 * fade)

	draw_string(
		_type("display"),
		Vector2(brand_x, brand_y),
		tr("brand.title"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 56, title_c
	)
	draw_rect(Rect2(brand_x, brand_y + 10.0, minf(380.0, vp.x * 0.42), 3.0), rust, true)
	draw_string(
		_type("display"),
		Vector2(brand_x, brand_y + 40.0),
		tr("brand.tagline"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, tag
	)
	draw_string(
		_type("mono"),
		Vector2(brand_x, brand_y + 68.0),
		tr("boot.wing_line"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, wing
	)
	# One spark — the only given.
	var spark_at := Vector2(vp.x * 0.78, vp.y * 0.42 + y_lift)
	var breath: float = 0.85 + 0.15 * sin(_t * 2.4)
	draw_circle(spark_at, 14.0 * breath, Color(0.545, 0.227, 0.122, 0.28 * fade))
	draw_circle(spark_at, 5.0 * breath, Color(0.769, 0.643, 0.416, 0.95 * fade))


func _draw_stars(vp: Vector2, fade: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 17
	var star := Color(0.953, 0.925, 0.855, 1.0)
	for i in range(70):
		var p := Vector2(rng.randf() * vp.x, rng.randf() * vp.y)
		var a: float = rng.randf_range(0.16, 0.65) * fade
		draw_circle(p, rng.randf_range(0.6, 1.6), Color(star.r, star.g, star.b, a))


func _type(role: String = "display") -> Font:
	if has_node("/root/LedgerType"):
		return LedgerType.font_or_fallback(role)
	return ThemeDB.fallback_font
