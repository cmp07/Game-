class_name RewriteOperators
extends RefCounted

## Habit-driven lattice edits.
##
## Each operator is a pure function that reads a Lattice + HabitSignature and
## proposes a list of candidate `Rewrite` objects sorted by desirability (best
## first). Operators must **never** mutate their inputs. Applying a rewrite
## and verifying solvability is the RewriteEngine's job.
##
## Rewrite dictionary shape (v2)
## -----------------------------
##   {
##     "name":       String,             # operator identifier
##     "score":      float,               # higher = more desired
##     "patches":    Array<Patch>,        # atomic cell edits, applied together
##     "meta":       Dictionary,          # provenance + telegraph + counterplay
##     "hardness":   String,              # "soft" | "hard"
##     "telegraph":  Dictionary,          # {kind, cells, dir, banner}
##     "counterplay":Dictionary,          # {kind, threshold, dir?}
##     "reacts_to":  PackedStringArray,   # names of ops this one chains onto
##   }
##
## A telegraph is what the player *sees* before the rewrite commits — the two
## seconds where the game is fair. A counterplay is the observable action that
## reverses (or partly negates) the rewrite. See ChamberRuntime.on_move for
## how counters are accumulated.
##
## v2 operator catalog (11 ops):
##   O1  fossilize_hot_cell     HARD  telegraph=cell,counter=none
##   O2  place_deflector        SOFT  telegraph=cell+arrow,counter=perp moves
##   O3  carve_shortcut         SOFT  telegraph=cell,counter=away moves
##   O4  grow_wall_far_from_path SOFT telegraph=cell,counter=undo x3
##   O5  widen_hot_corridor     SOFT  telegraph=cell,counter=re-enter
##   O6  mirror_walked_v        SOFT  telegraph=cells,counter=along axis
##   O7  mirror_walked_h        SOFT  telegraph=cells,counter=along axis
##   O8  rotate_walked_180      SOFT  telegraph=cells,counter=into region
##   O9  thicken_walked         HARD  telegraph=cells,counter=none
##   O10 echo_wisp              SOFT  telegraph=cell (WISP),counter=step through
##   O11 seal_backtrack         HARD  telegraph=cell (echo wall),counter=none
##
## Every operator advertises a `hardness` default so RewriteEngine can respect
## the chamber-level `soft_hard_bias` dial.

const _DIR_UP := Vector2i(0, -1)
const _DIR_DOWN := Vector2i(0, 1)
const _DIR_LEFT := Vector2i(-1, 0)
const _DIR_RIGHT := Vector2i(1, 0)

## Operator hardness registry. Referenced by RewriteEngine when composing
## `effective_hardness` under the soft_hard_bias dial.
const HARDNESS := {
	"fossilize_hot_cell":       "hard",
	"place_deflector":          "soft",
	"carve_shortcut":           "soft",
	"grow_wall_far_from_path":  "soft",
	"widen_hot_corridor":       "soft",
	"mirror_walked_v":          "soft",
	"mirror_walked_h":          "soft",
	"rotate_walked_180":        "soft",
	"thicken_walked":           "hard",
	"echo_wisp":                "soft",
	"seal_backtrack":           "hard",
}

## Canonical order used by tests and by propose_all so ties break identically
## everywhere.
const OPS := [
	"fossilize_hot_cell",
	"place_deflector",
	"carve_shortcut",
	"grow_wall_far_from_path",
	"widen_hot_corridor",
	"mirror_walked_v",
	"mirror_walked_h",
	"rotate_walked_180",
	"thicken_walked",
	"echo_wisp",
	"seal_backtrack",
]


# -----------------------------------------------------------------------------
# Public entry points
# -----------------------------------------------------------------------------

static func propose_all(lattice: Lattice, sig: HabitSignature, path: Array = []) -> Array:
	var all: Array = []
	all.append_array(fossilize_hot_cell(lattice, sig))
	all.append_array(place_deflector(lattice, sig))
	all.append_array(carve_shortcut(lattice, sig))
	all.append_array(grow_wall_far_from_path(lattice, sig))
	all.append_array(widen_hot_corridor(lattice, sig))
	all.append_array(mirror_walked_v(lattice, sig, path))
	all.append_array(mirror_walked_h(lattice, sig, path))
	all.append_array(rotate_walked_180(lattice, sig, path))
	all.append_array(thicken_walked(lattice, sig, path))
	all.append_array(echo_wisp(lattice, sig))
	all.append_array(seal_backtrack(lattice, sig, path))
	all.sort_custom(func(a, b): return float(a["score"]) > float(b["score"]))
	return all


# =============================================================================
# O1 fossilize_hot_cell (HARD)
# =============================================================================
## Freeze the player's favorite cell. Score scales with visit count and how
## dominant the top cell is relative to the rest of the visit histogram.
## Greedy runs (high greed_index) may produce a *pair* of fossils (top-2 hot
## cells) instead of one — denser scars, harder clears.
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
		# Greed bonus — a greedy pattern gets its hot cell fossilised sooner.
		score += 0.75 * sig.greed_index
		var patches: Array = [_patch(pos, Lattice.Cell.FOSSIL)]
		var telegraph_cells: Array = [pos]
		# Under a high greed_index, upgrade to a two-cell fossil pair.
		if sig.greed_index >= 0.65 and hot.size() >= 2 and hot[0] == pos:
			var second: Vector2i = hot[1]
			if lattice.in_bounds(second) and lattice.get_cell(second) == Lattice.Cell.FLOOR \
					and second != lattice.start and second != lattice.goal:
				patches.append(_patch(second, Lattice.Cell.FOSSIL))
				telegraph_cells.append(second)
				score += 0.5
		out.append(_mk("fossilize_hot_cell", score, patches, {
			"operator": "fossilize_hot_cell",
			"cell": pos,
			"visits": visits,
			"greed": sig.greed_index,
		}, {
			"kind": "cell",
			"cells": telegraph_cells,
			"banner": "your favourite cell freezes",
		}, {"kind": "none"}, PackedStringArray()))
	return out


# =============================================================================
# O2 place_deflector (SOFT)
# =============================================================================
## For every straight streak of length >=3 along the dominant direction, place
## a wall one step past the end of the streak. Reverses when the player commits
## 5 moves *perpendicular* to the dominant axis inside one motif.
static func place_deflector(lattice: Lattice, sig: HabitSignature) -> Array:
	var out: Array = []
	if sig.total_steps == 0:
		return out
	if sig.dominant_bias < 0.35:
		return out
	var dom := sig.dominant_dir
	if dom == Vector2i.ZERO:
		return out
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
		var pos: Vector2i = c["pos"]
		out.append(_mk("place_deflector", c["score"], [
			_patch(pos, Lattice.Cell.WALL),
		], {
			"operator": "place_deflector",
			"cell": pos,
			"streak": c["streak"],
			"dir": dom,
		}, {
			"kind": "cell_arrow",
			"cells": [pos],
			"dir": dom,
			"banner": "line objects",
		}, {
			"kind": "perpendicular_moves",
			"threshold": 5,
			"axis": dom,
		}, PackedStringArray()))
	return out


# =============================================================================
# O3 carve_shortcut (SOFT)
# =============================================================================
## Open a wall separating two visited cells along the dominant axis.
## Reverses when the player takes 3 moves strictly away from the carved axis.
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
			], {
				"operator": "carve_shortcut",
				"cell": candidate,
				"axis": axis,
			}, {
				"kind": "cell",
				"cells": [candidate],
				"banner": "commitment rewarded",
			}, {
				"kind": "away_from_axis",
				"threshold": 3,
				"axis": axis,
			}, PackedStringArray(["place_deflector"])))
	out.sort_custom(func(a, b): return float(a["score"]) > float(b["score"]))
	return out


# =============================================================================
# O4 grow_wall_far_from_path (SOFT)
# =============================================================================
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
				continue
			var min_hot_dist := _min_manhattan(pos, hot)
			if min_hot_dist < 2:
				continue
			var score := 0.2 + 0.6 * float(wall_neighbors) + 0.15 * float(min_hot_dist)
			out.append(_mk("grow_wall_far_from_path", score, [
				_patch(pos, Lattice.Cell.WALL),
			], {
				"operator": "grow_wall_far_from_path",
				"cell": pos,
				"wall_neighbors": wall_neighbors,
				"hot_dist": min_hot_dist,
			}, {
				"kind": "cell",
				"cells": [pos],
				"banner": "unused space calcifies",
			}, {
				"kind": "undo_burst",
				"threshold": 3,
			}, PackedStringArray()))
	out.sort_custom(func(a, b): return float(a["score"]) > float(b["score"]))
	return out


# =============================================================================
# O5 widen_hot_corridor (SOFT)
# =============================================================================
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
			], {
				"operator": "widen_hot_corridor",
				"cell": target,
				"hot_cell": pos,
			}, {
				"kind": "cell",
				"cells": [target],
				"banner": "a doorway opens",
			}, {
				"kind": "re_enter",
				"threshold": 3,
				"cell": target,
			}, PackedStringArray(["fossilize_hot_cell"])))
	out.sort_custom(func(a, b): return float(a["score"]) > float(b["score"]))
	return out


# =============================================================================
# O6 mirror_walked_v (SOFT) — reflect across vertical midline
# =============================================================================
static func mirror_walked_v(lattice: Lattice, sig: HabitSignature, path: Array) -> Array:
	return _mirror_or_rotate(lattice, sig, path,
			"mirror_walked_v", func(p: Vector2i, l: Lattice) -> Vector2i:
				return Vector2i(l.width - 1 - p.x, p.y),
			Lattice.Cell.ECHO_WALL, "your path mirrors")


# =============================================================================
# O7 mirror_walked_h (SOFT) — reflect across horizontal midline
# =============================================================================
static func mirror_walked_h(lattice: Lattice, sig: HabitSignature, path: Array) -> Array:
	return _mirror_or_rotate(lattice, sig, path,
			"mirror_walked_h", func(p: Vector2i, l: Lattice) -> Vector2i:
				return Vector2i(p.x, l.height - 1 - p.y),
			Lattice.Cell.ECHO_WALL, "your path mirrors")


# =============================================================================
# O8 rotate_walked_180 (SOFT) — reflect across both midlines
# =============================================================================
static func rotate_walked_180(lattice: Lattice, sig: HabitSignature, path: Array) -> Array:
	return _mirror_or_rotate(lattice, sig, path,
			"rotate_walked_180", func(p: Vector2i, l: Lattice) -> Vector2i:
				return Vector2i(l.width - 1 - p.x, l.height - 1 - p.y),
			Lattice.Cell.ECHO_WALL, "your path turns")


# =============================================================================
# O9 thicken_walked (HARD) — the walked cells themselves fossilise
# =============================================================================
## Every walked cell (excluding start/goal, keeping the last few floor for a
## return path) becomes FOSSIL. Under a high greed_index, magnitude is fully
## restored (no soft trim); this is the density-vs-difficulty knob.
static func thicken_walked(lattice: Lattice, sig: HabitSignature, path: Array) -> Array:
	if path.is_empty():
		if sig.visit_counts.is_empty():
			return []
	var out: Array = []
	var raw_cells: Array[Vector2i] = []
	if path.is_empty():
		for k in sig.visit_counts.keys():
			raw_cells.append(k)
	else:
		for p in path:
			raw_cells.append(p)
	var seen := {}
	var walk_cells: Array[Vector2i] = []
	for pos in raw_cells:
		if pos == lattice.start or pos == lattice.goal:
			continue
		if seen.has(pos):
			continue
		seen[pos] = true
		if lattice.in_bounds(pos) and lattice.get_cell(pos) == Lattice.Cell.FLOOR:
			walk_cells.append(pos)
	if walk_cells.is_empty():
		return out
	# Hottest cell only under low greed; whole walk under high greed.
	var keep_count: int = maxi(1, int(round(float(walk_cells.size()) * clampf(sig.greed_index + 0.15, 0.2, 1.0))))
	var telegraph_cells: Array = []
	var patches: Array = []
	# Fossilise in visit-order priority (hottest first).
	var by_visits: Array = walk_cells.duplicate()
	by_visits.sort_custom(func(a, b):
		return int(sig.visit_counts.get(a, 0)) > int(sig.visit_counts.get(b, 0))
	)
	for i in range(min(keep_count, by_visits.size())):
		var pos: Vector2i = by_visits[i]
		patches.append(_patch(pos, Lattice.Cell.FOSSIL))
		telegraph_cells.append(pos)
	if patches.is_empty():
		return out
	var score := 0.9 + 0.4 * float(patches.size()) + 0.7 * sig.greed_index
	out.append(_mk("thicken_walked", score, patches, {
		"operator": "thicken_walked",
		"greed": sig.greed_index,
	}, {
		"kind": "cells",
		"cells": telegraph_cells,
		"banner": "habit solidifies in place",
	}, {"kind": "none"}, PackedStringArray()))
	return out


# =============================================================================
# O10 echo_wisp (SOFT) — a one-shot phantom block
# =============================================================================
## Places a WISP (walkable-once) cell on the shortest s→g path baseline, one
## step ahead of the last visited cell along the dominant axis. The wisp is
## the *dramatic near-miss* generator: it blocks the obvious continuation,
## but the player can just step through it — it dissolves. Applies only when
## there is a clear dominant line (`dominant_bias >= 0.4`) so it never fires
## on a diffuse wander.
static func echo_wisp(lattice: Lattice, sig: HabitSignature) -> Array:
	var out: Array = []
	if sig.total_steps == 0:
		return out
	if sig.dominant_bias < 0.40:
		return out
	var dom := sig.dominant_dir
	if dom == Vector2i.ZERO:
		return out
	var hot := sig.hot_cells(4)
	for pos in hot:
		var target := pos + dom
		if not lattice.in_bounds(target):
			continue
		var c := lattice.get_cell(target)
		if c != Lattice.Cell.FLOOR:
			continue
		if target == lattice.start or target == lattice.goal:
			continue
		var score := 0.55 + 0.9 * sig.dominant_bias + 0.4 * sig.hot_dominance
		out.append(_mk("echo_wisp", score, [
			_patch(target, Lattice.Cell.WISP),
		], {
			"operator": "echo_wisp",
			"cell": target,
			"dir": dom,
		}, {
			"kind": "cell_wisp",
			"cells": [target],
			"dir": dom,
			"banner": "a wisp interposes",
		}, {
			"kind": "walk_through",
			"threshold": 1,
			"cell": target,
		}, PackedStringArray(["place_deflector"])))
	out.sort_custom(func(a, b): return float(a["score"]) > float(b["score"]))
	return out


# =============================================================================
# O11 seal_backtrack (HARD) — closes off refrain loops
# =============================================================================
## When the player is REFRAIN (echo_depth >= 3) — ping-ponging on the same
## corridor — one endpoint of that corridor is sealed with ECHO_WALL. Kills
## the pathological thrash pattern without touching hot cells. Fires only on
## explicit REFRAIN so the player has notice.
static func seal_backtrack(lattice: Lattice, sig: HabitSignature, path: Array) -> Array:
	var out: Array = []
	if sig.echo_depth < 3:
		return out
	if path.size() < 3:
		return out
	# Find the tail's ping-pong endpoints: consecutive pair (a,b) where the
	# last many transitions bounce between them.
	var last_two := _tail_pingpong_pair(path)
	if last_two.is_empty():
		return out
	var a: Vector2i = last_two[0]
	var b: Vector2i = last_two[1]
	# Seal the far endpoint (b) — the one further from goal. If distances tie,
	# fall back to the deterministic tie-break (y asc, x asc) on the two.
	var seal_pos: Vector2i = _pick_far_endpoint(lattice, a, b)
	if seal_pos == lattice.start or seal_pos == lattice.goal:
		return out
	if not lattice.in_bounds(seal_pos):
		return out
	if lattice.get_cell(seal_pos) != Lattice.Cell.FLOOR:
		return out
	var score := 1.2 + 0.5 * float(sig.echo_depth) + 0.4 * sig.undo_rate
	out.append(_mk("seal_backtrack", score, [
		_patch(seal_pos, Lattice.Cell.ECHO_WALL),
	], {
		"operator": "seal_backtrack",
		"cell": seal_pos,
		"echo_depth": sig.echo_depth,
	}, {
		"kind": "cell",
		"cells": [seal_pos],
		"banner": "the refrain seals",
	}, {"kind": "none"}, PackedStringArray()))
	return out


# =============================================================================
# Helpers
# =============================================================================

static func _patch(pos: Vector2i, cell: int) -> Dictionary:
	return {"pos": pos, "cell": cell}


## Rewrite constructor. Always populates the v2 metadata: hardness, telegraph,
## counterplay, reacts_to. Older call-sites that only pass name/score/patches
## /meta pick up sensible defaults from the HARDNESS registry.
static func _mk(name: String, score: float, patches: Array, meta: Dictionary,
		telegraph: Dictionary = {}, counterplay: Dictionary = {},
		reacts_to: PackedStringArray = PackedStringArray()) -> Dictionary:
	return {
		"name": name,
		"score": score,
		"patches": patches,
		"meta": meta,
		"hardness": HARDNESS.get(name, "soft"),
		"telegraph": telegraph,
		"counterplay": counterplay,
		"reacts_to": reacts_to,
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


## Shared body for O6/O7/O8. `transform` is a Callable taking (Vector2i, Lattice)
## and returning the reflected/rotated Vector2i.
static func _mirror_or_rotate(lattice: Lattice, sig: HabitSignature, path: Array,
		op_name: String, transform: Callable, target_cell: int,
		banner: String) -> Array:
	var out: Array = []
	var raw_walk: Array[Vector2i] = []
	if path.is_empty():
		for k in sig.visit_counts.keys():
			raw_walk.append(k)
	else:
		for p in path:
			raw_walk.append(p)
	var walk: Array[Vector2i] = []
	var seen := {}
	for pos in raw_walk:
		if pos == lattice.start or pos == lattice.goal:
			continue
		if seen.has(pos):
			continue
		seen[pos] = true
		walk.append(pos)
	if walk.is_empty():
		return out
	var patches: Array = []
	var telegraph_cells: Array = []
	var dedup := {}
	for pos in walk:
		var mp: Vector2i = transform.call(pos, lattice)
		if not lattice.in_bounds(mp):
			continue
		if mp == lattice.start or mp == lattice.goal:
			continue
		var c := lattice.get_cell(mp)
		if c == Lattice.Cell.WALL or c == Lattice.Cell.FOSSIL or c == Lattice.Cell.ECHO_WALL:
			continue
		var key := "%d,%d" % [mp.x, mp.y]
		if dedup.has(key):
			continue
		dedup[key] = true
		patches.append(_patch(mp, target_cell))
		telegraph_cells.append(mp)
	if patches.is_empty():
		return out
	var score := 1.0 + 0.2 * float(patches.size())
	out.append(_mk(op_name, score, patches, {
		"operator": op_name,
		"walk_cells": walk.size(),
	}, {
		"kind": "cells",
		"cells": telegraph_cells,
		"banner": banner,
	}, {
		"kind": "into_region",
		"threshold": 3,
		"cells": telegraph_cells,
	}, PackedStringArray()))
	return out


## Return [a, b] where a,b are the two cells being ping-ponged at the tail of
## the path. Empty array if no tight bounce pattern is present.
static func _tail_pingpong_pair(path: Array) -> Array:
	if path.size() < 4:
		return []
	var n := path.size()
	var a: Vector2i = path[n - 2]
	var b: Vector2i = path[n - 1]
	# Confirm the previous two also alternate the pair.
	if path[n - 3] != b:
		return []
	if path[n - 4] != a:
		return []
	return [a, b]


static func _pick_far_endpoint(lattice: Lattice, a: Vector2i, b: Vector2i) -> Vector2i:
	var da_path := LatticeBFS.shortest_path(lattice, a, lattice.goal)
	var db_path := LatticeBFS.shortest_path(lattice, b, lattice.goal)
	var da := da_path.size()
	var db := db_path.size()
	if da > db:
		return a
	if db > da:
		return b
	# Deterministic tie-break: y then x ascending.
	if a.y != b.y:
		return a if a.y < b.y else b
	return a if a.x <= b.x else b
