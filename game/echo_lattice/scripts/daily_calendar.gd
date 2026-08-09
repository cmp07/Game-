extends RefCounted
class_name DailyCalendar
##
## Pre-authored UTC daily calendar (launch → +89 days).
## Exact date hits win; otherwise fall back to DailySeeds catalog hash.
##

const CALENDAR_PATH: String = "res://content/daily/calendar_90.json"

static var _cache: Dictionary = {}
static var _by_date: Dictionary = {}


static func _ensure_loaded() -> void:
	if not _cache.is_empty():
		return
	if not FileAccess.file_exists(CALENDAR_PATH):
		_cache = {"days": []}
		_by_date = {}
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CALENDAR_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		_cache = {"days": []}
		_by_date = {}
		return
	_cache = parsed
	_by_date = {}
	for row in _cache.get("days", []):
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var d: String = str(row.get("date", ""))
		if d != "":
			_by_date[d] = row


static func reload() -> void:
	_cache = {}
	_by_date = {}
	_ensure_loaded()


static func has_date(date_yyyy_mm_dd: String) -> bool:
	_ensure_loaded()
	return _by_date.has(date_yyyy_mm_dd)


static func pick_for_date(date_yyyy_mm_dd: String) -> Dictionary:
	_ensure_loaded()
	if _by_date.has(date_yyyy_mm_dd):
		var entry: Dictionary = _by_date[date_yyyy_mm_dd]
		return {
			"date": date_yyyy_mm_dd,
			"source": "calendar_90",
			"day_index": int(entry.get("day_index", -1)),
			"seed": entry.get("seed", 0),
			"chamber_id": entry.get("chamber_id", ""),
			"slug": entry.get("slug", ""),
			"friend_code": entry.get("friend_code", ""),
			"variation": entry.get("variation", {}),
			"act": entry.get("act", ""),
			"tag": entry.get("tag", ""),
			"label": entry.get("label", ""),
		}
	var fallback: Dictionary = DailySeeds.pick_for_date(date_yyyy_mm_dd)
	if fallback.is_empty():
		return {}
	fallback["source"] = "catalog_hash"
	fallback["tag"] = "fallback"
	return fallback


static func today_utc() -> Dictionary:
	var t: Dictionary = Time.get_datetime_dict_from_system(true)
	var date := "%04d-%02d-%02d" % [int(t.year), int(t.month), int(t.day)]
	return pick_for_date(date)


static func window() -> Dictionary:
	_ensure_loaded()
	return {
		"start_date": str(_cache.get("start_date", "")),
		"end_date": str(_cache.get("end_date", "")),
		"day_count": int(_cache.get("day_count", 0)),
	}
