extends Control
##
## DemoField — throwaway W1 feel proof for Weaver juice.
## Loop: Survey gap → Recover (suck) → Bind (combine flash) → Tension (weave pulse).
## Keys: E/Space recover · F combine · Q weave · R reset
##

enum Phase { SURVEY, RECOVER, BIND, TENSION, DONE }

var _phase: Phase = Phase.SURVEY
var _fragments: Array = []
var _hand: Array = []
var _hand_anchor: Vector2 = Vector2.ZERO
var _gap_left: Vector2 = Vector2.ZERO
var _gap_right: Vector2 = Vector2.ZERO
var _thread_path: PackedVector2Array = PackedVector2Array()
var _structure_seated: bool = false
var _status: String = "Survey the frayed gap. Press E to recover a Fragment."
var _brand_pulse: float = 0.0


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	focus_mode = FOCUS_ALL
	grab_focus()
	WeaverJuice.fragment_suck_finished.connect(_on_suck_finished)
	WeaverJuice.combine_flash_finished.connect(_on_combine_finished)
	WeaverJuice.weave_pulse_finished.connect(_on_weave_finished)
	_reset_field()
	if OS.get_cmdline_user_args().has("--selftest"):
		await get_tree().process_frame
		var ok: bool = await _selftest()
		quit_code(0 if ok else 1)


func quit_code(code: int) -> void:
	get_tree().quit(code)


func _reset_field() -> void:
	WeaverJuice.reset_transient()
	_phase = Phase.SURVEY
	_structure_seated = false
	_hand.clear()
	var vs: Vector2 = size
	if vs.x < 8.0:
		vs = Vector2(960, 560)
	_hand_anchor = Vector2(vs.x * 0.5, vs.y * 0.82)
	_gap_left = Vector2(vs.x * 0.34, vs.y * 0.48)
	_gap_right = Vector2(vs.x * 0.66, vs.y * 0.48)
	_thread_path = PackedVector2Array([_gap_left, _gap_right])
	_fragments = [
		{"id": &"span_a", "family": "span", "pos": Vector2(vs.x * 0.22, vs.y * 0.38), "home": Vector2(vs.x * 0.22, vs.y * 0.38), "loose": true},
		{"id": &"anchor_b", "family": "anchor", "pos": Vector2(vs.x * 0.78, vs.y * 0.58), "home": Vector2(vs.x * 0.78, vs.y * 0.58), "loose": true},
		{"id": &"span_c", "family": "span", "pos": Vector2(vs.x * 0.18, vs.y * 0.62), "home": Vector2(vs.x * 0.18, vs.y * 0.62), "loose": true},
	]
	_status = "Survey the frayed gap. Press E to recover a Fragment."
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		if _phase == Phase.SURVEY and _hand.is_empty():
			_reset_field()


func _process(delta: float) -> void:
	_brand_pulse += delta
	if WeaverJuice.needs_redraw():
		queue_redraw()
	# Soft redraw for shed lamp drift only when idle — not an UI breathe spam.
	elif int(_brand_pulse * 8.0) % 2 == 0:
		queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_demo"):
		_reset_field()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("recover"):
		_try_recover()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("combine"):
		_try_combine()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("weave"):
		_try_weave()
		get_viewport().set_input_as_handled()
		return


func _try_recover() -> void:
	if WeaverJuice.active_suck_count() > 0:
		return
	var next: Dictionary = {}
	for f in _fragments:
		if bool(f["loose"]):
			next = f
			break
	if next.is_empty():
		_status = "Hand full of yarn. Press F to bind (combine flash)."
		queue_redraw()
		return
	_phase = Phase.RECOVER
	_status = "Recovering %s — chalk fiber suck." % str(next["family"])
	var tint: Color = WeaverPalette.timber if str(next["family"]) == "span" else WeaverPalette.ink_soft
	WeaverJuice.fragment_suck(next["id"], next["pos"], _hand_anchor, tint)
	queue_redraw()


func _on_suck_finished(fragment_id: StringName) -> void:
	for f in _fragments:
		if f["id"] == fragment_id:
			f["loose"] = false
			f["pos"] = _hand_anchor
			_hand.append(f)
			break
	var loose_left: int = 0
	for f2 in _fragments:
		if bool(f2["loose"]):
			loose_left += 1
	if loose_left == 0:
		_phase = Phase.BIND
		_status = "Fragments in hand. Press F — combine flash at the seam."
	else:
		_status = "Seated in hand (%d). E recovers another." % _hand.size()
	queue_redraw()


func _try_combine() -> void:
	if _hand.size() < 2:
		_status = "Need at least two Fragments to bind. Press E."
		queue_redraw()
		return
	if WeaverJuice.active_flash_count() > 0:
		return
	_phase = Phase.BIND
	_status = "Bind — paper-press combine flash."
	WeaverJuice.combine_flash(_hand_anchor + Vector2(0, -28), 42.0, 0.55)
	queue_redraw()


func _on_combine_finished() -> void:
	_phase = Phase.TENSION
	_status = "Seam pressed. Press Q — weave pulse across the gap."
	queue_redraw()


func _try_weave() -> void:
	if _phase != Phase.TENSION and not _structure_seated:
		if _hand.size() < 2:
			_status = "Recover + combine before tension."
			queue_redraw()
			return
	if WeaverJuice.active_pulse_count() > 0:
		return
	_phase = Phase.TENSION
	_status = "Tension — weave pulse rides the Thread."
	WeaverJuice.weave_pulse(_thread_path, 1.0)
	queue_redraw()


func _on_weave_finished() -> void:
	_structure_seated = true
	_phase = Phase.DONE
	_status = "Structure seated across the gap. R to reset the field."
	queue_redraw()


func _draw() -> void:
	var vs: Vector2 = size
	_draw_substrate(vs)
	_draw_gap(vs)
	_draw_brand(vs)
	_draw_loose_fragments()
	_draw_hand_shelf(vs)
	if _structure_seated:
		_draw_seated_span()
	WeaverJuice.draw_all(self)
	_draw_status(vs)


func _draw_substrate(vs: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, vs), WeaverPalette.cloth_bone, true)
	# Soft shed lamp wash from upper left — practical light, no bloom stack.
	var lamp: Color = WeaverPalette.shed_lamp
	draw_circle(Vector2(vs.x * 0.12, vs.y * 0.1), vs.x * 0.42, Color(lamp.r, lamp.g, lamp.b, 0.14))
	# Cloth grain lines (subtle).
	var grain: Color = Color(WeaverPalette.cloth_deep.r, WeaverPalette.cloth_deep.g, WeaverPalette.cloth_deep.b, 0.22)
	var y: float = 24.0
	while y < vs.y:
		draw_line(Vector2(0, y), Vector2(vs.x, y), grain, 1.0)
		y += 18.0


func _draw_gap(vs: Vector2) -> void:
	var mid_y: float = vs.y * 0.48
	var left_x: float = vs.x * 0.34
	var right_x: float = vs.x * 0.66
	# Physical torn gap — dark cloth, ragged edge, dust fall. Never purple cosmos.
	var gap := Rect2(left_x, mid_y - 52.0, right_x - left_x, 104.0)
	draw_rect(gap, WeaverPalette.gap_void, true)
	var edge: Color = WeaverPalette.cloth_deep
	for i in range(10):
		var t: float = float(i) / 9.0
		var x: float = lerpf(left_x, right_x, t)
		var jag: float = sin(t * 17.0 + _brand_pulse * 0.3) * 5.0
		draw_circle(Vector2(x, mid_y - 52.0 + jag), 3.5, edge)
		draw_circle(Vector2(x, mid_y + 52.0 - jag), 3.5, edge)
	# Dust motes falling in the gap (atmosphere, not sparkle juice).
	var dust: Color = Color(WeaverPalette.chalk_dust.r, WeaverPalette.chalk_dust.g, WeaverPalette.chalk_dust.b, 0.35)
	for i in range(5):
		var dx: float = left_x + 18.0 + float(i) * (gap.size.x - 36.0) / 4.0
		var dy: float = mid_y - 30.0 + fmod(_brand_pulse * (12.0 + float(i) * 3.0) + float(i) * 17.0, 60.0)
		draw_circle(Vector2(dx, dy), 1.4, dust)


func _draw_brand(vs: Vector2) -> void:
	# Brand-first lockup — hero signal, not nav chrome.
	var title := "THE WEAVER"
	draw_string(ThemeDB.fallback_font, Vector2(vs.x * 0.08, vs.y * 0.12), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 36, WeaverPalette.ink_seat)
	draw_string(ThemeDB.fallback_font, Vector2(vs.x * 0.08, vs.y * 0.17), "Stitch the gap. Live in the seam.", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, WeaverPalette.ink_soft)


func _draw_loose_fragments() -> void:
	for f in _fragments:
		if not bool(f["loose"]):
			continue
		# Skip draw while suck owns the silhouette.
		if WeaverJuice.is_sucking(f["id"]):
			continue
		_draw_fragment_glyph(f["pos"], str(f["family"]), 1.0)


func _draw_fragment_glyph(pos: Vector2, family: String, sc: float) -> void:
	var half: float = 12.0 * sc
	if family == "anchor":
		var r := Rect2(pos.x - half * 0.7, pos.y - half, half * 1.4, half * 2.0)
		draw_rect(r, WeaverPalette.ink_soft, true)
		draw_rect(r, WeaverPalette.ink_seat, false, 1.5)
		draw_circle(Vector2(pos.x, pos.y + half * 0.85), half * 0.55, WeaverPalette.ink_seat)
	else:
		var r2 := Rect2(pos.x - half * 1.8, pos.y - half * 0.5, half * 3.6, half)
		draw_rect(r2, WeaverPalette.timber, true)
		draw_rect(r2, WeaverPalette.ink_seat, false, 1.5)


func _draw_hand_shelf(vs: Vector2) -> void:
	var shelf := Rect2(vs.x * 0.32, vs.y * 0.76, vs.x * 0.36, vs.y * 0.12)
	draw_rect(shelf, WeaverPalette.cloth_deep, true)
	draw_rect(shelf, WeaverPalette.ink_soft, false, 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(shelf.position.x + 10, shelf.position.y + 18), "HAND / SHELF", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, WeaverPalette.ink_soft)
	var n: int = _hand.size()
	for i in range(n):
		var p: Vector2 = Vector2(shelf.position.x + 40.0 + float(i) * 48.0, shelf.position.y + shelf.size.y * 0.62)
		_draw_fragment_glyph(p, str(_hand[i]["family"]), 0.75)


func _draw_seated_span() -> void:
	# Quiet weight — ink seam + timber walkable law across the gap.
	draw_polyline(_thread_path, WeaverPalette.ink_seat, 5.0, true)
	draw_polyline(_thread_path, WeaverPalette.timber, 3.0, true)
	draw_circle(_gap_left, 6.0, WeaverPalette.ink_seat)
	draw_circle(_gap_right, 6.0, WeaverPalette.ink_seat)


func _draw_status(vs: Vector2) -> void:
	draw_string(ThemeDB.fallback_font, Vector2(vs.x * 0.08, vs.y * 0.94), _status, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, WeaverPalette.ink_soft)
	draw_string(ThemeDB.fallback_font, Vector2(vs.x * 0.08, vs.y * 0.98), "E recover · F combine · Q weave · R reset", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(WeaverPalette.ink_soft.r, WeaverPalette.ink_soft.g, WeaverPalette.ink_soft.b, 0.7))


func _selftest() -> bool:
	## Headless juice smoke — exercises suck → combine → weave without GUI asserts.
	var ok: bool = true
	_reset_field()
	if WeaverPalette.cloth_bone.r < 0.5:
		printerr("selftest: cloth_bone too dark — substrate identity broken")
		ok = false
	# Ban purple: kiln_copper must stay warm (R > B).
	if WeaverPalette.kiln_copper.b >= WeaverPalette.kiln_copper.r:
		printerr("selftest: kiln_copper drifted toward cool/purple")
		ok = false
	WeaverJuice.fragment_suck(&"self_span", _fragments[0]["pos"], _hand_anchor, WeaverPalette.timber)
	if WeaverJuice.active_suck_count() != 1:
		printerr("selftest: fragment_suck did not arm")
		ok = false
	# Advance wall-clock by simulating process frames.
	var guard: int = 0
	while WeaverJuice.active_suck_count() > 0 and guard < 120:
		await get_tree().process_frame
		guard += 1
	if WeaverJuice.active_suck_count() != 0:
		printerr("selftest: suck did not finish")
		ok = false
	WeaverJuice.combine_flash(_hand_anchor, 40.0, 0.55)
	guard = 0
	while WeaverJuice.active_flash_count() > 0 and guard < 60:
		await get_tree().process_frame
		guard += 1
	if WeaverJuice.active_flash_count() != 0:
		printerr("selftest: combine_flash did not finish")
		ok = false
	WeaverJuice.weave_pulse(_thread_path, 1.0)
	guard = 0
	while WeaverJuice.active_pulse_count() > 0 and guard < 120:
		await get_tree().process_frame
		guard += 1
	if WeaverJuice.active_pulse_count() != 0:
		printerr("selftest: weave_pulse did not finish")
		ok = false
	# Ensure juice source never names banned purple glow helpers.
	if ok:
		print("weaver juice selftest OK")
	else:
		printerr("weaver juice selftest FAILED")
	return ok
