extends Node2D
## Playable MVP stub field: void gap → collect Fragments → combine → weave Structure.

const FragmentScene := preload("res://scenes/fragment.tscn")
const StructureScene := preload("res://scenes/structure.tscn")

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


func _ready() -> void:
	Loom.reset()
	Loom.fragments_changed.connect(_on_fragments_changed)
	Loom.threads_changed.connect(_on_threads_changed)
	Loom.prompt_changed.connect(_on_prompt_changed)
	Loom.structure_seated.connect(_on_structure_seated)
	_on_fragments_changed(0)
	_on_threads_changed(0)
	_on_prompt_changed("Walk the frayed field. Collect Fragments near the void.")
	_spawn_fragments()
	_thread_preview.visible = false
	if has_node("%VoidZone"):
		var zone: Area2D = %VoidZone
		zone.body_entered.connect(_on_void_entered)
		zone.body_exited.connect(_on_void_exited)


func _spawn_fragments() -> void:
	var specs: Array = [
		{"family": "Span", "accent": Color(0.45, 0.36, 0.24), "pos": Vector2(280, 360)},
		{"family": "Anchor", "accent": Color(0.28, 0.26, 0.22), "pos": Vector2(360, 480)},
		{"family": "Channel", "accent": Color(0.35, 0.45, 0.42), "pos": Vector2(980, 340)},
		{"family": "Charge", "accent": Color(0.72, 0.38, 0.18), "pos": Vector2(1040, 500)},
	]
	for spec in specs:
		var frag: Area2D = FragmentScene.instantiate()
		frag.family = spec["family"]
		frag.accent = spec["accent"]
		frag.position = spec["pos"]
		_spawn_root.add_child(frag)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("combine"):
		if Loom.combine_two_into_thread():
			_flash_thread_bind()
		_refresh_thread_preview()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("weave"):
		_try_weave()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/main.tscn")
		get_viewport().set_input_as_handled()


func _try_weave() -> void:
	if not Loom.can_weave():
		if Loom.structure_built:
			Loom.prompt_changed.emit("Structure already seated. Esc returns to title.")
		elif Loom.thread_count <= 0:
			Loom.prompt_changed.emit("Spin a Thread first (collect 2 Fragments, press C).")
		return
	if not _near_void:
		Loom.prompt_changed.emit("Step closer to the void gap, then press Space to weave.")
		return
	Loom.seat_structure()


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
	## Chalk provisional Thread draw from player toward the void — motion budget beat.
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
	# Fade the frayed void fill — gap is stitched.
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_void_fill, "modulate:a", 0.15, 0.6)
	tw.tween_property(_void_root, "modulate", Color(0.95, 0.9, 0.8, 1), 0.6)
	_dust.emitting = true
	_structure_node = StructureScene.instantiate()
	_structure_node.position = _structure_anchor.position
	add_child(_structure_node)
	if _structure_node.has_method("play_seat"):
		_structure_node.play_seat()
