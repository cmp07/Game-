extends Node2D
##
## Chamber — VISUAL v2 Field Ledger + elevated playable loop.
##
## Materials follow the art bible: ink on paper, fossilization not radiance.
## Rewrite: 12-beat origami slam + juice/audio punches; cadmium only on warn/heartbeat.
## Stars via BFS par on win. Supports invert transform from the content book.
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

## Rewrite slam total duration (~12 beats × 75 ms).
const REWRITE_DURATION: float = 0.90
const REWRITE_HEARTBEAT: float = 0.07

var grid: Array = []
var player_pos: Vector2i = Vector2i.ZERO
var start_pos: Vector2i = Vector2i.ZERO
var goal_pos: Vector2i = Vector2i.ZERO

var move_count: int = 0
var moves_since_checkpoint: Array = []
var undo_stack: Array = []
var checkpoints_triggered: Dictionary = {}
var pending_echoes: Array = []
var pending_echo_timer: float = 0.0
var pending_echo_settle_time: float = REWRITE_DURATION
var rewrite_freeze: bool = false  ## hold mid-slam for screenshot capture
var telegraph_cells: Array = []
var rewrite_warn_armed: bool = false

var walked: Dictionary = {}  ## Vector2i -> true — paper darkens under footprints
var traverse_count: Dictionary = {}  ## Vector2i -> int — rust colonization intensity

var chamber: Dictionary = {}
var transform_name: String = "none"

var goal_pulse_t: float = 0.0
var has_won: bool = false
var lantern_t: float = 0.0

## Hold-to-walk (accessibility) — initial delay then repeat while held.
const HOLD_INITIAL_DELAY: float = 0.22
const HOLD_REPEAT_DELAY: float = 0.08
var _hold_dir: Vector2i = Vector2i.ZERO
var _hold_timer: float = 0.0

var tex_floor_fresh: Texture2D
var tex_floor_walked: Texture2D
var tex_wall_fresh: Texture2D
var tex_wall_fossil: Texture2D
var tex_wall_folding: Texture2D
var tex_player: Texture2D
var tex_chalk: Texture2D
var tex_rust: Array = []

var _ghost_assist: GhostPathAssist
var _assist_path: Array = []


func _ready() -> void:
	_load_art()
	set_process(true)
	set_process_input(true)
	var a11y := get_node_or_null("/root/AccessibilityService")
	_ghost_assist = GhostPathAssist.new(a11y)
	if a11y != null and a11y.has_signal("colorblind_changed"):
		a11y.colorblind_changed.connect(queue_redraw)
	if a11y != null and a11y.has_signal("fossil_style_changed"):
		a11y.fossil_style_changed.connect(queue_redraw)
	if not Input.joy_connection_changed.is_connected(_on_joy_connection_changed):
		Input.joy_connection_changed.connect(_on_joy_connection_changed)
	load_chamber(GameState.current_chamber)


func _on_joy_connection_changed(_device: int, connected: bool) -> void:
	# Unplug can leave stick axes "pressed" in the InputMap — kill hold-to-walk.
	if not connected:
		_hold_dir = Vector2i.ZERO
		_hold_timer = 0.0


func _exit_tree() -> void:
	# Never leave a mid-slam lattice half-applied when the scene tears down.
	if pending_echoes.size() > 0:
		_flush_pending_echoes()


func _load_art() -> void:
	tex_floor_fresh = ArtKit.tex("res://art/tiles/floor_fresh_32.png")
	tex_floor_walked = ArtKit.tex("res://art/tiles/floor_walked_32.png")
	tex_wall_fresh = ArtKit.tex("res://art/tiles/wall_fresh_32.png")
	tex_wall_fossil = ArtKit.tex("res://art/tiles/wall_fossilized_32.png")
	tex_wall_folding = ArtKit.tex("res://art/tiles/wall_folding_32.png")
	tex_player = ArtKit.tex("res://art/tiles/player_stamp_24.png")
	tex_chalk = ArtKit.tex("res://art/decals/chalk_footprint.png")
	tex_rust = [
		ArtKit.tex("res://art/decals/rust_01.png"),
		ArtKit.tex("res://art/decals/rust_02.png"),
		ArtKit.tex("res://art/decals/rust_03.png"),
		ArtKit.tex("res://art/decals/rust_04.png"),
	]


func _process(delta: float) -> void:
	goal_pulse_t = fmod(goal_pulse_t + delta, TAU)
	lantern_t = fmod(lantern_t + delta * 1.7, TAU)
	if pending_echoes.size() > 0 and not rewrite_freeze:
		pending_echo_timer += delta
		if pending_echo_timer >= pending_echo_settle_time:
			_flush_pending_echoes()
	elif not has_won and pending_echoes.is_empty():
		_update_hold_to_walk(delta)
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
	traverse_count.clear()
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
	walked[player_pos] = true
	move_count = 0
	moves_since_checkpoint.clear()
	undo_stack.clear()
	checkpoints_triggered.clear()
	pending_echoes.clear()
	pending_echo_timer = 0.0
	rewrite_freeze = false
	telegraph_cells.clear()
	rewrite_warn_armed = false
	has_won = false
	_assist_path.clear()
	if _ghost_assist != null:
		_ghost_assist.begin_chamber(str(id))
	_hold_dir = Vector2i.ZERO
	_hold_timer = 0.0
	if has_node("/root/AudioDirector"):
		AudioDirector.set_chamber(id)
		AudioDirector.on_pa_line("pa.ghost.floor")
	_subtitle_line("pa.ghost.floor")
	emit_signal("moves_changed", move_count)
	emit_signal("caption_changed", str(chamber.get("caption", "")))
	queue_redraw()


func reset_chamber() -> void:
	if chamber.is_empty():
		return
	load_chamber(int(chamber.get("id", 0)))


func freeze_rewrite_at(t_norm: float) -> void:
	## Hold the origami slam at a normalized progress for screenshot capture.
	if pending_echoes.is_empty():
		return
	rewrite_freeze = true
	pending_echo_timer = clampf(t_norm, 0.0, 1.0) * pending_echo_settle_time
	queue_redraw()


func is_rewrite_locking() -> bool:
	## True while the origami slam owns the board — movement would softlock.
	return pending_echoes.size() > 0


func _notification(what: int) -> void:
	# Alt-tab / focus loss mid-hold must not keep walking after return.
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_hold_dir = Vector2i.ZERO
		_hold_timer = 0.0
	# Focus return after mid-rewrite: if freeze was not intentional, let settle timer resume.
	if what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		if pending_echoes.size() > 0 and not rewrite_freeze:
			# Defensive: do not leave a stale hold edge armed across focus gaps.
			_hold_dir = Vector2i.ZERO
			_hold_timer = 0.0


func _input(event: InputEvent) -> void:
	if has_won:
		return
	# OS key-repeat echoes are handled by hold-to-walk, not as fresh presses.
	if event is InputEventKey and event.is_echo():
		return
	if event.is_action_pressed("ghost_assist"):
		_try_ghost_assist()
		return
	if event.is_action_pressed("restart"):
		reset_chamber()
		return
	# During rewrite slam: only restart is allowed (anti-softlock).
	if is_rewrite_locking():
		return
	if event.is_action_pressed("undo"):
		_undo()
		_subtitle_line("undo")
		return
	var dir := _dir_from_event(event)
	if dir != Vector2i.ZERO:
		_hold_dir = dir
		_hold_timer = HOLD_INITIAL_DELAY
		_try_move(dir)


func _dir_from_event(event: InputEvent) -> Vector2i:
	if event.is_action_pressed("move_up"):
		return Vector2i(0, -1)
	if event.is_action_pressed("move_down"):
		return Vector2i(0, 1)
	if event.is_action_pressed("move_left"):
		return Vector2i(-1, 0)
	if event.is_action_pressed("move_right"):
		return Vector2i(1, 0)
	return Vector2i.ZERO


func _update_hold_to_walk(delta: float) -> void:
	if has_won or not _hold_to_walk_enabled():
		_hold_dir = Vector2i.ZERO
		_hold_timer = 0.0
		return
	var dir := Vector2i.ZERO
	if Input.is_action_pressed("move_up"):
		dir = Vector2i(0, -1)
	elif Input.is_action_pressed("move_down"):
		dir = Vector2i(0, 1)
	elif Input.is_action_pressed("move_left"):
		dir = Vector2i(-1, 0)
	elif Input.is_action_pressed("move_right"):
		dir = Vector2i(1, 0)
	if dir == Vector2i.ZERO:
		_hold_dir = Vector2i.ZERO
		_hold_timer = 0.0
		return
	if dir != _hold_dir:
		# Fresh direction while another was held — treat as a new press edge.
		_hold_dir = dir
		_hold_timer = HOLD_INITIAL_DELAY
		_try_move(dir)
		return
	_hold_timer -= delta
	if _hold_timer <= 0.0:
		_hold_timer = HOLD_REPEAT_DELAY
		_try_move(dir)


func _try_move(dir: Vector2i) -> void:
	if has_won or is_rewrite_locking():
		return
	var target: Vector2i = player_pos + dir
	if not _in_bounds(target):
		return
	var t: int = grid[target.y][target.x]
	if t == Tile.WALL or t == Tile.ECHO_WALL:
		if has_node("/root/AudioDirector"):
			AudioDirector.on_footstep(true)
		if has_node("/root/Juice"):
			# Ink scuff only — cadmium is reserved for rewrite-imminent warn/heartbeat.
			Juice.bump(0.06)
			Juice.flash(0.05, 0.08, Palette.INK_SOFT)
		return
	undo_stack.push_back({
		"prev_pos": player_pos,
		"prev_tile_at_target": t,
		"moves_since_cp_len": moves_since_checkpoint.size(),
		"triggered_snapshot": checkpoints_triggered.duplicate(true),
		"grid_deltas": [],
		"walked_had_target": walked.has(target),
		"walked_target": target,
	})
	player_pos = target
	move_count += 1
	moves_since_checkpoint.append(target)
	walked[target] = true
	traverse_count[target] = int(traverse_count.get(target, 0)) + 1
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
	if undo_stack.is_empty() or has_won:
		return
	# Never undo mid-slam — settle first only if already locking (defensive).
	if is_rewrite_locking():
		return
	var frame: Dictionary = undo_stack.pop_back()
	var walked_target: Vector2i = frame.get("walked_target", player_pos)
	var had_walked: bool = bool(frame.get("walked_had_target", true))
	player_pos = frame["prev_pos"]
	move_count = max(0, move_count - 1)
	while moves_since_checkpoint.size() > int(frame["moves_since_cp_len"]):
		moves_since_checkpoint.pop_back()
	if not had_walked and walked.has(walked_target):
		walked.erase(walked_target)
	var new_triggered: Dictionary = frame["triggered_snapshot"]
	for pos in checkpoints_triggered.keys():
		if not new_triggered.has(pos):
			if _in_bounds(pos):
				grid[pos.y][pos.x] = Tile.CHECKPOINT
			_clear_all_echoes()
	checkpoints_triggered = new_triggered
	emit_signal("moves_changed", move_count)
	queue_redraw()


func _flush_pending_echoes() -> void:
	var placed: Array = []
	for p in pending_echoes:
		# Never fossilize under the player or goal — both are softlock vectors.
		if p == player_pos or p == goal_pos:
			continue
		if _in_bounds(p) and grid[p.y][p.x] == Tile.FLOOR:
			grid[p.y][p.x] = Tile.ECHO_WALL
			placed.append(p)
	pending_echoes.clear()
	pending_echo_timer = 0.0
	rewrite_freeze = false
	if placed.size() > 0 and not _goal_reachable_now():
		_recover_softlock(placed)


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
	pending_echo_settle_time = REWRITE_DURATION
	if _reduce_motion():
		# Skip slam animation — commit fossils immediately for photosensitivity / vestibular comfort.
		pending_echo_settle_time = 0.05
	rewrite_freeze = false
	telegraph_cells.clear()
	moves_since_checkpoint.clear()
	# Refresh diegetic punch-card (buffer emptied; move_count unchanged).
	emit_signal("moves_changed", move_count)
	if has_node("/root/Juice"):
		Juice.rewrite_punch(pending_echoes.size())
		var offset: Vector2 = _grid_offset()
		var burst_color: Color = _role_color(FossilPalette.FossilRole.ECHO_WALL)
		for p in pending_echoes:
			var wp: Vector2 = offset + Vector2(p.x + 0.5, p.y + 0.5) * CELL_SIZE
			Juice.spawn_burst(wp, burst_color, 6 if not _reduce_motion() else 2)
	if has_node("/root/AudioDirector"):
		AudioDirector.on_rewrite(transform_name)
		AudioDirector.on_pa_line("pa.checkpoint.armed")
	_subtitle_line("checkpoint")
	match transform_name:
		"mirror_v", "mirror_h", "mirror_v_then_h":
			_subtitle_line("rewrite_mirror")
		"rotate_180":
			_subtitle_line("rewrite_rotate")
		"thicken":
			_subtitle_line("rewrite_thicken")
		_:
			_subtitle_line("rewrite_begin")


func _would_still_be_reachable(new_wall: Vector2i) -> bool:
	var blocked := {}
	blocked[new_wall] = true
	for p in pending_echoes:
		blocked[p] = true
	return _bfs_goal_open(blocked)


func _goal_reachable_now() -> bool:
	return _bfs_goal_open({})


func _bfs_goal_open(extra_blocked: Dictionary) -> bool:
	var w: int = GRID_W
	var h: int = GRID_H
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
			if seen.has(n) or extra_blocked.has(n):
				continue
			var cell: int = grid[n.y][n.x]
			if cell == Tile.WALL or cell == Tile.ECHO_WALL:
				continue
			seen[n] = true
			q.append(n)
	return false


func _recover_softlock(placed: Array) -> void:
	## Balance v2 fallback: strip just-placed echoes until the goal is open again.
	push_warning("Echo Lattice: softlock assert failed after rewrite; recovering.")
	var tel := LocalTelemetry.from_balance()
	tel.emit_softlock_assert_failed({
		"chamber_id": int(chamber.get("id", -1)),
		"placed": placed.size(),
		"player": {"x": player_pos.x, "y": player_pos.y},
		"goal": {"x": goal_pos.x, "y": goal_pos.y},
	})
	# Remove newest-first so earlier safety-net picks stay preferred.
	var i: int = placed.size() - 1
	while i >= 0 and not _goal_reachable_now():
		var p: Vector2i = placed[i]
		if _in_bounds(p) and grid[p.y][p.x] == Tile.ECHO_WALL:
			grid[p.y][p.x] = Tile.FLOOR
		i -= 1
	# Absolute last resort — clear every echo fossil.
	if not _goal_reachable_now():
		_clear_all_echoes()


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
	if transform_name == "none" or has_won or pending_echoes.size() > 0:
		return
	if moves_since_checkpoint.is_empty():
		return
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


func nearest_unused_checkpoint_dist() -> int:
	## Public HUD/telegraph accessor (diegetic punch-card warn state).
	return _nearest_unused_checkpoint_dist()


func buffer_fill_count() -> int:
	return moves_since_checkpoint.size()


func _update_habit_audio() -> void:
	if not has_node("/root/AudioDirector"):
		return
	var hp: Dictionary = GameState.habit_profile
	var total: float = float(
		int(hp.get("up", 0)) + int(hp.get("down", 0)) + int(hp.get("left", 0)) + int(hp.get("right", 0))
	)
	var dom: String = GameState.dominant_habit()
	var bias: float = 0.0 if total <= 0.0 else float(int(hp.get(dom, 0))) / total
	var echoes: float = 0.0
	for y in range(GRID_H):
		for x in range(GRID_W):
			if grid[y][x] == Tile.ECHO_WALL:
				echoes += 1.0
	var fossil: float = echoes / float(GRID_W * GRID_H)
	var prox: float = 0.0
	var nd: int = _nearest_unused_checkpoint_dist()
	if nd >= 0:
		prox = clampf(1.0 - float(nd) / 8.0, 0.0, 1.0)
	AudioDirector.update_habit_audio(bias, bias, fossil, float(checkpoints_triggered.size()) * 0.25, prox)


func _on_win() -> void:
	if has_won:
		return
	has_won = true
	_hold_dir = Vector2i.ZERO
	_hold_timer = 0.0
	var cid: int = int(chamber.get("id", 0))
	var bfs_par: int = _bfs_length(start_pos, goal_pos)
	GameState.record_chamber_win(cid, move_count, bfs_par)
	if has_node("/root/Juice"):
		Juice.bump(0.25)
		Juice.hitstop(0.07, 0.08)
		Juice.flash(0.35, 0.4, _role_color(FossilPalette.FossilRole.CHECKPOINT))
		var offset: Vector2 = _grid_offset()
		var wp: Vector2 = offset + Vector2(goal_pos.x + 0.5, goal_pos.y + 0.5) * CELL_SIZE
		Juice.spawn_burst(wp, Palette.COPPER_KEY, 10)
	if has_node("/root/AudioDirector"):
		AudioDirector.on_chamber_won(true)
	_subtitle_line("win")
	var t := get_tree().create_timer(0.4)
	t.timeout.connect(func():
		emit_signal("chamber_won", cid, move_count)
	)


func _bfs_length(from: Vector2i, to: Vector2i) -> int:
	## Base-layout distance for star par (walls only; ignore echo fossils).
	var rows: Array = chamber.get("map", [])
	var seen := {}
	var dist := {}
	var q: Array = [from]
	seen[from] = true
	dist[from] = 0
	while q.size() > 0:
		var cur: Vector2i = q.pop_front()
		if cur == to:
			return int(dist[cur])
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = cur + d
			if n.x < 0 or n.y < 0 or n.y >= rows.size():
				continue
			var row: String = str(rows[n.y])
			if n.x >= row.length() or seen.has(n):
				continue
			if row.substr(n.x, 1) == "#":
				continue
			seen[n] = true
			dist[n] = int(dist[cur]) + 1
			q.append(n)
	return maxi(1, move_count)


func _in_bounds(p: Vector2i) -> bool:
	return p.x >= 0 and p.x < GRID_W and p.y >= 0 and p.y < GRID_H


func _grid_offset() -> Vector2:
	var vp_size: Vector2 = get_viewport_rect().size
	var grid_px: Vector2 = Vector2(GRID_W * CELL_SIZE, GRID_H * CELL_SIZE)
	return ((vp_size - grid_px) * 0.5).floor()


# ---------------- rendering ----------------

func _draw() -> void:
	var vp_size: Vector2 = get_viewport_rect().size
	var offset: Vector2 = _grid_offset()
	if has_node("/root/Juice"):
		var sh: Dictionary = Juice.shake_offset(8.0, 1.5)
		offset += Vector2(float(sh.get("dx", 0.0)), float(sh.get("dy", 0.0)))
	var grid_px: Vector2 = Vector2(GRID_W * CELL_SIZE, GRID_H * CELL_SIZE)
	var page := Rect2(offset - Vector2(24, 24), grid_px + Vector2(48, 48))

	# Full viewport paper wash + margin.
	draw_rect(Rect2(Vector2.ZERO, vp_size), Palette.PAPER_MARGIN, true)
	ArtKit.draw_paper_grain(self, Rect2(Vector2.ZERO, vp_size), 11, 0.05)

	# Cast shadow under the ledger page.
	draw_rect(Rect2(page.position + Vector2(5, 7), page.size), Palette.PAPER_SHADOW, true)
	draw_rect(page, Palette.PAPER_BONE, true)
	ArtKit.draw_ledger_grid(self, page, 16)
	ArtKit.draw_paper_grain(self, page, 42, 0.08)

	# Page border — ink rule.
	draw_rect(page, Palette.INK_SOFT, false, 2.0)

	# Tiles
	for y in range(GRID_H):
		for x in range(GRID_W):
			_draw_tile(Vector2i(x, y), offset)

	# Ghost trail — dashed chalk diagram line (art bible §5).
	_draw_ghost_trail(offset)
	_draw_assist_path(offset)

	# Telegraph ticks — slate/chalk diagram marks by default; cadmium only when
	# rewrite is ≤3 steps away (art bible cadmium exclusivity ≤1%).
	if telegraph_cells.size() > 0 and pending_echoes.is_empty():
		var near_cp2 := _nearest_unused_checkpoint_dist()
		var near_warn: bool = near_cp2 >= 0 and near_cp2 <= 3
		var tension: float = 0.0
		if near_warn:
			tension = 1.0 - float(near_cp2) / 3.0
		for p in telegraph_cells:
			var r := Rect2(offset + Vector2(p) * CELL_SIZE, Vector2(CELL_SIZE, CELL_SIZE))
			var c: Color
			if near_warn:
				c = _role_color(FossilPalette.FossilRole.WARN)
				c.a = 0.40 + 0.35 * tension
			else:
				c = _role_color(FossilPalette.FossilRole.CHECKPOINT)
				c.a = 0.30
			var tick := 4.0
			draw_line(r.position, r.position + Vector2(tick, 0), c, 1.5)
			draw_line(r.position, r.position + Vector2(0, tick), c, 1.5)
			draw_line(r.position + Vector2(r.size.x, 0), r.position + Vector2(r.size.x - tick, 0), c, 1.5)
			draw_line(r.position + Vector2(r.size.x, 0), r.position + Vector2(r.size.x, tick), c, 1.5)
			draw_line(r.position + Vector2(0, r.size.y), r.position + Vector2(tick, r.size.y), c, 1.5)
			draw_line(r.position + Vector2(0, r.size.y), r.position + Vector2(0, r.size.y - tick), c, 1.5)
			draw_line(r.end, r.end - Vector2(tick, 0), c, 1.5)
			draw_line(r.end, r.end - Vector2(0, tick), c, 1.5)

	# Pending rewrite origami slam.
	if pending_echoes.size() > 0:
		_draw_rewrite_slam(offset, vp_size, page)

	# Player — surveyor stamp + chest-lantern warm spot.
	_draw_player(offset)

	if has_node("/root/Juice"):
		for part in Juice.particles:
			var pc: Color = part.get("color", Palette.RUST_FOSSIL)
			var life: float = float(part.get("life", 0.0))
			var max_life: float = maxf(0.001, float(part.get("max_life", 0.55)))
			pc.a = clampf(life / max_life, 0.0, 1.0)
			draw_circle(part.get("pos", Vector2.ZERO), float(part.get("size", 2.0)), pc)
		var fa: float = Juice.flash_alpha()
		if fa > 0.01:
			var fc: Color = Juice.flash_color
			fc.a = fa
			draw_rect(Rect2(Vector2.ZERO, vp_size), fc, true)


func _draw_tile(p: Vector2i, offset: Vector2) -> void:
	var t: int = grid[p.y][p.x]
	var rect := Rect2(offset + Vector2(p.x * CELL_SIZE, p.y * CELL_SIZE), Vector2(CELL_SIZE, CELL_SIZE))
	var is_walked: bool = walked.has(p)

	match t:
		Tile.WALL:
			# Solid ink fill first so walls never read as hollow frames.
			draw_rect(rect, Palette.INK_BLACK, true)
			_blit(tex_wall_fresh, rect, Palette.INK_BLACK)
			draw_rect(rect, Palette.INK_SOFT, false, 1.0)
		Tile.ECHO_WALL:
			var echo_c: Color = _role_color(FossilPalette.FossilRole.ECHO_WALL)
			draw_rect(rect, echo_c, true)
			_blit(tex_wall_fossil, rect, echo_c)
			var rust_i: int = (p.x * 3 + p.y * 7) % max(1, tex_rust.size())
			if tex_rust.size() > 0 and tex_rust[rust_i] != null:
				draw_texture_rect(tex_rust[rust_i], rect.grow(-2.0), false)
			var edge: Color = echo_c.darkened(0.25)
			draw_rect(rect.grow(-1.0), edge, false, 1.5)
			_draw_role_pattern(rect, FossilPalette.FossilRole.ECHO_WALL, echo_c)
		Tile.FLOOR, Tile.CHECKPOINT, Tile.CHECKPOINT_USED, Tile.GOAL:
			var base_floor: Color = Palette.PAPER_BONE if (p.x + p.y) % 2 == 0 else Palette.PAPER_DEEP.lerp(Palette.PAPER_BONE, 0.55)
			if is_walked:
				draw_rect(rect, Palette.PAPER_DEEP, true)
				_blit(tex_floor_walked, rect, Palette.PAPER_DEEP)
			else:
				draw_rect(rect, base_floor, true)
				_blit(tex_floor_fresh, rect, base_floor)
			# Habit colonization — flecks on over-walked floors (never on unwalked).
			var tc: int = int(traverse_count.get(p, 0))
			if tc >= 3:
				var over_c: Color = _role_color(FossilPalette.FossilRole.OVERUSE)
				over_c.a = clampf(0.25 + 0.12 * float(tc - 2), 0.25, 0.7)
				if tex_rust.size() > 0:
					var ri: int = (p.x + p.y) % tex_rust.size()
					if tex_rust[ri] != null:
						draw_texture_rect(tex_rust[ri], rect.grow(-6.0), false, over_c)
				_draw_role_pattern(rect.grow(-6.0), FossilPalette.FossilRole.OVERUSE, over_c)
		_:
			draw_rect(rect, Palette.PAPER_BONE, true)

	# Fine ledger sub-grid on floors.
	if t != Tile.WALL and t != Tile.ECHO_WALL:
		var gcol: Color = Palette.INK_SOFT
		gcol.a = 0.12
		draw_rect(rect, gcol, false, 1.0)

	match t:
		Tile.CHECKPOINT:
			# Printed stamp — slate teal (or colorblind-safe), no aura.
			var cp_c: Color = _role_color(FossilPalette.FossilRole.CHECKPOINT)
			var stamp := rect.grow(-7.0)
			draw_rect(stamp, cp_c, false, 2.0)
			draw_rect(stamp.grow(-3.0), cp_c, false, 1.0)
			# Tiny § mark via crossed bars.
			var c: Vector2 = rect.get_center()
			draw_line(c + Vector2(-4, 0), c + Vector2(4, 0), cp_c, 1.5, true)
			draw_line(c + Vector2(0, -4), c + Vector2(0, 4), cp_c, 1.5, true)
		Tile.CHECKPOINT_USED:
			var c2: Vector2 = rect.get_center()
			draw_circle(c2, 3.0, Palette.INK_SOFT)
		Tile.GOAL:
			# Copper keyhole plate — dry-plate etch, not neon.
			var pulse: float = 0.5 + 0.5 * sin(goal_pulse_t * 2.0)
			var gcol: Color = Palette.COPPER_KEY.lerp(Palette.SLATE_TEAL, 0.15 * pulse)
			draw_rect(rect.grow(-5.0), gcol, false, 2.0)
			draw_rect(rect.grow(-10.0), gcol, true)
			draw_rect(rect.grow(-13.0), Palette.PAPER_BONE, true)


func _blit(tex: Texture2D, rect: Rect2, fallback: Color) -> void:
	if tex != null:
		draw_texture_rect(tex, rect, false)
	else:
		draw_rect(rect, fallback, true)


func _draw_ghost_trail(offset: Vector2) -> void:
	if moves_since_checkpoint.is_empty():
		return
	var fresh: Color = _role_color(FossilPalette.FossilRole.FRESH)
	var warm: Color = _role_color(FossilPalette.FossilRole.WARM)
	# Chalk footprints on each buffer tile.
	for i in range(moves_since_checkpoint.size()):
		var p: Vector2i = moves_since_checkpoint[i]
		var rect := Rect2(offset + Vector2(p.x * CELL_SIZE + 6, p.y * CELL_SIZE + 6), Vector2(CELL_SIZE - 12, CELL_SIZE - 12))
		var t: float = float(i + 1) / float(moves_since_checkpoint.size())
		var chalk_c: Color = warm.lerp(fresh, t)
		chalk_c.a = 0.35 + 0.45 * t
		if tex_chalk != null:
			draw_texture_rect(tex_chalk, rect, false, chalk_c)
		else:
			draw_rect(rect.grow(-4.0), chalk_c, true)
		if t > 0.66:
			_draw_role_pattern(rect, FossilPalette.FossilRole.FRESH, chalk_c)
		elif t > 0.33:
			_draw_role_pattern(rect, FossilPalette.FossilRole.WARM, chalk_c)
		else:
			_draw_role_pattern(rect, FossilPalette.FossilRole.COLD, chalk_c)
	# Dashed chalk connector.
	if moves_since_checkpoint.size() >= 2:
		var chalk := fresh
		chalk.a = 0.65
		for i in range(moves_since_checkpoint.size() - 1):
			var a: Vector2i = moves_since_checkpoint[i]
			var b: Vector2i = moves_since_checkpoint[i + 1]
			var pa: Vector2 = offset + Vector2(a.x * CELL_SIZE + CELL_SIZE * 0.5, a.y * CELL_SIZE + CELL_SIZE * 0.5)
			var pb: Vector2 = offset + Vector2(b.x * CELL_SIZE + CELL_SIZE * 0.5, b.y * CELL_SIZE + CELL_SIZE * 0.5)
			ArtKit.draw_dashed_line(self, pa, pb, chalk, 1.5, 4.0, 3.0)


func _draw_rewrite_slam(offset: Vector2, vp_size: Vector2, page: Rect2) -> void:
	var t_norm: float = clampf(pending_echo_timer / pending_echo_settle_time, 0.0, 1.0)
	# 12-beat origami slam (art bible §5).
	# 0.00–0.08: cadmium_warn margin heartbeat
	# 0.08–0.28: creases (S2)
	# 0.28–0.50: lift + cast shadow
	# 0.50–0.78: slot into place with overshoot
	# 0.78–1.00: rust bleed

	if t_norm < REWRITE_HEARTBEAT / REWRITE_DURATION and not _reduce_flash():
		# Single heartbeat — paper margin flash only (skipped when reduce-flash).
		var flash_a: float = 1.0 - (t_norm / (REWRITE_HEARTBEAT / REWRITE_DURATION))
		var warn_base: Color = _role_color(FossilPalette.FossilRole.WARN)
		var warn := Color(warn_base.r, warn_base.g, warn_base.b, 0.55 * flash_a)
		draw_rect(Rect2(0, 0, vp_size.x, 10), warn, true)
		draw_rect(Rect2(0, vp_size.y - 10, vp_size.x, 10), warn, true)
		draw_rect(Rect2(0, 0, 10, vp_size.y), warn, true)
		draw_rect(Rect2(vp_size.x - 10, 0, 10, vp_size.y), warn, true)
		# Thin rule around the page.
		var page_warn := Color(warn_base.r, warn_base.g, warn_base.b, 0.85 * flash_a)
		draw_rect(page.grow(2.0), page_warn, false, 3.0)

	var n: int = pending_echoes.size()
	for i in range(n):
		var p: Vector2i = pending_echoes[i]
		# Stagger each wall slightly so the cascade reads as paper folding, not a flash.
		var stagger: float = float(i) / float(maxi(n, 1)) * 0.18
		var local_t: float = clampf((t_norm - stagger) / max(0.001, 1.0 - stagger), 0.0, 1.0)
		var base := Rect2(offset + Vector2(p.x * CELL_SIZE, p.y * CELL_SIZE), Vector2(CELL_SIZE, CELL_SIZE))

		if local_t < 0.25:
			# Creases appear on doomed floor tiles.
			var crease_a: float = local_t / 0.25
			draw_rect(base, Palette.PAPER_DEEP, true)
			_blit(tex_wall_folding, base, Palette.PAPER_DEEP)
			var ink := Color(Palette.INK_SOFT.r, Palette.INK_SOFT.g, Palette.INK_SOFT.b, 0.85 * crease_a)
			draw_line(base.position + Vector2(2, 2), base.end - Vector2(2, 2), ink, 1.5, true)
			draw_line(base.position + Vector2(CELL_SIZE - 2, 2), base.position + Vector2(2, CELL_SIZE - 2), ink, 1.5, true)
			var warn_base2: Color = _role_color(FossilPalette.FossilRole.WARN)
			var warn_edge := Color(warn_base2.r, warn_base2.g, warn_base2.b, 0.35 * crease_a)
			draw_rect(base, warn_edge, false, 1.0)
		elif local_t < 0.50:
			# Lift — cast shadow, no rim light.
			var lift: float = (local_t - 0.25) / 0.25
			var shadow_off: Vector2 = Vector2(3.0 + 5.0 * lift, 4.0 + 6.0 * lift)
			var sh := Color(Palette.INK_BLACK.r, Palette.INK_BLACK.g, Palette.INK_BLACK.b, 0.28 + 0.22 * lift)
			draw_rect(Rect2(base.position + shadow_off, base.size), sh, true)
			var raised := Rect2(base.position - Vector2(0, 4.0 * lift), base.size)
			draw_rect(raised, Palette.PAPER_DEEP, true)
			_blit(tex_wall_folding, raised, Palette.PAPER_DEEP)
			draw_rect(raised, Palette.INK_SOFT, false, 1.5)
		elif local_t < 0.78:
			# Slot with 1px overshoot bounce into solid fossil.
			var slot: float = (local_t - 0.50) / 0.28
			var bounce: float = sin(slot * PI) * (1.0 - slot) * 3.0
			var slotted := Rect2(base.position - Vector2(0, bounce), base.size)
			var echo_c2: Color = _role_color(FossilPalette.FossilRole.ECHO_WALL)
			draw_rect(slotted, echo_c2, true)
			_blit(tex_wall_fossil, slotted, echo_c2)
			draw_rect(slotted.grow(-1.0), echo_c2.darkened(0.25), false, 1.5)
		else:
			# Rust bleed from the joins.
			var bleed: float = (local_t - 0.78) / 0.22
			var echo_c3: Color = _role_color(FossilPalette.FossilRole.ECHO_WALL)
			draw_rect(base, echo_c3, true)
			_blit(tex_wall_fossil, base, echo_c3)
			var rust_i: int = (p.x * 3 + p.y * 7) % max(1, tex_rust.size())
			if tex_rust.size() > 0 and tex_rust[rust_i] != null:
				draw_texture_rect(tex_rust[rust_i], base.grow(-2.0 + 2.0 * (1.0 - bleed)), false, Color(1, 1, 1, 0.4 + 0.6 * bleed))
			draw_rect(base.grow(-1.0), echo_c3.darkened(0.25), false, 1.5)
			_draw_role_pattern(base, FossilPalette.FossilRole.ECHO_WALL, echo_c3)

	# Quiet title plate during slam — "IT LEARNED YOU"
	if t_norm > 0.12 and t_norm < 0.85:
		var a: float = 1.0
		if t_norm < 0.25:
			a = (t_norm - 0.12) / 0.13
		elif t_norm > 0.70:
			a = 1.0 - (t_norm - 0.70) / 0.15
		var label_pos := Vector2(vp_size.x * 0.5 - 90, offset.y - 18)
		var plate := Rect2(label_pos - Vector2(8, 2), Vector2(188, 16))
		var plate_c := Color(Palette.PAPER_BONE.r, Palette.PAPER_BONE.g, Palette.PAPER_BONE.b, 0.92 * a)
		draw_rect(plate, plate_c, true)
		draw_rect(plate, Color(Palette.RUST_FOSSIL.r, Palette.RUST_FOSSIL.g, Palette.RUST_FOSSIL.b, 0.9 * a), false, 1.0)


func _draw_player(offset: Vector2) -> void:
	var center: Vector2 = offset + Vector2(player_pos.x * CELL_SIZE + CELL_SIZE * 0.5, player_pos.y * CELL_SIZE + CELL_SIZE * 0.5)
	# Soft copper lantern disc — hard 1-tile falloff, diegetic only.
	var flicker: float = 0.85 + 0.15 * sin(lantern_t)
	var lantern := Color(Palette.COPPER_KEY.r, Palette.COPPER_KEY.g, Palette.COPPER_KEY.b, 0.18 * flicker)
	draw_circle(center, CELL_SIZE * 0.95, lantern)
	var lantern_core := Color(Palette.COPPER_KEY.r, Palette.COPPER_KEY.g, Palette.COPPER_KEY.b, 0.35 * flicker)
	draw_circle(center, CELL_SIZE * 0.35, lantern_core)

	var pr := Rect2(center - Vector2(12, 12), Vector2(24, 24))
	if tex_player != null:
		draw_texture_rect(tex_player, pr, false)
	else:
		# Fallback surveyor stamp — triangular torso + lantern spot.
		var pts := PackedVector2Array([
			center + Vector2(0, -10),
			center + Vector2(9, 10),
			center + Vector2(-9, 10),
		])
		draw_colored_polygon(pts, Palette.INK_BLACK)
		draw_circle(center + Vector2(0, 2), 2.5, Palette.COPPER_KEY)


# ---------------- accessibility helpers ----------------

func _role_color(role: FossilPalette.FossilRole) -> Color:
	var a11y := get_node_or_null("/root/AccessibilityService")
	if a11y != null and a11y.has_method("role_color"):
		return a11y.role_color(role)
	return FossilPalette.color_for(FossilPalette.Mode.DEFAULT, role)


func _use_patterns() -> bool:
	var a11y := get_node_or_null("/root/AccessibilityService")
	if a11y != null and a11y.has_method("fossil_use_patterns"):
		return bool(a11y.fossil_use_patterns())
	return true


func _reduce_flash() -> bool:
	var a11y := get_node_or_null("/root/AccessibilityService")
	if a11y != null and a11y.has_method("reduce_flash"):
		return bool(a11y.reduce_flash())
	return false


func _reduce_motion() -> bool:
	var a11y := get_node_or_null("/root/AccessibilityService")
	if a11y != null and a11y.has_method("reduce_motion"):
		return bool(a11y.reduce_motion())
	return false


func _hold_to_walk_enabled() -> bool:
	var a11y := get_node_or_null("/root/AccessibilityService")
	if a11y != null and a11y.has_method("hold_to_walk"):
		return bool(a11y.hold_to_walk())
	return false


func _subtitle_line(id: String) -> void:
	var tree := get_tree()
	if tree == null or tree.root == null:
		return
	var overlay := tree.root.find_child("SubtitleOverlay", true, false)
	if overlay != null and overlay.has_method("show_line"):
		overlay.call("show_line", id)



func _try_ghost_assist() -> void:
	if _ghost_assist == null:
		return
	var path: Array = _compute_assist_path()
	if _ghost_assist.try_reveal(path):
		_assist_path = _ghost_assist.active_ghost_path()
		_subtitle_line("ghost_assist")
		queue_redraw()


func _compute_assist_path() -> Array:
	## BFS from player to goal on the live grid (ignores rewrite foresight).
	var w: int = GRID_W
	var h: int = GRID_H
	var start: Vector2i = player_pos
	var goal: Vector2i = goal_pos
	var came_from := {}
	came_from[start] = start
	var q: Array = [start]
	var found := false
	while q.size() > 0:
		var cur: Vector2i = q.pop_front()
		if cur == goal:
			found = true
			break
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = cur + d
			if n.x < 0 or n.x >= w or n.y < 0 or n.y >= h:
				continue
			if came_from.has(n):
				continue
			var cell: int = grid[n.y][n.x]
			if cell == Tile.WALL or cell == Tile.ECHO_WALL:
				continue
			came_from[n] = cur
			q.append(n)
	if not found:
		return []
	var rev: Array = []
	var cur2: Vector2i = goal
	while cur2 != start:
		rev.append(cur2)
		cur2 = came_from[cur2]
	rev.append(start)
	rev.reverse()
	return rev


func _draw_assist_path(offset: Vector2) -> void:
	if _assist_path.is_empty():
		return
	var ghost_c: Color = _role_color(FossilPalette.FossilRole.GHOST)
	ghost_c.a = 0.75
	for i in range(_assist_path.size()):
		var p: Vector2i = _assist_path[i]
		var rect := Rect2(offset + Vector2(p.x * CELL_SIZE + 8, p.y * CELL_SIZE + 8), Vector2(CELL_SIZE - 16, CELL_SIZE - 16))
		draw_rect(rect, ghost_c, false, 2.0)
		_draw_role_pattern(rect, FossilPalette.FossilRole.GHOST, ghost_c)
	if _assist_path.size() >= 2:
		for i in range(_assist_path.size() - 1):
			var a: Vector2i = _assist_path[i]
			var b: Vector2i = _assist_path[i + 1]
			var pa: Vector2 = offset + Vector2(a.x * CELL_SIZE + CELL_SIZE * 0.5, a.y * CELL_SIZE + CELL_SIZE * 0.5)
			var pb: Vector2 = offset + Vector2(b.x * CELL_SIZE + CELL_SIZE * 0.5, b.y * CELL_SIZE + CELL_SIZE * 0.5)
			ArtKit.draw_dashed_line(self, pa, pb, ghost_c, 2.0, 5.0, 3.0)


func _draw_role_pattern(rect: Rect2, role: FossilPalette.FossilRole, color: Color) -> void:
	if not _use_patterns():
		return
	var pattern: FossilPalette.Pattern = FossilPalette.pattern_for(role, true)
	var ink := color
	ink.a = minf(color.a + 0.15, 0.85)
	match pattern:
		FossilPalette.Pattern.STRIPES:
			var y: float = rect.position.y + 3.0
			while y < rect.end.y - 2.0:
				draw_line(Vector2(rect.position.x + 2.0, y), Vector2(rect.end.x - 2.0, y), ink, 1.0)
				y += 4.0
		FossilPalette.Pattern.DOTS:
			for i in range(3):
				for j in range(3):
					var c := Vector2(
						rect.position.x + 6.0 + float(i) * 8.0,
						rect.position.y + 6.0 + float(j) * 8.0
					)
					if rect.has_point(c):
						draw_circle(c, 1.4, ink)
		FossilPalette.Pattern.CROSSHATCH:
			draw_line(rect.position + Vector2(3, 3), rect.end - Vector2(3, 3), ink, 1.2, true)
			draw_line(Vector2(rect.end.x - 3, rect.position.y + 3), Vector2(rect.position.x + 3, rect.end.y - 3), ink, 1.2, true)
		FossilPalette.Pattern.DASHES:
			ArtKit.draw_dashed_line(
				self,
				rect.position + Vector2(4, rect.size.y * 0.5),
				rect.position + Vector2(rect.size.x - 4, rect.size.y * 0.5),
				ink, 1.5, 3.0, 2.0
			)
		_:
			pass
