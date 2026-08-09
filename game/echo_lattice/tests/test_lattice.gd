extends "res://echo_lattice/tests/test_framework.gd"

const Lattice := preload("res://echo_lattice/lattice.gd")


func test_v1_glyphs_round_trip() -> void:
	var text := "S...G\n.#.#.\n.*..:"
	var lat := Lattice.from_ascii(text)
	assert_eq(lat.width, 5)
	assert_eq(lat.height, 3)
	assert_eq(lat.start, Vector2i(0, 0))
	assert_eq(lat.goal, Vector2i(4, 0))
	assert_eq(lat.to_ascii(), text)


func test_v2_glyphs_are_understood() -> void:
	var text := "S.C..G\n.E.w..\n..c..."
	var lat := Lattice.from_ascii(text)
	assert_eq(lat.get_cell(Vector2i(2, 0)), Lattice.Cell.CHECKPOINT)
	assert_eq(lat.get_cell(Vector2i(1, 1)), Lattice.Cell.ECHO_WALL)
	assert_eq(lat.get_cell(Vector2i(3, 1)), Lattice.Cell.WISP)
	assert_eq(lat.get_cell(Vector2i(2, 2)), Lattice.Cell.CHECKPOINT_USED)
	assert_true(lat.is_wall(Vector2i(1, 1)), "ECHO_WALL is wall-like")
	assert_true(lat.is_passable(Vector2i(3, 1)), "WISP is passable")


func test_apply_patches_never_touches_terminals() -> void:
	var lat := Lattice.from_ascii("S...G")
	var patches: Array = [
		{"pos": Vector2i(0, 0), "cell": int(Lattice.Cell.FOSSIL)},
	]
	assert_false(lat.apply_patches(patches))
	# Nothing changed.
	assert_eq(lat.get_cell(Vector2i(0, 0)), Lattice.Cell.START)


func test_fossil_density_counts_fossil_and_echo_wall() -> void:
	var lat := Lattice.from_ascii("S*E.G")
	assert_eq(lat.fossil_density(), 2)


func test_fingerprint_stable_under_clone() -> void:
	var lat := Lattice.from_ascii("S.#.G\n.....\n.....")
	var f1 := lat.fingerprint()
	var lat2 := lat.clone()
	var f2 := lat2.fingerprint()
	assert_eq(f1, f2)
