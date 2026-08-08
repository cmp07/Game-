extends "res://echo_lattice/tests/test_framework.gd"

const Lattice := preload("res://echo_lattice/lattice.gd")
const PathRecorder := preload("res://echo_lattice/path_recorder.gd")
const HabitSignature := preload("res://echo_lattice/habit_signature.gd")
const RewriteEngine := preload("res://echo_lattice/rewrite_engine.gd")
const LatticeBFS := preload("res://echo_lattice/bfs.gd")


func _make_rng() -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	return rng


func _walked(lat: Lattice, cells: Array) -> HabitSignature:
	var r := PathRecorder.new()
	for c in cells:
		r.record_step(c)
	return HabitSignature.extract(r, lat)


const _WIDE_ASCII := (
	"S......\n" +
	".......\n" +
	".......\n" +
	".......\n" +
	"......G"
)


## Right along the top row, back one step to create a hot cell, then down the
## last column to the goal. Every transition is 4-adjacent.
func _walk_across_top(lat: Lattice) -> Array:
	var walk: Array = []
	var last_x := lat.width - 1
	var last_y := lat.height - 1
	for x in range(lat.width):
		walk.append(Vector2i(x, 0))
	walk.append(Vector2i(last_x - 1, 0))
	walk.append(Vector2i(last_x, 0))
	for y in range(1, last_y + 1):
		walk.append(Vector2i(last_x, y))
	return walk


func test_engine_applies_first_valid_rewrite() -> void:
	var lat := Lattice.from_ascii(_WIDE_ASCII)
	# Straight walk with a revisit so fossilize has a hot cell.
	var walk: Array = []
	for x in range(lat.width):
		walk.append(Vector2i(x, 0))
	walk.append(Vector2i(lat.width - 1, 1))
	walk.append(Vector2i(lat.width - 1, 0))
	walk.append(Vector2i(lat.width - 2, 0))
	walk.append(Vector2i(lat.width - 1, 0))
	walk.append(Vector2i(lat.width - 1, 1))
	for y in range(2, lat.height):
		walk.append(Vector2i(lat.width - 1, y))
	var sig := _walked(lat, walk)
	var res := RewriteEngine.apply(lat, sig, _make_rng())
	assert_true(res.applied, res.summary())
	assert_true(LatticeBFS.is_solvable(res.lattice))
	assert_false(res.lattice.equals(lat), "engine should mutate a clone")


func test_engine_never_mutates_input() -> void:
	var lat := Lattice.from_ascii(_WIDE_ASCII)
	var before := lat.to_ascii()
	var walk: Array = []
	for x in range(lat.width):
		walk.append(Vector2i(x, 0))
	for y in range(1, lat.height):
		walk.append(Vector2i(lat.width - 1, y))
	var sig := _walked(lat, walk)
	var _r := RewriteEngine.apply(lat, sig, _make_rng())
	assert_eq(lat.to_ascii(), before)


func test_engine_preserves_solvability_on_forced_choice() -> void:
	# Single-column corridor: any wall placed on the path breaks it, so the
	# engine must reject those and either pick a safe rewrite or return
	# no-op. Either way, the result must be solvable.
	var lat := Lattice.from_ascii("S\n.\n.\n.\nG")
	var r := PathRecorder.new()
	r.record_step(Vector2i(0, 0))
	r.record_step(Vector2i(0, 1))
	r.record_step(Vector2i(0, 2))
	r.record_step(Vector2i(0, 3))
	r.record_step(Vector2i(0, 4))
	# Add a re-visit so the corridor mid-cell is a "hot cell".
	r.record_step(Vector2i(0, 3))
	r.record_step(Vector2i(0, 2))
	var sig := HabitSignature.extract(r, lat)
	var res := RewriteEngine.apply(lat, sig, _make_rng())
	# In a 1-wide corridor, no rewrite is safe, so engine returns no-op.
	assert_false(res.applied)
	assert_true(LatticeBFS.is_solvable(res.lattice))
	assert_true(res.lattice.equals(lat))


func test_engine_config_disables_operators() -> void:
	var lat := Lattice.from_ascii(_WIDE_ASCII)
	var sig := _walked(lat, _walk_across_top(lat))
	var cfg := RewriteEngine.Config.new()
	cfg.enabled_ops = PackedStringArray([])
	var res := RewriteEngine.apply(lat, sig, _make_rng(), cfg)
	assert_false(res.applied)
	assert_eq(res.reason, "no_enabled_candidates")


func test_repeated_apply_converges() -> void:
	var lat := Lattice.from_ascii(
		"S.....\n" +
		"......\n" +
		"......\n" +
		"......\n" +
		".....G"
	)
	var walk: Array = []
	for x in range(6):
		walk.append(Vector2i(x, 0))
	for y in range(1, 5):
		walk.append(Vector2i(5, y))
	var sig := _walked(lat, walk)
	var out := RewriteEngine.apply_repeated(lat, sig, _make_rng(), 6)
	assert_gt(int(out["applied"].size()), 0)
	assert_true(LatticeBFS.is_solvable(out["lattice"]))


func test_engine_result_summary_is_readable() -> void:
	var lat := Lattice.from_ascii(_WIDE_ASCII)
	var sig := _walked(lat, _walk_across_top(lat))
	var res := RewriteEngine.apply(lat, sig, _make_rng())
	var s := res.summary()
	assert_true(s.length() > 0)


func test_engine_deterministic_for_fixed_seed() -> void:
	var lat := Lattice.from_ascii(_WIDE_ASCII)
	var sig := _walked(lat, _walk_across_top(lat))
	var a := RewriteEngine.apply(lat, sig, _make_rng())
	var b := RewriteEngine.apply(lat, sig, _make_rng())
	assert_eq(a.applied, b.applied)
	if a.applied and b.applied:
		assert_true(a.lattice.equals(b.lattice))


func test_engine_requires_solvable_baseline_flag() -> void:
	# require_shorter_or_equal only accepts a rewrite that doesn't make the
	# maze strictly longer. Regardless of what the engine picks, the result
	# must be solvable.
	var lat := Lattice.from_ascii(_WIDE_ASCII)
	var sig := _walked(lat, _walk_across_top(lat))
	var cfg := RewriteEngine.Config.new()
	cfg.require_shorter_or_equal = true
	var res := RewriteEngine.apply(lat, sig, _make_rng(), cfg)
	assert_true(LatticeBFS.is_solvable(res.lattice))
