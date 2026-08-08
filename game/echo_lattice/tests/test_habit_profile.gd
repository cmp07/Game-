## Classification tests for `HabitProfile`. These fix the mapping from
## MoveBuffer statistics to human-readable labels; changing a threshold
## should require updating both this file and the QA matrix.
extends EchoLatticeTestBase


func test_small_buffer_is_neutral() -> void:
	var b: MoveBuffer = MoveBuffer.new(30)
	b.extend([MoveBuffer.UP, MoveBuffer.RIGHT])
	assert_eq(HabitProfile.classify(b), HabitProfile.NEUTRAL, "3-move sample stays neutral")


func test_dash_heavy_detected_on_long_straight_runs() -> void:
	var b: MoveBuffer = MoveBuffer.new(30)
	for i in range(12):
		b.push(MoveBuffer.RIGHT)
	assert_eq(HabitProfile.classify(b), HabitProfile.DASH_HEAVY, "12 rights = dash-heavy")


func test_hesitant_detected_on_high_backtrack_rate() -> void:
	var b: MoveBuffer = MoveBuffer.new(30)
	for i in range(6):
		b.push(MoveBuffer.UP)
		b.push(MoveBuffer.DOWN)
	assert_eq(HabitProfile.classify(b), HabitProfile.HESITANT, "pure ping-pong = hesitant")


func test_loopy_detected_on_moderate_repetition_without_backtracks() -> void:
	# Moderate repetition, no reverses, low straight-run rate: qualifies as LOOPY.
	# Pattern: RIGHT UP RIGHT UP RIGHT UP (no two consecutive same, no reverses).
	# Straight-run rate = 0. Doesn't cleanly fit LOOPY under current rules,
	# so use a mix that hits ~0.35 straight-run without backtracks.
	var b: MoveBuffer = MoveBuffer.new(30)
	b.extend([
		MoveBuffer.UP, MoveBuffer.UP,
		MoveBuffer.RIGHT,
		MoveBuffer.UP, MoveBuffer.UP,
		MoveBuffer.RIGHT,
		MoveBuffer.UP, MoveBuffer.UP,
	])
	# straight_run_rate = repeats / pairs. Pairs = 7. Repeats: UU (yes),
	# UR (no), RU (no), UU (yes), UR (no), RU (no), UU (yes) => 3/7 ≈ 0.43.
	# Backtrack rate = 0. Should land as LOOPY (>=0.35 and <0.55).
	assert_eq(HabitProfile.classify(b), HabitProfile.LOOPY, "moderate straights = loopy")


func test_null_buffer_is_neutral() -> void:
	assert_eq(HabitProfile.classify(null), HabitProfile.NEUTRAL, "null buffer classifies as neutral")
