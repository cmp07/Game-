extends Control
##
## Cold-boot Field Ledger title plate — paper stamp, then hand off to menu.
## No fade-from-black, no glow. Skip path owned by Main for tooling launches.
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

	ArtKit.draw_desk_margin(self, vp, 7, 0.06 * fade)

	var page := Rect2(vp.x * 0.18, vp.y * 0.22, vp.x * 0.64, vp.y * 0.56)
	ArtKit.draw_ledger_page(self, page, {
		"shadow_off": Vector2(6, 8),
		"grain_seed": 19,
		"grain_a": 0.07 * fade,
		"major_cell": 28,
		"rule_w": 2.0,
		"double_rule": true,
	})
	# Fade the page plate when exiting — modulate ink/bone via overlay wash.
	if fade < 0.999:
		var wash := Palette.PAPER_MARGIN
		wash.a = 1.0 - fade
		draw_rect(page, wash, true)

	var bone := Palette.PAPER_BONE
	bone.a = fade
	# Binder holes — diegetic notebook chrome.
	for i in range(4):
		var hy: float = page.position.y + 36.0 + float(i) * ((page.size.y - 72.0) / 3.0)
		var hc := Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.55 * fade)
		draw_circle(Vector2(page.position.x + 18.0, hy), 4.0, hc)
		draw_circle(Vector2(page.position.x + 18.0, hy), 2.2, Color(bone.r, bone.g, bone.b, fade))

	var display_f: Font = TypeKit.display_font() if has_node("/root/TypeKit") else ThemeDB.fallback_font
	var body_f: Font = TypeKit.body_font() if has_node("/root/TypeKit") else ThemeDB.fallback_font
	var brand_x: float = page.position.x + 48.0
	var brand_y: float = page.position.y + page.size.y * 0.42
	var title_c := Color(Palette.INK_BLACK.r, Palette.INK_BLACK.g, Palette.INK_BLACK.b, fade)
	draw_string(
		display_f,
		Vector2(brand_x, brand_y),
		tr("brand.title"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 56, title_c
	)
	var rust := Color(Palette.RUST_FOSSIL.r, Palette.RUST_FOSSIL.g, Palette.RUST_FOSSIL.b, fade)
	draw_rect(Rect2(brand_x, brand_y + 10.0, 380.0, 3.0), rust, true)
	var tag := Color(Palette.SLATE_TEAL.r, Palette.SLATE_TEAL.g, Palette.SLATE_TEAL.b, fade)
	draw_string(
		display_f,
		Vector2(brand_x, brand_y + 40.0),
		tr("brand.tagline"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 20, tag
	)
	var wing := Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.95 * fade)
	draw_string(
		body_f,
		Vector2(brand_x, brand_y + 68.0),
		tr("boot.wing_line"),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, wing
	)
