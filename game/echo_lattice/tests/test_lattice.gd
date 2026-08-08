## Structural tests for `Lattice`. These are pre-requisites for the
## maze-solvability and rewrite-invariant suites — if lattices can't be
## constructed or compared correctly, nothing downstream is trustworthy.
extends EchoLatticeTestBase


func test_default_lattice_is_all_walls() -> void:
	var l: Lattice = Lattice.new(4, 3, Lattice.WALL)
	assert_eq(l.width, 4, "width")
	assert_eq(l.height, 3, "height")
	assert_eq(l.count_of(Lattice.WALL), 12, "all cells wall")


func test_from_rows_roundtrips_glyphs() -> void:
	var rows: Array = [
		"S...#",
		"#.#..",
		"..#.D",
	]
	var l: Lattice = Lattice.from_rows(rows)
	assert_eq(l.width, 5, "width from rows")
	assert_eq(l.height, 3, "height from rows")
	assert_eq(l.find_first(Lattice.START), Vector2i(0, 0), "start pos")
	assert_eq(l.find_first(Lattice.DOOR), Vector2i(4, 2), "door pos")
	assert_eq(l.to_rows(), rows, "roundtrip to_rows")


func test_is_valid_requires_one_start_one_door() -> void:
	var no_marks: Lattice = Lattice.from_rows(["....", "....", "...."])
	assert_false(no_marks.is_valid(), "no start/door should be invalid")

	var two_starts: Lattice = Lattice.from_rows(["S..S", "....", "...D"])
	assert_false(two_starts.is_valid(), "two starts should be invalid")

	var ok: Lattice = Lattice.from_rows(["S...", "....", "...D"])
	assert_true(ok.is_valid(), "one start one door should be valid")


func test_clone_is_independent() -> void:
	var l: Lattice = Lattice.from_rows(["S.#", "...", "#.D"])
	var c: Lattice = l.clone()
	assert_true(c.equals(l), "clone equals source")
	c.set_cell(0, 0, Lattice.WALL)
	assert_false(c.equals(l), "mutating clone doesn't touch source")
	assert_eq(l.get_cell(0, 0), Lattice.START, "source START preserved after clone mutation")


func test_equals_is_shape_and_value_sensitive() -> void:
	var a: Lattice = Lattice.from_rows(["S.", ".D"])
	var b: Lattice = Lattice.from_rows(["S.", ".D"])
	var c: Lattice = Lattice.from_rows(["S..", ".D.", "..."])
	assert_true(a.equals(b), "same contents equal")
	assert_false(a.equals(c), "different shape not equal")
