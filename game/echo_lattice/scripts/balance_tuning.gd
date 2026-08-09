class_name BalanceTuning
extends RefCounted

## Loads and queries `config/balance_v2.json`.
## Pure data accessor — no scene-tree dependency.

const SCHEMA_VERSION := 2
const DEFAULT_PATHS: PackedStringArray = PackedStringArray([
	"res://config/balance_v2.json",
	"res://echo_lattice/config/balance_v2.json",
	"res://game/echo_lattice/config/balance_v2.json",
])

var data: Dictionary = {}
var path_loaded: String = ""


static func load_default() -> BalanceTuning:
	var bal := BalanceTuning.new()
	var err := bal.load_from_paths(DEFAULT_PATHS)
	assert(err == OK, "BalanceTuning: failed to load balance_v2.json")
	return bal


static func load_from_path(path: String) -> BalanceTuning:
	var bal := BalanceTuning.new()
	var err := bal.load_file(path)
	assert(err == OK, "BalanceTuning: failed to load %s" % path)
	return bal


func load_from_paths(paths: PackedStringArray) -> int:
	for p in paths:
		if FileAccess.file_exists(p):
			return load_file(p)
	push_error("BalanceTuning: no balance_v2.json found in %s" % str(paths))
	return ERR_FILE_NOT_FOUND


func load_file(path: String) -> int:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return FileAccess.get_open_error()
	var text := f.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("BalanceTuning: invalid JSON root in %s" % path)
		return ERR_PARSE_ERROR
	data = parsed
	path_loaded = path
	if int(data.get("schema_version", 0)) != SCHEMA_VERSION:
		push_warning(
			"BalanceTuning: schema_version=%s expected %d"
			% [str(data.get("schema_version", "?")), SCHEMA_VERSION]
		)
	return OK


func mode(mode_id: String = "standard") -> Dictionary:
	var modes: Dictionary = data.get("modes", {})
	if modes.has(mode_id):
		return modes[mode_id]
	return modes.get("standard", {})


func act(act_id: int) -> Dictionary:
	var acts: Dictionary = data.get("acts", {})
	var key := str(act_id)
	if acts.has(key):
		return acts[key]
	return {}


func habit_window(act_id: int) -> int:
	return int(act(act_id).get("habit_window", 32))


func rewrite_cap(act_id: int) -> int:
	return int(act(act_id).get("rewrite_cap", 1))


func soft_hard_bias(act_id: int, mode_id: String = "standard") -> float:
	var a := act(act_id)
	var m := mode(mode_id)
	# Mode bias is the primary dial; act bias is a floor the mode can raise.
	return maxf(float(a.get("soft_hard_bias", 0.5)), float(m.get("soft_hard_bias", 0.5)))


func hard_ops_allowed(act_id: int, chamber_index: int, mode_id: String = "standard") -> bool:
	var a := act(act_id)
	var m := mode(mode_id)
	var from_act := int(m.get("hard_ops_allowed_from_act", 1))
	if act_id < from_act:
		return false
	if bool(a.get("hard_ops_enabled", false)):
		return true
	return chamber_index >= int(a.get("hard_ops_unlock_chamber_index", 99))


func undo_budget(mode_id: String = "standard") -> int:
	return int(mode(mode_id).get("undo_budget_per_chamber", 24))


func rewind_budget(mode_id: String = "standard") -> int:
	return int(mode(mode_id).get("rewind_budget_per_chamber", 5))


func is_unlimited(budget: int) -> bool:
	return budget < 0


func tempo_for(act_id: int, checkpoint_count: int, mode_id: String = "standard") -> int:
	var a := act(act_id)
	var m := mode(mode_id)
	var base := float(a.get("tempo_base", 72))
	var per_cp := float(a.get("tempo_per_checkpoint", 10))
	var act_bonus := 12.0 * float(act_id - 1)
	var mult := float(m.get("tempo_multiplier", 1.0))
	return int(floor((base + per_cp * float(checkpoint_count) + act_bonus) * mult))


func chamber_relative_difficulty(act_id: int, chamber_index: int) -> float:
	var curve: Array = data.get("difficulty_curve", {}).get("chamber_escalation", [])
	for entry in curve:
		if int(entry.get("act", -1)) == act_id and int(entry.get("index", -1)) == chamber_index:
			return float(entry.get("relative", 1.0))
	return 1.0


func rewrite_engine_config() -> Dictionary:
	return data.get("rewrite_engine", {})


func stars_config() -> Dictionary:
	return data.get("stars", {})


func archetypes_config() -> Dictionary:
	return data.get("habit_archetypes", {})


func anti_frustration() -> Dictionary:
	return data.get("anti_frustration", {})


func telemetry_config() -> Dictionary:
	return data.get("telemetry", {})


func engine_max_attempts() -> int:
	var af: Dictionary = anti_frustration().get("never_softlock", {})
	if af.has("engine_max_attempts"):
		return int(af["engine_max_attempts"])
	return int(rewrite_engine_config().get("max_attempts", 32))


func enabled_ops(act_id: int, chamber_index: int, mode_id: String = "standard") -> PackedStringArray:
	var cfg := rewrite_engine_config()
	var ops: PackedStringArray = PackedStringArray(cfg.get("enabled_ops_default", []))
	var hard: Array = cfg.get("hard_ops", [])
	if hard_ops_allowed(act_id, chamber_index, mode_id):
		return ops
	var filtered: PackedStringArray = PackedStringArray()
	for op in ops:
		if not hard.has(op):
			filtered.append(op)
	# Also strip thicken if present in extended sets.
	return filtered
