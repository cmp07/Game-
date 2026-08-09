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
	# Cloud must see the committed primary, not the pre-rename bytes.
	_push_cloud_after_commit()
	return true


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
	# Demo / Next Fest: drop out-of-range indices from a full-game save so
	# Continue cannot open an empty chamber (get_chamber → {}).
	_sanitize_queue_for_demo()
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
		elif GameState.run_queue.size() > 0:
			GameState.current_chamber = int(GameState.run_queue[GameState.run_queue.size() - 1])


func _sanitize_queue_for_demo() -> void:
	if not DemoBuild.is_demo():
		return
	var n: int = ChamberBook.chamber_count()
	if n <= 0:
		return
	var filtered: Array = []
	for idx in GameState.run_queue:
		var i: int = int(idx)
		if i >= 0 and i < n:
			filtered.append(i)
	GameState.run_queue = filtered
	if GameState.current_chamber < 0 or GameState.current_chamber >= n:
		GameState.current_chamber = int(GameState.run_queue[0]) if not GameState.run_queue.is_empty() else 0


func _write_primary_payload(payload: String) -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Echo Lattice: could not repair primary save after bak restore.")
		return false
	file.store_string(payload)
	file.close()
	return true


func _push_cloud_after_commit() -> void:
	if not Engine.get_main_loop() is SceneTree:
		return
	var root: Node = (Engine.get_main_loop() as SceneTree).root
	if root == null or not root.has_node("SteamService"):
		return
	var steam: Node = root.get_node("SteamService")
	var feats: Variant = steam.get("features")
	if steam.has_method("push_cloud_save") and typeof(feats) == TYPE_DICTIONARY \
			and bool(feats.get("cloud_save_enabled", false)):
		steam.push_cloud_save()


static func _stringify_int_keys(d: Dictionary) -> Dictionary:
	var out := {}
	for k in d.keys():
		var ik: int = int(k)
		out[ik] = d[k]
	return out
