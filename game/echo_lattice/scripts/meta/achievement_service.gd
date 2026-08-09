class_name AchievementService
extends RefCounted
## Milestone achievement evaluation against a v2 save.


signal achievement_unlocked(id: String)

var _catalog: Array = []


func load_catalog(path: String = "res://config/achievements_v2.json") -> void:
	_catalog = []
	if not FileAccess.file_exists(path):
		push_warning("AchievementService: missing catalog at %s" % path)
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		_catalog = parsed.get("achievements", [])


func set_catalog(achievements: Array) -> void:
	_catalog = achievements


func catalog() -> Array:
	return _catalog


func unlocked_ids(save: Dictionary) -> PackedStringArray:
	var arr: Array = save.get("unlocks", {}).get("achievements", [])
	var out: PackedStringArray = []
	for a in arr:
		out.append(str(a))
	return out


func is_unlocked(save: Dictionary, id: String) -> bool:
	return id in unlocked_ids(save)


func evaluate(save: Dictionary) -> PackedStringArray:
	## Returns newly unlocked ids.
	var newly: PackedStringArray = []
	if not save.has("unlocks") or typeof(save["unlocks"]) != TYPE_DICTIONARY:
		save["unlocks"] = {}
	var unlocks: Dictionary = save["unlocks"]
	if not unlocks.has("achievements") or typeof(unlocks["achievements"]) != TYPE_ARRAY:
		unlocks["achievements"] = []
	var have: Array = unlocks["achievements"]
	for entry in _catalog:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var id := str(entry.get("id", ""))
		if id == "" or id in have:
			continue
		if _rule_passes(entry.get("rule", {}), save):
			have.append(id)
			newly.append(id)
			achievement_unlocked.emit(id)
	unlocks["achievements"] = have
	save["unlocks"] = unlocks
	return newly


func _rule_passes(rule: Variant, save: Dictionary) -> bool:
	if typeof(rule) != TYPE_DICTIONARY:
		return false
	var kind := str(rule.get("kind", ""))
	match kind:
		"stat_at_least":
			return int(save.get("stats", {}).get(str(rule.get("stat", "")), 0)) >= int(rule.get("value", 0))
		"stars_total_at_least":
			return StarLedger.total(save) >= int(rule.get("value", 0))
		"stars_chamber_at_least":
			return StarLedger.best_for(save, str(rule.get("chamber_id", ""))) >= int(rule.get("value", 0))
		"chambers_cleared_at_least":
			return StarLedger.chambers_with_stars(save, 1).size() >= int(rule.get("value", 0))
		"streak_at_least":
			return int(save.get("streaks", {}).get(str(rule.get("streak", "")), 0)) >= int(rule.get("value", 0))
		"museum_count_at_least":
			return MuseumOfSelves.count(save) >= int(rule.get("value", 0))
		"flag_true":
			return bool(_dig(save, str(rule.get("path", ""))))
		"ng_plus_cycle_at_least":
			return int(save.get("profile", {}).get("ng_plus_cycles", 0)) >= int(rule.get("value", 0))
		"short_runs_at_least":
			return int(save.get("pacing", {}).get("short_runs_completed", 0)) >= int(rule.get("value", 0))
		"all_of":
			for r in rule.get("rules", []):
				if not _rule_passes(r, save):
					return false
			return true
		"any_of":
			for r in rule.get("rules", []):
				if _rule_passes(r, save):
					return true
			return false
		_:
			return false


static func _dig(root: Dictionary, path: String) -> Variant:
	var cur: Variant = root
	for part in path.split("."):
		if typeof(cur) != TYPE_DICTIONARY or not cur.has(part):
			return null
		cur = cur[part]
	return cur
