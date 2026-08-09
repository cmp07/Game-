extends "res://echo_lattice/tests/test_framework.gd"

const PathRecorder := preload("res://echo_lattice/path_recorder.gd")


func test_idle_collapse() -> void:
	var r := PathRecorder.new()
	r.record_step(Vector2i(2, 2))
	for i in range(5):
		r.record_step(Vector2i(2, 2))
	assert_eq(r.length(), 1)


func test_undo_appends_and_counts() -> void:
	var r := PathRecorder.new()
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))
	r.record_step(Vector2i(2, 0))
	var ok := r.record_undo()
	assert_true(ok)
	assert_eq(r.length(), 4, "undo appends the previous cell (not a delete)")
	assert_eq(r.last(), Vector2i(1, 0))
	assert_eq(r.undo_count, 1)


func test_undo_no_op_when_empty() -> void:
	var r := PathRecorder.new()
	assert_false(r.record_undo())


func test_visit_counts_include_ping_pong() -> void:
	var r := PathRecorder.new()
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(0, 1))
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(0, 1))
	r.record_step(Vector2i(0, 0))
	var vc := r.visit_counts()
	assert_eq(int(vc.get(Vector2i(0, 0), 0)), 3)
	assert_eq(int(vc.get(Vector2i(0, 1), 0)), 2)


func test_motif_boundaries_snapshot_lengths() -> void:
	var r := PathRecorder.new()
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))
	r.record_motif_boundary()
	r.record_step(Vector2i(2, 0))
	r.record_motif_boundary()
	var mb := r.motif_boundaries()
	assert_eq(mb.size(), 2)
	assert_eq(mb[0], 2)
	assert_eq(mb[1], 3)


func test_round_trip_preserves_undo_and_motifs() -> void:
	var r := PathRecorder.new()
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(1, 0))
	r.record_undo()
	r.record_motif_boundary()
	var d := r.to_data()
	var r2 := PathRecorder.from_data(d)
	assert_eq(r2.positions(), r.positions())
	assert_eq(r2.undo_count, r.undo_count)
	assert_eq(r2.motif_boundaries().size(), r.motif_boundaries().size())
