## Solver — BFS reachability & shortest-path checks over a `Lattice`.
##
## Used both at runtime (to decide whether a candidate lattice can be
## shown to the player) and in the QA suite (to enforce the solvability
## invariant after every grammar pass).
class_name Solver
extends RefCounted


static func is_solvable(lattice: Lattice) -> bool:
	return shortest_path_length(lattice) >= 0


static func shortest_path_length(lattice: Lattice) -> int:
	# Returns the number of steps in the shortest start→door path,
	# or -1 if no such path exists.
	if lattice == null:
		return -1
	var start: Vector2i = lattice.find_first(Lattice.START)
	var door: Vector2i = lattice.find_first(Lattice.DOOR)
	if start.x < 0 or door.x < 0:
		return -1
	if start == door:
		return 0

	var w: int = lattice.width
	var h: int = lattice.height
	var dist: PackedInt32Array = PackedInt32Array()
	dist.resize(w * h)
	for i in range(dist.size()):
		dist[i] = -1

	var q: Array = []
	dist[start.y * w + start.x] = 0
	q.append(start)

	var head: int = 0
	while head < q.size():
		var p: Vector2i = q[head]
		head += 1
		if p == door:
			return dist[p.y * w + p.x]
		var d: int = dist[p.y * w + p.x]
		var neigh: Array = [
			Vector2i(p.x, p.y - 1),
			Vector2i(p.x + 1, p.y),
			Vector2i(p.x, p.y + 1),
			Vector2i(p.x - 1, p.y),
		]
		for n in neigh:
			if not lattice.in_bounds(n.x, n.y):
				continue
			if not lattice.is_walkable(n.x, n.y):
				continue
			var idx: int = n.y * w + n.x
			if dist[idx] != -1:
				continue
			dist[idx] = d + 1
			q.append(n)
	return -1


static func reachable_walkable_count(lattice: Lattice) -> int:
	# Number of walkable cells reachable from START (inclusive of START).
	# Used to prove "no orphaned rooms" invariants in the QA matrix.
	if lattice == null:
		return 0
	var start: Vector2i = lattice.find_first(Lattice.START)
	if start.x < 0:
		return 0
	var w: int = lattice.width
	var h: int = lattice.height
	var seen: PackedByteArray = PackedByteArray()
	seen.resize(w * h)
	var q: Array = [start]
	seen[start.y * w + start.x] = 1
	var head: int = 0
	var count: int = 0
	while head < q.size():
		var p: Vector2i = q[head]
		head += 1
		count += 1
		var neigh: Array = [
			Vector2i(p.x, p.y - 1),
			Vector2i(p.x + 1, p.y),
			Vector2i(p.x, p.y + 1),
			Vector2i(p.x - 1, p.y),
		]
		for n in neigh:
			if not lattice.in_bounds(n.x, n.y):
				continue
			if not lattice.is_walkable(n.x, n.y):
				continue
			var idx: int = n.y * w + n.x
			if seen[idx] == 1:
				continue
			seen[idx] = 1
			q.append(n)
	return count
