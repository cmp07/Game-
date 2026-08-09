class_name ShortRunPacing
extends RefCounted
## Plans 8–15 minute short-run sessions.


static func ensure(save: Dictionary) -> Dictionary:
	if not save.has("pacing") or typeof(save["pacing"]) != TYPE_DICTIONARY:
		save["pacing"] = {
			"short_runs_completed": 0,
			"last_session_sec": 0.0,
			"best_short_run_sec": 0.0,
			"last_run_end_unix": 0,
		}
	return save["pacing"]


static func plan(cfg: Dictionary, kind: String = "standard", unix_secs: int = -1) -> Dictionary:
	var kinds: Dictionary = cfg.get("short_run", {}).get("kinds", {})
	var spec: Dictionary = kinds.get(kind, kinds.get("standard", {}))
	var count := int(spec.get("chamber_count", 3))
	var budget := int(spec.get("budget_sec", 720))
	var seed_mode := str(spec.get("seed_mode", kind if kind in ["daily", "weekly"] else "standard"))
	var chambers: Array = []
	if seed_mode == "daily":
		var ds := SeedClock.daily_datestamp(unix_secs)
		var seed := SeedClock.daily_seed(cfg, ds)
		var pool: Array = cfg.get("daily", {}).get("pool", [])
		chambers = [SeedClock.pick_from_pool(seed, pool)]
	elif seed_mode == "weekly":
		var wid := SeedClock.iso_week_id(unix_secs)
		var seed := SeedClock.weekly_seed(cfg, wid)
		var pool: Array = cfg.get("weekly", {}).get("pool", [])
		chambers = [SeedClock.pick_from_pool(seed, pool)]
	else:
		# First N Act I chambers as a default short-run ladder.
		var act1: Array = []
		for cid in cfg.get("chambers", {}).keys():
			if int(cfg["chambers"][cid].get("act", 1)) == 1:
				act1.append(str(cid))
		act1.sort()
		for i in mini(count, act1.size()):
			chambers.append(act1[i])
	return {
		"kind": kind,
		"seed_mode": seed_mode,
		"chambers": chambers,
		"budget_sec": budget,
		"min_budget_sec": int(spec.get("min_budget_sec", 480)),
		"max_budget_sec": int(spec.get("max_budget_sec", 900)),
		"copy": "Short Run · ~%d min" % int(round(budget / 60.0)),
	}


static func mark_session(save: Dictionary, cfg: Dictionary, elapsed_sec: float, completed: bool) -> Dictionary:
	var pacing := ensure(save)
	pacing["last_session_sec"] = elapsed_sec
	var result := {"completed_in_budget": false, "overage": false}
	if completed:
		var max_b := float(cfg.get("short_run", {}).get("kinds", {}).get("standard", {}).get("max_budget_sec", 900))
		if elapsed_sec <= max_b:
			pacing["short_runs_completed"] = int(pacing.get("short_runs_completed", 0)) + 1
			result["completed_in_budget"] = true
			var best := float(pacing.get("best_short_run_sec", 0.0))
			if best <= 0.0 or elapsed_sec < best:
				pacing["best_short_run_sec"] = elapsed_sec
		var warn := float(cfg.get("short_run", {}).get("overage_warn_sec", 1080))
		result["overage"] = elapsed_sec > warn
	save["pacing"] = pacing
	return result


static func note_run_end(save: Dictionary, unix_secs: int = -1) -> void:
	var pacing := ensure(save)
	var secs := unix_secs if unix_secs >= 0 else int(Time.get_unix_time_from_system())
	pacing["last_run_end_unix"] = secs


static func check_one_more(save: Dictionary, cfg: Dictionary, unix_secs: int = -1) -> bool:
	var pacing := ensure(save)
	var last := int(pacing.get("last_run_end_unix", 0))
	if last <= 0:
		return false
	var now := unix_secs if unix_secs >= 0 else int(Time.get_unix_time_from_system())
	var window := int(cfg.get("short_run", {}).get("one_more_window_sec", 300))
	return (now - last) <= window and (now - last) >= 0
