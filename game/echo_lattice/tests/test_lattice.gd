extends "res://echo_lattice/tests/test_framework.gd"

const Lattice := preload("res://echo_lattice/lattice.gd")


func test_new_lattice_defaults_to_floor() -> void:
	var lat := Lattice.new(3, 2)
	assert_eq(lat.width, 3)
	assert_eq(lat.height, 2)
	for y in range(2):
		for x in range(3):
			assert_eq(lat.get_cell(Vector2i(x, y)), Lattice.Cell.FLOOR)


func test_in_bounds() -> void:
	var lat := Lattice.new(4, 3)
	assert_true(lat.in_bounds(Vector2i(0, 0)))
	assert_true(lat.in_bounds(Vector2i(3, 2)))
	assert_false(lat.in_bounds(Vector2i(-1, 0)))
	assert_false(lat.in_bounds(Vector2i(4, 0)))
	assert_false(lat.in_bounds(Vector2i(0, 3)))


func test_set_cell_updates_start_and_goal() -> void:
	var lat := Lattice.new(3, 3)
	lat.set_cell(Vector2i(0, 0), Lattice.Cell.START)
	lat.set_cell(Vector2i(2, 2), Lattice.Cell.GOAL)
	assert_eq(lat.start, Vector2i(0, 0))
	assert_eq(lat.goal, Vector2i(2, 2))


func test_is_passable_and_is_wall() -> void:
	var lat := Lattice.new(2, 2)
	lat.set_cell(Vector2i(0, 0), Lattice.Cell.WALL)
	lat.set_cell(Vector2i(1, 0), Lattice.Cell.FOSSIL)
	lat.set_cell(Vector2i(0, 1), Lattice.Cell.SOFT)
	lat.set_cell(Vector2i(1, 1), Lattice.Cell.START)
	assert_false(lat.is_passable(Vector2i(0, 0)))
	assert_false(lat.is_passable(Vector2i(1, 0)))
	assert_true(lat.is_passable(Vector2i(0, 1)))
	assert_true(lat.is_passable(Vector2i(1, 1)))
	assert_true(lat.is_wall(Vector2i(0, 0)))
	assert_true(lat.is_wall(Vector2i(1, 0)))
	assert_false(lat.is_wall(Vector2i(0, 1)))
	# Out-of-bounds is treated as wall for is_wall (safe default for scans).
	assert_true(lat.is_wall(Vector2i(-1, 0)))


func test_clone_is_deep() -> void:
	var lat := Lattice.new(2, 2)
	lat.set_cell(Vector2i(0, 0), Lattice.Cell.START)
	lat.set_cell(Vector2i(1, 1), Lattice.Cell.GOAL)
	var copy := lat.clone()
	assert_true(copy.equals(lat))
	copy.set_cell(Vector2i(1, 0), Lattice.Cell.WALL)
	assert_false(copy.equals(lat))
	assert_eq(lat.get_cell(Vector2i(1, 0)), Lattice.Cell.FLOOR)


func test_apply_patches_all_or_nothing() -> void:
	var lat := Lattice.new(3, 3)
	lat.set_cell(Vector2i(0, 0), Lattice.Cell.START)
	lat.set_cell(Vector2i(2, 2), Lattice.Cell.GOAL)
	# Patch onto start is rejected -> no cell mutates.
	var ok := lat.apply_patches([
		{"pos": Vector2i(1, 1), "cell": Lattice.Cell.WALL},
		{"pos": Vector2i(0, 0), "cell": Lattice.Cell.WALL},
	])
	assert_false(ok)
	assert_eq(lat.get_cell(Vector2i(1, 1)), Lattice.Cell.FLOOR)
	# Clean patch succeeds atomically.
	ok = lat.apply_patches([
		{"pos": Vector2i(1, 1), "cell": Lattice.Cell.WALL},
		{"pos": Vector2i(2, 1), "cell": Lattice.Cell.FOSSIL},
	])
	assert_true(ok)
	assert_eq(lat.get_cell(Vector2i(1, 1)), Lattice.Cell.WALL)
	assert_eq(lat.get_cell(Vector2i(2, 1)), Lattice.Cell.FOSSIL)


func test_from_ascii_roundtrip() -> void:
	var src := "S.#\n.#.\n..G"
	var lat := Lattice.from_ascii(src)
	assert_eq(lat.width, 3)
	assert_eq(lat.height, 3)
	assert_eq(lat.start, Vector2i(0, 0))
	assert_eq(lat.goal, Vector2i(2, 2))
	assert_eq(lat.get_cell(Vector2i(2, 0)), Lattice.Cell.WALL)
	assert_eq(lat.to_ascii(), src)


func test_neighbors_and_passable_neighbors() -> void:
	var lat := Lattice.from_ascii("S.\n.G")
	var pn := lat.passable_neighbors(Vector2i(0, 0))
	assert_eq(pn.size(), 2)
	assert_contains(pn, Vector2i(1, 0))
	assert_contains(pn, Vector2i(0, 1))
	var n4 := lat.neighbors4(Vector2i(0, 0))
	assert_eq(n4.size(), 2)


func test_fingerprint_stable_and_sensitive() -> void:
	var a := Lattice.from_ascii("S.\n.G")
	var b := Lattice.from_ascii("S.\n.G")
	var c := Lattice.from_ascii("S#\n.G")
	assert_eq(a.fingerprint(), b.fingerprint())
	assert_ne(a.fingerprint(), c.fingerprint())


func test_cells_of_and_count_of() -> void:
	var lat := Lattice.from_ascii("S##\n.#.\n..G")
	var walls := lat.cells_of(Lattice.Cell.WALL)
	assert_eq(walls.size(), 3)
	assert_contains(walls, Vector2i(1, 0))
	assert_contains(walls, Vector2i(2, 0))
	assert_contains(walls, Vector2i(1, 1))
	assert_eq(lat.count_of(Lattice.Cell.FLOOR), 4)
