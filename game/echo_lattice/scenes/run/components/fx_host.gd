class_name FxHost
extends Node2D
## Drop under Run/World/FX. Owns FossilPool + VfxPool and exposes step/rewrite hooks.
## Core/juice agents call these instead of instantiating FX nodes.

@export var reduce_fx: bool = false
@export var cell_size: Vector2 = Vector2(32, 32)

var fossils: FossilPool
var vfx: VfxPool
var profiler: FrameProfiler


func _ready() -> void:
	profiler = FrameProfiler.new()
	profiler.enabled = OS.is_debug_build()

	fossils = FossilPool.new()
	fossils.name = "FossilPool"
	fossils.cell_size = cell_size
	add_child(fossils)
	fossils.set_profiler(profiler)

	vfx = VfxPool.new()
	vfx.name = "VfxPool"
	vfx.reduce_fx = reduce_fx
	add_child(vfx)
	vfx.set_profiler(profiler)


func set_reduce_fx(value: bool) -> void:
	reduce_fx = value
	if vfx != null:
		vfx.set_reduce_fx(value)


func set_fossil_style_provider(provider: Callable) -> void:
	if fossils != null:
		fossils.set_style_provider(provider)


func on_step_committed(cell: Vector2i, world_pos: Vector2) -> void:
	fossils.age_roles()
	fossils.spawn_at(cell, PooledFossil.Role.FRESH)
	vfx.play_footstep(world_pos)


func on_rewrite(world_pos: Vector2, buffer_cells: Array) -> void:
	profiler.begin(&"rewrite_fx")
	fossils.repaint_from_buffer(buffer_cells, false)
	vfx.play_rewrite(world_pos)
	profiler.end(&"rewrite_fx", PerfBudget.REWRITE_COMPUTE_MS)


func on_chamber_reset() -> void:
	fossils.release_all()
	vfx.release_all()


func perf_stats() -> Dictionary:
	return {
		"fossils": fossils.stats() if fossils else {},
		"vfx": vfx.stats() if vfx else {},
		"profiler": profiler.snapshot() if profiler else {},
	}
