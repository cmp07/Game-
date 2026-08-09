class_name SeedClock
extends RefCounted
## Deterministic daily / weekly seed helpers (FNV-1a 64-bit).


const FNV_OFFSET: int = 14695981039346656037
const FNV_PRIME: int = 1099511628211
const MASK64: int = 0xFFFFFFFFFFFFFFFF


static func fnv1a64(text: String) -> int:
	var h: int = FNV_OFFSET
	var bytes := text.to_utf8_buffer()
	for i in bytes.size():
		h ^= int(bytes[i])
		h = (h * FNV_PRIME) & MASK64
	# Keep positive for Godot RNG seeding comfort.
	return h & MASK64


static func daily_datestamp(unix_secs: int = -1) -> String:
	var secs := unix_secs if unix_secs >= 0 else int(Time.get_unix_time_from_system())
	var d := Time.get_datetime_dict_from_unix_time(secs)
	return "%04d-%02d-%02d" % [int(d.year), int(d.month), int(d.day)]


static func iso_week_id(unix_secs: int = -1) -> String:
	## ISO week id as YYYY-Www (UTC).
	var secs := unix_secs if unix_secs >= 0 else int(Time.get_unix_time_from_system())
	var d := Time.get_datetime_dict_from_unix_time(secs)
	var y := int(d.year)
	var m := int(d.month)
	var day := int(d.day)
	# Sakamoto DOW: 0=Sunday .. 6=Saturday → convert to ISO (Mon=1..Sun=7)
	var t := [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
	var yy := y - (1 if m < 3 else 0)
	var dow_sun0: int = (yy + yy / 4 - yy / 100 + yy / 400 + t[m - 1] + day) % 7
	var iso_dow: int = 7 if dow_sun0 == 0 else dow_sun0
	# Ordinal day of year
	var mdays := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if _is_leap(y):
		mdays[1] = 29
	var ordinal := day
	for i in range(m - 1):
		ordinal += mdays[i]
	var week: int = int((ordinal - iso_dow + 10) / 7.0)
	var week_year := y
	if week < 1:
		week_year = y - 1
		week = _iso_weeks_in_year(week_year)
	elif week > _iso_weeks_in_year(y):
		week_year = y + 1
		week = 1
	return "%04d-W%02d" % [week_year, week]


static func daily_seed(cfg: Dictionary, datestamp: String = "") -> int:
	var ns: String = str(cfg.get("daily", {}).get("namespace", "echo-lattice/daily/v2"))
	var key := datestamp if datestamp != "" else daily_datestamp()
	return fnv1a64("%s|%s" % [ns, key])


static func weekly_seed(cfg: Dictionary, week_id: String = "") -> int:
	var ns: String = str(cfg.get("weekly", {}).get("namespace", "echo-lattice/weekly/v2"))
	var key := week_id if week_id != "" else iso_week_id()
	return fnv1a64("%s|%s" % [ns, key])


static func pick_from_pool(seed: int, pool: Array) -> String:
	if pool.is_empty():
		return ""
	var idx := int(seed % pool.size())
	if idx < 0:
		idx += pool.size()
	return str(pool[idx])


static func chamber_rng_seed(key: String, chamber_id: String) -> int:
	return fnv1a64("%s:%s" % [key, chamber_id])


static func yesterday_datestamp(datestamp: String) -> String:
	var parts := datestamp.split("-")
	if parts.size() != 3:
		return ""
	var unix := Time.get_unix_time_from_datetime_dict({
		"year": int(parts[0]), "month": int(parts[1]), "day": int(parts[2]),
		"hour": 12, "minute": 0, "second": 0,
	})
	return daily_datestamp(int(unix) - 86400)


static func previous_iso_week(week_id: String) -> String:
	## Approximate: step back 7 days from Thursday of that ISO week.
	var parts := week_id.split("-W")
	if parts.size() != 2:
		return ""
	var y := int(parts[0])
	var w := int(parts[1])
	# Jan 4 is always in week 1; find Monday of week 1 then add.
	var jan4 := Time.get_unix_time_from_datetime_dict({
		"year": y, "month": 1, "day": 4, "hour": 12, "minute": 0, "second": 0,
	})
	var d4 := Time.get_datetime_dict_from_unix_time(int(jan4))
	var t := [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
	var yy := y
	var dow_sun0: int = (yy + yy / 4 - yy / 100 + yy / 400 + t[0] + 4) % 7
	var iso_dow: int = 7 if dow_sun0 == 0 else dow_sun0
	var week1_monday := int(jan4) - (iso_dow - 1) * 86400
	var target_monday := week1_monday + (w - 1) * 7 * 86400
	return iso_week_id(target_monday - 7 * 86400)


static func _is_leap(y: int) -> bool:
	return (y % 4 == 0 and y % 100 != 0) or (y % 400 == 0)


static func _iso_weeks_in_year(y: int) -> int:
	# Years with 53 weeks: those where Jan 1 or Dec 31 is Thursday.
	var jan1_sun0 := _dow_sun0(y, 1, 1)
	var dec31_sun0 := _dow_sun0(y, 12, 31)
	if jan1_sun0 == 4 or dec31_sun0 == 4:
		return 53
	return 52


static func _dow_sun0(y: int, m: int, day: int) -> int:
	var t := [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
	var yy := y - (1 if m < 3 else 0)
	return (yy + yy / 4 - yy / 100 + yy / 400 + t[m - 1] + day) % 7
