class_name SteamAchievements
extends RefCounted
##
## Evaluates Steam achievement rules against live GameState and unlocks via backend.
## Catalog: res://config/achievements_steam.json (mirrors docs/RELEASE/ACHIEVEMENTS.json).
##

signal unlocked(api_name: String)

const DEFAULT_CATALOG: String = "res://config/achievements_steam.json"

var catalog: Array = []
var _granted: Dictionary = {}  # api_name -> true (session + local mirror)


func load_catalog(path: String = DEFAULT_CATALOG) -> void:
	catalog = []
	if not FileAccess.file_exists(path):
		push_warning("SteamAchievements: missing catalog %s" % path)
		return
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var arr = parsed.get("achievements", [])
	if typeof(arr) == TYPE_ARRAY:
		catalog = arr


func set_catalog(achievements: Array) -> void:
	catalog = achievements


func remember_granted(api_names: Array) -> void:
	for n in api_names:
		_granted[str(n)] = true


func is_granted(api_name: String) -> bool:
	return _granted.has(api_name)


func evaluate_and_unlock(backend: SteamBackend, state: Node = null) -> PackedStringArray:
	## Returns newly unlocked API names.
	var newly: PackedStringArray = []
	var gs: Node = state
	if gs == null and Engine.get_main_loop() is SceneTree:
		var root: Node = (Engine.get_main_loop() as SceneTree).root
		if root != null and root.has_node("GameState"):
			gs = root.get_node("GameState")
	for entry in catalog:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var api := str(entry.get("api_name", ""))
		if api == "" or _granted.has(api):
			continue
		if _rule_passes(entry.get("unlock", {}), gs):
			_granted[api] = true
			if backend != null:
				backend.unlock_achievement(api)
			newly.append(api)
			unlocked.emit(api)
	if newly.size() > 0 and backend != null:
		backend.store_stats()
	return newly


func _rule_passes(rule: Variant, gs: Node) -> bool:
	if typeof(rule) != TYPE_DICTIONARY:
		return false
	var kind := str(rule.get("kind", ""))
	match kind:
		"chambers_completed_at_least":
			return _completed_count(gs) >= int(rule.get("value", 0))
		"chamber_completed":
			return _is_completed(gs, int(rule.get("chamber_id", -1)))
		"act_cleared":
			return _act_cleared(gs, int(rule.get("act", 1)))
		"total_stars_at_least":
			return _total_stars(gs) >= int(rule.get("value", 0))
		"any_stars_at_least":
			return _any_stars(gs) >= int(rule.get("value", 0))
		"daily_cleared":
			return _daily_cleared(gs)
		"run_mode_is":
			return _run_mode(gs) == str(rule.get("value", ""))
		"all_chambers_completed":
			return _all_chambers(gs)
		"flag_true":
			# Reserved for future explicit flags on GameState.
			if gs == null:
				return false
			var path := str(rule.get("path", ""))
			if path == "" or not gs.get(path):
				return false
			return bool(gs.get(path))
		"all_of":
			for r in rule.get("rules", []):
				if not _rule_passes(r, gs):
					return false
			return true
		"any_of":
			for r in rule.get("rules", []):
				if _rule_passes(r, gs):
					return true
			return false
		_:
			return false


func _completed_count(gs: Node) -> int:
	if gs == null:
		return 0
	var completed = gs.get("completed")
	if typeof(completed) != TYPE_DICTIONARY:
		return 0
	return completed.size()


func _is_completed(gs: Node, chamber_id: int) -> bool:
	if gs == null or chamber_id < 0:
		return false
	var completed = gs.get("completed")
	if typeof(completed) != TYPE_DICTIONARY:
		return false
	return bool(completed.get(chamber_id, false))


func _act_cleared(gs: Node, act: int) -> bool:
	## `act` is 1-based in ACHIEVEMENTS.json. Prefer chamber `act_index` (0-based)
	## so Act IV Mastery stays distinct from Act III Pressure / PRISM.
	if gs == null or act < 1:
		return false
	var target_index: int = act - 1
	var book: Node = null
	if Engine.get_main_loop() is SceneTree:
		var root: Node = (Engine.get_main_loop() as SceneTree).root
		if root != null and root.has_node("ChamberBook"):
			book = root.get_node("ChamberBook")
	if book == null or not book.has_method("chamber_count") or not book.has_method("get_chamber"):
		# Campaign sizes in acts.json: 9 + 9 + 9 + 8.
		var thresholds := {1: 9, 2: 18, 3: 27, 4: 35}
		return _completed_count(gs) >= int(thresholds.get(act, 999999))
	var count: int = int(book.call("chamber_count"))
	var completed = gs.get("completed")
	if typeof(completed) != TYPE_DICTIONARY:
		return false
	var any_in_act := false
	for i in range(count):
		var data: Dictionary = book.call("get_chamber", i)
		var aidx: int = int(data.get("act_index", int(data.get("act", 1)) - 1))
		if aidx != target_index:
			continue
		any_in_act = true
		if not bool(completed.get(i, false)):
			return false
	return any_in_act


func _total_stars(gs: Node) -> int:
	if gs == null:
		return 0
	if gs.has_method("total_stars_earned"):
		return int(gs.call("total_stars_earned"))
	return 0


func _any_stars(gs: Node) -> int:
	if gs == null:
		return 0
	var stars = gs.get("best_stars")
	if typeof(stars) != TYPE_DICTIONARY:
		return 0
	var best: int = 0
	for k in stars.keys():
		best = maxi(best, int(stars[k]))
	return best


func _daily_cleared(gs: Node) -> bool:
	if gs == null:
		return false
	if str(gs.get("run_mode")) != "daily":
		return false
	var queue = gs.get("run_queue")
	var completed = gs.get("completed")
	if typeof(queue) != TYPE_ARRAY or typeof(completed) != TYPE_DICTIONARY:
		return false
	if queue.is_empty():
		return false
	for idx in queue:
		if not bool(completed.get(int(idx), false)):
			return false
	return true


func _run_mode(gs: Node) -> String:
	if gs == null:
		return ""
	return str(gs.get("run_mode"))


func _all_chambers(gs: Node) -> bool:
	if gs == null:
		return false
	var book: Node = null
	if Engine.get_main_loop() is SceneTree:
		var root: Node = (Engine.get_main_loop() as SceneTree).root
		if root != null and root.has_node("ChamberBook"):
			book = root.get_node("ChamberBook")
	var need: int = 35
	if book != null and book.has_method("chamber_count"):
		need = int(book.call("chamber_count"))
	return _completed_count(gs) >= need
