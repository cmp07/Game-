extends Node2D
##
## Chamber — one playable room of Echo Lattice.
##
## Owns the tile grid, the player position, the local move buffer since the
## last checkpoint, and applies rewrites when a checkpoint is entered.
##
## The scene has a self-drawn look: no external tile textures. Everything is
## drawn in _draw() using solid rects, so the whole vertical slice runs
## with only project.godot + icon.svg + scripts + scenes on disk.
##

signal chamber_won(chamber_id: int, moves: int)
signal moves_changed(moves: int)
signal caption_changed(text: String)

enum Tile {
	FLOOR,
	WALL,
	CHECKPOINT,
	CHECKPOINT_USED,
	GOAL,
	ECHO_WALL,
}

const CELL_SIZE: int = 32
const GRID_W: int = ChamberBook.GRID_W
const GRID_H: int = ChamberBook.GRID_H

# Palette — brutalist subway map: monochrome lattice + one accent.
const COLOR_BG: Color              = Color("#0c0c11")
const COLOR_FLOOR: Color           = Color("#181822")
const COLOR_FLOOR_ALT: Color       = Color("#1c1c27")
const COLOR_GRID: Color            = Color("#22222f")
const COLOR_WALL: Color            = Color("#3b3b52")
const COLOR_WALL_HI: Color         = Color("#4a4a67")
const COLOR_CHECKPOINT: Color      = Color("#ffd166")
const COLOR_CHECKPOINT_USED: Color = Color("#5a4a20")
const COLOR_GOAL: Color            = Color("#57f2b0")
const COLOR_GOAL_PULSE: Color      = Color("#a9ffdb")
const COLOR_ECHO: Color            = Color("#ff5c3d")
const COLOR_ECHO_SOFT: Color       = Color("#a53a26")
const COLOR_PLAYER: Color          = Color("#e8e8f1")
const COLOR_GHOST: Color           = Color(1.0, 0.36, 0.24, 0.35)
const COLOR_GHOST_LINE: Color      = Color(1.0, 0.36, 0.24, 0.55)

var grid: Array = []                 # 2D: grid[y][x] -> Tile
var player_pos: Vector2i = Vector2i.ZERO
var start_pos: Vector2i = Vector2i.ZERO
var goal_pos: Vector2i = Vector2i.ZERO

var move_count: int = 0
var moves_since_checkpoint: Array = []   # Array[Vector2i]  positions walked since last rewrite
var undo_stack: Array = []               # Array of dicts {pos, tile_at_prev, moves_pop}
var checkpoints_triggered: Dictionary = {}   # Vector2i -> true
var pending_echoes: Array = []           # Array[Vector2i] echoes still animating in
var pending_echo_timer: float = 0.0
var pending_echo_settle_time: float = 0.35

var chamber: Dictionary = {}
var transform_name: String = "none"

var goal_pulse_t: float = 0.0
var move_accum: float = 0.0
var has_won: bool = false


func _ready() -> void:
	set_process(true)
	set_process_input(true)
	load_chamber(GameState.current_chamber)


func _process(delta: float) -> void:
	goal_pulse_t = fmod(goal_pulse_t + delta, TAU)
	if pending_echoes.size() > 0:
		pending_echo_timer += delta
		if pending_echo_timer >= pending_echo_settle_time:
			# Commit all pending echoes to real ECHO_WALL cells.
			for p in pending_echoes:
				if _in_bounds(p) and grid[p.y][p.x] == Tile.FLOOR:
					grid[p.y][p.x] = Tile.ECHO_WALL
			pending_echoes.clear()
			pending_echo_timer = 0.0
			queue_redraw()
	queue_redraw()


func load_chamber(id: int) -> void:
	chamber = ChamberBook.get_chamber(id)
	if chamber.is_empty():
		return
	transform_name = str(chamber.get("transform", "none"))
	var rows: Array = chamber.get("map", [])
	grid.clear()
	for y in range(GRID_H):
		var row: Array = []
		var src: String = rows[y] if y < rows.size() else ""
		for x in range(GRID_W):
			var c: String = " "
			if x < src.length():
				c = src.substr(x, 1)
			match c:
				"#":
					row.append(Tile.WALL)
				"P":
					row.append(Tile.FLOOR)
					start_pos = Vector2i(x, y)
					player_pos = start_pos
				"G":
					row.append(Tile.GOAL)
					goal_pos = Vector2i(x, y)
				"C":
					row.append(Tile.CHECKPOINT)
				_:
					row.append(Tile.FLOOR)
		grid.append(row)
	move_count = 0
	moves_since_checkpoint.clear()
	undo_stack.clear()
	checkpoints_triggered.clear()
	pending_echoes.clear()
	pending_echo_timer = 0.0
	has_won = false
	emit_signal("moves_changed", move_count)
	emit_signal("caption_changed", str(chamber.get("caption", "")))
	queue_redraw()


func reset_chamber() -> void:
	if chamber.is_empty():
		return
	load_chamber(int(chamber.get("id", 0)))


func _input(event: InputEvent) -> void:
	if has_won:
		return
	if event.is_action_pressed("move_up"):
		_try_move(Vector2i(0, -1))
	elif event.is_action_pressed("move_down"):
		_try_move(Vector2i(0, 1))
	elif event.is_action_pressed("move_left"):
		_try_move(Vector2i(-1, 0))
	elif event.is_action_pressed("move_right"):
		_try_move(Vector2i(1, 0))
	elif event.is_action_pressed("restart"):
		reset_chamber()
	elif event.is_action_pressed("undo"):
		_undo()


func _try_move(dir: Vector2i) -> void:
	var target: Vector2i = player_pos + dir
	if not _in_bounds(target):
		return
	var t: int = grid[target.y][target.x]
	if t == Tile.WALL or t == Tile.ECHO_WALL:
		return
	# Persist an undo frame BEFORE any state change.
	undo_stack.push_back({
		"prev_pos": player_pos,
		"prev_tile_at_target": t,
		"moves_since_cp_len": moves_since_checkpoint.size(),
		"triggered_snapshot": checkpoints_triggered.duplicate(true),
		"grid_deltas": [],
	})
	player_pos = target
	move_count += 1
	moves_since_checkpoint.append(target)
	GameState.record_direction(dir)
	emit_signal("moves_changed", move_count)

	if t == Tile.CHECKPOINT and not checkpoints_triggered.get(target, false):
		checkpoints_triggered[target] = true
		grid[target.y][target.x] = Tile.CHECKPOINT_USED
		_trigger_rewrite()
	elif t == Tile.GOAL:
		_on_win()
	queue_redraw()


func _undo() -> void:
	if undo_stack.is_empty():
		return
	# Commit any pending echoes first so undo state is deterministic.
	_flush_pending_echoes()
	var frame: Dictionary = undo_stack.pop_back()
	# Revert player.
	player_pos = frame["prev_pos"]
	move_count = max(0, move_count - 1)
	# Trim moves since checkpoint back to previous size.
	while moves_since_checkpoint.size() > int(frame["moves_since_cp_len"]):
		moves_since_checkpoint.pop_back()
	# Restore triggered map — if a checkpoint just got used, un-use it and revert echoes.
	var new_triggered: Dictionary = frame["triggered_snapshot"]
	# Any checkpoint that IS triggered now but wasn't before: revert its cell and its echoes.
	for pos in checkpoints_triggered.keys():
		if not new_triggered.has(pos):
			# Un-trigger — put the CHECKPOINT tile back.
			if _in_bounds(pos):
				grid[pos.y][pos.x] = Tile.CHECKPOINT
			# Clear ECHO_WALL tiles back to FLOOR (best-effort revert).
			_clear_all_echoes()
	checkpoints_triggered = new_triggered
	emit_signal("moves_changed", move_count)
	queue_redraw()


func _flush_pending_echoes() -> void:
	for p in pending_echoes:
		if _in_bounds(p) and grid[p.y][p.x] == Tile.FLOOR:
			grid[p.y][p.x] = Tile.ECHO_WALL
	pending_echoes.clear()
	pending_echo_timer = 0.0


func _clear_all_echoes() -> void:
	for y in range(GRID_H):
		for x in range(GRID_W):
			if grid[y][x] == Tile.ECHO_WALL:
				grid[y][x] = Tile.FLOOR


func _trigger_rewrite() -> void:
	# The rewrite is a deterministic transform of the path walked since last checkpoint.
	# We compute the transformed cells and mark them as pending echoes so the visual
	# has a moment to communicate causation.
	var path: Array = moves_since_checkpoint.duplicate()
	if path.is_empty():
		path.append(player_pos)
	var transformed: Array = _apply_transform(transform_name, path)
	# Deduplicate + filter to placeable candidates.
	var seen := {}
	var candidates: Array = []
	for p in transformed:
		if not _in_bounds(p):
			continue
		if p == player_pos or p == goal_pos:
			continue
		if seen.has(p):
			continue
		var cell: int = grid[p.y][p.x]
		if cell != Tile.FLOOR:
			continue
		seen[p] = true
		candidates.append(p)
	# Solvability safety net — never seal the goal off from the player.
	# Add candidates one by one; skip any that would break player→goal connectivity.
	pending_echoes.clear()
	for p in candidates:
		if _would_still_be_reachable(p):
			pending_echoes.append(p)
	pending_echo_timer = 0.0
	moves_since_checkpoint.clear()


func _would_still_be_reachable(new_wall: Vector2i) -> bool:
	# Treat WALL / ECHO_WALL / the proposed new_wall / any already-pending echo as blocked.
	# Player must remain able to reach the goal.
	var w: int = GRID_W
	var h: int = GRID_H
	var blocked := {}
	blocked[new_wall] = true
	for p in pending_echoes:
		blocked[p] = true
	var q: Array = [player_pos]
	var seen := {}
	seen[player_pos] = true
	while q.size() > 0:
		var cur: Vector2i = q.pop_front()
		if cur == goal_pos:
			return true
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = cur + d
			if n.x < 0 or n.x >= w or n.y < 0 or n.y >= h:
				continue
			if seen.has(n):
				continue
			if blocked.has(n):
				continue
			var cell: int = grid[n.y][n.x]
			if cell == Tile.WALL or cell == Tile.ECHO_WALL:
				continue
			seen[n] = true
			q.append(n)
	return false


func _apply_transform(name: String, path: Array) -> Array:
	var out: Array = []
	match name:
		"none":
			pass
		"mirror_v":
			for p in path:
				out.append(Vector2i(GRID_W - 1 - int(p.x), int(p.y)))
		"mirror_h":
			for p in path:
				out.append(Vector2i(int(p.x), GRID_H - 1 - int(p.y)))
		"rotate_180":
			for p in path:
				out.append(Vector2i(GRID_W - 1 - int(p.x), GRID_H - 1 - int(p.y)))
		"thicken":
			# Habit solidifies on the same cells you just walked, minus the player's current tile.
			for p in path:
				out.append(Vector2i(int(p.x), int(p.y)))
		"mirror_v_then_h":
			for p in path:
				out.append(Vector2i(GRID_W - 1 - int(p.x), int(p.y)))
				out.append(Vector2i(int(p.x), GRID_H - 1 - int(p.y)))
		_:
			pass
	return out


func _on_win() -> void:
	if has_won:
		return
	has_won = true
	GameState.record_chamber_win(int(chamber.get("id", 0)), move_count)
	# Small delay so the goal tile animation reads before the transition.
	var t := get_tree().create_timer(0.35)
	t.timeout.connect(func():
		emit_signal("chamber_won", int(chamber.get("id", 0)), move_count)
	)


func _in_bounds(p: Vector2i) -> bool:
	return p.x >= 0 and p.x < GRID_W and p.y >= 0 and p.y < GRID_H


# ---------------- rendering ----------------

func _draw() -> void:
	var vp_size: Vector2 = get_viewport_rect().size
	var grid_px: Vector2 = Vector2(GRID_W * CELL_SIZE, GRID_H * CELL_SIZE)
	var offset: Vector2 = ((vp_size - grid_px) * 0.5).floor()

	# Background wash
	draw_rect(Rect2(Vector2.ZERO, vp_size), COLOR_BG, true)

	# Tiles
	for y in range(GRID_H):
		for x in range(GRID_W):
			var t: int = grid[y][x]
			var rect := Rect2(offset + Vector2(x * CELL_SIZE, y * CELL_SIZE), Vector2(CELL_SIZE, CELL_SIZE))
			var col: Color
			match t:
				Tile.FLOOR:
					col = COLOR_FLOOR if (x + y) % 2 == 0 else COLOR_FLOOR_ALT
				Tile.WALL:
					col = COLOR_WALL
				Tile.CHECKPOINT:
					col = COLOR_FLOOR
				Tile.CHECKPOINT_USED:
					col = COLOR_FLOOR
				Tile.GOAL:
					col = COLOR_FLOOR
				Tile.ECHO_WALL:
					col = COLOR_ECHO
				_:
					col = COLOR_FLOOR
			draw_rect(rect, col, true)
			# Fine grid line
			draw_rect(rect, COLOR_GRID, false, 1.0)

			# Decorations over floor.
			match t:
				Tile.WALL:
					var inner := rect.grow(-2.0)
					draw_rect(inner, COLOR_WALL_HI, false, 1.0)
				Tile.CHECKPOINT:
					var r := 6.0 + sin(goal_pulse_t * 3.0) * 1.5
					draw_circle(rect.get_center(), r, COLOR_CHECKPOINT)
					draw_arc(rect.get_center(), r + 3.0, 0.0, TAU, 24, COLOR_CHECKPOINT, 1.0, true)
				Tile.CHECKPOINT_USED:
					draw_circle(rect.get_center(), 3.0, COLOR_CHECKPOINT_USED)
				Tile.GOAL:
					var pulse: float = 0.5 + 0.5 * sin(goal_pulse_t * 2.5)
					var gcol: Color = COLOR_GOAL.lerp(COLOR_GOAL_PULSE, pulse)
					draw_rect(rect.grow(-4.0), gcol, true)
					draw_rect(rect.grow(-8.0), COLOR_FLOOR, true)
					draw_rect(rect.grow(-11.0), gcol, true)
				Tile.ECHO_WALL:
					var inner2 := rect.grow(-3.0)
					draw_rect(inner2, COLOR_ECHO_SOFT, true)

	# Ghost trail — the path walked since last checkpoint.
	for i in range(moves_since_checkpoint.size()):
		var p: Vector2i = moves_since_checkpoint[i]
		var r := Rect2(offset + Vector2(p.x * CELL_SIZE + 12, p.y * CELL_SIZE + 12), Vector2(CELL_SIZE - 24, CELL_SIZE - 24))
		draw_rect(r, COLOR_GHOST, true)
	# Ghost trail lines (connecting)
	if moves_since_checkpoint.size() >= 2:
		var pts: PackedVector2Array = PackedVector2Array()
		for p in moves_since_checkpoint:
			pts.append(offset + Vector2(p.x * CELL_SIZE + CELL_SIZE * 0.5, p.y * CELL_SIZE + CELL_SIZE * 0.5))
		for i in range(pts.size() - 1):
			draw_line(pts[i], pts[i + 1], COLOR_GHOST_LINE, 2.0, true)

	# Pending echoes (animate in).
	if pending_echoes.size() > 0:
		var t_norm: float = clamp(pending_echo_timer / pending_echo_settle_time, 0.0, 1.0)
		var pulse: float = 0.35 + 0.65 * (1.0 - abs(sin(t_norm * PI * 2.0)))
		for p in pending_echoes:
			var r := Rect2(offset + Vector2(p.x * CELL_SIZE, p.y * CELL_SIZE), Vector2(CELL_SIZE, CELL_SIZE))
			var c: Color = COLOR_ECHO
			c.a = pulse
			draw_rect(r.grow(-2.0), c, true)

	# Player
	var pr := Rect2(offset + Vector2(player_pos.x * CELL_SIZE + 6, player_pos.y * CELL_SIZE + 6), Vector2(CELL_SIZE - 12, CELL_SIZE - 12))
	draw_rect(pr, COLOR_PLAYER, true)
	# Player outline for punch
	draw_rect(pr.grow(1.0), Color(0, 0, 0, 0.5), false, 1.0)
