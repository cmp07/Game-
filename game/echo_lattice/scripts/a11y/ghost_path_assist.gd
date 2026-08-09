class_name GhostPathAssist
extends RefCounted
## Difficulty assist: reveal a suggested ghost path once per chamber.

signal ghost_revealed(path: Array)
signal ghost_denied(reason: String)
signal assist_reset(chamber_id: String)

var _a11y: Node = null
var _chamber_id: String = ""
var _used_this_chamber: bool = false
var _active_path: Array = []


func _init(accessibility_service: Node = null) -> void:
	_a11y = accessibility_service


func set_accessibility_service(service: Node) -> void:
	_a11y = service


func begin_chamber(chamber_id: String) -> void:
	_chamber_id = chamber_id
	_used_this_chamber = false
	_active_path.clear()
	assist_reset.emit(chamber_id)


func is_available() -> bool:
	return _enabled() and not _used_this_chamber


func was_used() -> bool:
	return _used_this_chamber


func active_ghost_path() -> Array:
	return _active_path.duplicate()


func try_reveal(path: Array) -> bool:
	if not _enabled():
		ghost_denied.emit("assist_disabled")
		return false
	if _used_this_chamber:
		ghost_denied.emit("already_used")
		return false
	if path.is_empty():
		ghost_denied.emit("empty_path")
		return false
	_used_this_chamber = true
	_active_path = path.duplicate()
	ghost_revealed.emit(_active_path)
	return true


func clear_paint() -> void:
	_active_path.clear()


func status() -> Dictionary:
	return {
		"chamber_id": _chamber_id,
		"enabled": _enabled(),
		"available": is_available(),
		"used": _used_this_chamber,
		"painted_len": _active_path.size(),
	}


func _enabled() -> bool:
	if _a11y != null and _a11y.has_method("show_ghost_path_once_enabled"):
		return bool(_a11y.call("show_ghost_path_once_enabled"))
	return false
