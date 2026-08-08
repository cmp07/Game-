class_name FossilPool
extends Node2D
## Pooled path fossils (move-buffer heat / ghost stamps). Cap + steal-oldest.
## Colors: prefer AccessibilityService.fossil_style when available.

@export var cell_size: Vector2 = Vector2(32, 32)
@export var auto_configure: bool = true

var _pool: ObjectPool
var _style_provider: Callable = Callable() ## (role:int) -> Dictionary {color, pattern}
var _profiler: FrameProfiler


func _ready() -> void:
	_pool = ObjectPool.new()
	_pool.name = "ObjectPool"
	add_child(_pool)
	if auto_configure:
		_pool.configure(_factory, PerfBudget.MAX_FOSSILS_LIVE, PerfBudget.FOSSIL_PREWARM)
	_profiler = FrameProfiler.new()


func set_style_provider(provider: Callable) -> void:
	_style_provider = provider


func set_profiler(profiler: FrameProfiler) -> void:
	_profiler = profiler


func spawn_at(cell: Vector2i, role: PooledFossil.Role = PooledFossil.Role.FRESH, ttl: float = -1.0) -> PooledFossil:
	if _profiler != null:
		_profiler.begin(&"fossil_acquire")
	var node := _pool.acquire() as PooledFossil
	if node == null:
		if _profiler != null:
			_profiler.end(&"fossil_acquire")
		return null
	var style := _style_for(role)
	node.setup(cell, cell_size, role, style["color"], int(style["pattern"]), ttl)
	if _profiler != null:
		_profiler.end(&"fossil_acquire")
	return node


func release_fossil(fossil: PooledFossil) -> void:
	_pool.release(fossil)


func release_all() -> void:
	_pool.release_all()


## Age live fossils: FRESH→WARM→COLD. Avoids release+acquire churn each step.
func age_roles() -> void:
	for child in _pool.get_children():
		if child is PooledFossil and (child as PooledFossil).is_pool_alive():
			var f := child as PooledFossil
			var next := f.role
			match f.role:
				PooledFossil.Role.FRESH:
					next = PooledFossil.Role.WARM
				PooledFossil.Role.WARM:
					next = PooledFossil.Role.COLD
				_:
					next = f.role
			if next != f.role:
				var style := _style_for(next)
				f.promote_role(next, style["color"], int(style["pattern"]))


## Repaint from a list of cells (newest last). Releases existing first.
func repaint_from_buffer(cells: Array, ghost: bool = false) -> void:
	release_all()
	var n: int = mini(cells.size(), PerfBudget.MAX_FOSSILS_LIVE)
	var start: int = cells.size() - n
	for i in range(start, cells.size()):
		var cell: Vector2i = cells[i] as Vector2i
		var role := PooledFossil.Role.GHOST if ghost else _role_for_index(i - start, n)
		spawn_at(cell, role)


func stats() -> Dictionary:
	var s := _pool.stats()
	s["kind"] = "fossil"
	return s


func _factory() -> Node:
	return PooledFossil.new()


func _role_for_index(i: int, total: int) -> PooledFossil.Role:
	if total <= 1:
		return PooledFossil.Role.FRESH
	var t := float(i) / float(total - 1)
	if t > 0.75:
		return PooledFossil.Role.FRESH
	if t > 0.35:
		return PooledFossil.Role.WARM
	return PooledFossil.Role.COLD


func _style_for(role: PooledFossil.Role) -> Dictionary:
	if _style_provider.is_valid():
		var styled: Variant = _style_provider.call(int(role))
		if typeof(styled) == TYPE_DICTIONARY:
			var d: Dictionary = styled
			return {
				"color": d.get("color", _fallback_color(role)),
				"pattern": int(d.get("pattern", 1)),
			}
	return {"color": _fallback_color(role), "pattern": 1}


func _fallback_color(role: PooledFossil.Role) -> Color:
	## Defaults aligned with FossilPalette DEFAULT (a11y sibling); override via provider.
	match role:
		PooledFossil.Role.FRESH:
			return Color("5CE1FF")
		PooledFossil.Role.WARM:
			return Color("3AA0C8")
		PooledFossil.Role.COLD:
			return Color("2A5F78")
		PooledFossil.Role.GHOST:
			return Color("F0E6A8")
		PooledFossil.Role.OVERUSE:
			return Color("E85D4C")
		PooledFossil.Role.CHECKPOINT:
			return Color("FFFFFF")
		_:
			return Color.WHITE
