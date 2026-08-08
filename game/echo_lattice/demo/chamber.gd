extends Node2D

## Echo Lattice demo chamber.
##
## Renders a small maze from ASCII, lets you steer a token with WASD/arrows,
## records the walk into a PathRecorder, and applies a habit-driven rewrite
## when you press SPACE (or arrive at the goal). The chamber visibly changes
## between segments while remaining guaranteed-solvable.
##
## Everything on-screen is procedurally drawn (no asset dependencies) so the
## module works in a fresh clone without importing anything.

const Lattice := preload("res://echo_lattice/lattice.gd")
const PathRecorder := preload("res://echo_lattice/path_recorder.gd")
const HabitSignature := preload("res://echo_lattice/habit_signature.gd")
const RewriteEngine := preload("res://echo_lattice/rewrite_engine.gd")
const LatticeBFS := preload("res://echo_lattice/bfs.gd")

const CELL_PX := 48
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

const COLOR_BG := Color(0.08, 0.09, 0.12)
const COLOR_FLOOR := Color(0.16, 0.17, 0.22)
const COLOR_WALL := Color(0.32, 0.34, 0.42)
const COLOR_START := Color(0.28, 0.62, 0.36)
const COLOR_GOAL := Color(0.86, 0.62, 0.20)
const COLOR_FOSSIL := Color(0.55, 0.32, 0.72)
const COLOR_SOFT := Color(0.24, 0.30, 0.38)
const COLOR_PATH := Color(0.42, 0.78, 0.98, 0.35)
const COLOR_PLAYER := Color(0.98, 0.94, 0.86)
const COLOR_LAST_REWRITE := Color(0.98, 0.35, 0.45, 0.85)

var lattice: Lattice
var recorder: PathRecorder
var player_pos: Vector2i
var rng := RandomNumberGenerator.new()
var last_rewrite_cells: Array[Vector2i] = []
var applied_rewrites: Array = []
var status_line := ""
var _hud: Label


func _ready() -> void:
	rng.seed = 20260808
	_hud = Label.new()
	_hud.position = Vector2(12, 12)
	_hud.z_index = 10
	_hud.add_theme_color_override("font_color", Color(0.95, 0.96, 0.98))
	_hud.add_theme_font_size_override("font_size", 16)
	add_child(_hud)
	_reset_chamber(CHAMBER_ASCII)
	set_process_input(true)


func _reset_chamber(ascii: String) -> void:
	lattice = Lattice.from_ascii(ascii)
	assert(LatticeBFS.is_solvable(lattice), "Authored chamber must be solvable")
	recorder = PathRecorder.new()
	player_pos = lattice.start
	recorder.record_step(player_pos)
	last_rewrite_cells.clear()
	applied_rewrites.clear()
	status_line = "Segment 1 — walk to the goal, then press SPACE to rewrite."
	queue_redraw()
	_update_hud()


func _input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if event.is_action_pressed("echo_lattice_reset"):
		_reset_chamber(CHAMBER_ASCII)
		return
	if event.is_action_pressed("echo_lattice_apply_rewrite"):
		_apply_rewrite()
		return
	var dir := Vector2i.ZERO
	if event.is_action_pressed("echo_lattice_up"):
		dir = Lattice.DIR_UP
	elif event.is_action_pressed("echo_lattice_down"):
		dir = Lattice.DIR_DOWN
	elif event.is_action_pressed("echo_lattice_left"):
		dir = Lattice.DIR_LEFT
	elif event.is_action_pressed("echo_lattice_right"):
		dir = Lattice.DIR_RIGHT
	if dir == Vector2i.ZERO:
		return
	_try_move(dir)


func _try_move(dir: Vector2i) -> void:
	var target := player_pos + dir
	if not lattice.is_passable(target):
		return
	player_pos = target
	recorder.record_step(player_pos)
	if player_pos == lattice.goal:
		status_line = "Goal reached — pressing SPACE will fossilize your habit."
	queue_redraw()
	_update_hud()


func _apply_rewrite() -> void:
	if recorder.step_count() < 2:
		status_line = "Walk at least a few steps first."
		_update_hud()
		return
	var sig := HabitSignature.extract(recorder, lattice)
	var result := RewriteEngine.apply(lattice, sig, rng)
	if not result.applied:
		status_line = "No rewrite applied (%s)." % result.reason
		_update_hud()
		return
	last_rewrite_cells.clear()
	for p in result.rewrite["patches"]:
		last_rewrite_cells.append(p["pos"])
	applied_rewrites.append(result.rewrite)
	lattice = result.lattice
	recorder = PathRecorder.new()
	player_pos = lattice.start
	recorder.record_step(player_pos)
	status_line = "Segment %d — applied '%s' (score %.2f)." % [
		applied_rewrites.size() + 1,
		String(result.rewrite["name"]),
		float(result.rewrite["score"]),
	]
	queue_redraw()
	_update_hud()


func _update_hud() -> void:
	var sig := HabitSignature.extract(recorder, lattice)
	var lines := [
		status_line,
		"",
		"WASD / arrows to move.  SPACE apply rewrite.  R reset chamber.",
		"Segment %d   Steps %d   Uniques %d" % [
			applied_rewrites.size() + 1, recorder.step_count(), sig.unique_cell_count,
		],
		sig.summary(),
	]
	if applied_rewrites.size() > 0:
		lines.append("")
		lines.append("Applied rewrites:")
		var start_idx: int = max(0, applied_rewrites.size() - 4)
		for i in range(start_idx, applied_rewrites.size()):
			var rw: Dictionary = applied_rewrites[i]
			lines.append("  %d. %s @ %s" % [
				i + 1, String(rw["name"]), _first_patch_pos(rw),
			])
	_hud.text = "\n".join(lines)


func _first_patch_pos(rw: Dictionary) -> Vector2i:
	var patches: Array = rw.get("patches", [])
	if patches.is_empty():
		return Vector2i(-1, -1)
	return patches[0]["pos"]


# -----------------------------------------------------------------------------
# Drawing
# -----------------------------------------------------------------------------

func _draw() -> void:
	if lattice == null:
		return
	var origin := Vector2(24, 96)
	var size := Vector2(lattice.width * CELL_PX, lattice.height * CELL_PX)
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), COLOR_BG, true)
	draw_rect(Rect2(origin - Vector2(4, 4), size + Vector2(8, 8)), COLOR_WALL, false, 2.0)
	for y in range(lattice.height):
		for x in range(lattice.width):
			var pos := Vector2i(x, y)
			var cell := lattice.get_cell(pos)
			var rect := Rect2(origin + Vector2(x * CELL_PX, y * CELL_PX), Vector2(CELL_PX - 2, CELL_PX - 2))
			var color := COLOR_FLOOR
			match cell:
				Lattice.Cell.FLOOR:
					color = COLOR_FLOOR
				Lattice.Cell.WALL:
					color = COLOR_WALL
				Lattice.Cell.START:
					color = COLOR_START
				Lattice.Cell.GOAL:
					color = COLOR_GOAL
				Lattice.Cell.FOSSIL:
					color = COLOR_FOSSIL
				Lattice.Cell.SOFT:
					color = COLOR_SOFT
			draw_rect(rect, color, true)
	# Draw a translucent trace of the current recording so the habit is legible.
	var positions := recorder.positions()
	for p in positions:
		var rect := Rect2(origin + Vector2(p.x * CELL_PX + 6, p.y * CELL_PX + 6), Vector2(CELL_PX - 14, CELL_PX - 14))
		draw_rect(rect, COLOR_PATH, true)
	# Emphasize last rewrite cells with a red outline.
	for p in last_rewrite_cells:
		var rect := Rect2(origin + Vector2(p.x * CELL_PX, p.y * CELL_PX), Vector2(CELL_PX - 2, CELL_PX - 2))
		draw_rect(rect, COLOR_LAST_REWRITE, false, 3.0)
	# Player.
	var player_rect := Rect2(
		origin + Vector2(player_pos.x * CELL_PX + 8, player_pos.y * CELL_PX + 8),
		Vector2(CELL_PX - 18, CELL_PX - 18)
	)
	draw_rect(player_rect, COLOR_PLAYER, true)
