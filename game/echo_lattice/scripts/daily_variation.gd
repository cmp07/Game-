extends RefCounted
class_name DailyVariation
##
## Apply authored daily variation axes to a chamber map.
## Geometry only (rotate / reflect). Palette is cosmetic elsewhere.
##


static func apply_to_map(rows: Array, variation: Dictionary) -> Array:
	if variation.is_empty():
		return rows
	var out: Array = []
	for r in rows:
		out.append(str(r))
	var rot: int = int(variation.get("rotate", 0)) % 360
	if rot < 0:
		rot += 360
	match rot:
		90:
			out = _rotate_90(out)
		180:
			out = _rotate_180(out)
		270:
			out = _rotate_90(_rotate_90(_rotate_90(out)))
		_:
			pass
	var reflect: String = str(variation.get("reflect", "none"))
	match reflect:
		"vertical":
			out = _reflect_vertical(out)
		"horizontal":
			out = _reflect_horizontal(out)
		_:
			pass
	return out


static func _rotate_180(rows: Array) -> Array:
	var out: Array = []
	for i in range(rows.size() - 1, -1, -1):
		out.append(_reverse_row(str(rows[i])))
	return out


static func _rotate_90(rows: Array) -> Array:
	## Clockwise 90° on a rectangular glyph grid.
	if rows.is_empty():
		return rows
	var h: int = rows.size()
	var w: int = str(rows[0]).length()
	for r in rows:
		w = maxi(w, str(r).length())
	var out: Array = []
	for x in range(w):
		var line := ""
		for y in range(h - 1, -1, -1):
			var row: String = str(rows[y])
			line += row.substr(x, 1) if x < row.length() else " "
		out.append(line)
	return out


static func _reflect_vertical(rows: Array) -> Array:
	## Mirror across a vertical axis (swap left/right).
	var out: Array = []
	for r in rows:
		out.append(_reverse_row(str(r)))
	return out


static func _reflect_horizontal(rows: Array) -> Array:
	## Mirror across a horizontal axis (swap top/bottom).
	var out: Array = []
	for i in range(rows.size() - 1, -1, -1):
		out.append(str(rows[i]))
	return out


static func _reverse_row(row: String) -> String:
	var chars: PackedStringArray = PackedStringArray()
	for i in range(row.length() - 1, -1, -1):
		chars.append(row.substr(i, 1))
	return "".join(chars)
