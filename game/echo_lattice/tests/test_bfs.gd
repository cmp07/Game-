extends "res://echo_lattice/tests/test_framework.gd"

const Lattice := preload("res://echo_lattice/lattice.gd")
const LatticeBFS := preload("res://echo_lattice/bfs.gd")


func test_trivial_solvable() -> void:
	var lat := Lattice.from_ascii("S.\n.G")
	assert_true(LatticeBFS.is_solvable(lat))


func test_blocked_unsolvable() -> void:
	var lat := Lattice.from_ascii("S#\n#G")
	assert_false(LatticeBFS.is_solvable(lat))


func test_shortest_path_length() -> void:
	var lat := Lattice.from_ascii("S...\n.##.\n...G")
	var path := LatticeBFS.shortest_path(lat, lat.start, lat.goal)
	assert_eq(path[0], Vector2i(0, 0))
	assert_eq(path[path.size() - 1], Vector2i(3, 2))
	# Manhattan distance is 3+2 = 5, so the path has 6 cells (start inclusive).
	assert_eq(path.size(), 6)


func test_shortest_path_walks_around_wall() -> void:
	var lat := Lattice.from_ascii("S.\n#.\n.G")
	var path := LatticeBFS.shortest_path(lat, lat.start, lat.goal)
	assert_gt(path.size(), 0)
	for cell in path:
		assert_true(lat.is_passable(cell))


func test_shortest_path_empty_when_unreachable() -> void:
	var lat := Lattice.from_ascii("S#\n#G")
	var path := LatticeBFS.shortest_path(lat, lat.start, lat.goal)
	assert_eq(path.size(), 0)


func test_reachable_distances_grid() -> void:
	var lat := Lattice.from_ascii("S..\n...\n..G")
	var dist := LatticeBFS.reachable_distances(lat, lat.start)
	assert_eq(int(dist[Vector2i(0, 0)]), 0)
	assert_eq(int(dist[Vector2i(1, 0)]), 1)
	assert_eq(int(dist[Vector2i(2, 2)]), 4)
	assert_eq(dist.size(), 9)


func test_start_equals_goal() -> void:
	var lat := Lattice.new(2, 2)
	lat.set_cell(Vector2i(1, 1), Lattice.Cell.START)
	lat.goal = Vector2i(1, 1)
	# is_solvable requires both start and goal set; explicit set_cell for goal.
	lat.set_cell(Vector2i(1, 1), Lattice.Cell.GOAL)
	# After GOAL overwrite, treat cell as GOAL and passable.
	lat.start = Vector2i(1, 1)
	assert_true(LatticeBFS.is_solvable(lat))
