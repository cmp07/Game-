class_name GridBake
extends RefCounted
## Dirty-rect bake from LogicalGrid → TileMapLayer (or dictionary stub for tests).
## Supports staged bake across frames when rewrite would exceed PerfBudget.

signal bake_started(rect: Rect2i)
signal bake_finished(rect: Rect2i, staged: bool)
signal stage_progress(done_rows: int, total_rows: int)

var tile_size: Vector2i = Vector2i(32, 32)
var halo: int = 0 ## expand dirty rect for autotile neighbors
var staging: bool = false
var _stage_grid: LogicalGrid
var _stage_rect: Rect2i
var _stage_row: int = 0
var _stage_target: Object ## TileMapLayer or bake sink
var _source_id: int = 0
var _atlas_for_kind: Dictionary = {} ## int kind -> Vector2i atlas coords
var _profiler: FrameProfiler
var cells_written_last: int = 0


func set_profiler(profiler: FrameProfiler) -> void:
	_profiler = profiler


func set_atlas_map(kind_to_atlas: Dictionary, source_id: int = 0) -> void:
	_atlas_for_kind = kind_to_atlas
	_source_id = source_id


## Immediate dirty bake. Returns cells written.
func bake(grid: LogicalGrid, target: Object = null) -> int:
	if grid == null or not grid.has_dirty():
		cells_written_last = 0
		return 0
	if _profiler != null:
		_profiler.begin(&"bake")
	var rect := _expand(grid.dirty_rect(), grid)
	bake_started.emit(rect)
	var written := _bake_rect(grid, target, rect)
	grid.clear_dirty()
	cells_written_last = written
	bake_finished.emit(rect, false)
	if _profiler != null:
		_profiler.end(&"bake", PerfBudget.REWRITE_COMPUTE_MS)
	return written


## Begin staged bake (row slices). Call `poll_stage` each frame until false.
func begin_staged(grid: LogicalGrid, target: Object = null) -> void:
	if grid == null or not grid.has_dirty():
		staging = false
		return
	_stage_grid = grid
	_stage_target = target
	_stage_rect = _expand(grid.dirty_rect(), grid)
	_stage_row = _stage_rect.position.y
	staging = true
	bake_started.emit(_stage_rect)


## Returns true while staging remains.
func poll_stage(max_rows: int = 8) -> bool:
	if not staging or _stage_grid == null:
		staging = false
		return false
	if _profiler != null:
		_profiler.begin(&"bake_stage")
	var y_end: int = mini(_stage_row + max_rows, _stage_rect.position.y + _stage_rect.size.y)
	var slice := Rect2i(
		Vector2i(_stage_rect.position.x, _stage_row),
		Vector2i(_stage_rect.size.x, y_end - _stage_row)
	)
	_bake_rect(_stage_grid, _stage_target, slice)
	_stage_row = y_end
	var total: int = _stage_rect.size.y
	var done: int = _stage_row - _stage_rect.position.y
	stage_progress.emit(done, total)
	if _profiler != null:
		_profiler.end(&"bake_stage", PerfBudget.REWRITE_COMPUTE_MS)
	if _stage_row >= _stage_rect.position.y + _stage_rect.size.y:
		_stage_grid.clear_dirty()
		cells_written_last = _stage_rect.size.x * _stage_rect.size.y
		bake_finished.emit(_stage_rect, true)
		staging = false
		_stage_grid = null
		_stage_target = null
		return false
	return true


## Test / headless sink: writes kind ints into Dictionary keyed by Vector2i.
static func make_dict_sink() -> Dictionary:
	return {}


func _bake_rect(grid: LogicalGrid, target: Object, rect: Rect2i) -> int:
	var written := 0
	var x0 := clampi(rect.position.x, 0, grid.width)
	var y0 := clampi(rect.position.y, 0, grid.height)
	var x1 := clampi(rect.position.x + rect.size.x, 0, grid.width)
	var y1 := clampi(rect.position.y + rect.size.y, 0, grid.height)
	for y in range(y0, y1):
		for x in range(x0, x1):
			var kind := grid.get_cell(x, y)
			_write_cell(target, x, y, kind)
			written += 1
	return written


func _write_cell(target: Object, x: int, y: int, kind: int) -> void:
	if target == null:
		return
	if typeof(target) == TYPE_DICTIONARY:
		(target as Dictionary)[Vector2i(x, y)] = kind
		return
	## TileMapLayer duck-typing: set_cell(coords, source_id, atlas_coords)
	if target.has_method("set_cell"):
		var atlas: Vector2i = _atlas_for_kind.get(kind, Vector2i(kind, 0))
		target.call("set_cell", Vector2i(x, y), _source_id, atlas)


func _expand(rect: Rect2i, grid: LogicalGrid) -> Rect2i:
	if rect.size == Vector2i.ZERO:
		return rect
	var pos := Vector2i(
		maxi(0, rect.position.x - halo),
		maxi(0, rect.position.y - halo)
	)
	var end := Vector2i(
		mini(grid.width, rect.position.x + rect.size.x + halo),
		mini(grid.height, rect.position.y + rect.size.y + halo)
	)
	return Rect2i(pos, end - pos)
