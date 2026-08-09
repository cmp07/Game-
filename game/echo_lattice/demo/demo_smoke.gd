extends SceneTree

## Headless demo smoke script.
##
## Loads the same chamber ASCII that the demo scene uses, walks a synthetic
## habit path, applies the rewrite engine, and prints a before/after diff.
## Fails (exits 1) if:
##   * the chamber is not solvable to begin with, or
##   * the rewrite engine returns an unsolvable lattice, or
##   * the lattice is byte-identical before and after (no visible change).
##
## Invoke with:
##   godot --headless --path game --script res://echo_lattice/demo/demo_smoke.gd

const Lattice := preload("res://echo_lattice/lattice.gd")
const PathRecorder := preload("res://echo_lattice/path_recorder.gd")
const HabitSignature := preload("res://echo_lattice/habit_signature.gd")
const RewriteEngine := preload("res://echo_lattice/rewrite_engine.gd")
const LatticeBFS := preload("res://echo_lattice/bfs.gd")

const CHAMBER_ASCII := (
	"###############\n" +
	"#S............#\n" +
	"#.###.#####.#.#\n" +
	"#...#.......#.#\n" +
	"#.#.#.#####.#.#\n" +
	"#.#...#...#...#\n" +
	"#.#####.#.###.#\n" +
	"#.......#.....#\n" +
	"#.#####.#####.#\n" +
	"#.........#..G#\n" +
	"###############"
)


func _init() -> void:
	print("=== Echo Lattice demo smoke ===")
	var lat := Lattice.from_ascii(CHAMBER_ASCII)
	if not LatticeBFS.is_solvable(lat):
		printerr("Chamber is not solvable")
		quit(1)
		return
	# Synthetic "habit": walk the BFS shortest path from start to goal, but at
	# the midpoint, ping-pong 4x to build a hot cell before continuing.
	var recorder := PathRecorder.new()
	var path := LatticeBFS.shortest_path(lat, lat.start, lat.goal)
	var mid_index: int = path.size() / 2
	for i in range(mid_index + 1):
		recorder.record_step(path[i])
	var mid: Vector2i = path[mid_index]
	# First adjacent cell in the path (from mid) that isn't the next step.
	var pingpong_neighbor: Vector2i = mid
	for cand in lat.passable_neighbors(mid):
		if mid_index + 1 < path.size() and cand == path[mid_index + 1]:
			continue
		pingpong_neighbor = cand
		break
	if pingpong_neighbor != mid:
		for _i in range(3):
			recorder.record_step(pingpong_neighbor)
			recorder.record_step(mid)
	for i in range(mid_index + 1, path.size()):
		recorder.record_step(path[i])

	var sig := HabitSignature.extract(recorder, lat)
	print("Signature: %s" % sig.summary())
	print("")
	print("Before:")
	print(lat.to_ascii())

	var rng := RandomNumberGenerator.new()
	rng.seed = 20260808
	var result := RewriteEngine.apply(
			lat, sig, recorder.positions(), lat.start, rng)
	print("")
	print(result.summary())
	print("Greed index: %.2f" % sig.greed_index)
	if not result.applied:
		printerr("Expected a rewrite to be applied for this habit")
		quit(1)
		return
	if not LatticeBFS.is_solvable(result.lattice):
		printerr("Engine returned an unsolvable lattice")
		quit(1)
		return
	if result.lattice.equals(lat):
		printerr("Engine returned an unchanged lattice — chamber must visibly change")
		quit(1)
		return
	print("")
	print("After:")
	print(result.lattice.to_ascii())

	# Path length before/after.
	var new_path := LatticeBFS.shortest_path(result.lattice, result.lattice.start, result.lattice.goal)
	print("")
	print("BFS length before: %d, after: %d" % [path.size(), new_path.size()])
	print("Rewrite type: %s  hardness=%s" % [
		String(result.rewrite["name"]),
		String(result.rewrite.get("hardness", "?")),
	])
	if not result.combo.is_empty():
		print("Combo: %s" % String(result.combo["name"]))
	if result.near_miss:
		print("Near-miss at %s" % result.near_miss_cell)
	print("Safety: %s" % result.safety)
	quit(0)
