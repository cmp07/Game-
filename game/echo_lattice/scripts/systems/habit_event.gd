class_name HabitEvent
extends Resource
##
## Data-only Resource for a single habit occurrence.
##
## Kept as a Resource (not just a Dictionary) so designers can inspect and
## save habits from the editor, and so LatticeWorld can hold typed arrays.
##

@export var kind: StringName = &""
@export var payload: Dictionary = {}
@export var run_id: int = 0
@export var timestamp_ms: int = 0


static func make(kind: StringName, payload: Dictionary = {}) -> HabitEvent:
	var e := HabitEvent.new()
	e.kind = kind
	e.payload = payload
	e.timestamp_ms = Time.get_ticks_msec()
	return e
