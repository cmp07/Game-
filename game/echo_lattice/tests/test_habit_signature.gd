extends "res://echo_lattice/tests/test_framework.gd"

const Lattice := preload("res://echo_lattice/lattice.gd")
const PathRecorder := preload("res://echo_lattice/path_recorder.gd")
const HabitSignature := preload("res://echo_lattice/habit_signature.gd")


func _make_lat_and_recorder(ascii: String) -> Dictionary:
	var lat := Lattice.from_ascii(ascii)
	var r := PathRecorder.new()
	return {"lat": lat, "recorder": r}


func test_pure_right_bias() -> void:
	var ctx := _make_lat_and_recorder("S....G")
	var r: PathRecorder = ctx.recorder
	for x in range(6):
		r.record_step(Vector2i(x, 0))
	var sig := HabitSignature.extract(r, ctx.lat)
	assert_eq(sig.dominant_dir, Vector2i(1, 0))
	assert_approx(sig.dominant_bias, 1.0, 1e-6)
	assert_approx(sig.turn_rate, 0.0, 1e-6)
	assert_approx(sig.backtrack_rate, 0.0, 1e-6)


func test_zigzag_high_turn_rate() -> void:
	var ctx := _make_lat_and_recorder(".....\n.....\n.....")
	var r: PathRecorder = ctx.recorder
	# Path: (0,0) -> (1,0) -> (1,1) -> (2,1) -> (2,2) : dirs R, D, R, D
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))
	r.record_step(Vector2i(1, 1))
	r.record_step(Vector2i(2, 1))
	r.record_step(Vector2i(2, 2))
	var sig := HabitSignature.extract(r, ctx.lat)
	assert_approx(sig.turn_rate, 1.0, 1e-6)
	assert_approx(sig.backtrack_rate, 0.0, 1e-6)


func test_backtrack_rate() -> void:
	var ctx := _make_lat_and_recorder("......")
	var r: PathRecorder = ctx.recorder
	# Dirs: R, L, R -> transitions: R->L (turn+backtrack), L->R (turn+backtrack).
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))
	var sig := HabitSignature.extract(r, ctx.lat)
	assert_approx(sig.backtrack_rate, 1.0, 1e-6)
	assert_approx(sig.turn_rate, 1.0, 1e-6)


func test_wall_hug_is_one_when_all_cells_touch_wall() -> void:
	var ctx := _make_lat_and_recorder("######\nS....G\n######")
	var lat: Lattice = ctx.lat
	var r: PathRecorder = ctx.recorder
	for x in range(6):
		r.record_step(Vector2i(x, 1))
	var sig := HabitSignature.extract(r, lat)
	assert_approx(sig.wall_hug, 1.0, 1e-6)


func test_wall_hug_is_zero_in_open_room() -> void:
	var ctx := _make_lat_and_recorder(".....\n.....\n.....\n.....\n.....")
	var lat: Lattice = ctx.lat
	var r: PathRecorder = ctx.recorder
	r.record_step(Vector2i(2, 2))
	r.record_step(Vector2i(2, 3))
	r.record_step(Vector2i(2, 2))
	var sig := HabitSignature.extract(r, lat)
	assert_approx(sig.wall_hug, 0.0, 1e-6)


func test_hot_cells_exclude_terminals_and_sort_desc() -> void:
	var ctx := _make_lat_and_recorder("S....G")
	var lat: Lattice = ctx.lat
	var r: PathRecorder = ctx.recorder
	r.record_step(lat.start)                              # start ignored
	r.record_step(Vector2i(1, 0))
	r.record_step(Vector2i(2, 0))
	r.record_step(Vector2i(1, 0))
	r.record_step(Vector2i(2, 0))
	r.record_step(Vector2i(3, 0))
	r.record_step(Vector2i(4, 0))
	r.record_step(lat.goal)                               # goal ignored
	var sig := HabitSignature.extract(r, lat)
	var hot := sig.hot_cells(3)
	assert_eq(hot.size(), 3)
	# (1,0) and (2,0) are the two hottest and tie at 2 visits; sort by (y,x)
	# so (1,0) comes before (2,0).
	assert_eq(hot[0], Vector2i(1, 0))
	assert_eq(hot[1], Vector2i(2, 0))


func test_empty_path_yields_neutral_signature() -> void:
	var lat := Lattice.from_ascii("S.\n.G")
	var r := PathRecorder.new()
	var sig := HabitSignature.extract(r, lat)
	assert_eq(sig.total_steps, 0)
	assert_eq(sig.unique_cell_count, 0)
	assert_approx(sig.turn_rate, 0.0)
	assert_approx(sig.dominant_bias, 0.0)


func test_streaks_reported_desc() -> void:
	var lat := Lattice.from_ascii("S....\n.....\n....G")
	var r := PathRecorder.new()
	# Path: R R R D D D -> streaks [3, 3]
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))
	r.record_step(Vector2i(2, 0))
	r.record_step(Vector2i(3, 0))
	r.record_step(Vector2i(3, 1))
	r.record_step(Vector2i(3, 2))
	r.record_step(Vector2i(4, 2))
	var sig := HabitSignature.extract(r, lat)
	# The last streak (R of len 1) plus streaks [3, 2].
	assert_gt(sig.straight_streaks.size(), 0)
	assert_eq(sig.straight_streaks[0], sig.straight_streaks.max())
