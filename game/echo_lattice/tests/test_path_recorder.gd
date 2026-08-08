extends "res://echo_lattice/tests/test_framework.gd"

const PathRecorder := preload("res://echo_lattice/path_recorder.gd")


func test_records_first_position() -> void:
	var r := PathRecorder.new()
	assert_true(r.record_step(Vector2i(1, 1)))
	assert_eq(r.length(), 1)
	assert_eq(r.last(), Vector2i(1, 1))


func test_ignores_stationary_ticks() -> void:
	var r := PathRecorder.new()
	r.record_step(Vector2i(0, 0))
	assert_false(r.record_step(Vector2i(0, 0)))
	assert_eq(r.length(), 1)


func test_records_adjacent_moves() -> void:
	var r := PathRecorder.new()
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))
	r.record_step(Vector2i(1, 1))
	assert_eq(r.length(), 3)
	assert_eq(r.step_count(), 2)


func test_directions_returned() -> void:
	var r := PathRecorder.new()
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))
	r.record_step(Vector2i(1, 1))
	var dirs := r.directions()
	assert_eq(dirs.size(), 2)
	assert_eq(dirs[0], Vector2i(1, 0))
	assert_eq(dirs[1], Vector2i(0, 1))


func test_visit_counts_and_unique_cells() -> void:
	var r := PathRecorder.new()
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))
	var counts := r.visit_counts()
	assert_eq(int(counts[Vector2i(0, 0)]), 2)
	assert_eq(int(counts[Vector2i(1, 0)]), 2)
	assert_eq(r.unique_cells().size(), 2)


func test_record_move_handles_gap() -> void:
	var r := PathRecorder.new(false)   # non-strict
	r.record_move(Vector2i(5, 5), Vector2i(5, 6))
	assert_eq(r.length(), 2)
	assert_eq(r.last(), Vector2i(5, 6))


func test_serialization_roundtrip() -> void:
	var r := PathRecorder.new()
	r.record_step(Vector2i(1, 1))
	r.record_step(Vector2i(2, 1))
	r.record_step(Vector2i(2, 2))
	var data := r.to_data()
	var restored := PathRecorder.from_data(data)
	assert_eq(restored.positions(), r.positions())
