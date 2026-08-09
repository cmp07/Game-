extends Node2D
## Playable field: void gap → gather Fragments → combine UI → weave Structure → emit.

const FragmentScene := preload("res://scenes/fragment.tscn")
const StructureScene := preload("res://scenes/structure.tscn")
const CombinePanelScene := preload("res://scenes/ui/combine_panel.tscn")

@onready var _prompt: Label = %Prompt
@onready var _hud_fragments: Label = %HudFragments
@onready var _hud_threads: Label = %HudThreads
@onready var _void_root: Node2D = %VoidGap
@onready var _void_fill: Polygon2D = %VoidFill
@onready var _spawn_root: Node2D = %FragmentSpawns
@onready var _structure_anchor: Marker2D = %StructureAnchor
@onready var _player: CharacterBody2D = %Player
@onready var _thread_preview: Line2D = %ThreadPreview
@onready var _dust: CPUParticles2D = %Dust

var _near_void: bool = false
var _structure_node: Node2D = null
var _combine_panel: CanvasLayer = null


func _ready() -> void:
	Loom.reset()
	Loom.fragments_changed.connect(_on_fragments_changed)
	Loom.threads_changed.connect(_on_threads_changed)
	Loom.prompt_changed.connect(_on_prompt_changed)
	Loom.structure_seated.connect(_on_structure_seated)
	_on_fragments_changed(0)
	_on_threads_changed(0)
	_on_prompt_changed("East Post Gap — gather Anchor + Span (E / walk over).")
	_spawn_fragments()
	_thread_preview.visible = false
	_combine_panel = CombinePanelScene.instantiate()
	add_child(_combine_panel)
	if has_node("%VoidZone"):
		var zone: Area2D = %VoidZone
		zone.body_entered.connect(_on_void_entered)
		zone.body_exited.connect(_on_void_exited)
	if Loom.pending_selftest:
		await _run_field_selftest()
	elif Loom.pending_gameplay_demo:
		await _run_gameplay_demo()


func _spawn_fragments() -> void:
	# FIRST_FIVE fence: Anchor + Span only (two of each for a short retry).
	var specs: Array = [
		{"family": "Anchor", "accent": Color(0.28, 0.26, 0.22), "pos": Vector2(280, 360)},
		{"family": "Span", "accent": Color(0.45, 0.36, 0.24), "pos": Vector2(360, 480)},
		{"family": "Anchor", "accent": Color(0.28, 0.26, 0.22), "pos": Vector2(980, 340)},
		{"family": "Span", "accent": Color(0.45, 0.36, 0.24), "pos": Vector2(1040, 500)},
	]
	for spec in specs:
		spawn_fragment(str(spec["family"]), spec["pos"], spec["accent"])


func spawn_fragment(family: String, at: Vector2, accent: Color = Color(0.42, 0.33, 0.22, 1)) -> void:
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
	elif event.is_action_pressed("ui_cancel"):
		if _combine_panel != null and _combine_panel.visible:
			return
		get_tree().change_scene_to_file("res://scenes/main.tscn")
		get_viewport().set_input_as_handled()


func _try_weave() -> void:
	if not Loom.can_weave():
		if Loom.structure_built and Loom.thread_count <= 0:
			Loom.prompt_changed.emit("Structure stands and sheds Fragments. Esc returns to title.")
		elif Loom.thread_count <= 0:
			Loom.prompt_changed.emit("Spin a Thread first (collect 2 Fragments, press C).")
		return
	if not _near_void:
		Loom.prompt_changed.emit("Step closer to the void gap, then press Space to weave.")
		return
	if Loom.seat_structure():
		_flash_thread_bind()


func _on_void_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_near_void = true
		if Loom.can_weave():
			Loom.prompt_changed.emit("Void underfoot. Press Space to tension your Thread into a Structure.")


func _on_void_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_near_void = false


func _on_fragments_changed(count: int) -> void:
	_hud_fragments.text = "Fragments: %d" % count
	_refresh_thread_preview()


func _on_threads_changed(count: int) -> void:
	_hud_threads.text = "Threads: %d" % count
	_refresh_thread_preview()


func _on_prompt_changed(text: String) -> void:
	_prompt.text = text


func _refresh_thread_preview() -> void:
	if Loom.thread_count > 0 and not Loom.structure_built:
		_thread_preview.visible = true
		_thread_preview.default_color = Color(0.42, 0.28, 0.18, 0.55)
		_thread_preview.width = 3.0
	else:
		_thread_preview.visible = false


func _flash_thread_bind() -> void:
	var chalk := Line2D.new()
	chalk.width = 2.0
	chalk.default_color = Color(0.55, 0.5, 0.4, 0.9)
	chalk.points = PackedVector2Array([_player.global_position, _structure_anchor.global_position])
	add_child(chalk)
	var tw := create_tween()
	tw.tween_property(chalk, "width", 6.0, 0.25)
	tw.tween_property(chalk, "modulate:a", 0.0, 0.35)
	tw.tween_callback(chalk.queue_free)


func _on_structure_seated() -> void:
	_thread_preview.visible = false
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_void_fill, "modulate:a", 0.15, 0.6)
	tw.tween_property(_void_root, "modulate", Color(0.95, 0.9, 0.8, 1), 0.6)
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
	var accent := Color(0.28, 0.26, 0.22) if kind == "Anchor" else Color(0.45, 0.36, 0.24)
	spawn_fragment(kind, at, accent)


## Headless / screenshot helper: force weave without void proximity.
func debug_force_weave_at_anchor() -> bool:
	if not Loom.can_weave():
		if Loom.fragment_inventory.size() >= 2:
			Loom.combine_indices(0, 1)
		else:
			return false
	return Loom.seat_structure()


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
	for i in 4:
		await get_tree().process_frame
	var img: Image = get_viewport().get_texture().get_image()
	if img == null:
		printerr("weaver-screenshot: no image for %s" % filename)
		return
	var out_dir := ProjectSettings.globalize_path("res://").path_join("../../docs/WEAVER/screenshots")
	DirAccess.make_dir_recursive_absolute(out_dir)
	var path := out_dir.path_join(filename)
	var err := img.save_png(path)
	if err != OK:
		printerr("weaver-screenshot: save failed %s (%s)" % [path, err])
		return
	print("weaver-screenshot: wrote %s" % path)


## Paced gather→combine→weave for cloud / xvfb ffmpeg capture (`-- --gameplay-demo`).
## Does not quit — external recorder stops the process.
func _run_gameplay_demo() -> void:
	print("weaver-gameplay-demo: begin")
	_player.set_physics_process(false)
	_player.velocity = Vector2.ZERO
	for i in 20:
		await get_tree().process_frame
	await get_tree().create_timer(1.4).timeout

	Loom.prompt_changed.emit("DEMO · gather Anchor")
	await _demo_walk_to(Vector2(280, 360), 1.35)
	await _demo_collect_near(Vector2(280, 360))
	await get_tree().create_timer(0.7).timeout

	Loom.prompt_changed.emit("DEMO · gather Span")
	await _demo_walk_to(Vector2(360, 480), 1.2)
	await _demo_collect_near(Vector2(360, 480))
	await get_tree().create_timer(0.8).timeout

	Loom.prompt_changed.emit("DEMO · combine into Brace Thread")
	Loom.request_combine_ui()
	await get_tree().create_timer(1.1).timeout
	var i_a := Loom.fragment_inventory.find("Anchor")
	var i_s := Loom.fragment_inventory.find("Span")
	var combo: Dictionary = {}
	if i_a >= 0 and i_s >= 0:
		combo = Loom.combine_indices(i_a, i_s)
	elif Loom.fragment_inventory.size() >= 2:
		combo = Loom.combine_indices(0, 1)
	if not bool(combo.get("ok", false)):
		printerr("weaver-gameplay-demo: combine failed")
	if _combine_panel != null and _combine_panel.has_method("hide_panel"):
		await get_tree().create_timer(1.0).timeout
		_combine_panel.hide_panel()
	await get_tree().create_timer(0.6).timeout

	Loom.prompt_changed.emit("DEMO · weave at the void")
	await _demo_walk_to(Vector2(620, 360), 1.6)
	_near_void = true
	await get_tree().create_timer(0.45).timeout
	var woven := false
	if Loom.can_weave() and _near_void:
		woven = Loom.seat_structure()
		if woven:
			_flash_thread_bind()
	if not woven:
		# Fallback if proximity gate races the Area2D signals.
		woven = debug_force_weave_at_anchor()
	if not woven:
		printerr("weaver-gameplay-demo: weave failed")
	await get_tree().create_timer(2.2).timeout
	Loom.prompt_changed.emit("Structure seated — gather→combine→weave complete.")
	await _demo_walk_to(Vector2(520, 360), 0.9)
	await get_tree().create_timer(0.5).timeout
	await _demo_walk_to(Vector2(700, 360), 1.1)
	print("weaver-gameplay-demo: loop complete (holding for recorder)")
	# Hold for the rest of a ~25–30s capture window.
	await get_tree().create_timer(8.0).timeout
	Loom.pending_gameplay_demo = false
	print("weaver-gameplay-demo: done")


func _demo_walk_to(target: Vector2, duration: float) -> void:
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(_player, "global_position", target, duration)
	var face: Vector2 = target - _player.global_position
	if face.length_squared() > 1.0 and _player.has_node("Body"):
		(_player.get_node("Body") as Node2D).rotation = face.angle() + PI * 0.5
	await tw.finished
	for i in 4:
		await get_tree().physics_frame


func _demo_collect_near(at: Vector2) -> void:
	# Prefer the nearest loose Fragment (walking often auto-collects via Area2D).
	var best: Node2D = null
	var best_d := 999999.0
	for child in _spawn_root.get_children():
		if not is_instance_valid(child) or not (child is Node2D):
			continue
		if bool(child.get("_taken")):
			continue
		var d: float = (child as Node2D).global_position.distance_squared_to(at)
		if d < best_d:
			best_d = d
			best = child as Node2D
	if best == null:
		await get_tree().create_timer(0.2).timeout
		return
	if best.has_method("_try_collect"):
		best.call("_try_collect")
	await get_tree().create_timer(0.35).timeout
