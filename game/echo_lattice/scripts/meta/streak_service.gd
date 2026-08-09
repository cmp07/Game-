class_name StreakService
extends RefCounted
## Play / daily-clear / weekly-clear streaks (UTC).


static func ensure(save: Dictionary) -> Dictionary:
	if not save.has("streaks") or typeof(save["streaks"]) != TYPE_DICTIONARY:
		save["streaks"] = {
			"play_current": 0, "play_best": 0, "play_last_date": "",
			"daily_clear_current": 0, "daily_clear_best": 0, "daily_last_date": "",
			"weekly_clear_current": 0, "weekly_clear_best": 0, "weekly_last_id": "",
		}
	return save["streaks"]


static func on_run_end(save: Dictionary, mode: String, outcome: String, unix_secs: int = -1) -> void:
	var streaks := ensure(save)
	var date := SeedClock.daily_datestamp(unix_secs)
	_touch_play(streaks, date)

	if mode == "daily":
		if outcome == "clear":
			_extend_daily_clear(streaks, date)
		else:
			streaks["daily_clear_current"] = 0
			streaks["daily_last_date"] = date
	elif mode == "weekly":
		var week := SeedClock.iso_week_id(unix_secs)
		if outcome == "clear":
			_extend_weekly_clear(streaks, week)
		else:
			streaks["weekly_clear_current"] = 0
			streaks["weekly_last_id"] = week


static func _touch_play(streaks: Dictionary, date: String) -> void:
	var last := str(streaks.get("play_last_date", ""))
	if last == date:
		return
	if last == "" or last == SeedClock.yesterday_datestamp(date):
		streaks["play_current"] = int(streaks.get("play_current", 0)) + 1
	else:
		streaks["play_current"] = 1
	streaks["play_last_date"] = date
	streaks["play_best"] = maxi(int(streaks.get("play_best", 0)), int(streaks["play_current"]))


static func _extend_daily_clear(streaks: Dictionary, date: String) -> void:
	var last := str(streaks.get("daily_last_date", ""))
	if last == date:
		# Already recorded today — keep current (overwrite attempt).
		return
	if last == SeedClock.yesterday_datestamp(date):
		streaks["daily_clear_current"] = int(streaks.get("daily_clear_current", 0)) + 1
	else:
		streaks["daily_clear_current"] = 1
	streaks["daily_last_date"] = date
	streaks["daily_clear_best"] = maxi(
		int(streaks.get("daily_clear_best", 0)), int(streaks["daily_clear_current"])
	)


static func _extend_weekly_clear(streaks: Dictionary, week: String) -> void:
	var last := str(streaks.get("weekly_last_id", ""))
	if last == week:
		return
	if last != "" and last == SeedClock.previous_iso_week(week):
		streaks["weekly_clear_current"] = int(streaks.get("weekly_clear_current", 0)) + 1
	else:
		streaks["weekly_clear_current"] = 1
	streaks["weekly_last_id"] = week
	streaks["weekly_clear_best"] = maxi(
		int(streaks.get("weekly_clear_best", 0)), int(streaks["weekly_clear_current"])
	)
