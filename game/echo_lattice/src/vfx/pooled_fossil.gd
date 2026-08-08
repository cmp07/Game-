class_name PooledFossil
extends Node2D
## One path-fossil stamp. Styled via FossilPalette roles (a11y); pooled — never free.

enum Role {
	FRESH,
	WARM,
	COLD,
	GHOST,
	OVERUSE,
	CHECKPOINT,
}

var cell: Vector2i = Vector2i.ZERO
var role: Role = Role.FRESH
var pattern_id: int = 0
var age_steps: int = 0
var ttl_sec: float = -1.0
var _alive: bool = false
var _sprite: Polygon2D


func _ready() -> void:
	if _sprite == null:
		_sprite = Polygon2D.new()
		_sprite.polygon = PackedVector2Array([
			Vector2(-4, -4), Vector2(4, -4), Vector2(4, 4), Vector2(-4, 4),
		])
		add_child(_sprite)
	pool_deactivate()


func pool_activate() -> void:
	_alive = true
	visible = true
	set_process(ttl_sec > 0.0)


func pool_deactivate() -> void:
	_alive = false
	visible = false
	set_process(false)
	ttl_sec = -1.0
	age_steps = 0
	modulate = Color.WHITE
	cell = Vector2i.ZERO


func is_pool_alive() -> bool:
	return _alive


func setup(at_cell: Vector2i, cell_size: Vector2, new_role: Role, color: Color, pattern: int = 0, ttl: float = -1.0) -> void:
	cell = at_cell
	role = new_role
	pattern_id = pattern
	ttl_sec = ttl
	age_steps = 0
	position = Vector2((float(at_cell.x) + 0.5) * cell_size.x, (float(at_cell.y) + 0.5) * cell_size.y)
	modulate = color
	_apply_pattern(pattern)
	pool_activate()


func promote_role(new_role: Role, color: Color, pattern: int = -1) -> void:
	role = new_role
	modulate = color
	if pattern >= 0:
		pattern_id = pattern
		_apply_pattern(pattern_id)
	age_steps += 1


func _process(delta: float) -> void:
	if ttl_sec < 0.0:
		return
	ttl_sec -= delta
	if ttl_sec <= 0.0:
		var parent_pool := get_parent()
		if parent_pool != null and parent_pool.has_method("release_fossil"):
			parent_pool.call("release_fossil", self)
		else:
			pool_deactivate()


func _apply_pattern(pattern: int) -> void:
	## Pattern channel mirrors FossilPalette.Pattern ints when a11y is present.
	## 0 NONE/SOLID, 1 SOLID, 2 STRIPES, 3 DOTS, 4 CROSSHATCH, 5 DASHES
	match pattern:
		2:
			scale = Vector2(1.0, 0.55)
			rotation = 0.0
		3:
			scale = Vector2(0.65, 0.65)
			rotation = 0.0
		4:
			scale = Vector2(0.9, 0.9)
			rotation = PI * 0.25
		5:
			scale = Vector2(1.15, 0.35)
			rotation = PI * 0.15
		_:
			scale = Vector2.ONE
			rotation = 0.0
