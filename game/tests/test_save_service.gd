extends SceneTree
##
## Headless smoke tests for SaveService + ChamberCatalog.
##
## Run with:
##   godot --headless --path game -s tests/test_save_service.gd
##
## Exits with non-zero code on the first assertion failure.
##

const ChamberCatalogScript := preload("res://scripts/chamber_catalog.gd")

var failures: Array[String] = []


func _init() -> void:
	print("[test_save_service] booting")
	# SaveService is autoloaded on the root; grab it.
	# Deliberately untyped so we can call its methods without
	# needing a `class_name` on the autoload (which would collide
	# with the autoload identifier).
	var save = root.get_node_or_null("SaveService")
	if save == null:
		save = load("res://scripts/save_service.gd").new()
		root.add_child(save)

	save.autosave_enabled = false
	save.wipe(true)

	_test_fresh_defaults(save)
	_test_daily_seed_determinism(save)
	_test_unlock_cycle(save)
	_test_run_lifecycle(save)
	_test_save_load_roundtrip(save)
	_test_migration_missing_fields(save)

	if failures.is_empty():
		print("[test_save_service] OK  all tests passed")
		quit(0)
	else:
		push_error("[test_save_service] FAILED")
		for f in failures:
			push_error("  - " + f)
		quit(1)


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		failures.append(msg)
		push_error("ASSERT FAIL: " + msg)


func _test_fresh_defaults(save) -> void:
	print("  -> fresh_defaults")
	save.wipe(true)
	_assert(save.data.get("version", -1) == save.SAVE_VERSION, "version set on wipe")
	_assert(save.is_chamber_unlocked("ec_01_boot"), "boot chamber unlocked by default")
	_assert(not save.is_chamber_unlocked("ec_05_choir"), "endgame chamber NOT unlocked by default")
	_assert(int(save.stats().get("runs_started", 0)) == 0, "runs_started starts at 0")


func _test_daily_seed_determinism(save) -> void:
	print("  -> daily_seed_determinism")
	var a: int = save.daily_seed("2026-08-08")
	var b: int = save.daily_seed("2026-08-08")
	var c: int = save.daily_seed("2026-08-09")
	_assert(a == b, "same date -> same seed")
	_assert(a != c, "different date -> different seed")
	_assert(a != 0, "seed is nonzero")
	var stamp: String = save.daily_datestamp(1_754_611_200) # 2025-08-08 UTC
	_assert(stamp == "2025-08-08", "datestamp is YYYY-MM-DD (got %s)" % stamp)


func _test_unlock_cycle(save) -> void:
	print("  -> unlock_cycle")
	save.wipe(true)
	var signal_hits := [0]
	var conn := func(_kind): signal_hits[0] += 1
	save.unlocks_changed.connect(conn)

	_assert(save.unlock_chamber("ec_02_hum"), "first unlock returns true")
	_assert(not save.unlock_chamber("ec_02_hum"), "re-unlock returns false")
	_assert(save.is_chamber_unlocked("ec_02_hum"), "unlocked chamber reads back")
	_assert(signal_hits[0] == 1, "unlock signal emitted exactly once")

	save.unlocks_changed.disconnect(conn)

	# Catalog gating.
	_assert(ChamberCatalogScript.is_available("ec_01_boot", save), "boot is always available")
	_assert(not ChamberCatalogScript.is_available("ec_04_silence", save), "silence gated behind runs_completed")


func _test_run_lifecycle(save) -> void:
	print("  -> run_lifecycle")
	save.wipe(true)
	var run: Dictionary = save.record_run_start("ec_01_boot", 42, "standard")
	_assert(save.has_active_run(), "active run present after start")
	_assert(int(save.stats().get("runs_started", 0)) == 1, "runs_started incremented")

	OS.delay_msec(20)
	var record: Dictionary = save.record_run_end(run, "clear", {"kills": 3})
	_assert(not save.has_active_run(), "active run cleared after end")
	_assert(String(record.get("outcome", "")) == "clear", "outcome recorded")
	_assert(int(save.stats().get("runs_completed", 0)) == 1, "runs_completed incremented")
	var clears: Dictionary = save.stats().get("clears_per_chamber", {})
	_assert(int(clears.get("ec_01_boot", 0)) == 1, "per-chamber clear counter incremented")
	var bests: Dictionary = save.stats().get("best_time_per_chamber", {})
	_assert(bests.has("ec_01_boot"), "best time recorded")
	_assert(save.run_history().size() == 1, "run history length 1")

	var newly: Array[String] = ChamberCatalogScript.refresh_unlocks(save)
	_assert("ec_02_hum" in newly, "clearing boot chamber unlocks the next one")
	_assert(save.is_chamber_unlocked("ec_02_hum"), "unlock persisted")

	var run2: Dictionary = save.record_run_start("ec_02_hum", 43, "standard")
	save.record_run_end(run2, "death", {})
	_assert(int(save.stats().get("runs_failed", 0)) == 1, "runs_failed incremented on death")

	for i in range(save.RUN_HISTORY_CAP + 5):
		var r: Dictionary = save.record_run_start("ec_01_boot", i, "standard")
		save.record_run_end(r, "clear", {})
	_assert(save.run_history().size() == save.RUN_HISTORY_CAP, "run history capped at %d" % save.RUN_HISTORY_CAP)


func _test_save_load_roundtrip(save) -> void:
	print("  -> save_load_roundtrip")
	save.wipe(true)
	save.unlock_chamber("ec_02_hum")
	var run: Dictionary = save.record_run_start("ec_02_hum", 777, "daily")
	OS.delay_msec(5)
	save.record_run_end(run, "clear", {"kills": 9})
	_assert(save.save_to_disk(true), "save_to_disk returns true")

	# Perturb in-memory state, then reload.
	save.data["stats"]["runs_completed"] = 999
	_assert(save.load_from_disk(), "load_from_disk returns true")
	_assert(int(save.stats().get("runs_completed", 0)) == 1, "loaded stats overwrite in-memory")
	_assert(save.run_history().size() == 1, "loaded runs restored")
	_assert(String(save.data.get("stats", {}).get("last_daily_date", "")).length() == 10, "daily bookkeeping persisted")


func _test_migration_missing_fields(save) -> void:
	print("  -> migration_missing_fields")
	save.wipe(true)
	# Simulate an ancient save missing several keys.
	var stub := {
		"version": 0,
		"unlocks": {"chambers": ["ec_01_boot"]},
	}
	var f := FileAccess.open(save.SAVE_PATH, FileAccess.WRITE)
	f.store_string(JSON.stringify(stub))
	f.close()
	_assert(save.load_from_disk(), "load_from_disk accepts legacy save")
	_assert(int(save.data.get("version", 0)) == save.SAVE_VERSION, "version upgraded to current")
	_assert(save.data.has("stats"), "stats block backfilled")
	_assert(save.data.has("runs"), "runs block backfilled")
	_assert(save.data.has("settings"), "settings block backfilled")
	_assert(save.is_chamber_unlocked("ec_01_boot"), "legacy unlocks retained")
