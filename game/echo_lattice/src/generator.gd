## Generator — turns (seed, MoveBuffer) into a solvable, habit-conditioned
## `Lattice`.
##
## Pipeline:
##
##   1. Carve a spanning-tree maze with recursive-backtracker DFS,
##      seeded jointly by the world seed and the buffer hash. This step
##      is deterministic and always yields a fully connected maze.
##   2. Place START on the corner cell of that spanning tree, and DOOR
##      on the cell with the greatest BFS distance from START — the
##      classic "farthest" heuristic used for solvable procedural mazes.
##   3. Pick a transform deck conditioned on the habit profile and apply
##      it via `Grammar.apply_deck`, which never returns an unsolvable
##      lattice.
##
## Result: same (seed, buffer) → same lattice; every returned lattice is
## solvable and structurally valid.
class_name LatticeGenerator
extends RefCounted


static func generate(seed: int, width: int, height: int, buffer: MoveBuffer) -> Lattice:
	# Convenience for tests that don't care about transform deck details.
	# Applies the default habit-conditioned deck.
	assert(width >= 3 and height >= 3, "generator needs at least a 3x3 grid")
	var base: Lattice = _carve_base_maze(seed, width, height, buffer)
	var deck: Array = pick_deck(buffer)
	var final_lattice: Lattice = Grammar.apply_deck(base, deck, seed ^ int(buffer.hash_code()))
	# Post-condition asserted by is_valid / is_solvable in tests; here we
	# just double-check to catch programmer error early in dev.
	assert(final_lattice.is_valid(), "generator produced structurally invalid lattice")
	assert(Solver.is_solvable(final_lattice), "generator produced unsolvable lattice")
	return final_lattice


static func pick_deck(buffer: MoveBuffer) -> Array:
	# Deterministic mapping from habit label to a transform deck. The QA
	# matrix pins these to detect accidental "no-op deck for HESITANT"
	# regressions.
	var label: String = HabitProfile.classify(buffer)
	match label:
		HabitProfile.DASH_HEAVY:
			return [Grammar.T_THICKEN, Grammar.T_MIRROR_H]
		HabitProfile.LOOPY:
			return [Grammar.T_MIRROR_V, Grammar.T_ROTATE_180]
		HabitProfile.HESITANT:
			return [Grammar.T_CARVE, Grammar.T_MIRROR_H]
		_:
			return [Grammar.T_IDENTITY]


static func _carve_base_maze(seed: int, width: int, height: int, buffer: MoveBuffer) -> Lattice:
	# Recursive backtracker on a cell grid where every other cell is a
	# potential passage. Odd dimensions are guaranteed by rounding down.
	var w: int = width if width % 2 == 1 else width - 1
	var h: int = height if height % 2 == 1 else height - 1
	var lattice: Lattice = Lattice.new(w, h, Lattice.WALL)

	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = (int(seed) ^ int(buffer.hash_code())) & 0x7FFFFFFF

	var stack: Array = []
	var start_cell: Vector2i = Vector2i(1, 1)
	lattice.set_cell(start_cell.x, start_cell.y, Lattice.FLOOR)
	stack.append(start_cell)

	while stack.size() > 0:
		var cur: Vector2i = stack[stack.size() - 1]
		var neighbours: Array = _unvisited_neighbours(lattice, cur)
		if neighbours.is_empty():
			stack.pop_back()
			continue
		# Deterministic shuffle by pulling a rng int per pick.
		var pick_idx: int = rng.randi_range(0, neighbours.size() - 1)
		var nxt: Vector2i = neighbours[pick_idx]
		# Knock down the wall between cur and nxt.
		var mid: Vector2i = Vector2i((cur.x + nxt.x) / 2, (cur.y + nxt.y) / 2)
		lattice.set_cell(mid.x, mid.y, Lattice.FLOOR)
		lattice.set_cell(nxt.x, nxt.y, Lattice.FLOOR)
		stack.append(nxt)

	# Place START at the carved spawn and DOOR at the farthest reachable cell.
	lattice.set_cell(start_cell.x, start_cell.y, Lattice.START)
	var door_cell: Vector2i = _farthest_floor(lattice, start_cell)
	assert(door_cell.x >= 0, "no walkable cells to place a door on")
	lattice.set_cell(door_cell.x, door_cell.y, Lattice.DOOR)

	# If the caller asked for even dimensions, wrap the odd carve in the
	# larger grid so downstream code sees `width`×`height` exactly.
	if w == width and h == height:
		return lattice
	var wrapped: Lattice = Lattice.new(width, height, Lattice.WALL)
	for y in range(h):
		for x in range(w):
			wrapped.set_cell(x, y, lattice.get_cell(x, y))
	return wrapped


static func _unvisited_neighbours(lattice: Lattice, cell: Vector2i) -> Array:
	var out: Array = []
	var dirs: Array = [Vector2i(0, -2), Vector2i(2, 0), Vector2i(0, 2), Vector2i(-2, 0)]
	for d in dirs:
		var n: Vector2i = cell + d
		if not lattice.in_bounds(n.x, n.y):
			continue
		if lattice.get_cell(n.x, n.y) == Lattice.WALL:
			out.append(n)
	return out


static func _farthest_floor(lattice: Lattice, start: Vector2i) -> Vector2i:
	# BFS from start on walkable cells; return the last cell dequeued —
	# guaranteed by BFS to be at maximum shortest-path distance.
	var w: int = lattice.width
	var dist: PackedInt32Array = PackedInt32Array()
	dist.resize(lattice.width * lattice.height)
	for i in range(dist.size()):
		dist[i] = -1
	var q: Array = [start]
	dist[start.y * w + start.x] = 0
	var head: int = 0
	var best: Vector2i = start
	while head < q.size():
		var p: Vector2i = q[head]
		head += 1
		best = p
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
			dist[idx] = dist[p.y * w + p.x] + 1
			q.append(n)
	return best
