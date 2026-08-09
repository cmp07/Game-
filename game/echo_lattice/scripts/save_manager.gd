extends Node
##
## SaveManager — atomic JSON persistence in user://save.json.
## Writes via tmp + rename, keeps save.json.bak, recovers from backup on corrupt load.
##

const SAVE_PATH: String = "user://save.json"
const SAVE_TMP: String = "user://save.json.tmp"
const SAVE_BAK: String = "user://save.json.bak"
const SAVE_VERSION: int = 2


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
		"run_started": GameState.run_started,
	}
	var payload: String = JSON.stringify(data, "\t")
	var file := FileAccess.open(SAVE_TMP, FileAccess.WRITE)
	if file == null:
		push_warning("Echo Lattice: could not open save tmp for write.")
		return false
	file.store_string(payload)
	file.close()
	if Engine.get_main_loop() is SceneTree:
		var root: Node = (Engine.get_main_loop() as SceneTree).root
		if root != null and root.has_node("SteamService"):
			var steam: Node = root.get_node("SteamService")
			var feats: Variant = steam.get("features")
			if steam.has_method("push_cloud_save") and typeof(feats) == TYPE_DICTIONARY \
					and bool(feats.get("cloud_save_enabled", false)):
				steam.push_cloud_save()

	var abs_path: String = ProjectSettings.globalize_path(SAVE_PATH)
	var abs_tmp: String = ProjectSettings.globalize_path(SAVE_TMP)
	var abs_bak: String = ProjectSettings.globalize_path(SAVE_BAK)

	# Rotate current → bak, then tmp → current (atomic-ish on POSIX).
	if FileAccess.file_exists(SAVE_PATH):
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
	return true


func load_from_disk() -> bool:
	var parsed: Variant = _read_json_file(SAVE_PATH)
	if typeof(parsed) != TYPE_DICTIONARY:
		parsed = _read_json_file(SAVE_BAK)
		if typeof(parsed) != TYPE_DICTIONARY:
			return false
		push_warning("Echo Lattice: primary save corrupt; restored from .bak.")
	_apply_save(parsed as Dictionary)
	return true


func wipe() -> void:
	for p in [SAVE_PATH, SAVE_TMP, SAVE_BAK]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))


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
	GameState.current_chamber = int(parsed.get("current_chamber", 0))
	var best = parsed.get("best_moves", {})
	if typeof(best) == TYPE_DICTIONARY:
		GameState.best_moves = _stringify_int_keys(best)
	var stars = parsed.get("best_stars", {})
	if typeof(stars) == TYPE_DICTIONARY:
		GameState.best_stars = _stringify_int_keys(stars)
	var done = parsed.get("completed", {})
	if typeof(done) == TYPE_DICTIONARY:
		GameState.completed = _stringify_int_keys(done)
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
	GameState.run_started = bool(parsed.get("run_started", false))
	var rq = parsed.get("run_queue", [])
	if typeof(rq) == TYPE_ARRAY:
		GameState.run_queue = rq.duplicate()
	var dbest = parsed.get("daily_best_stars", {})
	if typeof(dbest) == TYPE_DICTIONARY:
		GameState.daily_best_stars = dbest.duplicate()
	# Legacy / partial saves: rebuild a standard queue so Continue cannot softlock.
	if GameState.run_queue.is_empty() and GameState.run_mode == "standard":
		for i in range(ChamberBook.chamber_count()):
			GameState.run_queue.append(i)
	if GameState.queue_pos < 0:
		GameState.queue_pos = 0
	if GameState.run_queue.size() > 0:
		GameState.queue_pos = mini(GameState.queue_pos, GameState.run_queue.size())
		if GameState.queue_pos < GameState.run_queue.size():
			GameState.current_chamber = int(GameState.run_queue[GameState.queue_pos])
		else:
			GameState.current_chamber = int(GameState.run_queue[GameState.run_queue.size() - 1])


static func _stringify_int_keys(d: Dictionary) -> Dictionary:
	var out := {}
	for k in d.keys():
		var ik: int = int(k)
		out[ik] = d[k]
	return out
