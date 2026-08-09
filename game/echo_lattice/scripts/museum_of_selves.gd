class_name MuseumOfSelves
extends RefCounted
##
## Thin habit archive — Field Ledger fossils of who you were on a clear.
## Retention without genre mash: no cosmetics shop, no race ladder, no MX.
## Ghost path is for replay vignette only (chalk handwriting, not PvP).
##

const DEFAULT_CAP: int = 48
const DEFAULT_STRIDE: int = 2
const MAX_PATH_POINTS: int = 96

const TITLE_TEMPLATES := {
	"right_leaner": "The Right-Leaner of {chamber}",
	"looper": "The Looper of {chamber}",
	"zigzagger": "The Zigzag of {chamber}",
	"balanced": "The Balanced Echo of {chamber}",
	"default": "A Self from {chamber}",
}


static func ensure(museum: Dictionary, cap: int = DEFAULT_CAP) -> Dictionary:
	var out: Dictionary = museum.duplicate(true) if not museum.is_empty() else {}
	if typeof(out.get("selves", null)) != TYPE_ARRAY:
		out["selves"] = []
	out["cap"] = clampi(int(out.get("cap", cap)), 1, 128)
	return out


static func compact_path(path: Array, stride: int = DEFAULT_STRIDE) -> Array:
	## Compact [x,y] pairs for save. Keeps first/last; stride samples middle.
	if path.is_empty():
		return []
	var step: int = maxi(1, stride)
	var packed: Array = []
	var i := 0
	while i < path.size():
		packed.append(_pack_point(path[i]))
		i += step
	var last = _pack_point(path[path.size() - 1])
	if packed.is_empty() or packed[packed.size() - 1] != last:
		packed.append(last)
	while packed.size() > MAX_PATH_POINTS:
		# Drop every other middle sample when over budget.
		var thinned: Array = [packed[0]]
		for j in range(1, packed.size() - 1, 2):
			thinned.append(packed[j])
		thinned.append(packed[packed.size() - 1])
		packed = thinned
	return packed


static func title_for(archetype: String, chamber_title: String) -> String:
	var arch := archetype if TITLE_TEMPLATES.has(archetype) else "default"
	var tmpl: String = str(TITLE_TEMPLATES.get(arch, TITLE_TEMPLATES["default"]))
	var name := chamber_title if chamber_title != "" else "the Lattice"
	return tmpl.replace("{chamber}", name)


static func build_habit_snapshot(sig: Dictionary, dominant: String, archetype_id: String) -> Dictionary:
	return {
		"dominant": dominant if dominant != "" else "none",
		"dominant_bias": snappedf(float(sig.get("dominant_bias", 0.0)), 0.001),
		"turn_rate": snappedf(float(sig.get("turn_rate", 0.0)), 0.001),
		"backtrack_rate": snappedf(float(sig.get("backtrack_rate", 0.0)), 0.001),
		"archetype": archetype_id if archetype_id != "" else "balanced",
		"fingerprint": int(sig.get("total_steps", 0)) ^ int(round(float(sig.get("dominant_bias", 0.0)) * 1000.0)),
	}


static func stamp_plaque(stamp: Dictionary) -> Dictionary:
	## Compact identity / birth stamp for museum plaque (mask + grade only).
	if stamp.is_empty():
		return {}
	var plaque := {
		"grade": str(stamp.get("grade", "")),
		"portrait": snappedf(float(stamp.get("portrait", 0.0)), 0.001),
		"identity_tag": str(stamp.get("identity_tag", "")),
		"birth": bool(stamp.get("birth", false)),
		"identity_boss": bool(stamp.get("identity_boss", false)),
	}
	var mask = stamp.get("mask", {})
	if typeof(mask) == TYPE_DICTIONARY and not mask.is_empty():
		plaque["mask"] = (mask as Dictionary).duplicate(true)
	return plaque


static func archive_clear(
	museum: Dictionary,
	chamber_data: Dictionary,
	chamber_index: int,
	mode: String,
	seed_int: int,
	stars: int,
	moves: int,
	undos: int,
	habit: Dictionary,
	path: Array,
	stamp: Dictionary = {},
	stride: int = DEFAULT_STRIDE
) -> Dictionary:
	## Returns { "museum": updated, "self": row }. Only call on clears.
	var state := ensure(museum)
	var chamber_title: String = str(chamber_data.get("title", ""))
	var content_id: String = str(chamber_data.get("content_id", chamber_data.get("id", "")))
	var archetype: String = str(habit.get("archetype", "balanced"))
	var title := title_for(archetype, chamber_title)
	var compact := compact_path(path, stride)
	var serial: int = int(state.get("selves", []).size()) + 1
	var day: String = _utc_datestamp().replace("-", "")
	var row := {
		"id": "self_%s_%04d" % [day, serial],
		"created_at": Time.get_datetime_string_from_system(true),
		"chamber_id": content_id,
		"chamber_index": chamber_index,
		"mode": mode if mode != "" else "standard",
		"seed": seed_int,
		"stars": clampi(stars, 0, 3),
		"moves": maxi(0, moves),
		"undos": maxi(0, undos),
		"outcome": "clear",
		"habit": habit.duplicate(true) if not habit.is_empty() else {},
		"ghost": {"stride": maxi(1, stride), "path": compact},
		"title": title,
		"stamp": stamp_plaque(stamp),
	}
	var selves: Array = state["selves"]
	selves.push_front(row)
	var cap: int = int(state.get("cap", DEFAULT_CAP))
	while selves.size() > cap:
		selves.pop_back()
	state["selves"] = selves
	return {"museum": state, "self": row}


static func count(museum: Dictionary) -> int:
	var selves = museum.get("selves", [])
	return selves.size() if typeof(selves) == TYPE_ARRAY else 0


static func get_self(museum: Dictionary, self_id: String) -> Dictionary:
	for row in museum.get("selves", []):
		if typeof(row) == TYPE_DICTIONARY and str(row.get("id", "")) == self_id:
			return row
	return {}


static func unpack_path(ghost: Dictionary) -> Array:
	## Returns Array[Vector2i] from packed ghost.path.
	var out: Array = []
	if typeof(ghost) != TYPE_DICTIONARY:
		return out
	var path = ghost.get("path", [])
	if typeof(path) != TYPE_ARRAY:
		return out
	for p in path:
		out.append(_unpack_point(p))
	return out


static func sanitize_museum(raw: Variant, cap: int = DEFAULT_CAP) -> Dictionary:
	## Soft-validate untrusted museum blob for load / cloud.
	if typeof(raw) != TYPE_DICTIONARY:
		return {"selves": [], "cap": cap}
	var museum: Dictionary = raw
	var out_cap: int = clampi(int(museum.get("cap", cap)), 1, 128)
	var selves_in = museum.get("selves", [])
	var selves: Array = []
	if typeof(selves_in) == TYPE_ARRAY:
		for row in selves_in:
			if typeof(row) != TYPE_DICTIONARY:
				continue
			var clean := _sanitize_self(row as Dictionary)
			if not clean.is_empty():
				selves.append(clean)
			if selves.size() >= out_cap:
				break
	return {"selves": selves, "cap": out_cap}


static func _sanitize_self(row: Dictionary) -> Dictionary:
	var id := str(row.get("id", ""))
	if id == "" or id.length() > 64:
		return {}
	if str(row.get("outcome", "clear")) != "clear":
		return {}
	var habit = row.get("habit", {})
	if typeof(habit) != TYPE_DICTIONARY:
		habit = {}
	var ghost = row.get("ghost", {})
	if typeof(ghost) != TYPE_DICTIONARY:
		ghost = {"stride": DEFAULT_STRIDE, "path": []}
	var path = ghost.get("path", [])
	var clean_path: Array = []
	if typeof(path) == TYPE_ARRAY:
		for p in path:
			clean_path.append(_pack_point(p))
			if clean_path.size() >= MAX_PATH_POINTS:
				break
	var stamp = row.get("stamp", {})
	if typeof(stamp) != TYPE_DICTIONARY:
		stamp = {}
	return {
		"id": id,
		"created_at": str(row.get("created_at", "")).substr(0, 40),
		"chamber_id": str(row.get("chamber_id", "")).substr(0, 128),
		"chamber_index": clampi(int(row.get("chamber_index", 0)), 0, 1023),
		"mode": str(row.get("mode", "standard")).substr(0, 32),
		"seed": int(row.get("seed", 0)),
		"stars": clampi(int(row.get("stars", 0)), 0, 3),
		"moves": maxi(0, int(row.get("moves", 0))),
		"undos": maxi(0, int(row.get("undos", 0))),
		"outcome": "clear",
		"habit": {
			"dominant": str(habit.get("dominant", "none")).substr(0, 16),
			"dominant_bias": clampf(float(habit.get("dominant_bias", 0.0)), 0.0, 1.0),
			"turn_rate": clampf(float(habit.get("turn_rate", 0.0)), 0.0, 1.0),
			"backtrack_rate": clampf(float(habit.get("backtrack_rate", 0.0)), 0.0, 1.0),
			"archetype": str(habit.get("archetype", "balanced")).substr(0, 32),
			"fingerprint": int(habit.get("fingerprint", 0)),
		},
		"ghost": {
			"stride": clampi(int(ghost.get("stride", DEFAULT_STRIDE)), 1, 8),
			"path": clean_path,
		},
		"title": str(row.get("title", "")).substr(0, 160),
		"stamp": stamp_plaque(stamp as Dictionary),
	}


static func _pack_point(p) -> Array:
	if typeof(p) == TYPE_VECTOR2I:
		return [p.x, p.y]
	if typeof(p) == TYPE_ARRAY and p.size() >= 2:
		return [int(p[0]), int(p[1])]
	if typeof(p) == TYPE_DICTIONARY:
		return [int(p.get("x", 0)), int(p.get("y", 0))]
	return [0, 0]


static func _unpack_point(p) -> Vector2i:
	if typeof(p) == TYPE_VECTOR2I:
		return p
	if typeof(p) == TYPE_ARRAY and p.size() >= 2:
		return Vector2i(int(p[0]), int(p[1]))
	if typeof(p) == TYPE_DICTIONARY:
		return Vector2i(int(p.get("x", 0)), int(p.get("y", 0)))
	return Vector2i.ZERO


static func _utc_datestamp() -> String:
	var dt := Time.get_datetime_dict_from_system(true)
	return "%04d-%02d-%02d" % [int(dt.year), int(dt.month), int(dt.day)]
