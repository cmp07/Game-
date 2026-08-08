## Determinism and bookkeeping tests for `MoveBuffer`.
##
## The buffer's hash is the anchor of the whole "same seed, different
## player" fantasy; if this drifts, every downstream determinism claim
## in the QA matrix collapses.
extends EchoLatticeTestBase


func test_push_respects_capacity() -> void:
	var b: MoveBuffer = MoveBuffer.new(4)
	for m in [MoveBuffer.UP, MoveBuffer.UP, MoveBuffer.RIGHT, MoveBuffer.DOWN, MoveBuffer.LEFT, MoveBuffer.RIGHT]:
		b.push(m)
	assert_eq(b.size(), 4, "buffer stays at capacity after overflow")
	# The four most recent moves should be [RIGHT, DOWN, LEFT, RIGHT].
	var expected: PackedByteArray = PackedByteArray([MoveBuffer.RIGHT, MoveBuffer.DOWN, MoveBuffer.LEFT, MoveBuffer.RIGHT])
	assert_eq(b.get_moves(), expected, "trims oldest moves first")


func test_hash_is_deterministic_across_instances() -> void:
	var a: MoveBuffer = MoveBuffer.new(30)
	var c: MoveBuffer = MoveBuffer.new(30)
	var seq: Array = [MoveBuffer.UP, MoveBuffer.RIGHT, MoveBuffer.UP, MoveBuffer.LEFT, MoveBuffer.INTERACT, MoveBuffer.DOWN]
	a.extend(seq)
	c.extend(seq)
	assert_eq(a.hash_code(), c.hash_code(), "same moves same hash")


func test_hash_changes_with_order() -> void:
	var a: MoveBuffer = MoveBuffer.new(30)
	var c: MoveBuffer = MoveBuffer.new(30)
	a.extend([MoveBuffer.UP, MoveBuffer.RIGHT])
	c.extend([MoveBuffer.RIGHT, MoveBuffer.UP])
	assert_ne(a.hash_code(), c.hash_code(), "order matters")


func test_hash_changes_with_capacity() -> void:
	var a: MoveBuffer = MoveBuffer.new(4)
	var c: MoveBuffer = MoveBuffer.new(30)
	var seq: Array = [MoveBuffer.UP, MoveBuffer.UP]
	a.extend(seq)
	c.extend(seq)
	assert_ne(a.hash_code(), c.hash_code(), "capacity is part of hash")


func test_backtrack_rate_counts_reverses() -> void:
	var b: MoveBuffer = MoveBuffer.new(30)
	b.extend([MoveBuffer.UP, MoveBuffer.DOWN, MoveBuffer.UP, MoveBuffer.DOWN, MoveBuffer.UP])
	# pairs = 4, all reverses -> 1.0.
	assert_eq(b.backtrack_rate(), 1.0, "pure ping-pong backtracks 100%")


func test_straight_run_rate_counts_repeats() -> void:
	var b: MoveBuffer = MoveBuffer.new(30)
	b.extend([MoveBuffer.UP, MoveBuffer.UP, MoveBuffer.UP, MoveBuffer.UP])
	# 3 pairs, all repeats -> 1.0.
	assert_eq(b.straight_run_rate(), 1.0, "pure straight run")


func test_left_right_bias_is_bounded() -> void:
	var b: MoveBuffer = MoveBuffer.new(30)
	b.extend([MoveBuffer.LEFT, MoveBuffer.LEFT, MoveBuffer.LEFT])
	assert_eq(b.left_right_bias(), -1.0, "all-left saturates to -1")
	var b2: MoveBuffer = MoveBuffer.new(30)
	b2.extend([MoveBuffer.RIGHT, MoveBuffer.RIGHT])
	assert_eq(b2.left_right_bias(), 1.0, "all-right saturates to +1")


func test_interact_does_not_count_as_direction() -> void:
	var b: MoveBuffer = MoveBuffer.new(30)
	b.extend([MoveBuffer.INTERACT, MoveBuffer.INTERACT])
	assert_eq(b.left_right_bias(), 0.0, "interact-only bias is 0")
	assert_eq(b.backtrack_rate(), 0.0, "interact-only backtrack rate is 0")
	assert_eq(b.straight_run_rate(), 0.0, "interact-only run rate is 0")
