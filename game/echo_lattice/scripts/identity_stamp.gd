class_name IdentityStamp
extends RefCounted
##
## Portrait / ledger scoring for identity bosses and Mirror Birth ceremonies.
## Scores echo silhouettes by symmetry, negative-space face, and non-thrash ink.
## Pure Field Ledger fantasy — no psychology jargon.
##

const GRADE_SCRIBBLE := "scribble"
const GRADE_READABLE := "readable"
const GRADE_SIGNED := "signed"

const BIRTH_SLUGS := {
	"mirror_birth": true,
	"mirror_birth_hard": true,
	"looking_glass": true,
	"looking_glass_hard": true,
}


static func is_identity_chamber(data: Dictionary) -> bool:
	if data.is_empty():
		return false
	if str(data.get("teaches", "")) == "identity":
		return true
	if data.get("identity", null) != null and str(data.get("identity", "")) != "":
		return true
	return str(data.get("role", "")) == "boss"


static func is_birth_moment(data: Dictionary) -> bool:
	if data.is_empty():
		return false
	var slug: String = str(data.get("slug", ""))
	if BIRTH_SLUGS.has(slug):
		return true
	var cid: String = str(data.get("content_id", data.get("id", "")))
	return cid.contains("mirror_birth") or cid.contains("looking_glass")


static func should_stamp(data: Dictionary) -> bool:
	return is_identity_chamber(data) or is_birth_moment(data)


static func affects_stars(data: Dictionary) -> bool:
	## Only identity bosses fold portrait metrics into ★ — births are ceremony stamps.
	return is_identity_chamber(data)


static func evaluate_from_chamber(chamber_node: Node) -> Dictionary:
	## Duck-typed for chamber.gd: reads grid, walked, transform_name, chamber, move_count.
	if chamber_node == null:
		return {}
	var data: Dictionary = chamber_node.get("chamber") if typeof(chamber_node.get("chamber")) == TYPE_DICTIONARY else {}
	var grid: Array = chamber_node.get("grid") if typeof(chamber_node.get("grid")) == TYPE_ARRAY else []
	var walked: Dictionary = chamber_node.get("walked") if typeof(chamber_node.get("walked")) == TYPE_DICTIONARY else {}
	var transform_name: String = str(chamber_node.get("transform_name"))
	var move_count: int = int(chamber_node.get("move_count"))
	var echo_tile: int = 5  ## Tile.ECHO_WALL in chamber.gd
	if chamber_node.get("Tile") != null:
		# Enum access via script constant when available.
		pass
	var cells: Array = collect_echo_cells(grid, echo_tile)
	var path_unique: int = walked.size()
	return evaluate(cells, transform_name, path_unique, move_count, data)


static func collect_echo_cells(grid: Array, echo_tile: int = 5) -> Array:
	var cells: Array = []
	for y in range(grid.size()):
		var row = grid[y]
		if typeof(row) != TYPE_ARRAY:
			continue
		for x in range(row.size()):
			if int(row[x]) == echo_tile:
				cells.append(Vector2i(x, y))
	return cells


static func evaluate(
	echo_cells: Array,
	transform_name: String,
	path_unique: int,
	move_count: int,
	data: Dictionary = {}
) -> Dictionary:
	var symmetry := _symmetry_score(echo_cells, transform_name)
	var negative_space := _negative_space_score(echo_cells)
	var non_thrash := _non_thrash_score(path_unique, move_count)
	# Weights favor the boss promise: readable silhouette first, intentional ink second.
	var portrait: float = clampf(0.42 * symmetry + 0.33 * negative_space + 0.25 * non_thrash, 0.0, 1.0)
	var grade := GRADE_SCRIBBLE
	if portrait >= 0.72:
		grade = GRADE_SIGNED
	elif portrait >= 0.45:
		grade = GRADE_READABLE
	var mask: Array = _pack_mask(echo_cells)
	var identity_tag: String = str(data.get("identity", ""))
	if identity_tag == "" and is_birth_moment(data):
		identity_tag = "birth_" + str(data.get("slug", "mirror"))
	return {
		"symmetry": snappedf(symmetry, 0.001),
		"negative_space": snappedf(negative_space, 0.001),
		"non_thrash": snappedf(non_thrash, 0.001),
		"portrait": snappedf(portrait, 0.001),
		"grade": grade,
		"mask": mask,
		"echo_count": echo_cells.size(),
		"identity_tag": identity_tag,
		"content_id": str(data.get("content_id", data.get("id", ""))),
		"title": str(data.get("title", "")),
		"transform": transform_name,
		"birth": is_birth_moment(data),
		"identity_boss": is_identity_chamber(data),
		"portrait_stars": stars_from_portrait(portrait),
	}


static func stars_from_portrait(portrait: float) -> int:
	if portrait >= 0.72:
		return 3
	if portrait >= 0.45:
		return 2
	return 1


static func merge_stars(move_stars: int, stamp: Dictionary) -> int:
	if stamp.is_empty():
		return move_stars
	var portrait_stars: int = int(stamp.get("portrait_stars", 1))
	return maxi(clampi(move_stars, 1, 3), clampi(portrait_stars, 1, 3))


static func _symmetry_score(cells: Array, transform_name: String) -> float:
	if cells.is_empty():
		return 0.0
	var set := {}
	var min_x := 999
	var max_x := -1
	var min_y := 999
	var max_y := -1
	for c in cells:
		var p: Vector2i = c
		set[p] = true
		min_x = mini(min_x, p.x)
		max_x = maxi(max_x, p.x)
		min_y = mini(min_y, p.y)
		max_y = maxi(max_y, p.y)
	var mid_x: float = float(min_x + max_x) * 0.5
	var mid_y: float = float(min_y + max_y) * 0.5
	var want_v := false
	var want_h := false
	match transform_name:
		"mirror_v", "mirror_v_then_h":
			want_v = true
			want_h = transform_name == "mirror_v_then_h"
		"mirror_h":
			want_h = true
		"rotate_180":
			want_v = true
			want_h = true
		"thicken", "invert":
			# Soft both-axis rhyme — calcify / invert still want a composed blot.
			want_v = true
			want_h = true
		_:
			want_v = true
	var scores: Array = []
	if want_v:
		scores.append(_axis_match(set, cells, true, mid_x, mid_y))
	if want_h:
		scores.append(_axis_match(set, cells, false, mid_x, mid_y))
	if scores.is_empty():
		return 0.0
	var acc := 0.0
	for s in scores:
		acc += float(s)
	return acc / float(scores.size())


static func _axis_match(set: Dictionary, cells: Array, vertical_axis: bool, mid_x: float, mid_y: float) -> float:
	var hits := 0
	for c in cells:
		var p: Vector2i = c
		var mirror: Vector2i
		if vertical_axis:
			# Reflect across vertical axis (x flips).
			var dx: float = float(p.x) - mid_x
			mirror = Vector2i(int(round(mid_x - dx)), p.y)
		else:
			var dy: float = float(p.y) - mid_y
			mirror = Vector2i(p.x, int(round(mid_y - dy)))
		if set.has(mirror):
			hits += 1
	return float(hits) / float(cells.size())


static func _negative_space_score(cells: Array) -> float:
	## Reward a single coherent blot with face-like fill of its bounding box.
	if cells.is_empty():
		return 0.0
	var min_x := 999
	var max_x := -1
	var min_y := 999
	var max_y := -1
	var set := {}
	for c in cells:
		var p: Vector2i = c
		set[p] = true
		min_x = mini(min_x, p.x)
		max_x = maxi(max_x, p.x)
		min_y = mini(min_y, p.y)
		max_y = maxi(max_y, p.y)
	var bw: int = maxi(1, max_x - min_x + 1)
	var bh: int = maxi(1, max_y - min_y + 1)
	var area: int = bw * bh
	var fill: float = float(cells.size()) / float(area)
	# Ideal "face" fill sits in a mid band — sparse scribble and solid blot both fail.
	var fill_score: float = 1.0 - clampf(abs(fill - 0.38) / 0.38, 0.0, 1.0)
	var largest: int = _largest_component(set)
	var cohesion: float = float(largest) / float(cells.size())
	var aspect: float = float(mini(bw, bh)) / float(maxi(bw, bh))
	return clampf(0.45 * fill_score + 0.40 * cohesion + 0.15 * aspect, 0.0, 1.0)


static func _largest_component(set: Dictionary) -> int:
	var seen := {}
	var best := 0
	for key in set.keys():
		var start: Vector2i = key
		if seen.has(start):
			continue
		var q: Array = [start]
		seen[start] = true
		var count := 0
		while q.size() > 0:
			var cur: Vector2i = q.pop_front()
			count += 1
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var n: Vector2i = cur + d
				if set.has(n) and not seen.has(n):
					seen[n] = true
					q.append(n)
		best = maxi(best, count)
	return best


static func _non_thrash_score(path_unique: int, move_count: int) -> float:
	if move_count <= 0:
		return 0.0
	var ratio: float = float(path_unique) / float(move_count)
	# Light revisit is human; thrash (ratio << 0.55) reads as scribble.
	return clampf((ratio - 0.35) / 0.55, 0.0, 1.0)


static func _pack_mask(cells: Array) -> Dictionary:
	## Compact row strings for save + stamp card draw. Empty → {}.
	if cells.is_empty():
		return {}
	var min_x := 999
	var max_x := -1
	var min_y := 999
	var max_y := -1
	var set := {}
	for c in cells:
		var p: Vector2i = c
		set[p] = true
		min_x = mini(min_x, p.x)
		max_x = maxi(max_x, p.x)
		min_y = mini(min_y, p.y)
		max_y = maxi(max_y, p.y)
	var bw: int = maxi(1, max_x - min_x + 1)
	var bh: int = maxi(1, max_y - min_y + 1)
	var rows: Array = []
	for y in range(min_y, max_y + 1):
		var line := ""
		for x in range(min_x, max_x + 1):
			line += "#" if set.has(Vector2i(x, y)) else "."
		rows.append(line)
	return {
		"w": bw,
		"h": bh,
		"rows": rows,
	}
