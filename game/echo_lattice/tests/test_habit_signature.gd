extends "res://echo_lattice/tests/test_framework.gd"

const Lattice := preload("res://echo_lattice/lattice.gd")
const PathRecorder := preload("res://echo_lattice/path_recorder.gd")
const HabitSignature := preload("res://echo_lattice/habit_signature.gd")


func _walked(lat: Lattice, cells: Array) -> HabitSignature:
	var r := PathRecorder.new()
	for c in cells:
		r.record_step(c)
	return HabitSignature.extract(r, lat)


func test_single_direction_all_bias() -> void:
	var lat := Lattice.from_ascii("S......G")
	var walk: Array = []
	for x in range(6):
		walk.append(Vector2i(x, 0))
	var sig := _walked(lat, walk)
	assert_approx(sig.dominant_bias, 1.0, 1e-6)
	assert_eq(sig.dominant_dir, Vector2i(1, 0))
	assert_eq(sig.echo_depth, 0)
	assert_eq(sig.bucket("H2"), "BIASED")


func test_echo_depth_counts_backtrack_run() -> void:
	# Path R L R L R -> dirs = [R, L, R, L, R]; backtrack streaks of 4.
	var lat := Lattice.from_ascii("......\n......")
	var r := PathRecorder.new()
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))  # R
	r.record_step(Vector2i(0, 0))  # L
	r.record_step(Vector2i(1, 0))  # R
	r.record_step(Vector2i(0, 0))  # L
	r.record_step(Vector2i(1, 0))  # R
	var sig := HabitSignature.extract(r, lat)
	assert_eq(sig.echo_depth, 4)
	assert_eq(sig.bucket("H8"), "REFRAIN")


func test_undo_rate_reflects_thrash() -> void:
	var lat := Lattice.from_ascii("......")
	var r := PathRecorder.new()
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))
	r.record_undo()
	r.record_undo()
	# For the undo to actually pop we need >=2 in history at each moment.
	var sig := HabitSignature.extract(r, lat)
	assert_gt(sig.undo_rate, 0.0)
	assert_eq(sig.bucket("H7"), "THRASH")


func test_density_slope_growth_and_shrink() -> void:
	var lat := Lattice.from_ascii("..........\n..........")
	# Grow: keep discovering new cells all the way.
	var grow_walk: Array = []
	for x in range(10):
		grow_walk.append(Vector2i(x, 0))
	var sig_grow := _walked(lat, grow_walk)
	assert_gt(sig_grow.density_slope, 0.0)

	# Shrink: bounce back and forth in a small area.
	var r := PathRecorder.new()
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))
	r.record_step(Vector2i(0, 0))
	var sig_shrink := HabitSignature.extract(r, lat)
	assert_le(sig_shrink.density_slope, 0.05)


func test_greed_index_rises_with_directed_growth() -> void:
	var lat := Lattice.from_ascii("..........\n..........")
	var walk: Array = []
	for x in range(8):
		walk.append(Vector2i(x, 0))
	var sig := _walked(lat, walk)
	assert_gt(sig.greed_index, 0.5, "linear march = greedy pattern")


func test_greed_index_is_zero_on_empty_path() -> void:
	var lat := Lattice.from_ascii("S.G")
	var r := PathRecorder.new()
	var sig := HabitSignature.extract(r, lat)
	assert_eq(sig.greed_index, 0.0)


func test_fingerprint_stable_under_replay() -> void:
	var lat := Lattice.from_ascii("S.....G")
	var walk: Array = []
	for x in range(6):
		walk.append(Vector2i(x, 0))
	var s1 := _walked(lat, walk)
	var s2 := _walked(lat, walk)
	assert_eq(s1.fingerprint(), s2.fingerprint())


func test_hot_dominance_counts_top_cell() -> void:
	var lat := Lattice.from_ascii("......")
	var r := PathRecorder.new()
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))
	r.record_undo()
	r.record_step(Vector2i(1, 0))
	r.record_undo()
	r.record_step(Vector2i(1, 0))
	var sig := HabitSignature.extract(r, lat)
	assert_gt(sig.hot_dominance, 0.0)
