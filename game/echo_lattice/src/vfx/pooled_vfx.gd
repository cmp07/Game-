class_name PooledVfx
extends Node2D
## Short-lived pooled VFX node (footstep / rewrite burst / overuse spark).

enum Kind {
	FOOTSTEP,
	REWRITE_BURST,
	OVERUSE,
}

signal finished(vfx: PooledVfx)

var kind: Kind = Kind.FOOTSTEP
var ttl_sec: float = 0.35
var _alive: bool = false
var _particles_budget: int = 0
var _body: Polygon2D


func _ready() -> void:
	if _body == null:
		_body = Polygon2D.new()
		_body.polygon = PackedVector2Array([
			Vector2(-6, -6), Vector2(6, -6), Vector2(6, 6), Vector2(-6, 6),
		])
		add_child(_body)
	pool_deactivate()


func pool_activate() -> void:
	_alive = true
	visible = true
	set_process(true)


func pool_deactivate() -> void:
	_alive = false
	visible = false
	set_process(false)
	_particles_budget = 0
	modulate = Color.WHITE
	scale = Vector2.ONE


func is_pool_alive() -> bool:
	return _alive


func particles_budget() -> int:
	return _particles_budget


func play(at: Vector2, new_kind: Kind, color: Color, duration: float, particle_equiv: int = 0, reduce_fx: bool = false) -> void:
	kind = new_kind
	position = at
	modulate = color
	ttl_sec = duration
	_particles_budget = 0 if reduce_fx else maxi(0, particle_equiv)
	match new_kind:
		Kind.REWRITE_BURST:
			scale = Vector2.ONE * (1.0 if reduce_fx else 1.6)
		Kind.OVERUSE:
			scale = Vector2.ONE * 0.85
		_:
			scale = Vector2.ONE * 0.55
	pool_activate()


func _process(delta: float) -> void:
	if not _alive:
		return
	ttl_sec -= delta
	## Cheap fade — no tween alloc.
	var a: float = clampf(ttl_sec / 0.2, 0.0, 1.0)
	modulate.a = a
	if ttl_sec <= 0.0:
		finished.emit(self)
		var parent_pool := get_parent()
		if parent_pool != null and parent_pool.has_method("release_vfx"):
			parent_pool.call("release_vfx", self)
		else:
			pool_deactivate()
