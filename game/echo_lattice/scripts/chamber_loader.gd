extends RefCounted
class_name ChamberLoader
##
## Loads playable v2 chamber JSON from res://content/chambers/.
## Fail-closed: invalid files are skipped with a push_error diagnostic.
##

const CHAMBERS_DIR: String = "res://content/chambers"
const GRID_W: int = 24
const GRID_H: int = 14

const VALID_TRANSFORMS: Array = [
	"none", "mirror_v", "mirror_h", "rotate_180", "thicken", "mirror_v_then_h", "invert"
]
const VALID_ACTS: Array = ["induction", "reflection", "pressure", "mastery"]


static func load_all() -> Array:
	var records: Array = []
	var dir := DirAccess.open(CHAMBERS_DIR)
	if dir == null:
		push_error("ChamberLoader: cannot open %s" % CHAMBERS_DIR)
		return records
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	var paths: Array = []
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			paths.append("%s/%s" % [CHAMBERS_DIR, file_name])
		file_name = dir.get_next()
	dir.list_dir_end()
	paths.sort()
	for path in paths:
		var rec: Dictionary = load_one(str(path))
		if not rec.is_empty():
			records.append(rec)
	records.sort_custom(func(a, b): return int(a.get("index", 0)) < int(b.get("index", 0)))
	return records


static func load_one(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("ChamberLoader: missing %s" % path)
		return {}
	var text: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("ChamberLoader: JSON root not object in %s" % path)
		return {}
	var raw: Dictionary = parsed
	var err: String = validate(raw, path)
	if err != "":
		push_error("ChamberLoader: %s" % err)
		return {}
	return _normalize(raw)


static func validate(raw: Dictionary, path: String = "") -> String:
	var id: String = str(raw.get("id", ""))
	if id == "":
		return "%s: missing id" % path
	if not VALID_ACTS.has(str(raw.get("act", ""))):
		return "%s: bad act" % id
	var transform: String = str(raw.get("transform", ""))
	if not VALID_TRANSFORMS.has(transform):
		return "%s: bad transform %s" % [id, transform]
	var rows: Array = raw.get("map", raw.get("lattice", {}).get("cells", []))
	if typeof(rows) != TYPE_ARRAY or rows.size() != GRID_H:
		return "%s: map must be %d rows" % [id, GRID_H]
	var p_count := 0
	var g_count := 0
	var c_count := 0
	for y in range(GRID_H):
		var row: String = str(rows[y])
		if row.length() > GRID_W:
			return "%s: row %d too long" % [id, y]
		for x in range(mini(row.length(), GRID_W)):
			var ch: String = row.substr(x, 1)
			match ch:
				"P":
					p_count += 1
				"G":
					g_count += 1
				"C":
					c_count += 1
				"#", ".", " ", "E", "*":
					pass
				_:
					return "%s: illegal glyph '%s' at %d,%d" % [id, ch, x, y]
	if p_count != 1 or g_count != 1:
		return "%s: need exactly one P and one G (P=%d G=%d)" % [id, p_count, g_count]
	if transform != "none" and c_count < 1:
		return "%s: non-none transform needs a checkpoint" % id
	return ""


static func _normalize(raw: Dictionary) -> Dictionary:
	var rows: Array = []
	var src_rows: Array = raw.get("map", [])
	if src_rows.is_empty() and raw.has("lattice"):
		src_rows = raw["lattice"].get("cells", [])
	for y in range(GRID_H):
		var row: String = str(src_rows[y]) if y < src_rows.size() else ""
		if row.length() > GRID_W:
			row = row.substr(0, GRID_W)
		while row.length() < GRID_W:
			row += " "
		rows.append(row)
	var idx: int = int(raw.get("index", 0))
	return {
		"id": idx,
		"index": idx,
		"content_id": str(raw.get("id", "")),
		"slug": str(raw.get("slug", "")),
		"title": str(raw.get("title", "")),
		"caption": str(raw.get("caption", "")),
		"transform": str(raw.get("transform", "none")),
		"act": str(raw.get("act", "induction")),
		"act_index": int(raw.get("act_index", 0)),
		"role": str(raw.get("role", "lesson")),
		"teaches": str(raw.get("teaches", "")),
		"difficulty": int(raw.get("difficulty", 0)),
		"seed": int(raw.get("seed", 0)),
		"daily_eligible": bool(raw.get("daily_eligible", false)),
		"identity": raw.get("identity", null),
		"rewrite": raw.get("rewrite", {}),
		"hard_variant_of": raw.get("hard_variant_of", null),
		"par_moves": int(raw.get("par_moves", 0)),
		"hints": raw.get("hints", []) if typeof(raw.get("hints", [])) == TYPE_ARRAY else [],
		"onboarding": bool(raw.get("onboarding", false)),
		"spectacle": bool(raw.get("spectacle", false)),
		"map": rows,
		"raw": raw,
	}


static func _soft_hard_from_record(rec: Dictionary) -> float:
	## Authored dial lives on rewrite{} (content bible); identity{} is optional.
	for key in ["rewrite", "identity"]:
		var block = rec.get(key, null)
		if typeof(block) == TYPE_DICTIONARY and block.has("soft_hard_bias"):
			return float(block.get("soft_hard_bias"))
	var raw = rec.get("raw", null)
	if typeof(raw) == TYPE_DICTIONARY:
		for key2 in ["rewrite", "identity"]:
			var block2 = raw.get(key2, null)
			if typeof(block2) == TYPE_DICTIONARY and block2.has("soft_hard_bias"):
				return float(block2.get("soft_hard_bias"))
	return -1.0


static func to_playable(rec: Dictionary) -> Dictionary:
	## Shape expected by chamber.gd / GameState (PR #48).
	var raw: Dictionary = rec.get("raw", {}) if typeof(rec.get("raw", {})) == TYPE_DICTIONARY else {}
	var rewrite: Dictionary = raw.get("rewrite", {}) if typeof(raw.get("rewrite", {})) == TYPE_DICTIONARY else {}
	var rewrite_cap: int = int(rewrite.get("cap", -1))
	if rewrite_cap < 0:
		# Fallback: allow every authored checkpoint to fire.
		var rows: Array = rec.get("map", [])
		var cps := 0
		for row in rows:
			var s := str(row)
			for i in range(s.length()):
				if s.substr(i, 1) == "C":
					cps += 1
		rewrite_cap = maxi(cps, 1)
	var soft_hard := _soft_hard_from_record(rec)
	var hints: Array = []
	if typeof(rec.get("hints", null)) == TYPE_ARRAY:
		hints = (rec.get("hints") as Array).duplicate()
	elif typeof(raw.get("hints", null)) == TYPE_ARRAY:
		hints = (raw.get("hints") as Array).duplicate()
	return {
		"id": int(rec.get("id", 0)),
		"title": str(rec.get("title", "")),
		"caption": str(rec.get("caption", "")),
		"transform": str(rec.get("transform", "none")),
		"map": rec.get("map", []),
		"act": str(rec.get("act", "")),
		"role": str(rec.get("role", "")),
		"content_id": str(rec.get("content_id", "")),
		"slug": str(rec.get("slug", "")),
		"teaches": str(rec.get("teaches", "")),
		"identity": rec.get("identity", null),
		"seed": int(rec.get("seed", 0)),
		"daily_eligible": bool(rec.get("daily_eligible", false)),
		"rewrite_cap": rewrite_cap,
		"soft_hard_bias": soft_hard,
		"act_index": int(rec.get("act_index", 0)),
		"hints": hints,
		"onboarding": bool(rec.get("onboarding", raw.get("onboarding", false))),
		"spectacle": bool(rec.get("spectacle", raw.get("spectacle", false))),
		"hard_variant_of": str(rec.get("hard_variant_of", "")) if rec.get("hard_variant_of", null) != null else "",
	}
