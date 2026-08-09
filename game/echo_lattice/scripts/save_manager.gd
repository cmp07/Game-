extends Node
##
## SaveManager — atomic JSON persistence in user://save.json.
## Writes via tmp + rename, keeps save.json.bak, recovers from backup on corrupt load.
##

const SAVE_PATH: String = "user://save.json"
const SAVE_TMP: String = "user://save.json.tmp"
const SAVE_BAK: String = "user://save.json.bak"
const SAVE_VERSION: int = 2
## Bounds for SEC-02 cloud / untrusted save validation (also useful locally).
const SAVE_VERSION_MIN: int = 1
const SAVE_MAX_BYTES: int = 262144
const SAVE_MAX_MAP_ENTRIES: int = 256
const SAVE_MAX_QUEUE_LEN: int = 128
const SAVE_MAX_CHAMBER_INDEX: int = 1023
const SAVE_MAX_STRING_LEN: int = 256
const SAVE_ALLOWED_KEYS: Array[String] = [
	"version",
	"build_flavor",
	"current_chamber",
	"best_moves",
	"best_stars",
	"completed",
	"run_cleared",
	"habit_profile",
	"run_mode",
	"run_queue",
	"queue_pos",
	"daily_seed",
	"daily_label",
	"daily_best_stars",
	"run_started",
]


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Best-effort flush so quit mid-chamber keeps Continue honest.
		if has_node("/root/GameState"):
			save_to_disk()


func _exit_tree() -> void:
	if has_node("/root/GameState"):
		save_to_disk()


func save_to_disk() -> bool:
	if not has_node("/root/GameState"):
		return false
	var data := {
		"version": SAVE_VERSION,
		"build_flavor": "demo" if DemoBuild.is_demo() else "full",
		"current_chamber": GameState.current_chamber,
		"best_moves": GameState.best_moves,
		"best_stars": GameState.best_stars,
		"completed": GameState.completed,
		"run_cleared": GameState.run_cleared,
		"habit_profile": GameState.habit_profile,
		"run_mode": GameState.run_mode,
		"run_queue": GameState.run_queue,
		"queue_pos": GameState.queue_pos,
		"daily_seed": GameState.daily_seed,
		"daily_label": GameState.daily_label,
		"daily_best_stars": GameState.daily_best_stars,
		"endless_seed": GameState.endless_seed,
		"endless_depth": GameState.endless_depth,
		"endless_best_depth": GameState.endless_best_depth,
		"endless_label": GameState.endless_label,
		"run_started": GameState.run_started,
	}
	var payload: String = JSON.stringify(data, "\t")
	var file := FileAccess.open(SAVE_TMP, FileAccess.WRITE)
	if file == null:
		push_warning("Echo Lattice: could not open save tmp for write.")
		return false
	file.store_string(payload)
	file.close()

	var abs_path: String = ProjectSettings.globalize_path(SAVE_PATH)
	var abs_tmp: String = ProjectSettings.globalize_path(SAVE_TMP)
	var abs_bak: String = ProjectSettings.globalize_path(SAVE_BAK)

	# Rotate current → bak, then tmp → current (atomic-ish on POSIX).
	# Never promote a corrupt primary into .bak — that would destroy the last
	# known-good backup after a bak-recovery boot.
	if FileAccess.file_exists(SAVE_PATH):
		var primary_ok: bool = typeof(_read_json_file(SAVE_PATH)) == TYPE_DICTIONARY
		if primary_ok:
			if FileAccess.file_exists(SAVE_BAK):
				DirAccess.remove_absolute(abs_bak)
			var ren_bak: Error = DirAccess.rename_absolute(abs_path, abs_bak)
			if ren_bak != OK:
				# Fallback copy if rename across volumes fails.
				var src := FileAccess.open(SAVE_PATH, FileAccess.READ)
				var dst := FileAccess.open(SAVE_BAK, FileAccess.WRITE)
				if src != null and dst != null:
					dst.store_string(src.get_as_text())
					dst.close()
					src.close()
					DirAccess.remove_absolute(abs_path)
				else:
					if src:
						src.close()
					if dst:
						dst.close()
					push_warning("Echo Lattice: could not rotate save backup.")
		else:
			DirAccess.remove_absolute(abs_path)
	var ren: Error = DirAccess.rename_absolute(abs_tmp, abs_path)
	if ren != OK:
		# Last resort: direct write so progress is not lost.
		var direct := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if direct == null:
			push_warning("Echo Lattice: atomic save rename failed (%s)." % ren)
			return false
		direct.store_string(payload)
		direct.close()
		if FileAccess.file_exists(SAVE_TMP):
			DirAccess.remove_absolute(abs_tmp)
	# Cloud must read the committed save.json — never the pre-rename stale file.
	_push_cloud_after_commit()
	return true


func _push_cloud_after_commit() -> void:
	if not (Engine.get_main_loop() is SceneTree):
		return
	var root: Node = (Engine.get_main_loop() as SceneTree).root
	if root == null or not root.has_node("SteamService"):
		return
	var steam: Node = root.get_node("SteamService")
	var feats: Variant = steam.get("features")
	if steam.has_method("push_cloud_save") and typeof(feats) == TYPE_DICTIONARY \
			and bool(feats.get("cloud_save_enabled", false)):
		steam.push_cloud_save()


func load_from_disk() -> bool:
	var parsed: Variant = _read_json_file(SAVE_PATH)
	var restored_from_bak := false
	if typeof(parsed) != TYPE_DICTIONARY:
		parsed = _read_json_file(SAVE_BAK)
		if typeof(parsed) != TYPE_DICTIONARY:
			return false
		restored_from_bak = true
		push_warning("Echo Lattice: primary save corrupt; restored from .bak.")
	_apply_save(parsed as Dictionary)
	if restored_from_bak:
		# Repair primary in place so the next save cannot rotate corrupt bytes over .bak.
		_write_primary_payload(JSON.stringify(parsed as Dictionary, "\t"))
	return true


func wipe() -> void:
	for p in [SAVE_PATH, SAVE_TMP, SAVE_BAK]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))


## SEC-02 / SEC-06: validate untrusted save JSON (Steam Cloud pull, corrupt files).
## Returns { "ok": bool, "data": Dictionary?, "reason": String }.
static func validate_save_text(text: String) -> Dictionary:
	if text.length() > SAVE_MAX_BYTES:
		return {"ok": false, "reason": "payload_too_large"}
	var stripped := text.strip_edges()
	if stripped == "":
		return {"ok": false, "reason": "empty"}
	var parsed: Variant = JSON.parse_string(stripped)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "reason": "not_object"}
	return validate_save_dict(parsed as Dictionary)


static func validate_save_dict(data: Dictionary) -> Dictionary:
	if not data.has("version"):
		return {"ok": false, "reason": "missing_version"}
	var version: int = int(data.get("version", -1))
	if version < SAVE_VERSION_MIN or version > SAVE_VERSION:
		return {"ok": false, "reason": "version_out_of_range"}
	for k in data.keys():
		var key := str(k)
		if key not in SAVE_ALLOWED_KEYS:
			return {"ok": false, "reason": "unknown_key:%s" % key}
	if data.has("build_flavor"):
		var flavor := str(data.get("build_flavor", ""))
		if flavor.length() > SAVE_MAX_STRING_LEN:
			return {"ok": false, "reason": "build_flavor_too_long"}
		if flavor != "" and flavor != "demo" and flavor != "full":
			return {"ok": false, "reason": "build_flavor_invalid"}
	if data.has("run_mode"):
		var mode := str(data.get("run_mode", ""))
		if mode.length() > SAVE_MAX_STRING_LEN:
			return {"ok": false, "reason": "run_mode_too_long"}
		if mode != "" and mode != "standard" and mode != "daily":
			return {"ok": false, "reason": "run_mode_invalid"}
	if data.has("daily_label") and str(data.get("daily_label", "")).length() > SAVE_MAX_STRING_LEN:
		return {"ok": false, "reason": "daily_label_too_long"}
	for int_field in ["current_chamber", "queue_pos", "daily_seed"]:
		if data.has(int_field) and typeof(data[int_field]) not in [TYPE_INT, TYPE_FLOAT]:
			return {"ok": false, "reason": "%s_not_number" % int_field}
	if data.has("current_chamber"):
		var cc: int = int(data.get("current_chamber", 0))
		if cc < 0 or cc > SAVE_MAX_CHAMBER_INDEX:
			return {"ok": false, "reason": "current_chamber_out_of_range"}
	if data.has("queue_pos"):
		var qp: int = int(data.get("queue_pos", 0))
		if qp < 0 or qp > SAVE_MAX_QUEUE_LEN:
			return {"ok": false, "reason": "queue_pos_out_of_range"}
	if data.has("run_started") and typeof(data["run_started"]) != TYPE_BOOL:
		# JSON has no bool distinction from int in some parsers; allow 0/1 ints.
		if typeof(data["run_started"]) not in [TYPE_BOOL, TYPE_INT, TYPE_FLOAT]:
			return {"ok": false, "reason": "run_started_not_bool"}
	for map_key in ["best_moves", "best_stars", "completed", "run_cleared", "daily_best_stars"]:
		if not data.has(map_key):
			continue
		if typeof(data[map_key]) != TYPE_DICTIONARY:
			return {"ok": false, "reason": "%s_not_object" % map_key}
		var m: Dictionary = data[map_key]
		if m.size() > SAVE_MAX_MAP_ENTRIES:
			return {"ok": false, "reason": "%s_too_many_keys" % map_key}
		if map_key != "daily_best_stars":
			for mk in m.keys():
				var idx: int = int(mk)
				if idx < 0 or idx > SAVE_MAX_CHAMBER_INDEX:
					return {"ok": false, "reason": "%s_bad_index" % map_key}
	if data.has("habit_profile"):
		if typeof(data["habit_profile"]) != TYPE_DICTIONARY:
			return {"ok": false, "reason": "habit_profile_not_object"}
		var habit: Dictionary = data["habit_profile"]
		if habit.size() > 8:
			return {"ok": false, "reason": "habit_profile_too_many_keys"}
		for hk in habit.keys():
			if str(hk) not in ["up", "down", "left", "right"]:
				return {"ok": false, "reason": "habit_profile_unknown_key"}
	if data.has("run_queue"):
		if typeof(data["run_queue"]) != TYPE_ARRAY:
			return {"ok": false, "reason": "run_queue_not_array"}
		var rq: Array = data["run_queue"]
		if rq.size() > SAVE_MAX_QUEUE_LEN:
			return {"ok": false, "reason": "run_queue_too_long"}
		for idx_v in rq:
			if typeof(idx_v) not in [TYPE_INT, TYPE_FLOAT]:
				return {"ok": false, "reason": "run_queue_entry_not_number"}
			var qi: int = int(idx_v)
			if qi < 0 or qi > SAVE_MAX_CHAMBER_INDEX:
				return {"ok": false, "reason": "run_queue_index_out_of_range"}
	return {"ok": true, "data": data, "reason": ""}


func _read_json_file(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var text := file.get_as_text()
	file.close()
	if text.strip_edges() == "":
		return null
	return JSON.parse_string(text)


func _apply_save(parsed: Dictionary) -> void:
	var flavor: String = str(parsed.get("build_flavor", ""))
	var now_demo: bool = DemoBuild.is_demo()
	if flavor == "full" and now_demo:
		push_warning("Echo Lattice: loading full-game save into demo — clamping to Act I book.")
	elif flavor == "demo" and not now_demo:
		push_warning("Echo Lattice: loading demo save into full game — Continue may only cover Act I.")
	GameState.current_chamber = int(parsed.get("current_chamber", 0))
	var best = parsed.get("best_moves", {})
	if typeof(best) == TYPE_DICTIONARY:
		GameState.best_moves = _stringify_int_keys(best)
	else:
		GameState.best_moves = {}
	var stars = parsed.get("best_stars", {})
	if typeof(stars) == TYPE_DICTIONARY:
		GameState.best_stars = _stringify_int_keys(stars)
	else:
		GameState.best_stars = {}
	var done = parsed.get("completed", {})
	if typeof(done) == TYPE_DICTIONARY:
		GameState.completed = _stringify_int_keys(done)
	else:
		GameState.completed = {}
	var cleared = parsed.get("run_cleared", null)
	if typeof(cleared) == TYPE_DICTIONARY:
		GameState.run_cleared = _stringify_int_keys(cleared)
	else:
		# Legacy saves used lifetime `completed` for Continue skips. Seed the
		# per-run set from those clears so win→menu→Continue cannot soft-loop,
		# then Start New / Daily still wipe run_cleared independently.
		GameState.run_cleared.clear()
		for k in GameState.completed.keys():
			GameState.run_cleared[int(k)] = true
	var habit = parsed.get("habit_profile", null)
	if typeof(habit) == TYPE_DICTIONARY:
		for k in ["up", "down", "left", "right"]:
			GameState.habit_profile[k] = int(habit.get(k, 0))
	GameState.run_mode = str(parsed.get("run_mode", "standard"))
	GameState.queue_pos = int(parsed.get("queue_pos", 0))
	GameState.daily_seed = int(parsed.get("daily_seed", 0))
	GameState.daily_label = str(parsed.get("daily_label", ""))
	GameState.endless_seed = int(parsed.get("endless_seed", 0))
	GameState.endless_depth = int(parsed.get("endless_depth", 0))
	GameState.endless_best_depth = int(parsed.get("endless_best_depth", 0))
	GameState.endless_label = str(parsed.get("endless_label", ""))
	GameState.run_started = bool(parsed.get("run_started", false))
	var rq = parsed.get("run_queue", [])
	if typeof(rq) == TYPE_ARRAY:
		GameState.run_queue = rq.duplicate()
	else:
		GameState.run_queue = []
	var dbest = parsed.get("daily_best_stars", {})
	if typeof(dbest) == TYPE_DICTIONARY:
		GameState.daily_best_stars = dbest.duplicate()
	else:
		GameState.daily_best_stars = {}
	# Drop chamber indices the active build cannot address (demo↔full / corrupt).
	_sanitize_queue_against_book()
	# Legacy / partial saves: rebuild a standard queue so Continue cannot softlock.
	if GameState.run_queue.is_empty() and GameState.run_mode == "standard":
		for i in range(ChamberBook.chamber_count()):
			GameState.run_queue.append(i)
	elif GameState.run_queue.is_empty() and GameState.run_mode == "endless" and GameState.endless_seed != 0:
		GameState.run_queue = ChamberBook.endless_chamber_batch(
			GameState.endless_seed, GameState.endless_depth, GameState.ENDLESS_BATCH, {}
		)
		GameState.queue_pos = 0
	if GameState.queue_pos < 0:
		GameState.queue_pos = 0
	if GameState.run_queue.size() > 0:
		GameState.queue_pos = mini(GameState.queue_pos, GameState.run_queue.size())
		if GameState.queue_pos < GameState.run_queue.size():
			GameState.current_chamber = int(GameState.run_queue[GameState.queue_pos])
		else:
			GameState.current_chamber = int(GameState.run_queue[GameState.run_queue.size() - 1])
	else:
		GameState.current_chamber = clampi(GameState.current_chamber, 0, maxi(0, ChamberBook.chamber_count() - 1))


func _sanitize_queue_against_book() -> void:
	var n: int = ChamberBook.chamber_count()
	if n <= 0:
		GameState.run_queue = []
		return
	var filtered: Array = []
	for idx in GameState.run_queue:
		var i: int = int(idx)
		if i >= 0 and i < n:
			filtered.append(i)
	if filtered.size() != GameState.run_queue.size():
		push_warning(
			"Echo Lattice: save run_queue had out-of-range chamber indices; clamped to book size %d."
			% n
		)
	GameState.run_queue = filtered
	# Prune score tables that point past the active book (demo load of full save).
	for table in [GameState.best_moves, GameState.best_stars, GameState.completed, GameState.run_cleared]:
		var drop: Array = []
		for k in table.keys():
			if int(k) < 0 or int(k) >= n:
				drop.append(k)
		for k2 in drop:
			table.erase(k2)


func _write_primary_payload(payload: String) -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Echo Lattice: could not repair primary save after bak restore.")
		return false
	file.store_string(payload)
	file.close()
	return true


static func _stringify_int_keys(d: Dictionary) -> Dictionary:
	var out := {}
	for k in d.keys():
		var ik: int = int(k)
		out[ik] = d[k]
	return out
