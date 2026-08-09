extends Node
## MetaV2 — facade autoload for Echo Lattice retention systems.
##
## Wire in project.godot:
##   MetaV2="*res://scripts/meta/meta_v2.gd"

signal save_updated()
signal achievement_unlocked(id: String)
signal museum_updated(self_row: Dictionary)
signal ng_plus_unlocked()

const CFG_PATH := "res://config/meta_v2.json"
const ACH_PATH := "res://config/achievements_v2.json"
const RUN_HISTORY_CAP := 50

var cfg: Dictionary = {}
var save: Dictionary = {}
var achievements := AchievementService.new()


func _ready() -> void:
	cfg = _load_json(CFG_PATH)
	if cfg.is_empty():
		cfg = {"save_version": 2, "museum": {"cap": 48}}
	achievements.load_catalog(ACH_PATH)
	achievements.achievement_unlocked.connect(func(id: String): achievement_unlocked.emit(id))
	save = MetaSave.load_from_disk(cfg)
	NgPlusService.ensure(save)
	StreakService.ensure(save)
	ShortRunPacing.ensure(save)
	MuseumOfSelves.ensure(save, cfg)


func get_save() -> Dictionary:
	return save


func persist(force: bool = true) -> bool:
	var ok := MetaSave.save_to_disk(save)
	if ok or force:
		save_updated.emit()
	return ok


func daily_challenge(unix_secs: int = -1) -> Dictionary:
	var ds := SeedClock.daily_datestamp(unix_secs)
	var seed := SeedClock.daily_seed(cfg, ds)
	var chamber := SeedClock.pick_from_pool(seed, cfg.get("daily", {}).get("pool", []))
	return {
		"datestamp": ds,
		"seed": seed,
		"chamber_id": chamber,
		"chamber_seed": SeedClock.chamber_rng_seed(ds, chamber),
		"played": str(save.get("seeds", {}).get("last_daily_date", "")) == ds,
		"streak_current": int(save.get("streaks", {}).get("daily_clear_current", 0)),
		"streak_best": int(save.get("streaks", {}).get("daily_clear_best", 0)),
	}


func weekly_challenge(unix_secs: int = -1) -> Dictionary:
	var wid := SeedClock.iso_week_id(unix_secs)
	var seed := SeedClock.weekly_seed(cfg, wid)
	var chamber := SeedClock.pick_from_pool(seed, cfg.get("weekly", {}).get("pool", []))
	return {
		"week_id": wid,
		"seed": seed,
		"chamber_id": chamber,
		"chamber_seed": SeedClock.chamber_rng_seed(wid, chamber),
		"played": str(save.get("seeds", {}).get("last_weekly_id", "")) == wid,
		"streak_current": int(save.get("streaks", {}).get("weekly_clear_current", 0)),
		"streak_best": int(save.get("streaks", {}).get("weekly_clear_best", 0)),
	}


func plan_short_run(kind: String = "standard", unix_secs: int = -1) -> Dictionary:
	return ShortRunPacing.plan(cfg, kind, unix_secs)


func start_run(chamber_id: String, seed: int, mode: String = "standard", modifiers: PackedStringArray = []) -> Dictionary:
	if ShortRunPacing.check_one_more(save, cfg):
		save["stats"]["one_more_runs"] = int(save["stats"].get("one_more_runs", 0)) + 1
	var run := {
		"chamber_id": chamber_id,
		"seed": seed,
		"mode": mode,
		"modifiers": Array(modifiers),
		"started_at": Time.get_datetime_string_from_system(true),
		"ng_plus": NgPlusService.is_active(save),
	}
	save["active_run"] = run
	save["stats"]["runs_started"] = int(save["stats"].get("runs_started", 0)) + 1
	if mode == "daily":
		save["stats"]["daily_runs"] = int(save["stats"].get("daily_runs", 0)) + 1
	elif mode == "weekly":
		save["stats"]["weekly_runs"] = int(save["stats"].get("weekly_runs", 0)) + 1
	if "museum:" in ",".join(modifiers):
		pass  # ghost race start flagged via modifier prefix
	persist()
	return run


func end_run(outcome: String, run_stats: Dictionary = {}) -> Dictionary:
	var run: Dictionary = save.get("active_run", {})
	if run.is_empty():
		return {}
	run["outcome"] = outcome
	run["ended_at"] = Time.get_datetime_string_from_system(true)
	run["run_stats"] = run_stats
	var mode := str(run.get("mode", "standard"))
	var chamber_id := str(run.get("chamber_id", ""))

	match outcome:
		"clear":
			save["stats"]["runs_completed"] = int(save["stats"].get("runs_completed", 0)) + 1
			var clears: Dictionary = save["stats"].get("clears_per_chamber", {})
			clears[chamber_id] = int(clears.get(chamber_id, 0)) + 1
			save["stats"]["clears_per_chamber"] = clears
			var stars := int(run_stats.get("stars", 1))
			StarLedger.apply_clear(save, chamber_id, stars)
			if mode == "daily":
				save["stats"]["daily_clears"] = int(save["stats"].get("daily_clears", 0)) + 1
				save["seeds"]["last_daily_date"] = SeedClock.daily_datestamp()
				save["seeds"]["last_daily_outcome"] = "clear"
			elif mode == "weekly":
				save["stats"]["weekly_clears"] = int(save["stats"].get("weekly_clears", 0)) + 1
				save["seeds"]["last_weekly_id"] = SeedClock.iso_week_id()
				save["seeds"]["last_weekly_outcome"] = "clear"
			if NgPlusService.is_active(save):
				save["stats"]["ng_plus_clears"] = int(save["stats"].get("ng_plus_clears", 0)) + 1
			if int(run_stats.get("undos", 0)) == 0:
				save["stats"]["no_undo_clears"] = int(save["stats"].get("no_undo_clears", 0)) + 1
			if mode == "cold" or str(run_stats.get("difficulty", "")) == "cold":
				save["stats"]["cold_clears"] = int(save["stats"].get("cold_clears", 0)) + 1
			if mode == "reader" or str(run_stats.get("difficulty", "")) == "reader":
				save["stats"]["reader_clears"] = int(save["stats"].get("reader_clears", 0)) + 1
			if int(run_stats.get("hard_rewrites", 0)) == 0:
				save["stats"]["soft_only_clears"] = int(save["stats"].get("soft_only_clears", 0)) + 1
			_track_mode_clear(chamber_id, mode)
			var self_row := MuseumOfSelves.maybe_archive(save, cfg, run, outcome, run_stats)
			if not self_row.is_empty():
				museum_updated.emit(self_row)
		"death":
			save["stats"]["runs_failed"] = int(save["stats"].get("runs_failed", 0)) + 1
			var deaths: Dictionary = save["stats"].get("deaths_per_chamber", {})
			deaths[chamber_id] = int(deaths.get(chamber_id, 0)) + 1
			save["stats"]["deaths_per_chamber"] = deaths
			if mode == "daily":
				save["seeds"]["last_daily_date"] = SeedClock.daily_datestamp()
				save["seeds"]["last_daily_outcome"] = "death"
			elif mode == "weekly":
				save["seeds"]["last_weekly_id"] = SeedClock.iso_week_id()
				save["seeds"]["last_weekly_outcome"] = "death"
		_:
			save["stats"]["runs_abandoned"] = int(save["stats"].get("runs_abandoned", 0)) + 1

	save["stats"]["rewrites_committed"] = int(save["stats"].get("rewrites_committed", 0)) + int(run_stats.get("rewrites_committed", 0))
	save["stats"]["fossils_seen"] = int(save["stats"].get("fossils_seen", 0)) + int(run_stats.get("fossils_seen", 0))
	if _is_ghost_run(run):
		save["stats"]["ghost_races"] = int(save["stats"].get("ghost_races", 0)) + 1

	StreakService.on_run_end(save, mode, outcome)
	ShortRunPacing.note_run_end(save)

	if NgPlusService.check_unlock(save, cfg):
		ng_plus_unlocked.emit()
	if bool(run_stats.get("wing_clear", false)):
		NgPlusService.on_wing_clear(save, cfg, true)

	var history: Array = save.get("runs", [])
	history.push_front(run)
	while history.size() > RUN_HISTORY_CAP:
		history.pop_back()
	save["runs"] = history
	save["active_run"] = {}

	var newly := achievements.evaluate(save)
	run["new_achievements"] = newly
	persist()
	return run


func complete_short_run(elapsed_sec: float) -> Dictionary:
	var result := ShortRunPacing.mark_session(save, cfg, elapsed_sec, true)
	achievements.evaluate(save)
	persist()
	return result


func set_ng_plus_active(active: bool) -> void:
	NgPlusService.set_active(save, active)
	NgPlusService.active_modifiers(save, cfg)
	persist()


func museum_selves() -> Array:
	return MuseumOfSelves.list_selves(save)


func star_total() -> int:
	return StarLedger.total(save)


func _track_mode_clear(chamber_id: String, mode: String) -> void:
	var block: Dictionary = save["stats"].get("modes_cleared_per_chamber", {})
	var modes: Array = block.get(chamber_id, [])
	if typeof(modes) != TYPE_ARRAY:
		modes = []
	var norm := mode
	if mode in ["daily", "weekly", "ghost"]:
		norm = "standard"
	if norm not in modes:
		modes.append(norm)
	block[chamber_id] = modes
	save["stats"]["modes_cleared_per_chamber"] = block
	var triples := 0
	for cid in block.keys():
		var m: Array = block[cid]
		if "reader" in m and "standard" in m and "cold" in m:
			triples += 1
	save["stats"]["triple_mode_chambers"] = triples


func _is_ghost_run(run: Dictionary) -> bool:
	if str(run.get("mode", "")) == "ghost":
		return true
	for m in run.get("modifiers", []):
		if str(m).begins_with("museum:"):
			return true
	return false


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}
