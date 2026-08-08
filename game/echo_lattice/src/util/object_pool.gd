class_name ObjectPool
extends Node
## Generic node pool: prewarm, acquire, release, steal-oldest at cap.
## Children are pool-owned instances parented under this node.

signal acquired(item: Node)
signal released(item: Node)
signal stolen(item: Node)

@export var cap: int = 64
@export var prewarm_count: int = 0

var _factory: Callable = Callable()
var _free: Array[Node] = []
var _live: Array[Node] = [] ## oldest at front
var _instantiate_count: int = 0
var _acquire_count: int = 0
var _release_count: int = 0
var _steal_count: int = 0


func configure(factory: Callable, pool_cap: int, prewarm: int = 0) -> void:
	_factory = factory
	cap = maxi(1, pool_cap)
	prewarm_count = maxi(0, prewarm)
	prewarm_now()


func prewarm_now() -> void:
	while _free.size() + _live.size() < prewarm_count and _total() < cap:
		var item := _create()
		_deactivate(item)
		_free.append(item)


func acquire() -> Node:
	var item: Node = null
	if not _free.is_empty():
		item = _free.pop_back()
	elif _total() < cap:
		item = _create()
	else:
		item = _steal_oldest()
	if item == null:
		return null
	_activate(item)
	_live.append(item)
	_acquire_count += 1
	acquired.emit(item)
	return item


func release(item: Node) -> void:
	if item == null:
		return
	var idx := _live.find(item)
	if idx < 0:
		return
	_live.remove_at(idx)
	_deactivate(item)
	_free.append(item)
	_release_count += 1
	released.emit(item)


func release_all() -> void:
	while not _live.is_empty():
		release(_live[_live.size() - 1])


func live_count() -> int:
	return _live.size()


func free_count() -> int:
	return _free.size()


func stats() -> Dictionary:
	return {
		"cap": cap,
		"live": _live.size(),
		"free": _free.size(),
		"total": _total(),
		"instantiate_count": _instantiate_count,
		"acquire_count": _acquire_count,
		"release_count": _release_count,
		"steal_count": _steal_count,
	}


func _total() -> int:
	return _free.size() + _live.size()


func _create() -> Node:
	assert(_factory.is_valid(), "ObjectPool factory not configured")
	var item: Node = _factory.call()
	assert(item != null)
	add_child(item)
	_instantiate_count += 1
	return item


func _steal_oldest() -> Node:
	if _live.is_empty():
		return null
	var item: Node = _live.pop_front()
	_deactivate(item)
	_steal_count += 1
	stolen.emit(item)
	return item


func _activate(item: Node) -> void:
	if item is CanvasItem:
		(item as CanvasItem).visible = true
	if item.has_method("pool_activate"):
		item.call("pool_activate")
	elif "process_mode" in item:
		item.process_mode = Node.PROCESS_MODE_INHERIT


func _deactivate(item: Node) -> void:
	if item.has_method("pool_deactivate"):
		item.call("pool_deactivate")
	if item is CanvasItem:
		(item as CanvasItem).visible = false
	if "process_mode" in item:
		item.process_mode = Node.PROCESS_MODE_DISABLED
