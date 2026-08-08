class_name LogicalGrid
extends RefCounted
## Flat PackedByteArray grid with dirty AABB + double-buffer rewrite support.
## Source of truth for lattice ops; TileMap is baked via GridBake.

signal mutated(dirty: Rect2i)

var width: int = 0
var height: int = 0
var cells: PackedByteArray = PackedByteArray()
var scratch: PackedByteArray = PackedByteArray()

var dirty_min: Vector2i = Vector2i.ZERO
var dirty_max: Vector2i = Vector2i(-1, -1) ## empty when max < min
var key_count: int = 0
var door_count: int = 0
var checkpoint_count: int = 0


func resize(w: int, h: int, fill: int = GridTypes.Cell.EMPTY) -> void:
	assert(PerfBudget.grid_within_limits(w, h), "grid exceeds PerfBudget limits")
	width = w
	height = h
	var n := w * h
	cells = PackedByteArray()
	cells.resize(n)
	scratch = PackedByteArray()
	scratch.resize(n)
	for i in n:
		cells[i] = fill
		scratch[i] = fill
	key_count = 0
	door_count = 0
	checkpoint_count = 0
	clear_dirty()


func in_bounds(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < width and y < height


func index(x: int, y: int) -> int:
	return y * width + x


func get_cell(x: int, y: int) -> int:
	if not in_bounds(x, y):
		return GridTypes.Cell.WALL
	return int(cells[index(x, y)])


func get_cellv(p: Vector2i) -> int:
	return get_cell(p.x, p.y)


func set_cell(x: int, y: int, kind: int) -> void:
	if not in_bounds(x, y):
		return
	var i := index(x, y)
	var prev := int(cells[i])
	if prev == kind:
		return
	_adjust_counters(prev, -1)
	cells[i] = kind
	_adjust_counters(kind, 1)
	_mark_dirty(x, y)


func set_cellv(p: Vector2i, kind: int) -> void:
	set_cell(p.x, p.y, kind)


func fill_rect(rect: Rect2i, kind: int) -> void:
	var x0 := clampi(rect.position.x, 0, width)
	var y0 := clampi(rect.position.y, 0, height)
	var x1 := clampi(rect.position.x + rect.size.x, 0, width)
	var y1 := clampi(rect.position.y + rect.size.y, 0, height)
	for y in range(y0, y1):
		for x in range(x0, x1):
			set_cell(x, y, kind)


func is_walkable(x: int, y: int) -> bool:
	return GridTypes.is_walkable(get_cell(x, y))


## Writes up to 4 neighbor walkability flags into out_dirs (N,E,S,W as 0/1). No alloc.
func walkable_neighbors_into(x: int, y: int, out_dirs: PackedByteArray) -> void:
	if out_dirs.size() < 4:
		out_dirs.resize(4)
	for i in 4:
		var o: Vector2i = GridTypes.NEIGHBOR_OFFSETS[i]
		out_dirs[i] = 1 if is_walkable(x + o.x, y + o.y) else 0


func begin_rewrite() -> void:
	## Copy cells → scratch so operators can read old / write new without aliasing.
	scratch = cells.duplicate()


func set_scratch(x: int, y: int, kind: int) -> void:
	if not in_bounds(x, y):
		return
	scratch[index(x, y)] = kind
	_mark_dirty(x, y)


func commit_rewrite() -> void:
	## Swap buffers and recompute counters from scratch→cells.
	var tmp := cells
	cells = scratch
	scratch = tmp
	_recompute_counters()
	if has_dirty():
		mutated.emit(dirty_rect())


func clear_dirty() -> void:
	dirty_min = Vector2i.ZERO
	dirty_max = Vector2i(-1, -1)


func has_dirty() -> bool:
	return dirty_max.x >= dirty_min.x and dirty_max.y >= dirty_min.y


func dirty_rect() -> Rect2i:
	if not has_dirty():
		return Rect2i()
	return Rect2i(dirty_min, dirty_max - dirty_min + Vector2i.ONE)


func mark_all_dirty() -> void:
	if width <= 0 or height <= 0:
		clear_dirty()
		return
	dirty_min = Vector2i.ZERO
	dirty_max = Vector2i(width - 1, height - 1)


## FNV-1a 32-bit over cell bytes for determinism fixtures.
func hash_cells() -> int:
	var h: int = 2166136261
	for i in cells.size():
		h ^= int(cells[i])
		h = int((h * 16777619) & 0xFFFFFFFF)
	## Mix dimensions so 2x2 empty ≠ 4x1 empty.
	h ^= width
	h = int((h * 16777619) & 0xFFFFFFFF)
	h ^= height
	h = int((h * 16777619) & 0xFFFFFFFF)
	return h


func to_rows() -> Array:
	var rows: Array = []
	for y in height:
		var row: Array = []
		for x in width:
			row.append(get_cell(x, y))
		rows.append(row)
	return rows


func load_rows(rows: Array) -> void:
	assert(rows.size() > 0)
	var h: int = rows.size()
	var w: int = (rows[0] as Array).size()
	resize(w, h, GridTypes.Cell.EMPTY)
	for y in h:
		var row: Array = rows[y]
		for x in w:
			set_cell(x, y, int(row[x]))
	## Initial load: full dirty.
	mark_all_dirty()


func _mark_dirty(x: int, y: int) -> void:
	if not has_dirty():
		dirty_min = Vector2i(x, y)
		dirty_max = Vector2i(x, y)
		return
	dirty_min.x = mini(dirty_min.x, x)
	dirty_min.y = mini(dirty_min.y, y)
	dirty_max.x = maxi(dirty_max.x, x)
	dirty_max.y = maxi(dirty_max.y, y)


func _adjust_counters(kind: int, delta: int) -> void:
	match kind:
		GridTypes.Cell.KEY:
			key_count += delta
		GridTypes.Cell.DOOR, GridTypes.Cell.DOOR_OPEN:
			door_count += delta
		GridTypes.Cell.CHECKPOINT:
			checkpoint_count += delta


func _recompute_counters() -> void:
	key_count = 0
	door_count = 0
	checkpoint_count = 0
	for i in cells.size():
		_adjust_counters(int(cells[i]), 1)
