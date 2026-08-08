## Maze solvability invariants — the release gates from
## `docs/ECHO_LATTICE/09_QA.md` §"Solvability" expressed as automated
## checks.
##
## The invariant is stated as a universal quantifier over (seed, buffer):
##
##     ∀ seed ∈ Seeds, ∀ buf ∈ MoveBuffers.
##         Solver.is_solvable(LatticeGenerator.generate(seed, w, h, buf))
##
## We exercise it against three families of inputs:
##
##   1. A grid of deterministic seeds paired with an empty buffer — the
##      dumb case: catches any regression in the base carve.
##   2. The same seeds paired with hand-crafted "adversarial" habit
##      profiles (all-hesitant, all-dash, all-loopy).
##   3. Randomised fuzz: many (seed, buffer) pairs drawn from a fixed
##      RNG stream so a failure re-runs the same case next time.
extends EchoLatticeTestBase

const GRID_SIZES: Array = [
	Vector2i(9, 9),
	Vector2i(11, 7),
	Vector2i(13, 13),
	Vector2i(17, 9),
]

const DETERMINISTIC_SEEDS: Array = [
	1, 2, 3, 7, 42, 101, 1024, 65535, 123456,
]

const FUZZ_ITERATIONS: int = 60


func test_generator_output_is_structurally_valid() -> void:
	for size in GRID_SIZES:
		for seed in DETERMINISTIC_SEEDS:
			var buffer: MoveBuffer = MoveBuffer.new()
			var lattice: Lattice = LatticeGenerator.generate(seed, size.x, size.y, buffer)
			assert_true(
				lattice.is_valid(),
				"lattice must be valid for seed=%d size=%s" % [seed, str(size)],
			)


func test_generator_output_is_always_solvable_empty_buffer() -> void:
	for size in GRID_SIZES:
		for seed in DETERMINISTIC_SEEDS:
			var buffer: MoveBuffer = MoveBuffer.new()
			var lattice: Lattice = LatticeGenerator.generate(seed, size.x, size.y, buffer)
			assert_true(
				Solver.is_solvable(lattice),
				"empty-buffer lattice unsolvable at seed=%d size=%s" % [seed, str(size)],
			)


func test_generator_output_is_solvable_for_each_habit_archetype() -> void:
	# One canonical buffer per non-neutral habit label.
	var archetype_buffers: Dictionary = {
		HabitProfile.DASH_HEAVY: _make_dash_buffer(),
		HabitProfile.LOOPY: _make_loopy_buffer(),
		HabitProfile.HESITANT: _make_hesitant_buffer(),
	}
	for label in archetype_buffers.keys():
		var buf: MoveBuffer = archetype_buffers[label]
		assert_eq(HabitProfile.classify(buf), label, "buffer really is a %s sample" % label)
		for size in GRID_SIZES:
			for seed in DETERMINISTIC_SEEDS:
				var lattice: Lattice = LatticeGenerator.generate(seed, size.x, size.y, buf)
				assert_true(
					lattice.is_valid(),
					"%s lattice invalid at seed=%d size=%s" % [label, seed, str(size)],
				)
				assert_true(
					Solver.is_solvable(lattice),
					"%s lattice unsolvable at seed=%d size=%s" % [label, seed, str(size)],
				)


func test_generator_output_is_solvable_under_fuzz() -> void:
	# Randomised — but with a fixed seed so failures are reproducible.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 0xEC80_A771
	for i in range(FUZZ_ITERATIONS):
		var seed: int = rng.randi()
		var w: int = 2 * rng.randi_range(3, 9) + 1   # odd widths 7..19
		var h: int = 2 * rng.randi_range(3, 9) + 1
		var buf: MoveBuffer = MoveBuffer.new(rng.randi_range(4, 30))
		var moves_to_push: int = rng.randi_range(0, 40)
		for _j in range(moves_to_push):
			buf.push(rng.randi_range(0, 4))
		var lattice: Lattice = LatticeGenerator.generate(seed, w, h, buf)
		assert_true(
			lattice.is_valid(),
			"fuzz #%d invalid (seed=%d size=%dx%d)" % [i, seed, w, h],
		)
		assert_true(
			Solver.is_solvable(lattice),
			"fuzz #%d unsolvable (seed=%d size=%dx%d, buf_hash=%d)" % [
				i, seed, w, h, buf.hash_code(),
			],
		)


func test_generator_is_deterministic() -> void:
	# Same (seed, buffer) → same lattice, byte for byte. This is the
	# "streamer-science / ghost-race" release gate.
	var buf1: MoveBuffer = MoveBuffer.new()
	buf1.extend([MoveBuffer.UP, MoveBuffer.RIGHT, MoveBuffer.UP, MoveBuffer.DOWN])
	var buf2: MoveBuffer = MoveBuffer.new()
	buf2.extend([MoveBuffer.UP, MoveBuffer.RIGHT, MoveBuffer.UP, MoveBuffer.DOWN])
	var a: Lattice = LatticeGenerator.generate(42, 11, 11, buf1)
	var b: Lattice = LatticeGenerator.generate(42, 11, 11, buf2)
	assert_lattices_equal(a, b, "same inputs must produce identical lattice")


func test_generator_reacts_to_buffer_change() -> void:
	# Different buffers should (in general) produce a different lattice.
	# We probe several seeds so a "coincidental identity" doesn't hide a
	# real regression, and require at least one difference to observe.
	var buf_empty: MoveBuffer = MoveBuffer.new()
	var buf_dash: MoveBuffer = _make_dash_buffer()
	var any_difference: bool = false
	for seed in DETERMINISTIC_SEEDS:
		var a: Lattice = LatticeGenerator.generate(seed, 13, 13, buf_empty)
		var b: Lattice = LatticeGenerator.generate(seed, 13, 13, buf_dash)
		if not a.equals(b):
			any_difference = true
			break
	assert_true(any_difference, "empty vs dash-heavy buffer should change the lattice")


func _make_dash_buffer() -> MoveBuffer:
	var b: MoveBuffer = MoveBuffer.new(30)
	for _i in range(20):
		b.push(MoveBuffer.RIGHT)
	return b


func _make_loopy_buffer() -> MoveBuffer:
	var b: MoveBuffer = MoveBuffer.new(30)
	# Same pattern as the habit-profile LOOPY test above.
	var pattern: Array = [MoveBuffer.UP, MoveBuffer.UP, MoveBuffer.RIGHT]
	for _i in range(6):
		for m in pattern:
			b.push(m)
	return b


func _make_hesitant_buffer() -> MoveBuffer:
	var b: MoveBuffer = MoveBuffer.new(30)
	for _i in range(10):
		b.push(MoveBuffer.UP)
		b.push(MoveBuffer.DOWN)
	return b
