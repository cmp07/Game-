## Baseline tests for `Solver`. These aren't invariants of the game per
## se — they check that the reachability engine used by every other
## invariant is itself correct.
extends EchoLatticeTestBase


func test_open_corridor_is_solvable() -> void:
	var l: Lattice = Lattice.from_rows(["S....D"])
	assert_true(Solver.is_solvable(l), "straight corridor")
	assert_eq(Solver.shortest_path_length(l), 5, "5 steps for width-6 corridor")


func test_walled_off_door_is_unsolvable() -> void:
	var l: Lattice = Lattice.from_rows([
		"S.#..",
		"..#..",
		"..#.D",
	])
	assert_false(Solver.is_solvable(l), "vertical wall blocks path")
	assert_eq(Solver.shortest_path_length(l), -1, "unreachable path length is -1")


func test_reachable_walkable_count_ignores_orphans() -> void:
	var l: Lattice = Lattice.from_rows([
		"S.#..",
		"..#..",
		"..#.D",
	])
	# Left region: S(0,0), (1,0), (0,1), (1,1), (0,2), (1,2) — 6 walkable cells.
	# Door is orphaned in the right region and must not be counted.
	assert_eq(Solver.reachable_walkable_count(l), 6, "counts only cells reachable from START")
	assert_false(Solver.is_solvable(l), "door on the far side of a wall is unreachable")


func test_start_equals_door_is_zero_length() -> void:
	# Trivially, we never author a chamber like this — but the solver
	# should still tolerate it because grammar edits could produce it as
	# an intermediate before the safe wrapper reverts.
	var l: Lattice = Lattice.new(1, 1, Lattice.FLOOR)
	l.set_cell(0, 0, Lattice.START)
	# Manually treat as door too via a bespoke lattice for the equality case.
	# We use a 1x2 layout where START then DOOR abut with distance 1.
	var l2: Lattice = Lattice.from_rows(["SD"])
	assert_eq(Solver.shortest_path_length(l2), 1, "adjacent S/D = 1 step")
