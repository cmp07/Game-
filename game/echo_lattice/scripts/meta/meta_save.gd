class_name MetaSave
extends RefCounted
## META v2 save template, migration, and atomic disk I/O.


const SAVE_PATH := "user://save.json"
const SAVE_TMP := "user://save.json.tmp"
const SAVE_BAK := "user://save.json.bak"


static func fresh(cfg: Dictionary = {}) -> Dictionary:
	var root_chamber := "ec_01_boot"
	return {
		"version": int(cfg.get("save_version", 2)),
		"created_at_utc": Time.get_datetime_string_from_system(true),
		"updated_at_utc": Time.get_datetime_string_from_system(true),
		"profile": {"name": "Operator", "ng_plus_unlocked": false, "ng_plus_cycles": 0},
		"unlocks": {
			"chambers": [root_chamber],
			"modifiers": [],
			"cosmetics": [],
			"runes": [],
			"achievements": [],
		},
		"stars": {"best": {}, "total_earned": 0},
		"streaks": {
			"play_current": 0, "play_best": 0, "play_last_date": "",
			"daily_clear_current": 0, "daily_clear_best": 0, "daily_last_date": "",
			"weekly_clear_current": 0, "weekly_clear_best": 0, "weekly_last_id": "",
		},
		"seeds": {
			"last_daily_date": "",
			"last_daily_outcome": "",
			"last_weekly_id": "",
			"last_weekly_outcome": "",
		},
		"museum": {"selves": [], "cap": int(cfg.get("museum", {}).get("cap", 48))},
		"ng_plus": {"active": false, "cycle": 0, "modifiers": []},
		"pacing": {
			"short_runs_completed": 0,
			"last_session_sec": 0.0,
			"best_short_run_sec": 0.0,
			"last_run_end_unix": 0,
		},
		"stats": {
			"runs_started": 0, "runs_completed": 0, "runs_failed": 0, "runs_abandoned": 0,
			"total_time_sec": 0.0,
			"rewrites_committed": 0, "fossils_seen": 0,
			"daily_runs": 0, "daily_clears": 0,
			"weekly_runs": 0, "weekly_clears": 0,
			"ghost_races": 0, "ng_plus_clears": 0,
			"one_more_runs": 0, "no_undo_clears": 0,
			"cold_clears": 0, "reader_clears": 0,
			"triple_mode_chambers": 0, "soft_only_clears": 0,
			"best_time_per_chamber": {},
			"clears_per_chamber": {},
			"deaths_per_chamber": {},
			"modes_cleared_per_chamber": {},
		},
		"runs": [],
		"active_run": {},
		"settings": {
			"master_volume": 1.0, "sfx_volume": 1.0, "music_volume": 0.8,
			"fullscreen": false, "reduce_motion": false, "screen_shake": true,
		},
	}


static func migrate(raw: Dictionary, cfg: Dictionary = {}) -> Dictionary:
	var base := fresh(cfg)
	var merged := _deep_merge(base, raw)
	merged["version"] = int(cfg.get("save_version", 2))
	return merged


static func load_from_disk(cfg: Dictionary = {}, path: String = SAVE_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return fresh(cfg)
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return fresh(cfg)
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return fresh(cfg)
	return migrate(parsed, cfg)


static func save_to_disk(save: Dictionary, path: String = SAVE_PATH) -> bool:
	save["updated_at_utc"] = Time.get_datetime_string_from_system(true)
	var text := JSON.stringify(save, "\t")
	var tmp := path + ".tmp" if path != SAVE_PATH else SAVE_TMP
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(text)
	f.close()
	if FileAccess.file_exists(path):
		DirAccess.copy_absolute(
			ProjectSettings.globalize_path(path),
			ProjectSettings.globalize_path(SAVE_BAK if path == SAVE_PATH else path + ".bak")
		)
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var err := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(tmp),
		ProjectSettings.globalize_path(path)
	)
	return err == OK


static func _deep_merge(base: Dictionary, overlay: Dictionary) -> Dictionary:
	var out := base.duplicate(true)
	for k in overlay.keys():
		if out.has(k) and typeof(out[k]) == TYPE_DICTIONARY and typeof(overlay[k]) == TYPE_DICTIONARY:
			out[k] = _deep_merge(out[k], overlay[k])
		else:
			out[k] = overlay[k]
	return out
