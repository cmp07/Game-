extends Node2D
##
## Chamber — one playable room of Echo Lattice v2.
## Field-ledger palette (art bible), rewrite telegraph, juice punch, audio hooks.
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

# Field Ledger palette — docs/ECHO_LATTICE/05_ART_BIBLE.md
const COLOR_BG: Color              = Color("#141210")
const COLOR_FLOOR: Color           = Color("#EFE6D2")
const COLOR_FLOOR_ALT: Color       = Color("#E6DCC4")
const COLOR_FLOOR_WALKED: Color    = Color("#D9CDB0")
const COLOR_GRID: Color            = Color("#3A342C")
const COLOR_WALL: Color            = Color("#141210")
const COLOR_WALL_HI: Color         = Color("#3A342C")
const COLOR_CHECKPOINT: Color      = Color("#B8763A")
const COLOR_CHECKPOINT_USED: Color = Color("#5E2412")
const COLOR_GOAL: Color            = Color("#2D4A55")
const COLOR_GOAL_PULSE: Color      = Color("#4A6D77")
const COLOR_ECHO: Color            = Color("#8B3A1F")
const COLOR_ECHO_SOFT: Color       = Color("#5E2412")
const COLOR_PLAYER: Color          = Color("#F5EFDD")
const COLOR_GHOST: Color           = Color(0.96, 0.94, 0.87, 0.45)
const COLOR_GHOST_LINE: Color      = Color(0.45, 0.58, 0.62, 0.7)
const COLOR_TELEGRAPH: Color       = Color(0.84, 0.26, 0.17, 0.0)
const COLOR_FLASH_REWRITE: Color   = Color("#D6432B")

var grid: Array = []
var player_pos: Vector2i = Vector2i.ZERO
var start_pos: Vector2i = Vector2i.ZERO
var goal_pos: Vector2i = Vector2i.ZERO
var walked: Dictionary = {}  # Vector2i -> true

var move_count: int = 0
var moves_since_checkpoint: Array = []
var undo_stack: Array = []
var checkpoints_triggered: Dictionary = {}
var pending_echoes: Array = []
var pending_echo_timer: float = 0.0
var pending_echo_settle_time: float = 0.42
var telegraph_cells: Array = []
var rewrite_warn_armed: bool = false

var chamber: Dictionary = {}
var transform_name: String = "none"

var goal_pulse_t: float = 0.0
var has_won: bool = false
var draw_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	set_process(true)
	set_process_input(true)
	load_chamber(GameState.current_chamber)


func _process(delta: float) -> void:
	goal_pulse_t = fmod(goal_pulse_t + delta, TAU)
	if pending_echoes.size() > 0:
		pending_echo_timer += delta
		if pending_echo_timer >= pending_echo_settle_time:
			for p in pending_echoes:
				if _in_bounds(p) and grid[p.y][p.x] == Tile.FLOOR:
					grid[p.y][p.x] = Tile.ECHO_WALL
			pending_echoes.clear()
			pending_echo_timer = 0.0
			queue_redraw()
	_refresh_telegraph()
	queue_redraw()


func load_chamber(id: int) -> void:
	chamber = ChamberBook.get_chamber(id)
	if chamber.is_empty():
		return
	transform_name = str(chamber.get("transform", "none"))
	var rows: Array = chamber.get("map", [])
	grid.clear()
	walked.clear()
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
	telegraph_cells.clear()
	rewrite_warn_armed = false
	has_won = false
	walked[player_pos] = true
	emit_signal("moves_changed", move_count)
	emit_signal("caption_changed", str(chamber.get("caption", "")))
	if has_node("/root/AudioDirector"):
		AudioDirector.set_chamber(id)
		AudioDirector.on_pa_line("pa.ghost.floor")
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
		if has_node("/root/AudioDirector"):
			AudioDirector.on_footstep(true)
		if has_node("/root/Juice"):
			Juice.bump(0.08)
		return
	undo_stack.push_back({
		"prev_pos": player_pos,
		"prev_tile_at_target": t,
		"moves_since_cp_len": moves_since_checkpoint.size(),
		"triggered_snapshot": checkpoints_triggered.duplicate(true),
		"walked_had_target": walked.has(target),
	})
	player_pos = target
	move_count += 1
	moves_since_checkpoint.append(target)
	walked[target] = true
	GameState.record_direction(dir)
	emit_signal("moves_changed", move_count)
	if has_node("/root/AudioDirector"):
		AudioDirector.on_footstep(false)
		_update_habit_audio()

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
	_flush_pending_echoes()
	var frame: Dictionary = undo_stack.pop_back()
	var old_pos: Vector2i = player_pos
	player_pos = frame["prev_pos"]
	move_count = max(0, move_count - 1)
	while moves_since_checkpoint.size() > int(frame["moves_since_cp_len"]):
		moves_since_checkpoint.pop_back()
	if not bool(frame.get("walked_had_target", true)):
		walked.erase(old_pos)
	var new_triggered: Dictionary = frame["triggered_snapshot"]
	for pos in checkpoints_triggered.keys():
		if not new_triggered.has(pos):
			if _in_bounds(pos):
				grid[pos.y][pos.x] = Tile.CHECKPOINT
			_clear_all_echoes()
	checkpoints_triggered = new_triggered
	rewrite_warn_armed = false
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
	var path: Array = moves_since_checkpoint.duplicate()
	if path.is_empty():
		path.append(player_pos)
	var transformed: Array = _apply_transform(transform_name, path)
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
	pending_echoes.clear()
	for p in candidates:
		if _would_still_be_reachable(p):
			pending_echoes.append(p)
	pending_echo_timer = 0.0
	moves_since_checkpoint.clear()
	telegraph_cells.clear()
	rewrite_warn_armed = false

	# Juice + audio punch
	if has_node("/root/Juice"):
		Juice.rewrite_punch(pending_echoes.size())
		var offset := _grid_draw_offset()
		for p in pending_echoes:
			var wp: Vector2 = offset + Vector2(p.x * CELL_SIZE + CELL_SIZE * 0.5, p.y * CELL_SIZE + CELL_SIZE * 0.5)
			Juice.spawn_burst(wp, COLOR_ECHO, 6)
	if has_node("/root/AudioDirector"):
		AudioDirector.on_rewrite(transform_name)
		AudioDirector.on_pa_line("pa.checkpoint.armed")


func _would_still_be_reachable(new_wall: Vector2i) -> bool:
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
			for p in path:
				out.append(Vector2i(int(p.x), int(p.y)))
		"mirror_v_then_h":
			for p in path:
				out.append(Vector2i(GRID_W - 1 - int(p.x), int(p.y)))
				out.append(Vector2i(int(p.x), GRID_H - 1 - int(p.y)))
		"invert":
			# Negative-space halo: floors adjacent to the habit become echo walls.
			var on_path := {}
			for p in path:
				on_path[Vector2i(int(p.x), int(p.y))] = true
			for p in path:
				for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var n: Vector2i = Vector2i(int(p.x), int(p.y)) + d
					if on_path.has(n):
						continue
					out.append(n)
		_:
			pass
	return out


func _refresh_telegraph() -> void:
	telegraph_cells.clear()
	if transform_name == "none" or has_won:
		return
	if moves_since_checkpoint.is_empty():
		return
	# Preview where the next rewrite would land.
	var transformed: Array = _apply_transform(transform_name, moves_since_checkpoint)
	var seen := {}
	for p in transformed:
		if not _in_bounds(p):
			continue
		if p == player_pos or p == goal_pos:
			continue
		if seen.has(p):
			continue
		if grid[p.y][p.x] != Tile.FLOOR:
			continue
		seen[p] = true
		telegraph_cells.append(p)
	# Warn when near an unused checkpoint.
	var near_cp := _nearest_unused_checkpoint_dist()
	if near_cp >= 0 and near_cp <= 3 and telegraph_cells.size() > 0:
		if not rewrite_warn_armed and has_node("/root/AudioDirector"):
			AudioDirector.on_rewrite_warn()
			rewrite_warn_armed = true
		if has_node("/root/AudioDirector"):
			AudioDirector.set_rewrite_tension(1.0 - float(near_cp) / 3.0)
	else:
		rewrite_warn_armed = false
		if has_node("/root/AudioDirector"):
			AudioDirector.set_rewrite_tension(0.0)


func _nearest_unused_checkpoint_dist() -> int:
	var best: int = -1
	for y in range(GRID_H):
		for x in range(GRID_W):
			if grid[y][x] != Tile.CHECKPOINT:
				continue
			var d: int = abs(x - player_pos.x) + abs(y - player_pos.y)
			if best < 0 or d < best:
				best = d
	return best


func _update_habit_audio() -> void:
	if not has_node("/root/AudioDirector"):
		return
	var hp: Dictionary = GameState.habit_profile
	var total: float = float(
		int(hp.get("up", 0)) + int(hp.get("down", 0)) + int(hp.get("left", 0)) + int(hp.get("right", 0))
	)
	var dom: String = GameState.dominant_habit()
	var bias: float = 0.0 if total <= 0.0 else float(int(hp.get(dom, 0))) / total
	var fossil: float = 0.0
	var cells: float = float(GRID_W * GRID_H)
	var echoes: float = 0.0
	for y in range(GRID_H):
		for x in range(GRID_W):
			if grid[y][x] == Tile.ECHO_WALL:
				echoes += 1.0
	fossil = echoes / cells
	var prox: float = 0.0
	var nd: int = _nearest_unused_checkpoint_dist()
	if nd >= 0:
		prox = clampf(1.0 - float(nd) / 8.0, 0.0, 1.0)
	AudioDirector.update_habit_audio(bias, bias, fossil, float(checkpoints_triggered.size()) * 0.25, prox)


func _on_win() -> void:
	if has_won:
		return
	has_won = true
	var cid: int = int(chamber.get("id", 0))
	var bfs_par: int = _bfs_length(start_pos, goal_pos)
	GameState.record_chamber_win(cid, move_count, bfs_par)
	if has_node("/root/Juice"):
		Juice.bump(0.25)
		Juice.flash(0.35, 0.4, COLOR_GOAL_PULSE)
	if has_node("/root/AudioDirector"):
		AudioDirector.on_chamber_won(true)
	var t := get_tree().create_timer(0.4)
	t.timeout.connect(func():
		emit_signal("chamber_won", cid, move_count)
	)


func _bfs_length(from: Vector2i, to: Vector2i) -> int:
	# Base-layout distance ignoring echo walls (par for stars).
	var rows: Array = chamber.get("map", [])
	var start := from
	var goal := to
	var seen := {}
	var dist := {}
	var q: Array = [start]
	seen[start] = true
	dist[start] = 0
	while q.size() > 0:
		var cur: Vector2i = q.pop_front()
		if cur == goal:
			return int(dist[cur])
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = cur + d
			if not _in_bounds(n) or seen.has(n):
				continue
			var row_s: String = rows[n.y] if n.y < rows.size() else ""
			if n.x >= row_s.length():
				continue
			if row_s.substr(n.x, 1) == "#":
				continue
			seen[n] = true
			dist[n] = int(dist[cur]) + 1
			q.append(n)
	return maxi(1, move_count)


func _in_bounds(p: Vector2i) -> bool:
	return p.x >= 0 and p.x < GRID_W and p.y >= 0 and p.y < GRID_H


func _grid_draw_offset() -> Vector2:
	var vp_size: Vector2 = get_viewport_rect().size
	var grid_px: Vector2 = Vector2(GRID_W * CELL_SIZE, GRID_H * CELL_SIZE)
	return ((vp_size - grid_px) * 0.5).floor()


func _draw() -> void:
	var vp_size: Vector2 = get_viewport_rect().size
	var offset: Vector2 = _grid_draw_offset()
	if has_node("/root/Juice"):
		var sh: Dictionary = Juice.shake_offset(8.0, 1.5)
		offset += Vector2(float(sh.get("dx", 0.0)), float(sh.get("dy", 0.0)))
	draw_offset = offset

	draw_rect(Rect2(Vector2.ZERO, vp_size), COLOR_BG, true)

	for y in range(GRID_H):
		for x in range(GRID_W):
			var t: int = grid[y][x]
			var rect := Rect2(offset + Vector2(x * CELL_SIZE, y * CELL_SIZE), Vector2(CELL_SIZE, CELL_SIZE))
			var col: Color
			match t:
				Tile.FLOOR:
					if walked.has(Vector2i(x, y)):
						col = COLOR_FLOOR_WALKED
					else:
						col = COLOR_FLOOR if (x + y) % 2 == 0 else COLOR_FLOOR_ALT
				Tile.WALL:
					col = COLOR_WALL
				Tile.CHECKPOINT, Tile.CHECKPOINT_USED, Tile.GOAL:
					col = COLOR_FLOOR if (x + y) % 2 == 0 else COLOR_FLOOR_ALT
				Tile.ECHO_WALL:
					col = COLOR_ECHO
				_:
					col = COLOR_FLOOR
			draw_rect(rect, col, true)
			draw_rect(rect, Color(COLOR_GRID, 0.35), false, 1.0)

			match t:
				Tile.WALL:
					var inner := rect.grow(-3.0)
					draw_rect(inner, COLOR_WALL_HI, false, 1.0)
				Tile.CHECKPOINT:
					var r := 6.0 + sin(goal_pulse_t * 3.0) * 1.5
					draw_circle(rect.get_center(), r, COLOR_CHECKPOINT)
					draw_arc(rect.get_center(), r + 3.0, 0.0, TAU, 24, COLOR_CHECKPOINT, 1.5, true)
				Tile.CHECKPOINT_USED:
					draw_circle(rect.get_center(), 3.0, COLOR_CHECKPOINT_USED)
				Tile.GOAL:
					var pulse: float = 0.5 + 0.5 * sin(goal_pulse_t * 2.5)
					var gcol: Color = COLOR_GOAL.lerp(COLOR_GOAL_PULSE, pulse)
					draw_rect(rect.grow(-4.0), gcol, true)
					draw_rect(rect.grow(-8.0), COLOR_FLOOR, true)
					draw_rect(rect.grow(-11.0), gcol, true)
				Tile.ECHO_WALL:
					draw_rect(rect.grow(-3.0), COLOR_ECHO_SOFT, true)
					draw_rect(rect.grow(-6.0), Color(COLOR_FLOOR, 0.15), false, 1.0)

	# Ghost trail
	for i in range(moves_since_checkpoint.size()):
		var p: Vector2i = moves_since_checkpoint[i]
		var r := Rect2(offset + Vector2(p.x * CELL_SIZE + 12, p.y * CELL_SIZE + 12), Vector2(CELL_SIZE - 24, CELL_SIZE - 24))
		draw_rect(r, COLOR_GHOST, true)
	if moves_since_checkpoint.size() >= 2:
		var pts: PackedVector2Array = PackedVector2Array()
		for p in moves_since_checkpoint:
			pts.append(offset + Vector2(p.x * CELL_SIZE + CELL_SIZE * 0.5, p.y * CELL_SIZE + CELL_SIZE * 0.5))
		for i in range(pts.size() - 1):
			draw_line(pts[i], pts[i + 1], COLOR_GHOST_LINE, 2.0, true)

	# Telegraph foreshadow — dashed cadmium cells where the rewrite will land.
	if telegraph_cells.size() > 0 and pending_echoes.is_empty():
		var pulse: float = 0.25 + 0.35 * (0.5 + 0.5 * sin(goal_pulse_t * 5.0))
		var near: int = _nearest_unused_checkpoint_dist()
		if near >= 0 and near <= 4:
			pulse = 0.4 + 0.5 * (0.5 + 0.5 * sin(goal_pulse_t * 8.0))
		for p in telegraph_cells:
			var r := Rect2(offset + Vector2(p.x * CELL_SIZE + 4, p.y * CELL_SIZE + 4), Vector2(CELL_SIZE - 8, CELL_SIZE - 8))
			var c := COLOR_FLASH_REWRITE
			c.a = pulse
			draw_rect(r, c, false, 2.0)
			# Corner ticks
			var tl: Vector2 = r.position
			var br: Vector2 = r.position + r.size
			draw_line(tl, tl + Vector2(6, 0), c, 2.0)
			draw_line(tl, tl + Vector2(0, 6), c, 2.0)
			draw_line(br, br - Vector2(6, 0), c, 2.0)
			draw_line(br, br - Vector2(0, 6), c, 2.0)

	# Pending echoes settling in
	if pending_echoes.size() > 0:
		var t_norm: float = clamp(pending_echo_timer / pending_echo_settle_time, 0.0, 1.0)
		var pulse2: float = 0.4 + 0.6 * t_norm
		for p in pending_echoes:
			var r := Rect2(offset + Vector2(p.x * CELL_SIZE, p.y * CELL_SIZE), Vector2(CELL_SIZE, CELL_SIZE))
			var c: Color = COLOR_ECHO
			c.a = pulse2
			draw_rect(r.grow(-2.0 * (1.0 - t_norm)), c, true)

	# Particles
	if has_node("/root/Juice"):
		for p in Juice.particles:
			var life_t: float = clampf(float(p["life"]) / float(p.get("max_life", 0.55)), 0.0, 1.0)
			var col: Color = p["color"]
			col.a = life_t
			draw_circle(p["pos"], float(p["size"]) * life_t, col)

	# Player stamp
	var pr := Rect2(offset + Vector2(player_pos.x * CELL_SIZE + 6, player_pos.y * CELL_SIZE + 6), Vector2(CELL_SIZE - 12, CELL_SIZE - 12))
	draw_rect(pr, COLOR_PLAYER, true)
	draw_rect(pr.grow(1.0), Color(COLOR_BG, 0.65), false, 1.5)

	# Full-screen rewrite flash
	if has_node("/root/Juice"):
		var fa: float = Juice.flash_alpha()
		if fa > 0.01:
			var fc: Color = Juice.flash_color
			fc.a = fa
			draw_rect(Rect2(Vector2.ZERO, vp_size), fc, true)
