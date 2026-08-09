extends "res://echo_lattice/tests/test_framework.gd"

const Lattice := preload("res://echo_lattice/lattice.gd")
const ChamberRuntime := preload("res://echo_lattice/chamber_runtime.gd")
const RewriteEngine := preload("res://echo_lattice/rewrite_engine.gd")
const LatticeBFS := preload("res://echo_lattice/bfs.gd")


func _lat_with_checkpoint() -> Lattice:
	# 8-wide corridor with a checkpoint at (3,0) and goal at (7,0).
	return Lattice.from_ascii(
			"S..C...G\n" +
			"........\n" +
			"........")


func test_walking_records_positions() -> void:
	var lat := _lat_with_checkpoint()
	var cr := ChamberRuntime.new(lat)
	cr.move(Vector2i(1, 0))
	cr.move(Vector2i(1, 0))
	assert_eq(cr.player_pos, Vector2i(2, 0))
	assert_eq(cr.recorder.length(), 3)


func test_checkpoint_queues_and_auto_commits_on_next_move() -> void:
	var lat := _lat_with_checkpoint()
	var cr := ChamberRuntime.new(lat)
	# Walk RRR to reach checkpoint at (3,0) via 4 cells.
	cr.move(Vector2i(1, 0))
	cr.move(Vector2i(1, 0))
	cr.move(Vector2i(1, 0))
	# The checkpoint cell should now be spent and something either queued or
	# activated. Committing on next move guarantees the rewrite lands.
	cr.move(Vector2i(1, 0))
	assert_eq(cr.lattice.get_cell(Vector2i(3, 0)), Lattice.Cell.CHECKPOINT_USED)


func test_wisp_dissolves_on_leave() -> void:
	var lat := Lattice.from_ascii("S.w.G")
	var cr := ChamberRuntime.new(lat)
	cr.move(Vector2i(1, 0))
	cr.move(Vector2i(1, 0))  # onto wisp
	assert_eq(cr.lattice.get_cell(Vector2i(2, 0)), Lattice.Cell.WISP)
	cr.move(Vector2i(1, 0))  # leave wisp
	assert_eq(cr.lattice.get_cell(Vector2i(2, 0)), Lattice.Cell.FLOOR)


func test_cap_enforcement_reverses_oldest_soft() -> void:
	var lat := Lattice.from_ascii(
			"S......G\n" +
			"........\n" +
			"........")
	var cr := ChamberRuntime.new(lat)
	cr.cap = 1
	# Manually activate two soft rewrites via checkpoint calls.
	# Walk to build up habit signature first.
	for x in range(1, 7):
		cr.move(Vector2i(1, 0))
	cr.move(Vector2i(-1, 0))
	cr.move(Vector2i(1, 0))  # bounce for hot cell
	cr.checkpoint()
	cr.commit_telegraphed()
	var count_after_first: int = cr.active.size()
	cr.checkpoint()
	cr.commit_telegraphed()
	# Cap = 1 means active must never exceed 1 (counting non-retired).
	var counting := 0
	for a in cr.active:
		if not a.retired:
			counting += 1
	assert_le(counting, 1)


func test_solvability_holds_across_full_run() -> void:
	var lat := Lattice.from_ascii(
			"S...C....G\n" +
			"..........\n" +
			"..........")
	var cr := ChamberRuntime.new(lat)
	for x in range(1, 10):
		cr.move(Vector2i(1, 0))
		assert_true(LatticeBFS.is_solvable(cr.lattice))
	# Should now be on the goal.
	assert_eq(cr.player_pos, cr.lattice.goal)


func test_undo_restores_and_ticks_counters() -> void:
	var lat := Lattice.from_ascii("S...G")
	var cr := ChamberRuntime.new(lat)
	cr.move(Vector2i(1, 0))
	cr.move(Vector2i(1, 0))
	assert_eq(cr.player_pos, Vector2i(2, 0))
	cr.undo()
	assert_eq(cr.player_pos, Vector2i(1, 0))
	assert_eq(cr.recorder.undo_count, 1)


func test_reset_restores_seed_lattice() -> void:
	var lat := Lattice.from_ascii(
			"S......G\n" +
			"........\n" +
			"........")
	var seed_hash := lat.fingerprint()
	var cr := ChamberRuntime.new(lat)
	for x in range(1, 7):
		cr.move(Vector2i(1, 0))
	cr.checkpoint()
	cr.commit_telegraphed()
	cr.reset()
	assert_eq(cr.lattice.fingerprint(), seed_hash)
	assert_eq(cr.player_pos, cr.lattice.start)
	assert_eq(cr.active.size(), 0)
