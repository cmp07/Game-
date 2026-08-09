extends RefCounted
class_name DailySeeds
##
## Daily-ready seed catalog. Same UTC date → same chamber + variation.
##

const SEEDS_PATH: String = "res://content/daily/seeds.json"


static func fnv1a32(text: String) -> int:
	var h: int = 2166136261
	for i in range(text.length()):
		h = int(h ^ text.unicode_at(i))
		h = int((h * 16777619) & 0xFFFFFFFF)
	return h


static func load_catalog() -> Dictionary:
	if not FileAccess.file_exists(SEEDS_PATH):
		return {"seeds": []}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SEEDS_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"seeds": []}
	return parsed


static func pick_for_date(date_yyyy_mm_dd: String) -> Dictionary:
	var catalog: Dictionary = load_catalog()
	var seeds: Array = catalog.get("seeds", [])
	if seeds.is_empty():
		return {}
	var idx: int = fnv1a32(date_yyyy_mm_dd) % seeds.size()
	var entry: Dictionary = seeds[idx]
	return {
		"date": date_yyyy_mm_dd,
		"index": idx,
		"seed": entry.get("seed", 0),
		"chamber_id": entry.get("chamber_id", ""),
		"slug": entry.get("slug", ""),
		"friend_code": entry.get("friend_code", ""),
		"variation": entry.get("variation", {}),
	}


static func today_utc() -> Dictionary:
	var t: Dictionary = Time.get_datetime_dict_from_system(true)
	var date := "%04d-%02d-%02d" % [int(t.year), int(t.month), int(t.day)]
	return pick_for_date(date)
