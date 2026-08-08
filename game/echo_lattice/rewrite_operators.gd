class_name RewriteOperators
extends RefCounted

## Habit-driven lattice edits.
##
## Each operator is a pure function that reads a Lattice + HabitSignature and
## proposes a list of candidate `Rewrite` objects sorted by desirability (best
## first). Operators must **never** mutate their inputs. Applying a rewrite
## and verifying solvability is the RewriteEngine's job.
##
## A `Rewrite` is a small value dictionary:
##   {
##     "name": String,             # human-readable operator label
##     "score": float,             # higher = more desired
##     "patches": Array<Patch>,    # atomic cell edits, applied together
##     "meta": Dictionary,         # optional diagnostics
##   }
## Each Patch is `{ "pos": Vector2i, "cell": int }`.
##
## Operators available:
##
##   fossilize_hot_cell    — hottest floor cell becomes FOSSIL.
##   place_deflector       — wall placed ahead of the dominant streak.
##   carve_shortcut        — wall bordering the dominant direction is opened.
##   grow_wall_far_from_path — wall grown on an unvisited FLOOR cell adjacent
##                             to an existing wall, farthest from the path.
##   widen_hot_corridor    — floor grown next to a hot cell to open alternates.
##
## `propose_all` returns the union of every operator's candidates, still sorted
## by score desc, tagged with the operator name in `meta.operator`.

const _DIR_UP := Vector2i(0, -1)
const _DIR_DOWN := Vector2i(0, 1)
const _DIR_LEFT := Vector2i(-1, 0)
const _DIR_RIGHT := Vector2i(1, 0)


# -----------------------------------------------------------------------------
# Public entry points
# -----------------------------------------------------------------------------

static func propose_all(lattice: Lattice, sig: HabitSignature) -> Array:
	var all: Array = []
	all.append_array(fossilize_hot_cell(lattice, sig))
	all.append_array(place_deflector(lattice, sig))
	all.append_array(carve_shortcut(lattice, sig))
	all.append_array(grow_wall_far_from_path(lattice, sig))
	all.append_array(widen_hot_corridor(lattice, sig))
	all.sort_custom(func(a, b): return float(a["score"]) > float(b["score"]))
	return all


# -----------------------------------------------------------------------------
# fossilize_hot_cell
# -----------------------------------------------------------------------------
## Freeze the player's favorite cell. Score scales with visit count and how
## dominant the top cell is relative to the rest of the visit histogram.
static func fossilize_hot_cell(lattice: Lattice, sig: HabitSignature) -> Array:
	var out: Array = []
	var hot := sig.hot_cells(6)
	for pos in hot:
		if not lattice.in_bounds(pos):
			continue
		var c := lattice.get_cell(pos)
		if c != Lattice.Cell.FLOOR:
			continue
		if pos == lattice.start or pos == lattice.goal:
			continue
		var visits: int = int(sig.visit_counts.get(pos, 0))
		if visits < 2:
			continue
		var score := 1.0 + float(visits) + 0.5 * sig.dominant_bias
		out.append(_mk("fossilize_hot_cell", score, [
			_patch(pos, Lattice.Cell.FOSSIL),
		], {"operator": "fossilize_hot_cell", "cell": pos, "visits": visits}))
	return out


# -----------------------------------------------------------------------------
# place_deflector
# -----------------------------------------------------------------------------
## For every straight streak of length >=3 along the dominant direction, place
## a wall one step past the end of the streak to force a turn on the next run.
## Candidates that already have a wall in the target cell are skipped.
static func place_deflector(lattice: Lattice, sig: HabitSignature) -> Array:
	var out: Array = []
	if sig.total_steps == 0:
		return out
	if sig.dominant_bias < 0.35:
		# Too spread out — no clear "line" to deflect.
		return out
	var dom := sig.dominant_dir
	if dom == Vector2i.ZERO:
		return out
	# Scan visit_counts for cells that sit on a streak: any cell whose neighbour
	# in `dom` was also visited. The "end of streak" is a visited cell whose
	# neighbour in `dom` is an in-bounds FLOOR and further-out neighbour is not
	# visited (or wall).
	var visited: Dictionary = sig.visit_counts
	var candidates: Array = []
	for cell in visited.keys():
		var pos: Vector2i = cell
		var back := pos - dom
		var ahead := pos + dom
		if not visited.has(back):
			continue
		if visited.has(ahead):
			continue
		if not lattice.in_bounds(ahead):
			continue
		if lattice.get_cell(ahead) != Lattice.Cell.FLOOR:
			continue
		if ahead == lattice.start or ahead == lattice.goal:
			continue
		var streak_len := _measure_streak_back(pos, -dom, visited)
		if streak_len < 3:
			continue
		var score := 0.5 + float(streak_len) + 1.5 * sig.dominant_bias
		candidates.append({"pos": ahead, "score": score, "streak": streak_len})
	candidates.sort_custom(func(a, b): return a["score"] > b["score"])
	for c in candidates:
		out.append(_mk("place_deflector", c["score"], [
			_patch(c["pos"], Lattice.Cell.WALL),
		], {"operator": "place_deflector", "cell": c["pos"], "streak": c["streak"], "dir": dom}))
	return out


# -----------------------------------------------------------------------------
# carve_shortcut
# -----------------------------------------------------------------------------
## Open a wall that separates two visited cells along the dominant axis. This
## rewards the player's committed direction and gives future runs a
## visibly-changed geometry to explore. Only carves WALL -> FLOOR (never
## FOSSIL, so fossils remain permanent scars).
static func carve_shortcut(lattice: Lattice, sig: HabitSignature) -> Array:
	var out: Array = []
	if sig.total_steps == 0:
		return out
	var axes: Array[Vector2i] = _dominant_axis_dirs(sig.dominant_dir)
	if axes.is_empty():
		return out
	var visited: Dictionary = sig.visit_counts
	var seen := {}
	for cell in visited.keys():
		var pos: Vector2i = cell
		for axis in axes:
			var candidate := pos + axis
			if not lattice.in_bounds(candidate):
				continue
			if lattice.get_cell(candidate) != Lattice.Cell.WALL:
				continue
			var beyond := candidate + axis
			if not visited.has(beyond) and not lattice.is_passable(beyond):
				continue
			var key := "%d,%d" % [candidate.x, candidate.y]
			if seen.has(key):
				continue
			seen[key] = true
			var score := 0.75 + 1.5 * sig.dominant_bias
			if visited.has(beyond):
				score += 0.5
			out.append(_mk("carve_shortcut", score, [
				_patch(candidate, Lattice.Cell.FLOOR),
			], {"operator": "carve_shortcut", "cell": candidate, "axis": axis}))
	out.sort_custom(func(a, b): return float(a["score"]) > float(b["score"]))
	return out


# -----------------------------------------------------------------------------
# grow_wall_far_from_path
# -----------------------------------------------------------------------------
## Fill in unused FLOOR that is adjacent to an existing WALL/FOSSIL — but only
## when it's *far* from the visited path, so we don't box the player in.
## Prefers cells that create longer wall runs and are farther from any hot
## cell.
static func grow_wall_far_from_path(lattice: Lattice, sig: HabitSignature) -> Array:
	var out: Array = []
	var hot := sig.hot_cells(8)
	var visited: Dictionary = sig.visit_counts
	for y in range(lattice.height):
		for x in range(lattice.width):
			var pos := Vector2i(x, y)
			if lattice.get_cell(pos) != Lattice.Cell.FLOOR:
				continue
			if pos == lattice.start or pos == lattice.goal:
				continue
			if visited.has(pos):
				continue
			var wall_neighbors := 0
			for d in Lattice.DIRS_4:
				var n := pos + d
				if lattice.is_wall(n):
					wall_neighbors += 1
			if wall_neighbors == 0:
				# Isolated floor: skip so we don't create loose walls.
				continue
			var min_hot_dist := _min_manhattan(pos, hot)
			if min_hot_dist < 2:
				continue
			var score := 0.2 + 0.6 * float(wall_neighbors) + 0.15 * float(min_hot_dist)
			out.append(_mk("grow_wall_far_from_path", score, [
				_patch(pos, Lattice.Cell.WALL),
			], {"operator": "grow_wall_far_from_path", "cell": pos, "wall_neighbors": wall_neighbors, "hot_dist": min_hot_dist}))
	out.sort_custom(func(a, b): return float(a["score"]) > float(b["score"]))
	return out


# -----------------------------------------------------------------------------
# widen_hot_corridor
# -----------------------------------------------------------------------------
## Open a wall neighbour of a hot cell so future paths have an alternate.
## Applies only when wall_hug is high (>=0.6) — the player is hugging walls,
## so widening explicitly opens up new lateral options. Skips FOSSIL so that
## fossilized cells stay permanent.
static func widen_hot_corridor(lattice: Lattice, sig: HabitSignature) -> Array:
	var out: Array = []
	if sig.wall_hug < 0.6:
		return out
	var hot := sig.hot_cells(6)
	var perpendicular: Array[Vector2i] = _perpendicular_dirs(sig.dominant_dir)
	if perpendicular.is_empty():
		perpendicular = [_DIR_UP, _DIR_DOWN, _DIR_LEFT, _DIR_RIGHT]
	for pos in hot:
		for d in perpendicular:
			var target := pos + d
			if not lattice.in_bounds(target):
				continue
			if lattice.get_cell(target) != Lattice.Cell.WALL:
				continue
			var score := 0.4 + 0.6 * sig.wall_hug
			out.append(_mk("widen_hot_corridor", score, [
				_patch(target, Lattice.Cell.FLOOR),
			], {"operator": "widen_hot_corridor", "cell": target, "hot_cell": pos}))
	out.sort_custom(func(a, b): return float(a["score"]) > float(b["score"]))
	return out


# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

static func _patch(pos: Vector2i, cell: int) -> Dictionary:
	return {"pos": pos, "cell": cell}


static func _mk(name: String, score: float, patches: Array, meta: Dictionary) -> Dictionary:
	return {
		"name": name,
		"score": score,
		"patches": patches,
		"meta": meta,
	}


static func _measure_streak_back(pos: Vector2i, back_dir: Vector2i, visited: Dictionary) -> int:
	var length := 1
	var cur := pos + back_dir
	while visited.has(cur):
		length += 1
		cur += back_dir
		if length > 1_000_000:
			break
	return length


static func _dominant_axis_dirs(dom: Vector2i) -> Array[Vector2i]:
	if dom == Vector2i.ZERO:
		return []
	if dom.x != 0:
		return [Vector2i(1, 0), Vector2i(-1, 0)]
	return [Vector2i(0, 1), Vector2i(0, -1)]


static func _perpendicular_dirs(dom: Vector2i) -> Array[Vector2i]:
	if dom == Vector2i.ZERO:
		return []
	if dom.x != 0:
		return [Vector2i(0, 1), Vector2i(0, -1)]
	return [Vector2i(1, 0), Vector2i(-1, 0)]


static func _min_manhattan(pos: Vector2i, others: Array) -> int:
	if others.is_empty():
		return 1_000_000
	var best: int = 1_000_000
	for o in others:
		var v: Vector2i = o
		var d: int = absi(pos.x - v.x) + absi(pos.y - v.y)
		if d < best:
			best = d
	return best
