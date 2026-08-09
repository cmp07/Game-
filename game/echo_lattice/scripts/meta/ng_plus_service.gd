class_name NgPlusService
extends RefCounted
## NG+ unlock, activation, and cycle-scaled modifiers.


static func ensure(save: Dictionary) -> void:
	if not save.has("profile") or typeof(save["profile"]) != TYPE_DICTIONARY:
		save["profile"] = {"name": "Operator", "ng_plus_unlocked": false, "ng_plus_cycles": 0}
	var profile: Dictionary = save["profile"]
	if not profile.has("ng_plus_unlocked"):
		profile["ng_plus_unlocked"] = false
	if not profile.has("ng_plus_cycles"):
		profile["ng_plus_cycles"] = 0
	if not save.has("ng_plus") or typeof(save["ng_plus"]) != TYPE_DICTIONARY:
		save["ng_plus"] = {"active": false, "cycle": 0, "modifiers": []}


static func check_unlock(save: Dictionary, cfg: Dictionary) -> bool:
	ensure(save)
	if bool(save["profile"].get("ng_plus_unlocked", false)):
		return false
	var required: Array = cfg.get("ng_plus", {}).get("unlock_chambers", [])
	for cid in required:
		if StarLedger.best_for(save, str(cid)) < 1:
			return false
	save["profile"]["ng_plus_unlocked"] = true
	return true


static func set_active(save: Dictionary, active: bool) -> void:
	ensure(save)
	if active and not bool(save["profile"].get("ng_plus_unlocked", false)):
		return
	save["ng_plus"]["active"] = active


static func is_active(save: Dictionary) -> bool:
	return bool(save.get("ng_plus", {}).get("active", false))


static func active_modifiers(save: Dictionary, cfg: Dictionary) -> Array:
	ensure(save)
	if not is_active(save):
		return []
	var cycle := maxi(1, int(save["profile"].get("ng_plus_cycles", 0)) + (1 if is_active(save) else 0))
	var max_scale := int(cfg.get("ng_plus", {}).get("max_cycle_scale", 5))
	var scale := mini(cycle, max_scale)
	var out: Array = []
	for mod in cfg.get("ng_plus", {}).get("modifiers", []):
		if typeof(mod) != TYPE_DICTIONARY:
			continue
		var row := mod.duplicate(true)
		row["scale"] = scale
		if row.has("habit_window_delta"):
			var base_window := 48
			var delta := int(row["habit_window_delta"]) * scale
			var floor_v := int(row.get("habit_window_floor", 24))
			row["habit_window"] = maxi(floor_v, base_window + delta)
		if row.has("soft_hard_bias_delta"):
			row["soft_hard_bias"] = clampf(0.5 + float(row["soft_hard_bias_delta"]) * scale, 0.0, 0.95)
		if row.has("star_slack_mult"):
			row["star_slack"] = pow(float(row["star_slack_mult"]), scale)
		out.append(row)
	save["ng_plus"]["modifiers"] = out
	save["ng_plus"]["cycle"] = int(save["profile"].get("ng_plus_cycles", 0))
	return out


static func on_wing_clear(save: Dictionary, cfg: Dictionary, explicit: bool = false) -> bool:
	## Call with explicit=true when the player finishes a full Act I wing while NG+ is active.
	ensure(save)
	if not explicit or not is_active(save):
		return false
	var required: Array = cfg.get("ng_plus", {}).get("unlock_chambers", [])
	for cid in required:
		if StarLedger.best_for(save, str(cid)) < 1:
			return false
	save["profile"]["ng_plus_cycles"] = int(save["profile"].get("ng_plus_cycles", 0)) + 1
	save["ng_plus"]["cycle"] = int(save["profile"]["ng_plus_cycles"])
	return true
