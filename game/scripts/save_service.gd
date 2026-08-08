extends Node
##
## SaveService (autoload)
##
## Central meta-progression store for Echo Lattice. Owns:
##   * unlocks (chambers, modifiers, cosmetics)
##   * lifetime stats (runs, deaths, clears, per-chamber bests)
##   * run history (ring buffer of the last N runs)
##   * settings (audio, display)
##   * daily seed derivation (deterministic per UTC date)
##
## Save format: JSON at `user://save.json`. Writes are atomic
## (write to `save.json.tmp`, then `DirAccess.rename`).
##
## API stability: the on-disk `version` field guards migrations.
## Bump `SAVE_VERSION` and add a case in `_migrate()` when the
## shape changes.
##

signal save_updated                     # any persistent field changed
signal stats_updated                    # stats block changed
signal unlocks_changed(kind: String)    # kind in {"chamber", "modifier", "cosmetic"}
signal run_recorded(run: Dictionary)    # a run row was appended
signal settings_changed
signal saved_to_disk(path: String)
signal loaded_from_disk(path: String)
signal save_error(reason: String)

const SAVE_VERSION := 1
const SAVE_PATH := "user://save.json"
const SAVE_TMP_PATH := "user://save.json.tmp"
const SAVE_BACKUP_PATH := "user://save.json.bak"

## Ring buffer size for `runs`. Older runs are dropped from disk
## but their aggregate counters stay in `stats`.
const RUN_HISTORY_CAP := 50

## Namespace prefix folded into the daily seed. Bumping this
## invalidates every existing daily leaderboard.
const DAILY_SEED_NAMESPACE := "echo-lattice/daily/v1"

## Autosave debounce. Multiple mutations inside this window
## coalesce into a single disk write.
const AUTOSAVE_DEBOUNCE_SEC := 0.5

var data: Dictionary = {}
var _dirty: bool = false
var _autosave_timer: Timer

## Set to `false` from tests / tools to keep everything in-memory.
var autosave_enabled: bool = true


func _ready() -> void:
	_autosave_timer = Timer.new()
	_autosave_timer.one_shot = true
	_autosave_timer.wait_time = AUTOSAVE_DEBOUNCE_SEC
	_autosave_timer.timeout.connect(_on_autosave_timeout)
	add_child(_autosave_timer)

	if not load_from_disk():
		data = _fresh_save()
		_mark_dirty()

# ---------------------------------------------------------------------------
# Persistence
# ---------------------------------------------------------------------------

func load_from_disk() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		emit_signal("save_error", "open_failed:%d" % FileAccess.get_open_error())
		return false
	var raw := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		emit_signal("save_error", "parse_failed")
		return false
	data = _migrate(parsed as Dictionary)
	emit_signal("loaded_from_disk", SAVE_PATH)
	emit_signal("save_updated")
	return true


func save_to_disk(force: bool = false) -> bool:
	if not force and not _dirty:
		return true
	data["updated_at_utc"] = Time.get_datetime_string_from_system(true)
	var text := JSON.stringify(data, "\t")

	var f := FileAccess.open(SAVE_TMP_PATH, FileAccess.WRITE)
	if f == null:
		emit_signal("save_error", "tmp_open_failed:%d" % FileAccess.get_open_error())
		return false
	f.store_string(text)
	f.flush()
	f.close()

	if FileAccess.file_exists(SAVE_PATH):
		var da := DirAccess.open("user://")
		if da != null:
			# Best-effort backup, ignore result.
			da.copy(SAVE_PATH, SAVE_BACKUP_PATH)

	var da2 := DirAccess.open("user://")
	if da2 == null:
		emit_signal("save_error", "user_dir_unavailable")
		return false
	var err := da2.rename(SAVE_TMP_PATH, SAVE_PATH)
	if err != OK:
		emit_signal("save_error", "rename_failed:%d" % err)
		return false

	_dirty = false
	emit_signal("saved_to_disk", SAVE_PATH)
	return true


func wipe(reset_in_memory: bool = true) -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	if FileAccess.file_exists(SAVE_BACKUP_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_BACKUP_PATH))
	if reset_in_memory:
		data = _fresh_save()
		_mark_dirty()
		emit_signal("save_updated")

# ---------------------------------------------------------------------------
# Fresh save + migration
# ---------------------------------------------------------------------------

func _fresh_save() -> Dictionary:
	var now := Time.get_datetime_string_from_system(true)
	return {
		"version": SAVE_VERSION,
		"created_at_utc": now,
		"updated_at_utc": now,
		"profile": {
			"name": "Operator",
		},
		"unlocks": {
			"chambers": ["ec_01_boot"],
			"modifiers": [],
			"cosmetics": [],
		},
		"settings": {
			"master_volume": 1.0,
			"sfx_volume": 1.0,
			"music_volume": 0.8,
			"fullscreen": false,
			"reduce_motion": false,
			"screen_shake": true,
		},
		"stats": {
			"runs_started": 0,
			"runs_completed": 0,
			"runs_failed": 0,
			"runs_abandoned": 0,
			"total_time_sec": 0.0,
			"best_time_per_chamber": {},
			"clears_per_chamber": {},
			"deaths_per_chamber": {},
			"daily_streak_current": 0,
			"daily_streak_best": 0,
			"last_daily_date": "",
			"last_daily_outcome": "",
		},
		"runs": [],
		"active_run": {},
	}


func _migrate(loaded: Dictionary) -> Dictionary:
	var v: int = int(loaded.get("version", 0))
	var base := _fresh_save()
	_deep_merge_defaults(loaded, base)
	if v < SAVE_VERSION:
		# Add case-per-version migrations as SAVE_VERSION grows.
		loaded["version"] = SAVE_VERSION
	return loaded


static func _deep_merge_defaults(target: Dictionary, defaults: Dictionary) -> void:
	for k in defaults.keys():
		if not target.has(k):
			target[k] = defaults[k]
		elif typeof(defaults[k]) == TYPE_DICTIONARY and typeof(target[k]) == TYPE_DICTIONARY:
			_deep_merge_defaults(target[k], defaults[k])

# ---------------------------------------------------------------------------
# Unlocks
# ---------------------------------------------------------------------------

func is_chamber_unlocked(chamber_id: String) -> bool:
	return chamber_id in (data.get("unlocks", {}).get("chambers", []) as Array)


func unlock_chamber(chamber_id: String) -> bool:
	return _unlock("chambers", chamber_id, "chamber")


func unlock_modifier(modifier_id: String) -> bool:
	return _unlock("modifiers", modifier_id, "modifier")


func unlock_cosmetic(cosmetic_id: String) -> bool:
	return _unlock("cosmetics", cosmetic_id, "cosmetic")


func unlocked_chambers() -> Array:
	return (data.get("unlocks", {}).get("chambers", []) as Array).duplicate()


func _unlock(bucket: String, id: String, kind: String) -> bool:
	var unlocks: Dictionary = data.get("unlocks", {})
	var arr: Array = unlocks.get(bucket, [])
	if id in arr:
		return false
	arr.append(id)
	unlocks[bucket] = arr
	data["unlocks"] = unlocks
	_mark_dirty()
	emit_signal("unlocks_changed", kind)
	emit_signal("save_updated")
	return true

# ---------------------------------------------------------------------------
# Settings
# ---------------------------------------------------------------------------

func get_setting(key: String, default: Variant = null) -> Variant:
	return (data.get("settings", {}) as Dictionary).get(key, default)


func set_setting(key: String, value: Variant) -> void:
	var s: Dictionary = data.get("settings", {})
	if s.get(key) == value:
		return
	s[key] = value
	data["settings"] = s
	_mark_dirty()
	emit_signal("settings_changed")
	emit_signal("save_updated")

# ---------------------------------------------------------------------------
# Runs + stats
# ---------------------------------------------------------------------------

## Begin recording a run. Returns the in-memory run dict; keep a
## reference and pass it back to `record_run_end`. The run is NOT
## added to history until it ends.
func record_run_start(chamber_id: String, seed: int, mode: String = "standard", modifiers: PackedStringArray = PackedStringArray()) -> Dictionary:
	var run := {
		"id": _new_run_id(),
		"chamber_id": chamber_id,
		"seed": seed,
		"mode": mode,
		"modifiers": Array(modifiers),
		"started_at_utc": Time.get_datetime_string_from_system(true),
		"started_ticks_ms": Time.get_ticks_msec(),
		"ended_at_utc": "",
		"duration_sec": 0.0,
		"outcome": "in_progress",
		"stats": {},
	}
	data["active_run"] = run
	var stats: Dictionary = data.get("stats", {})
	stats["runs_started"] = int(stats.get("runs_started", 0)) + 1
	data["stats"] = stats
	_mark_dirty()
	emit_signal("stats_updated")
	emit_signal("save_updated")
	return run


## Finalize a run and append it to history. `outcome` is one of
## `"clear"`, `"death"`, `"abandoned"`. Extra per-run counters may
## be included in `run_stats`.
func record_run_end(run: Dictionary, outcome: String, run_stats: Dictionary = {}) -> Dictionary:
	if run == null or run.is_empty():
		return {}
	run = run.duplicate(true)
	var started_ms: int = int(run.get("started_ticks_ms", Time.get_ticks_msec()))
	var duration_sec: float = max(0.0, (Time.get_ticks_msec() - started_ms) / 1000.0)
	run["duration_sec"] = duration_sec
	run["ended_at_utc"] = Time.get_datetime_string_from_system(true)
	run["outcome"] = outcome
	var merged_stats: Dictionary = run.get("stats", {}).duplicate(true)
	for k in run_stats.keys():
		merged_stats[k] = run_stats[k]
	run["stats"] = merged_stats
	run.erase("started_ticks_ms")

	var runs: Array = data.get("runs", [])
	runs.push_front(run)
	while runs.size() > RUN_HISTORY_CAP:
		runs.pop_back()
	data["runs"] = runs
	data["active_run"] = {}

	_apply_stats_from_run(run)
	_mark_dirty()
	emit_signal("run_recorded", run)
	emit_signal("stats_updated")
	emit_signal("save_updated")
	return run


func _apply_stats_from_run(run: Dictionary) -> void:
	var stats: Dictionary = data.get("stats", {})
	var chamber_id: String = String(run.get("chamber_id", ""))
	var outcome: String = String(run.get("outcome", ""))
	var duration_sec: float = float(run.get("duration_sec", 0.0))
	var mode: String = String(run.get("mode", "standard"))

	stats["total_time_sec"] = float(stats.get("total_time_sec", 0.0)) + duration_sec

	match outcome:
		"clear":
			stats["runs_completed"] = int(stats.get("runs_completed", 0)) + 1
			var clears: Dictionary = stats.get("clears_per_chamber", {})
			clears[chamber_id] = int(clears.get(chamber_id, 0)) + 1
			stats["clears_per_chamber"] = clears
			var bests: Dictionary = stats.get("best_time_per_chamber", {})
			var prev := float(bests.get(chamber_id, INF))
			if duration_sec > 0.0 and duration_sec < prev:
				bests[chamber_id] = duration_sec
				stats["best_time_per_chamber"] = bests
		"death":
			stats["runs_failed"] = int(stats.get("runs_failed", 0)) + 1
			var deaths: Dictionary = stats.get("deaths_per_chamber", {})
			deaths[chamber_id] = int(deaths.get(chamber_id, 0)) + 1
			stats["deaths_per_chamber"] = deaths
		"abandoned":
			stats["runs_abandoned"] = int(stats.get("runs_abandoned", 0)) + 1

	if mode == "daily":
		var today := daily_datestamp()
		var last: String = String(stats.get("last_daily_date", ""))
		if outcome == "clear":
			if last == _yesterday_datestamp():
				stats["daily_streak_current"] = int(stats.get("daily_streak_current", 0)) + 1
			else:
				stats["daily_streak_current"] = 1
			stats["daily_streak_best"] = max(int(stats.get("daily_streak_best", 0)), int(stats["daily_streak_current"]))
		else:
			stats["daily_streak_current"] = 0
		stats["last_daily_date"] = today
		stats["last_daily_outcome"] = outcome

	data["stats"] = stats


func stats() -> Dictionary:
	return (data.get("stats", {}) as Dictionary).duplicate(true)


func run_history() -> Array:
	return (data.get("runs", []) as Array).duplicate(true)


func active_run() -> Dictionary:
	return (data.get("active_run", {}) as Dictionary).duplicate(true)


func has_active_run() -> bool:
	var r: Dictionary = data.get("active_run", {})
	return not r.is_empty()


func clear_active_run() -> void:
	if data.get("active_run", {}).is_empty():
		return
	data["active_run"] = {}
	_mark_dirty()
	emit_signal("save_updated")

# ---------------------------------------------------------------------------
# Daily seed
# ---------------------------------------------------------------------------

## UTC date stamp used to key the daily challenge (YYYY-MM-DD).
func daily_datestamp(unix_secs: int = -1) -> String:
	var dt: Dictionary
	if unix_secs < 0:
		dt = Time.get_datetime_dict_from_system(true)
	else:
		dt = Time.get_datetime_dict_from_unix_time(unix_secs)
	return "%04d-%02d-%02d" % [int(dt["year"]), int(dt["month"]), int(dt["day"])]


## Deterministic 64-bit seed derived from the UTC date. Same date
## => same seed on every platform.
func daily_seed(datestamp: String = "") -> int:
	if datestamp.is_empty():
		datestamp = daily_datestamp()
	return _fnv1a_64("%s|%s" % [DAILY_SEED_NAMESPACE, datestamp])


## True if the current user has already recorded a daily-mode run
## for today (regardless of outcome).
func has_played_today() -> bool:
	var today := daily_datestamp()
	for r in run_history():
		if String(r.get("mode", "")) == "daily" and String(r.get("ended_at_utc", "")).begins_with(today):
			return true
	return false


func _yesterday_datestamp() -> String:
	var now_unix: int = int(Time.get_unix_time_from_system())
	return daily_datestamp(now_unix - 86400)


static func _fnv1a_64(s: String) -> int:
	# 64-bit FNV-1a. Cast to signed int; GDScript ints are 64-bit.
	var hash_val: int = -3750763034362895579  # 0xcbf29ce484222325
	var bytes := s.to_utf8_buffer()
	for b in bytes:
		hash_val ^= b
		# 0x100000001b3 = 1099511628211
		hash_val = (hash_val * 1099511628211) & 0x7fffffffffffffff
	return hash_val

# ---------------------------------------------------------------------------
# Autosave plumbing
# ---------------------------------------------------------------------------

func _mark_dirty() -> void:
	_dirty = true
	if not autosave_enabled:
		return
	if _autosave_timer != null:
		_autosave_timer.start()


func _on_autosave_timeout() -> void:
	save_to_disk()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		if _dirty:
			save_to_disk(true)


static func _new_run_id() -> String:
	# Not RFC 4122; just unique enough for local history.
	var t := Time.get_unix_time_from_system()
	var r := randi()
	return "r_%d_%d" % [int(t), r]
