extends Node
##
## HabitTracker
##
## Central store for repeated player behaviour. Every gameplay system emits
## `EventBus.habit_recorded(kind, payload)` when the player does something
## the lattice should notice ("stared at exit", "picked up a bell", "took the
## left corridor again"). This node aggregates those events, persists them,
## and exposes queries so LatticeWorld can turn habits into echoes.
##
## Persistence lives at `user://habits.save` (JSON). We keep the schema
## versioned so future migrations don't silently corrupt older saves.
##

const SAVE_PATH := "user://habits.save"
const SCHEMA_VERSION := 1

## Rolling in-memory history. Newest entries are appended to the end.
var _events: Array[Dictionary] = []

## kind (StringName) -> count (int). Cheap lookup for LatticeWorld heuristics.
var _kind_counts: Dictionary = {}

## Cap on retained events so a long play session doesn't unbounded-grow the log.
@export var max_events: int = 4096


func _ready() -> void:
	EventBus.habit_recorded.connect(_on_habit_recorded)
	_load()


func record(kind: StringName, payload: Dictionary = {}) -> void:
	## Convenience wrapper so gameplay code can call HabitTracker directly
	## when it isn't already going through EventBus.
	EventBus.habit_recorded.emit(kind, payload)


func count_of(kind: StringName) -> int:
	return int(_kind_counts.get(kind, 0))


func total_events() -> int:
	return _events.size()


func recent(limit: int = 32) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var start := maxi(0, _events.size() - limit)
	for i in range(start, _events.size()):
		out.append(_events[i])
	return out


func snapshot() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"run_id": GameState.run_id,
		"kind_counts": _kind_counts.duplicate(true),
		"events": _events.duplicate(true),
	}


func clear() -> void:
	_events.clear()
	_kind_counts.clear()
	_save()


# --- Persistence -------------------------------------------------------------


func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		push_warning("HabitTracker: could not open %s for read." % SAVE_PATH)
		return
	var text := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("HabitTracker: save file is not a dictionary; ignoring.")
		return
	var data: Dictionary = parsed
	if int(data.get("schema_version", 0)) != SCHEMA_VERSION:
		push_warning("HabitTracker: schema mismatch; ignoring old save.")
		return
	var loaded_events: Array = data.get("events", [])
	_events.clear()
	for e in loaded_events:
		if typeof(e) == TYPE_DICTIONARY:
			_events.append(e)
	_kind_counts = data.get("kind_counts", {}).duplicate(true)


func _save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("HabitTracker: could not open %s for write." % SAVE_PATH)
		return
	f.store_string(JSON.stringify(snapshot(), "\t"))
	f.close()


# --- Signal handlers ---------------------------------------------------------


func _on_habit_recorded(kind: StringName, payload: Dictionary) -> void:
	var entry := {
		"kind": String(kind),
		"payload": payload,
		"t": Time.get_ticks_msec(),
		"run_id": GameState.run_id,
	}
	_events.append(entry)
	if _events.size() > max_events:
		_events = _events.slice(_events.size() - max_events)
	_kind_counts[kind] = int(_kind_counts.get(kind, 0)) + 1
	_save()
