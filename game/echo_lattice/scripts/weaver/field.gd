extends Node2D
## Playable field hosted by Echo Lattice Main: void gap → gather → combine → weave → emit.
## Esc returns through Main (menu_requested) — does not hard-swap the Godot project main scene.

signal menu_requested

const FragmentScene := preload("res://scenes/weaver/fragment.tscn")
const StructureScene := preload("res://scenes/weaver/structure.tscn")
const CombinePanelScene := preload("res://scenes/weaver/ui/combine_panel.tscn")

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
	elif event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause_menu"):
		if _combine_panel != null and _combine_panel.visible:
			return
		menu_requested.emit()
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
	for i in 6:
		await get_tree().process_frame
	if Loom.pending_screenshot:
		await _capture_screenshot("02_thread_ready.png")
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
		await _capture_screenshot("03_structure_standing.png")
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
