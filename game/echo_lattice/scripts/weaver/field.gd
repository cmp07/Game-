extends Node2D
## Playable Weaver field: true void → recover → combine → weave → geometry fills.
## Esc returns through Main (menu_requested) — does not hard-swap the Godot project main scene.

signal menu_requested

const FragmentScene := preload("res://scenes/weaver/fragment.tscn")
const StructureScene := preload("res://scenes/weaver/structure.tscn")
const CombinePanelScene := preload("res://scenes/weaver/ui/combine_panel.tscn")

## Authored void field. Camera COVER-zooms this into the window —
## never 1:1 world pixels on a 1920×1080 capture (postage stamp + cream gutters).
const FIELD_SIZE := Vector2(1280, 720)
const FIELD_CENTER := Vector2(640, 360)
## Mild overscan so 16:9 stills and 16:10 Deck crop into the banks, not letterbox.
const FILL_OVERSCAN := 1.04

@onready var _prompt: Label = %Prompt
@onready var _hud_fragments: Label = %HudFragments
@onready var _hud_threads: Label = %HudThreads
@onready var _void_root: Node2D = %VoidGap
@onready var _void_fill: Polygon2D = %VoidFill
@onready var _spawn_root: Node2D = %FragmentSpawns
@onready var _structure_anchor: Marker2D = %StructureAnchor
@onready var _player: CharacterBody2D = %Player
@onready var _thread_preview: Line2D = %ThreadPreview
@onready var _thread_shadow: Line2D = get_node_or_null("%ThreadShadow")
@onready var _dust: CPUParticles2D = %Dust
@onready var _camera: Camera2D = $Camera2D
@onready var _lamp_rect: ColorRect = get_node_or_null("%Lamp")
@onready var _yard_art: Node2D = get_node_or_null("YardArt")
@onready var _gap_art: Node2D = get_node_or_null("%GapArt")

var _near_void: bool = false
var _structure_node: Node2D = null
var _combine_panel: CanvasLayer = null
var _creation_fill: float = 0.0
var _first_light: float = 0.07


func _ready() -> void:
	Loom.reset()
	Loom.fragments_changed.connect(_on_fragments_changed)
	Loom.threads_changed.connect(_on_threads_changed)
	Loom.prompt_changed.connect(_on_prompt_changed)
	Loom.structure_seated.connect(_on_structure_seated)
	_on_fragments_changed(0)
	_on_threads_changed(0)
	_on_prompt_changed("East Post Gap — recover Anchor + Span in the void (E / walk over).")
	_style_diegetic_hud()
	_bind_playfield_camera()
	_fill_window_with_field()
	_spawn_fragments()
	_sync_void_creation()
	_thread_preview.visible = false
	if _thread_shadow:
		_thread_shadow.visible = false
	if _lamp_rect != null and _lamp_rect.material is ShaderMaterial:
		_lamp_rect.material = (_lamp_rect.material as ShaderMaterial).duplicate()
	_combine_panel = CombinePanelScene.instantiate()
	add_child(_combine_panel)
	if has_node("%VoidZone"):
		var zone: Area2D = %VoidZone
		zone.body_entered.connect(_on_void_entered)
		zone.body_exited.connect(_on_void_exited)
	if Loom.pending_selftest:
		await _run_field_selftest()


func _spawn_fragments() -> void:
	# FIRST_FIVE fence: Anchor + Span only (two of each for a short retry).
	var specs: Array = [
		{"family": "Anchor", "accent": Color(0.78, 0.82, 0.90), "pos": Vector2(280, 360)},
		{"family": "Span", "accent": Color(0.90, 0.86, 0.74), "pos": Vector2(360, 480)},
		{"family": "Anchor", "accent": Color(0.78, 0.82, 0.90), "pos": Vector2(980, 340)},
		{"family": "Span", "accent": Color(0.90, 0.86, 0.74), "pos": Vector2(1040, 500)},
	]
	for spec in specs:
		spawn_fragment(str(spec["family"]), spec["pos"], spec["accent"])


func spawn_fragment(family: String, at: Vector2, accent: Color = Color(0.82, 0.84, 0.90, 1)) -> void:
	var frag: Area2D = FragmentScene.instantiate()
	frag.family = family
	frag.accent = accent
	_spawn_root.add_child(frag)
	frag.position = at


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("combine"):
		if _combine_panel != null and _combine_panel.visible:
			return
		Loom.request_combine_ui()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("weave"):
		_try_weave()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause_menu"):
		if _combine_panel != null and _combine_panel.visible:
			return
		menu_requested.emit()
		get_viewport().set_input_as_handled()


func _try_weave() -> void:
	if not Loom.can_weave():
		if Loom.structure_built and Loom.thread_count <= 0:
			Loom.prompt_changed.emit("Geometry stands in the void. Esc returns.")
		elif Loom.thread_count <= 0:
			Loom.prompt_changed.emit("Combine first (recover 2 Fragments, press C).")
		return
	if not _near_void:
		Loom.prompt_changed.emit("Step into the void well, then press Space to weave.")
		return
	if Loom.seat_structure():
		_flash_thread_bind()


func _on_void_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_near_void = true
		if Loom.can_weave():
			Loom.prompt_changed.emit("Void underfoot. Press Space — first light seats the Thread.")


func _on_void_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_near_void = false


func _style_diegetic_hud() -> void:
	## Light captions on the void — not glass HUD chrome, not shed chalk.
	for lab in [_hud_fragments, _hud_threads, _prompt]:
		if lab == null:
			continue
		lab.add_theme_color_override("font_color", Color(0.86, 0.88, 0.92, 0.92))
	if has_node("UI/Hud"):
		var hud: Control = $UI/Hud
		hud.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _nest_marks(count: int) -> String:
	var filled: int = clampi(count, 0, 3)
	var s := ""
	for i in range(3):
		s += "▣" if i < filled else "▢"
	return s


func _thread_marks(count: int) -> String:
	var n: int = clampi(count, 0, 4)
	var s := ""
	for i in range(4):
		s += "━" if i < n else "·"
	return s


func _on_fragments_changed(count: int) -> void:
	_hud_fragments.text = "nest  %s" % _nest_marks(count)
	_refresh_thread_preview()
	_sync_void_creation()


func _on_threads_changed(count: int) -> void:
	_hud_threads.text = "thread  %s" % _thread_marks(count)
	_refresh_thread_preview()
	_sync_void_creation()


func _on_prompt_changed(text: String) -> void:
	_prompt.text = text


func _sync_void_creation() -> void:
	## Void fills as the player creates: recover → combine → weave.
	var frags: int = Loom.fragment_inventory.size()
	var thread_n: int = int(Loom.thread_count)
	var seated: bool = bool(Loom.structure_built)
	var fill: float = 0.0
	fill += minf(float(frags) * 0.08, 0.28)
	fill += minf(float(thread_n) * 0.32, 0.36)
	if seated:
		fill = 1.0
	elif thread_n > 0:
		fill = maxf(fill, 0.48)
	_creation_fill = clampf(fill, 0.0, 1.0)
	var wake: float = 0.08 if frags > 0 else 0.0
	_first_light = clampf(0.07 + _creation_fill * 0.72 + wake, 0.05, 0.95)
	if _yard_art != null and _yard_art.has_method("set_creation_state"):
		_yard_art.set_creation_state(_creation_fill, _first_light)
	if _gap_art != null and _gap_art.has_method("set_creation_state"):
		_gap_art.set_creation_state(_creation_fill, _first_light)
	_apply_first_light_strength()


func _apply_first_light_strength() -> void:
	if _lamp_rect == null:
		return
	var mat := _lamp_rect.material as ShaderMaterial
	if mat == null:
		return
	mat.set_shader_parameter("strength", lerpf(0.06, 0.34, _first_light))


func _refresh_thread_preview() -> void:
	var taut := PackedVector2Array([Vector2(500, 360), Vector2(640, 352), Vector2(780, 358)])
	var shadow := PackedVector2Array([Vector2(498, 368), Vector2(642, 364), Vector2(782, 366)])
	if Loom.thread_count > 0 and not Loom.structure_built:
		_thread_preview.visible = true
		# Luminous filament across the void — not a slack neon bridge, not timber.
		_thread_preview.default_color = Color(0.90, 0.88, 0.82, 0.92)
		_thread_preview.width = 2.8
		_thread_preview.points = taut
		if _thread_shadow:
			_thread_shadow.visible = true
			_thread_shadow.points = shadow
	else:
		_thread_preview.visible = false
		if _thread_shadow:
			_thread_shadow.visible = false


func _flash_thread_bind() -> void:
	var chalk := Line2D.new()
	chalk.width = 1.5
	chalk.default_color = Color(0.92, 0.90, 0.84, 0.95)
	chalk.points = PackedVector2Array([_player.global_position, _structure_anchor.global_position])
	add_child(chalk)
	var tw := create_tween()
	tw.tween_property(chalk, "width", 3.2, 0.22)
	tw.tween_property(chalk, "modulate:a", 0.0, 0.28)
	tw.tween_callback(chalk.queue_free)
	if has_node("/root/WeaverJuice"):
		WeaverJuice.weave_pulse(PackedVector2Array([
			_player.global_position,
			_structure_anchor.global_position,
		]), 1.0)


func _on_structure_seated() -> void:
	_thread_preview.visible = false
	if _thread_shadow:
		_thread_shadow.visible = false
	_sync_void_creation()
	var tw := create_tween()
	tw.set_parallel(true)
	# Void does not bleach to cream — it fills with light geometry.
	tw.tween_property(_void_fill, "modulate", Color(0.55, 0.60, 0.70, 0.55), 0.7)
	tw.tween_property(_void_root, "modulate", Color(1.05, 1.02, 0.98, 1), 0.7)
	_dust.emitting = true
	if _structure_node != null and is_instance_valid(_structure_node):
		return
	_structure_node = StructureScene.instantiate()
	_structure_node.position = _structure_anchor.position
	add_child(_structure_node)
	if _structure_node.has_signal("request_spawn_fragment"):
		_structure_node.request_spawn_fragment.connect(_on_structure_emit)
	if _structure_node.has_method("play_seat"):
		_structure_node.play_seat()


func _on_structure_emit(kind: String, at: Vector2) -> void:
	var accent := Color(0.78, 0.82, 0.90) if kind == "Anchor" else Color(0.90, 0.86, 0.74)
	spawn_fragment(kind, at, accent)
	_sync_void_creation()


## Headless / screenshot helper: force weave without void proximity.
func debug_force_weave_at_anchor() -> bool:
	if not Loom.can_weave():
		if Loom.fragment_inventory.size() >= 2:
			Loom.combine_indices(0, 1)
		else:
			return false
	return Loom.seat_structure()


## Staged gameplay photo pack (gather→combine→weave→emit→wider).
## Writes PNGs into `out_dir` (must be absolute or under project for SEC-03 hosts).
func run_photo_beats(out_dir: String) -> bool:
	print("weaver-photos: field beats → %s" % out_dir)
	DirAccess.make_dir_recursive_absolute(out_dir)
	_freeze_fragments_auto_collect()
	# --- gather ---
	await _stage_gather_beat()
	await _capture_to(out_dir, "02_gather.png")
	# --- combine ---
	await _stage_combine_beat()
	await _capture_to(out_dir, "03_combine.png")
	if _combine_panel != null and _combine_panel.has_method("hide_panel"):
		_combine_panel.hide_panel()
	# --- weave ---
	await _stage_weave_beat()
	await _capture_to(out_dir, "04_weave.png")
	# --- structure emit ---
	await _stage_emit_beat()
	await _capture_to(out_dir, "05_structure_emit.png")
	# --- wider yard ---
	await _stage_wider_yard_beat()
	await _capture_to(out_dir, "06_wider_yard.png")
	# Legacy pair for docs/WEAVER/screenshots/
	var legacy := ProjectSettings.globalize_path("res://").path_join("../../docs/WEAVER/screenshots")
	DirAccess.make_dir_recursive_absolute(legacy)
	await _stage_legacy_void_beat()
	await _capture_to(legacy, "01_void_field.png")
	await _stage_wider_yard_beat()
	await _capture_to(legacy, "02_structure_standing.png")
	print("weaver-photos: field beats OK")
	return true


func _freeze_fragments_auto_collect() -> void:
	for child in _spawn_root.get_children():
		if child.has_method("set_auto_collect"):
			child.set_auto_collect(false)


func _clear_spawned_fragments() -> void:
	for child in _spawn_root.get_children():
		if child.has_method("debug_despawn"):
			child.debug_despawn()
		else:
			child.queue_free()


func _bind_playfield_camera() -> void:
	var vp: Viewport = get_viewport()
	if vp != null and not vp.size_changed.is_connected(_on_viewport_size_changed):
		vp.size_changed.connect(_on_viewport_size_changed)


func _on_viewport_size_changed() -> void:
	_fill_window_with_field()


func _fill_window_with_field(look: Vector2 = FIELD_CENTER) -> void:
	## COVER the window with East Post Gap void. HUD CanvasLayer then
	## sits on the field — not in a leftover folio / cream rail beside a plate.
	if _camera == null:
		return
	var vp: Vector2 = get_viewport().get_visible_rect().size
	if vp.x < 8.0 or vp.y < 8.0:
		vp = Vector2(960, 560)
	var zoom: float = maxf(vp.x / FIELD_SIZE.x, vp.y / FIELD_SIZE.y) * FILL_OVERSCAN
	zoom = maxf(zoom, 0.01)
	var vis: Vector2 = vp / zoom
	var cx: float = look.x
	var cy: float = look.y
	if vis.x >= FIELD_SIZE.x:
		cx = FIELD_CENTER.x
	else:
		var hx: float = vis.x * 0.5
		cx = clampf(look.x, hx, FIELD_SIZE.x - hx)
	if vis.y >= FIELD_SIZE.y:
		cy = FIELD_CENTER.y
	else:
		var hy: float = vis.y * 0.5
		cy = clampf(look.y, hy, FIELD_SIZE.y - hy)
	_camera.enabled = true
	_camera.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
	_camera.position = Vector2(cx, cy)
	_camera.zoom = Vector2(zoom, zoom)
	_sync_lamp_uv(Vector2(cx, cy), zoom)


func _sync_lamp_uv(center: Vector2, zoom: float) -> void:
	if _lamp_rect == null:
		return
	var mat := _lamp_rect.material as ShaderMaterial
	if mat == null:
		return
	var vp: Vector2 = get_viewport().get_visible_rect().size
	# First light lives in the void well center.
	var lamp_world := Vector2(640, 300)
	var screen: Vector2 = (lamp_world - center) * zoom + vp * 0.5
	mat.set_shader_parameter("lamp_uv", Vector2(
		screen.x / maxf(vp.x, 1.0),
		screen.y / maxf(vp.y, 1.0)
	))
	_apply_first_light_strength()


func _stage_gather_beat() -> void:
	Loom.reset()
	_clear_spawned_fragments()
	_structure_node = null
	_near_void = false
	_void_fill.modulate = Color(1, 1, 1, 1)
	_void_root.modulate = Color(1, 1, 1, 1)
	_thread_preview.visible = false
	if _thread_shadow:
		_thread_shadow.visible = false
	spawn_fragment("Anchor", Vector2(300, 360), Color(0.78, 0.82, 0.90))
	spawn_fragment("Span", Vector2(380, 470), Color(0.90, 0.86, 0.74))
	spawn_fragment("Anchor", Vector2(980, 340), Color(0.78, 0.82, 0.90))
	spawn_fragment("Span", Vector2(1040, 500), Color(0.90, 0.86, 0.74))
	_freeze_fragments_auto_collect()
	# One Fragment already in hand; player stands at the next recover.
	Loom.add_fragment("Anchor")
	_player.global_position = Vector2(340, 450)
	_fill_window_with_field(Vector2(380, 430))
	_sync_void_creation()
	Loom.prompt_changed.emit("Gather — recover the Span beside you (E / walk over).")
	for i in 10:
		await get_tree().process_frame


func _stage_combine_beat() -> void:
	Loom.reset()
	_clear_spawned_fragments()
	spawn_fragment("Anchor", Vector2(980, 340), Color(0.78, 0.82, 0.90))
	spawn_fragment("Span", Vector2(1040, 500), Color(0.90, 0.86, 0.74))
	_freeze_fragments_auto_collect()
	Loom.add_fragment("Anchor")
	Loom.add_fragment("Span")
	_player.global_position = Vector2(520, 400)
	_fill_window_with_field()
	_sync_void_creation()
	if _combine_panel != null and _combine_panel.has_method("stage_photo_selection"):
		_combine_panel.stage_photo_selection([0, 1])
	else:
		Loom.request_combine_ui()
	Loom.prompt_changed.emit("Combine — spin Anchor + Span into a Brace Thread.")
	for i in 12:
		await get_tree().process_frame


func _stage_weave_beat() -> void:
	Loom.reset()
	_clear_spawned_fragments()
	spawn_fragment("Anchor", Vector2(980, 340), Color(0.78, 0.82, 0.90))
	spawn_fragment("Span", Vector2(1040, 500), Color(0.90, 0.86, 0.74))
	_freeze_fragments_auto_collect()
	Loom.add_fragment("Anchor")
	Loom.add_fragment("Span")
	var combo := Loom.combine_indices(0, 1)
	if not combo.get("ok", false):
		printerr("weaver-photos: weave staging combine failed")
		return
	_near_void = true
	_player.global_position = Vector2(640, 400)
	_fill_window_with_field()
	_refresh_thread_preview()
	_sync_void_creation()
	_flash_thread_bind()
	Loom.prompt_changed.emit("Weave — seat the Thread across the void (Space). First light answers.")
	for i in 14:
		await get_tree().process_frame


func _stage_emit_beat() -> void:
	if not Loom.structure_built:
		if Loom.thread_count <= 0:
			Loom.reset()
			Loom.add_fragment("Anchor")
			Loom.add_fragment("Span")
			Loom.combine_indices(0, 1)
		debug_force_weave_at_anchor()
	_sync_void_creation()
	for i in 20:
		await get_tree().process_frame
	_player.global_position = Vector2(520, 420)
	_fill_window_with_field()
	var kind := Loom.emit_from_structure(_structure_anchor.global_position)
	if kind == "":
		kind = "Span"
	var emit_at := _structure_anchor.global_position + Vector2(70, 80)
	_on_structure_emit(kind, emit_at)
	_freeze_fragments_auto_collect()
	Loom.prompt_changed.emit("Structure emit — geometry sheds Fragments back into the void.")
	for i in 18:
		await get_tree().process_frame


func _stage_wider_yard_beat() -> void:
	if not Loom.structure_built:
		await _stage_emit_beat()
	# Extra fringe Fragments so the filled void reads as authored space.
	spawn_fragment("Anchor", Vector2(160, 180), Color(0.78, 0.82, 0.90))
	spawn_fragment("Span", Vector2(1120, 180), Color(0.90, 0.86, 0.74))
	spawn_fragment("Span", Vector2(180, 600), Color(0.90, 0.86, 0.74))
	_freeze_fragments_auto_collect()
	_player.global_position = Vector2(200, 560)
	_fill_window_with_field()
	_sync_void_creation()
	Loom.prompt_changed.emit("East Post Gap — Structure stands; creation filled the void.")
	for i in 12:
		await get_tree().process_frame


func _stage_legacy_void_beat() -> void:
	## Fresh void field (no structure) for the older screenshots pair.
	if _structure_node != null and is_instance_valid(_structure_node):
		_structure_node.queue_free()
		_structure_node = null
	Loom.reset()
	_clear_spawned_fragments()
	_void_fill.modulate = Color(1, 1, 1, 1)
	_void_root.modulate = Color(1, 1, 1, 1)
	_thread_preview.visible = false
	if _thread_shadow:
		_thread_shadow.visible = false
	_spawn_fragments()
	_freeze_fragments_auto_collect()
	_player.global_position = Vector2(220, 400)
	_fill_window_with_field()
	_sync_void_creation()
	Loom.prompt_changed.emit("East Post Gap — gather Anchor + Span in the void (E / walk over).")
	for i in 10:
		await get_tree().process_frame


func _run_field_selftest() -> void:
	print("weaver-selftest: begin")
	var api: Dictionary = Loom.api_selftest_result
	if not bool(api.get("ok", false)):
		printerr("weaver-selftest: loom API failed")
		get_tree().quit(1)
		return
	for i in 8:
		await get_tree().process_frame
	if Loom.pending_screenshot:
		await _capture_screenshot("01_void_field.png")
	Loom.reset()
	if not Loom.add_fragment("Anchor") or not Loom.add_fragment("Span"):
		printerr("weaver-selftest: gather failed")
		get_tree().quit(1)
		return
	var combo := Loom.combine_indices(0, 1)
	if not combo.get("ok", false):
		printerr("weaver-selftest: combine failed")
		get_tree().quit(1)
		return
	if not debug_force_weave_at_anchor():
		printerr("weaver-selftest: weave failed")
		get_tree().quit(1)
		return
	for i in 12:
		await get_tree().process_frame
	if get_tree().get_nodes_in_group("structures").is_empty():
		printerr("weaver-selftest: structure node missing")
		get_tree().quit(1)
		return
	if Loom.pending_screenshot:
		await _capture_screenshot("02_structure_standing.png")
	var emitted := Loom.emit_from_structure(global_position)
	if emitted == "":
		printerr("weaver-selftest: emit failed")
		get_tree().quit(1)
		return
	print("weaver-selftest: PASS phase=%s structures=%d log=%s" % [
		api.get("phase", "?"),
		api.get("structures", 0),
		str(api.get("log", [])),
	])
	Loom.pending_selftest = false
	get_tree().quit(0)


func _capture_screenshot(filename: String) -> void:
	var out_dir := ProjectSettings.globalize_path("res://").path_join("../../docs/WEAVER/screenshots")
	await _capture_to(out_dir, filename)


func _capture_to(out_dir: String, filename: String) -> void:
	for i in 4:
		await get_tree().process_frame
	var img: Image = get_viewport().get_texture().get_image()
	if img == null:
		printerr("weaver-screenshot: no image for %s" % filename)
		return
	DirAccess.make_dir_recursive_absolute(out_dir)
	var path := out_dir.path_join(filename)
	var err := img.save_png(path)
	if err != OK:
		printerr("weaver-screenshot: save failed %s (%s)" % [path, err])
		return
	print("weaver-screenshot: wrote %s" % path)
