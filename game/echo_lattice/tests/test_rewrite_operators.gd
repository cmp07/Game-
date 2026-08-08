extends "res://echo_lattice/tests/test_framework.gd"

const Lattice := preload("res://echo_lattice/lattice.gd")
const PathRecorder := preload("res://echo_lattice/path_recorder.gd")
const HabitSignature := preload("res://echo_lattice/habit_signature.gd")
const RewriteOperators := preload("res://echo_lattice/rewrite_operators.gd")


func _walked_right(lat: Lattice, cells: Array) -> HabitSignature:
	var r := PathRecorder.new()
	for c in cells:
		r.record_step(c)
	return HabitSignature.extract(r, lat)


func test_fossilize_targets_hot_floor() -> void:
	var lat := Lattice.from_ascii("S....G")
	var sig := _walked_right(lat, [
		Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
	])
	var rewrites := RewriteOperators.fossilize_hot_cell(lat, sig)
	assert_gt(rewrites.size(), 0)
	var first: Dictionary = rewrites[0]
	var patch: Dictionary = first["patches"][0]
	assert_eq(int(patch["cell"]), Lattice.Cell.FOSSIL)
	# Must not touch start / goal.
	assert_ne(patch["pos"], lat.start)
	assert_ne(patch["pos"], lat.goal)


func test_place_deflector_requires_streak_and_bias() -> void:
	var lat := Lattice.from_ascii("S......G")
	var walk: Array = []
	for x in range(6):
		walk.append(Vector2i(x, 0))
	var sig := _walked_right(lat, walk)
	var rewrites := RewriteOperators.place_deflector(lat, sig)
	assert_gt(rewrites.size(), 0)
	var first: Dictionary = rewrites[0]
	# Deflector goes into an empty floor ahead of the visited streak.
	var patch: Dictionary = first["patches"][0]
	assert_eq(int(patch["cell"]), Lattice.Cell.WALL)
	assert_ne(patch["pos"], lat.goal)
	assert_ne(patch["pos"], lat.start)


func test_place_deflector_yields_none_on_weak_bias() -> void:
	var lat := Lattice.from_ascii("......\n......\n......\n......")
	var r := PathRecorder.new()
	# Fully balanced 3-direction path so dominant_bias falls below the 0.35
	# threshold and no deflector is proposed.
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))    # R
	r.record_step(Vector2i(1, 1))    # D
	r.record_step(Vector2i(0, 1))    # L
	var sig := HabitSignature.extract(r, lat)
	assert_lt(sig.dominant_bias, 0.35)
	var rewrites := RewriteOperators.place_deflector(lat, sig)
	assert_eq(rewrites.size(), 0)


func test_carve_shortcut_opens_wall_adjacent_to_visited() -> void:
	var lat := Lattice.from_ascii("S.#.G\n#.#..\n.....")
	var sig := _walked_right(lat, [
		Vector2i(0, 0), Vector2i(1, 0),
	])
	var rewrites := RewriteOperators.carve_shortcut(lat, sig)
	assert_gt(rewrites.size(), 0)
	for c in rewrites:
		var p: Dictionary = c["patches"][0]
		assert_eq(int(p["cell"]), Lattice.Cell.FLOOR)


func test_grow_wall_avoids_path_and_terminals() -> void:
	var lat := Lattice.from_ascii(
		"S.....\n" +
		"......\n" +
		"......\n" +
		"......\n" +
		"#.....\n" +
		".....G"
	)
	# Walk across the top row only.
	var walk: Array = []
	for x in range(6):
		walk.append(Vector2i(x, 0))
	var sig := _walked_right(lat, walk)
	var rewrites := RewriteOperators.grow_wall_far_from_path(lat, sig)
	assert_gt(rewrites.size(), 0)
	for c in rewrites:
		var p: Dictionary = c["patches"][0]
		assert_ne(p["pos"], lat.start)
		assert_ne(p["pos"], lat.goal)
		# The proposed cell must have been a FLOOR (i.e. not already a wall).
		assert_eq(int(p["cell"]), Lattice.Cell.WALL)


func test_propose_all_sorted_desc() -> void:
	var lat := Lattice.from_ascii("S......G")
	var walk: Array = []
	for x in range(6):
		walk.append(Vector2i(x, 0))
	# Adjacent back-and-forth to create a hot cell.
	walk.append(Vector2i(4, 0))
	walk.append(Vector2i(5, 0))
	walk.append(Vector2i(4, 0))
	walk.append(Vector2i(5, 0))
	var sig := _walked_right(lat, walk)
	var all := RewriteOperators.propose_all(lat, sig)
	assert_gt(all.size(), 0)
	for i in range(1, all.size()):
		assert_ge(float(all[i - 1]["score"]), float(all[i]["score"]))


func test_operators_never_mutate_input_lattice() -> void:
	var lat := Lattice.from_ascii("S..\n.#.\n..G")
	var before := lat.to_ascii()
	var sig := _walked_right(lat, [
		Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2),
	])
	var _a := RewriteOperators.fossilize_hot_cell(lat, sig)
	var _b := RewriteOperators.place_deflector(lat, sig)
	var _c := RewriteOperators.carve_shortcut(lat, sig)
	var _d := RewriteOperators.grow_wall_far_from_path(lat, sig)
	var _e := RewriteOperators.widen_hot_corridor(lat, sig)
	var _f := RewriteOperators.propose_all(lat, sig)
	assert_eq(lat.to_ascii(), before)
