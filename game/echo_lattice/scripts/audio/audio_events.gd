extends RefCounted
class_name AudioEvents
## Loads and queries structured audio events from audio/events/audio_events.json.

const CATALOG_PATH := "res://audio/events/audio_events.json"

var version: int = 0
var events: Dictionary = {}
var silence_policy: Dictionary = {}
var operators: PackedStringArray = PackedStringArray()


func load_catalog(path: String = CATALOG_PATH) -> bool:
	if not FileAccess.file_exists(path):
		push_warning("AudioEvents: missing catalog %s" % path)
		return false
	var raw := FileAccess.get_file_as_string(path)
	var data = JSON.parse_string(raw)
	if typeof(data) != TYPE_DICTIONARY:
		push_warning("AudioEvents: invalid JSON in %s" % path)
		return false
	version = int(data.get("version", 0))
	events = data.get("events", {}) as Dictionary
	silence_policy = data.get("silence_policy", {}) as Dictionary
	var ops: Array = data.get("operators", []) as Array
	operators = PackedStringArray()
	for op in ops:
		operators.append(str(op))
	return not events.is_empty()


func has_event(event_id: String) -> bool:
	return events.has(event_id)


func get_event(event_id: String) -> Dictionary:
	if not events.has(event_id):
		return {}
	return (events[event_id] as Dictionary).duplicate(true)


func stream_path(event_id: String) -> String:
	var ev := get_event(event_id)
	return str(ev.get("stream", ""))


func bus_name(event_id: String) -> String:
	var ev := get_event(event_id)
	return str(ev.get("bus", "SFX"))


## Content transforms → catalog stinger operators (audio bible §6 / UPGRADE P0-03).
const REWRITE_OPERATOR_ALIASES := {
	"mirror_v": "mirror",
	"mirror_h": "mirror",
	"mirror_v_then_h": "mirror",
	"rotate_180": "rotate",
	"rotate": "rotate",
	"thicken": "thicken",
	"invert": "invert",
}


func rewrite_event_id(operator_name: String) -> String:
	var op := operator_name.strip_edges()
	if op.is_empty() or op == "none":
		return "sfx.rewrite"
	var aliased: String = str(REWRITE_OPERATOR_ALIASES.get(op, op))
	var specific := "sfx.rewrite.%s" % aliased
	if has_event(specific):
		return specific
	var exact := "sfx.rewrite.%s" % op
	if has_event(exact):
		return exact
	return "sfx.rewrite"


func max_intensity_for_chamber(chamber_index: int) -> float:
	var table: Dictionary = silence_policy.get("early_chambers_max_intensity", {}) as Dictionary
	var key := str(chamber_index)
	if table.has(key):
		return float(table[key])
	return float(silence_policy.get("default_max_intensity", 1.0))
