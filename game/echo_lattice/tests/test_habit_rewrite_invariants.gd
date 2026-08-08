## Habit-rewrite invariants — the rules the grammar in `src/grammar.gd`
## must uphold no matter which transform pack the habit profile pulls.
##
## These are the algebraic guarantees that make the "watch the maze
## become a different person" fantasy trustworthy: mirrors are their
## own inverse, rotations compose, safe transforms never break the
## walk, and identity is really identity.
extends EchoLatticeTestBase

const SEEDS: Array = [0, 1, 42, 137, 9001]

const SAMPLE_ROWS: Array = [
	# Snakes an S-shaped corridor between three wall bands so mirror and
	# rotate operations have real content to permute, while keeping
	# start→door connected for the solvability checks.
	"S.........",
	"#########.",
	"..........",
	".#########",
	"..........",
	".#########",
	".........D",
]


func _sample_lattice() -> Lattice:
	# Hand-crafted small solvable chamber; used across the isometry checks
	# so we're always comparing to a lattice with real content, not the
	# degenerate "all-floor" case.
	return Lattice.from_rows(SAMPLE_ROWS)


func test_sample_lattice_itself_is_valid_and_solvable() -> void:
	var l: Lattice = _sample_lattice()
	assert_true(l.is_valid(), "sample lattice must be valid")
	assert_true(Solver.is_solvable(l), "sample lattice must be solvable")


func test_identity_is_identity() -> void:
	var l: Lattice = _sample_lattice()
	var out: Lattice = Grammar.identity(l)
	assert_lattices_equal(l, out, "identity transform must not alter the lattice")


func test_mirror_h_is_involution() -> void:
	var l: Lattice = _sample_lattice()
	assert_lattices_equal(Grammar.mirror_h(Grammar.mirror_h(l)), l, "mirror_h ∘ mirror_h = id")


func test_mirror_v_is_involution() -> void:
	var l: Lattice = _sample_lattice()
	assert_lattices_equal(Grammar.mirror_v(Grammar.mirror_v(l)), l, "mirror_v ∘ mirror_v = id")


func test_rotate_180_is_involution() -> void:
	var l: Lattice = _sample_lattice()
	assert_lattices_equal(Grammar.rotate_180(Grammar.rotate_180(l)), l, "rotate_180² = id")


func test_mirror_h_composed_mirror_v_equals_rotate_180() -> void:
	var l: Lattice = _sample_lattice()
	var lhs: Lattice = Grammar.mirror_h(Grammar.mirror_v(l))
	var rhs: Lattice = Grammar.rotate_180(l)
	assert_lattices_equal(lhs, rhs, "mirror_h ∘ mirror_v = rotate_180")


func test_isometries_preserve_dimensions_and_marker_counts() -> void:
	var l: Lattice = _sample_lattice()
	var isometries: Array = [
		Grammar.mirror_h(l),
		Grammar.mirror_v(l),
		Grammar.rotate_180(l),
		Grammar.identity(l),
	]
	for r in isometries:
		assert_eq(r.width, l.width, "width preserved by isometry")
		assert_eq(r.height, l.height, "height preserved by isometry")
		assert_eq(r.count_of(Lattice.START), 1, "exactly one start after isometry")
		assert_eq(r.count_of(Lattice.DOOR), 1, "exactly one door after isometry")


func test_isometries_preserve_solvability() -> void:
	var l: Lattice = _sample_lattice()
	assert_true(Solver.is_solvable(l), "sample lattice is solvable")
	for f in [Grammar.T_MIRROR_H, Grammar.T_MIRROR_V, Grammar.T_ROTATE_180, Grammar.T_IDENTITY]:
		var out: Lattice = Grammar.apply(f, l, 0)
		assert_true(Solver.is_solvable(out), "%s must preserve solvability" % f)


func test_isometries_preserve_shortest_path_length() -> void:
	var l: Lattice = _sample_lattice()
	var base_len: int = Solver.shortest_path_length(l)
	for f in [Grammar.T_MIRROR_H, Grammar.T_MIRROR_V, Grammar.T_ROTATE_180, Grammar.T_IDENTITY]:
		var out: Lattice = Grammar.apply(f, l, 0)
		assert_eq(
			Solver.shortest_path_length(out),
			base_len,
			"%s must preserve start→door distance" % f,
		)


func test_safe_apply_never_returns_unsolvable_lattice() -> void:
	var l: Lattice = _sample_lattice()
	for name in Grammar.all_transforms():
		for seed in SEEDS:
			var out: Lattice = Grammar.safe_apply(name, l, seed)
			assert_true(out.is_valid(), "safe_apply(%s, seed=%d) invalid" % [name, seed])
			assert_true(
				Solver.is_solvable(out),
				"safe_apply(%s, seed=%d) unsolvable" % [name, seed],
			)


func test_apply_deck_is_deterministic() -> void:
	var l: Lattice = _sample_lattice()
	var deck: Array = [Grammar.T_MIRROR_H, Grammar.T_THICKEN, Grammar.T_MIRROR_V, Grammar.T_CARVE]
	for seed in SEEDS:
		var a: Lattice = Grammar.apply_deck(l, deck, seed)
		var b: Lattice = Grammar.apply_deck(l, deck, seed)
		assert_lattices_equal(a, b, "apply_deck deterministic at seed=%d" % seed)


func test_apply_deck_is_order_sensitive() -> void:
	# We only require that *some* seed pair changes the outcome. Pure
	# isometry decks are order-insensitive by design (mirror_h and
	# mirror_v commute), so we mix in a content edit that has room to
	# actually take effect on the sample lattice.
	var l: Lattice = _sample_lattice()
	var deck_a: Array = [Grammar.T_CARVE, Grammar.T_MIRROR_H]
	var deck_b: Array = [Grammar.T_MIRROR_H, Grammar.T_CARVE]
	var extra_seeds: Array = range(1, 32)
	var any_difference: bool = false
	for seed in extra_seeds:
		var a: Lattice = Grammar.apply_deck(l, deck_a, seed)
		var b: Lattice = Grammar.apply_deck(l, deck_b, seed)
		if not a.equals(b):
			any_difference = true
			break
	assert_true(any_difference, "deck order must matter when a content edit is involved")


func test_apply_deck_preserves_start_and_door_count() -> void:
	var l: Lattice = _sample_lattice()
	var deck: Array = [Grammar.T_THICKEN, Grammar.T_CARVE, Grammar.T_ROTATE_180]
	for seed in SEEDS:
		var out: Lattice = Grammar.apply_deck(l, deck, seed)
		assert_eq(out.count_of(Lattice.START), 1, "one start after full deck (seed=%d)" % seed)
		assert_eq(out.count_of(Lattice.DOOR), 1, "one door after full deck (seed=%d)" % seed)


func test_habit_conditioned_deck_choice_is_stable() -> void:
	# For a given buffer, the generator must always pick the same deck.
	# The QA matrix pins each label to a specific deck; changing this
	# mapping is a versioned rule change.
	var expectations: Dictionary = {
		HabitProfile.DASH_HEAVY: [Grammar.T_THICKEN, Grammar.T_MIRROR_H],
		HabitProfile.LOOPY: [Grammar.T_MIRROR_V, Grammar.T_ROTATE_180],
		HabitProfile.HESITANT: [Grammar.T_CARVE, Grammar.T_MIRROR_H],
		HabitProfile.NEUTRAL: [Grammar.T_IDENTITY],
	}
	var samples: Dictionary = {
		HabitProfile.DASH_HEAVY: _make_dash_buffer(),
		HabitProfile.LOOPY: _make_loopy_buffer(),
		HabitProfile.HESITANT: _make_hesitant_buffer(),
		HabitProfile.NEUTRAL: MoveBuffer.new(),
	}
	for label in samples.keys():
		var buf: MoveBuffer = samples[label]
		var deck: Array = LatticeGenerator.pick_deck(buf)
		assert_eq(deck, expectations[label], "deck mapping stable for %s" % label)


func _make_dash_buffer() -> MoveBuffer:
	var b: MoveBuffer = MoveBuffer.new(30)
	for _i in range(20):
		b.push(MoveBuffer.RIGHT)
	return b


func _make_loopy_buffer() -> MoveBuffer:
	var b: MoveBuffer = MoveBuffer.new(30)
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
