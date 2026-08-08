class_name VfxPool
extends Node2D
## Pooled footstep / rewrite / overuse VFX with particle budget gate.

signal rejected_budget(kind: StringName, reason: StringName)

@export var reduce_fx: bool = false
@export var auto_configure: bool = true

var _pools: Dictionary = {} ## Kind -> ObjectPool
var _particles_live: int = 0
var _rejected: int = 0
var _profiler: FrameProfiler


func _ready() -> void:
	_profiler = FrameProfiler.new()
	if auto_configure:
		_ensure_pool(PooledVfx.Kind.FOOTSTEP, PerfBudget.VFX_FOOTSTEP_CAP, PerfBudget.VFX_FOOTSTEP_PREWARM)
		_ensure_pool(PooledVfx.Kind.REWRITE_BURST, PerfBudget.VFX_REWRITE_CAP, PerfBudget.VFX_REWRITE_PREWARM)
		_ensure_pool(PooledVfx.Kind.OVERUSE, PerfBudget.VFX_OVERUSE_CAP, PerfBudget.VFX_OVERUSE_PREWARM)


func set_profiler(profiler: FrameProfiler) -> void:
	_profiler = profiler


func set_reduce_fx(value: bool) -> void:
	reduce_fx = value


func play_footstep(at: Vector2, color: Color = Color(0.7, 0.75, 0.8, 0.8)) -> PooledVfx:
	if reduce_fx:
		return null
	return _play(PooledVfx.Kind.FOOTSTEP, at, color, 0.28, 2)


func play_rewrite(at: Vector2, color: Color = Color(0.9, 0.95, 1.0, 1.0)) -> PooledVfx:
	var duration: float = 0.25 if reduce_fx else PerfBudget.REWRITE_BURST_MAX_SEC
	var particles: int = 0 if reduce_fx else 48
	return _play(PooledVfx.Kind.REWRITE_BURST, at, color, duration, particles)


func play_overuse(at: Vector2, color: Color = Color("E85D4C")) -> PooledVfx:
	if reduce_fx:
		return null
	return _play(PooledVfx.Kind.OVERUSE, at, color, 0.4, 6)


func release_vfx(vfx: PooledVfx) -> void:
	if vfx == null:
		return
	_particles_live = maxi(0, _particles_live - vfx.particles_budget())
	var pool: ObjectPool = _pools.get(vfx.kind) as ObjectPool
	if pool != null:
		pool.release(vfx)


func release_all() -> void:
	for kind in _pools.keys():
		var pool: ObjectPool = _pools[kind] as ObjectPool
		pool.release_all()
	_particles_live = 0


func stats() -> Dictionary:
	var by_kind := {}
	var live_nodes := 0
	for kind in _pools.keys():
		var pool: ObjectPool = _pools[kind] as ObjectPool
		var s := pool.stats()
		by_kind[str(kind)] = s
		live_nodes += int(s["live"])
	return {
		"kind": "vfx",
		"reduce_fx": reduce_fx,
		"particles_live": _particles_live,
		"live_nodes": live_nodes,
		"rejected_budget": _rejected,
		"by_kind": by_kind,
	}


func _play(kind: PooledVfx.Kind, at: Vector2, color: Color, duration: float, particle_equiv: int) -> PooledVfx:
	if _profiler != null:
		_profiler.begin(&"vfx_acquire")
	if _particles_live + particle_equiv > PerfBudget.MAX_PARTICLES_LIVE:
		_rejected += 1
		rejected_budget.emit(_kind_name(kind), &"particles")
		if _profiler != null:
			_profiler.end(&"vfx_acquire")
		return null
	var pool := _ensure_pool(kind, _cap_for(kind), _prewarm_for(kind))
	if pool.live_count() >= pool.cap and pool.free_count() == 0:
		## steal-oldest path still allowed; particle budget updated on release of stolen via play overwrite
		pass
	var node := pool.acquire() as PooledVfx
	if node == null:
		_rejected += 1
		rejected_budget.emit(_kind_name(kind), &"cap")
		if _profiler != null:
			_profiler.end(&"vfx_acquire")
		return null
	## If reusing a live stolen node mid-effect, drop its old particle reservation.
	_particles_live = maxi(0, _particles_live - node.particles_budget())
	node.play(at, kind, color, duration, particle_equiv, reduce_fx)
	_particles_live += node.particles_budget()
	if not node.finished.is_connected(_on_vfx_finished):
		node.finished.connect(_on_vfx_finished)
	if _profiler != null:
		_profiler.end(&"vfx_acquire")
	return node


func _on_vfx_finished(vfx: PooledVfx) -> void:
	## release_vfx usually called by the node; keep hook for external listeners.
	pass


func _ensure_pool(kind: PooledVfx.Kind, pool_cap: int, prewarm: int) -> ObjectPool:
	if _pools.has(kind):
		return _pools[kind] as ObjectPool
	var pool := ObjectPool.new()
	pool.name = "Pool_%s" % _kind_name(kind)
	add_child(pool)
	var k := kind
	pool.configure(func() -> Node: return _factory(k), pool_cap, prewarm)
	_pools[kind] = pool
	return pool


func _factory(kind: PooledVfx.Kind) -> Node:
	var v := PooledVfx.new()
	v.kind = kind
	return v


func _cap_for(kind: PooledVfx.Kind) -> int:
	match kind:
		PooledVfx.Kind.REWRITE_BURST:
			return PerfBudget.VFX_REWRITE_CAP
		PooledVfx.Kind.OVERUSE:
			return PerfBudget.VFX_OVERUSE_CAP
		_:
			return PerfBudget.VFX_FOOTSTEP_CAP


func _prewarm_for(kind: PooledVfx.Kind) -> int:
	match kind:
		PooledVfx.Kind.REWRITE_BURST:
			return PerfBudget.VFX_REWRITE_PREWARM
		PooledVfx.Kind.OVERUSE:
			return PerfBudget.VFX_OVERUSE_PREWARM
		_:
			return PerfBudget.VFX_FOOTSTEP_PREWARM


func _kind_name(kind: PooledVfx.Kind) -> StringName:
	match kind:
		PooledVfx.Kind.REWRITE_BURST:
			return &"rewrite"
		PooledVfx.Kind.OVERUSE:
			return &"overuse"
		_:
			return &"footstep"
