class_name LatticeBFS
extends RefCounted

## Breadth-first search utilities over a Lattice.
##
## Pure static functions. No allocation of the Lattice, no scene tree, no RNG.
## Used both by the rewrite engine (to prove a proposed edit keeps the maze
## solvable) and by tests/tools.

const _NO_PARENT := Vector2i(-1, -1)


## Return true iff there is a passable-4-connected path from lattice.start to
## lattice.goal. Terminals must be set on the lattice.
static func is_solvable(lattice: Lattice) -> bool:
	if lattice.start == Vector2i(-1, -1) or lattice.goal == Vector2i(-1, -1):
		return false
	if not lattice.is_passable(lattice.start) or not lattice.is_passable(lattice.goal):
		return false
	return has_path(lattice, lattice.start, lattice.goal)


static func has_path(lattice: Lattice, from_pos: Vector2i, to_pos: Vector2i) -> bool:
	if not lattice.is_passable(from_pos) or not lattice.is_passable(to_pos):
		return false
	if from_pos == to_pos:
		return true
	var visited := {}
	visited[from_pos] = true
	var queue: Array[Vector2i] = [from_pos]
	while queue.size() > 0:
		var cur: Vector2i = queue.pop_front()
		for n in lattice.passable_neighbors(cur):
			if visited.has(n):
				continue
			if n == to_pos:
				return true
			visited[n] = true
			queue.append(n)
	return false


## Shortest 4-connected path as an Array[Vector2i], inclusive of both endpoints.
## Returns [] when unreachable. Deterministic tie-breaking (up, down, left,
## right) because neighbours are iterated in Lattice.DIRS_4 order.
static func shortest_path(lattice: Lattice, from_pos: Vector2i, to_pos: Vector2i) -> Array[Vector2i]:
	var empty: Array[Vector2i] = []
	if not lattice.is_passable(from_pos) or not lattice.is_passable(to_pos):
		return empty
	if from_pos == to_pos:
		return [from_pos] as Array[Vector2i]
	var parent := {}
	parent[from_pos] = _NO_PARENT
	var queue: Array[Vector2i] = [from_pos]
	var found := false
	while queue.size() > 0 and not found:
		var cur: Vector2i = queue.pop_front()
		for n in lattice.passable_neighbors(cur):
			if parent.has(n):
				continue
			parent[n] = cur
			if n == to_pos:
				found = true
				break
			queue.append(n)
	if not found:
		return empty
	var path: Array[Vector2i] = []
	var cur: Vector2i = to_pos
	while cur != _NO_PARENT:
		path.append(cur)
		cur = parent[cur]
	path.reverse()
	return path


## Return the set of cells reachable from origin as a Dictionary[Vector2i, int]
## where value is BFS distance.
static func reachable_distances(lattice: Lattice, origin: Vector2i) -> Dictionary:
	var dist := {}
	if not lattice.is_passable(origin):
		return dist
	dist[origin] = 0
	var queue: Array[Vector2i] = [origin]
	while queue.size() > 0:
		var cur: Vector2i = queue.pop_front()
		var d: int = dist[cur]
		for n in lattice.passable_neighbors(cur):
			if dist.has(n):
				continue
			dist[n] = d + 1
			queue.append(n)
	return dist


static func is_reachable(lattice: Lattice, from_pos: Vector2i, to_pos: Vector2i) -> bool:
	return has_path(lattice, from_pos, to_pos)


## Number of *distinct* start-to-goal simple corridors: how many passable
## cells adjacent to the goal are reachable from start. A value of 1 means the
## goal is on a bottleneck; walling any part of that bottleneck locks the
## chamber. Used by the wall-yourself-in oracle for near-miss detection.
static func goal_bottleneck_width(lattice: Lattice) -> int:
	if lattice.goal == Vector2i(-1, -1):
		return 0
	var reachable := reachable_distances(lattice, lattice.start)
	var count := 0
	for d in Lattice.DIRS_4:
		var n: Vector2i = lattice.goal + d
		if reachable.has(n):
			count += 1
	return count


## Number of *distinct* corridor exits from the player's current position:
## adjacent passable cells that themselves have a path to the goal (excluding
## the player's own cell). Value 1 = player is in a bottleneck. Value 0 = the
## player is already walled in.
static func player_exits(lattice: Lattice, player_pos: Vector2i) -> int:
	if lattice.goal == Vector2i(-1, -1):
		return 0
	if not lattice.is_passable(player_pos):
		return 0
	var count := 0
	for d in Lattice.DIRS_4:
		var n: Vector2i = player_pos + d
		if not lattice.is_passable(n):
			continue
		# Cheap approximation: count neighbours that are passable AND from
		# which the goal remains reachable via lattice-wide BFS.
		if has_path(lattice, n, lattice.goal):
			count += 1
	return count


## Full safety summary at the current state. `path_len` is the shortest s→g
## distance (0 = unreachable). `bottleneck` = corridor exits at goal.
## `player_exits` = live exits from player_pos (or from start if omitted).
static func safety(lattice: Lattice, player_pos: Vector2i = Vector2i(-1, -1)) -> Dictionary:
	var pos := lattice.start if player_pos == Vector2i(-1, -1) else player_pos
	var path := shortest_path(lattice, pos, lattice.goal)
	return {
		"path_len": path.size(),
		"bottleneck": goal_bottleneck_width(lattice),
		"player_exits": player_exits(lattice, pos),
	}
