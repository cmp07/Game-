extends "res://echo_lattice/tests/test_framework.gd"

const Lattice := preload("res://echo_lattice/lattice.gd")
const LatticeBFS := preload("res://echo_lattice/bfs.gd")


func test_open_grid_solvable() -> void:
	var lat := Lattice.from_ascii("S...G")
	assert_true(LatticeBFS.is_solvable(lat))
	var p := LatticeBFS.shortest_path(lat, lat.start, lat.goal)
	assert_eq(p.size(), 5)


func test_walled_off_unsolvable() -> void:
	var lat := Lattice.from_ascii("S#..G")
	# Column of walls between S and G? Actually only one wall — let's build a
	# full wall column.
	var text := "S#..G\n.#...\n.#..."
	lat = Lattice.from_ascii(text)
	assert_false(LatticeBFS.is_solvable(lat))


func test_bottleneck_width() -> void:
	# Only one reachable passable neighbour of G: the cell above it.
	var lat := Lattice.from_ascii(
			"S....\n" +
			".###.\n" +
			"...#G")
	assert_true(LatticeBFS.is_solvable(lat))
	assert_eq(LatticeBFS.goal_bottleneck_width(lat), 1)


func test_bottleneck_wide_when_goal_open() -> void:
	var lat := Lattice.from_ascii("S...\n....\n...G")
	# Goal cell (3,2) neighbours: (2,2), (3,1), all passable.
	assert_ge(LatticeBFS.goal_bottleneck_width(lat), 2)


func test_player_exits_counts_live_neighbours() -> void:
	var lat := Lattice.from_ascii(
			"S...G\n" +
			".....\n" +
			".....")
	assert_ge(LatticeBFS.player_exits(lat, Vector2i(1, 0)), 2)


func test_safety_summary() -> void:
	var lat := Lattice.from_ascii("S....G")
	var s := LatticeBFS.safety(lat)
	assert_eq(s["path_len"], 6)
	assert_ge(s["bottleneck"], 1)
	assert_ge(s["player_exits"], 1)
