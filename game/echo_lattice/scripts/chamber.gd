extends Node2D
##
## Chamber — one playable room of Echo Lattice.
##
## Owns the tile grid, the player position, the local move buffer since the
## last checkpoint, and applies rewrites when a checkpoint is entered.
##
## JUICE v2: rewrite commits fire hitstop / shake / flash / camera punch /
## particles; pending echo cells foreshadow via three-phase telegraphs, then
## birth as walls (footstep trail → wall). Drawing applies camera spring + shake.
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
var pending_echo_settle_time: float = 0.55  # fallback if telegraphs miss a cell

var chamber: Dictionary = {}
var transform_name: String = "none"

var goal_pulse_t: float = 0.0
var move_accum: float = 0.0
var has_won: bool = false

# Ambient lattice-pulse telegraph (hostile foreshadow) — cadence per chamber.
var _pulse_cooldown: float = 2.4
var _pulse_timer: float = 0.0
var _ambient_pulses: bool = true


func _ready() -> void:
	set_process(true)
	set_process_input(true)
	# Headless / self-test: keep rewrite juice, skip ambient pulses for determinism.
	if DisplayServer.get_name() == "headless":
		_ambient_pulses = false
	load_chamber(GameState.current_chamber)


func _exit_tree() -> void:
	JuiceDirector.reset()
	Engine.time_scale = 1.0


func _process(delta: float) -> void:
	goal_pulse_t = fmod(goal_pulse_t + delta, TAU)
	# Sim-side juice (telegraphs + particles) — runs on scaled dt via Engine.time_scale.
	var fired: Array = JuiceDirector.update_sim(delta)
	for z in fired:
		_handle_fired_telegraph(z)

	# Fallback settle: any leftover pending echoes eventually solidify.
	if pending_echoes.size() > 0:
		pending_echo_timer += delta
		if pending_echo_timer >= pending_echo_settle_time:
			_flush_pending_echoes()

	# Ambient lattice pulses in chambers that rewrite (telegraph pillar in the loop).
	if _ambient_pulses and transform_name != "none" and not has_won:
		_pulse_timer += delta
		if _pulse_timer >= _pulse_cooldown:
			_pulse_timer = 0.0
			_spawn_ambient_pulse()

	# Keep camera target glued to the player cell.
	JuiceDirector.track_player(_cell_center_local(player_pos))
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
	_pulse_timer = 0.0
	_pulse_cooldown = 2.6
	JuiceDirector.reset()
	JuiceDirector.snap_camera(_cell_center_local(player_pos))
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

	var world: Vector2 = _cell_center_local(player_pos)
	JuiceDirector.track_player(world, Vector2(dir), float(CELL_SIZE))
	JuiceDirector.footstep_dust(world, Vector2(dir))

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
	JuiceDirector.snap_camera(_cell_center_local(player_pos))
	emit_signal("moves_changed", move_count)
	queue_redraw()


func _flush_pending_echoes() -> void:
	for p in pending_echoes:
		_birth_echo(p, false)
	pending_echoes.clear()
	pending_echo_timer = 0.0
	# Drop any outstanding wall-birth telegraphs so self-test / undo stay deterministic.
	var kept: Array = []
	for z in JuiceDirector.telegraphs.zones:
		var meta: Variant = z.get("meta", null)
		var kind := ""
		if typeof(meta) == TYPE_DICTIONARY:
			kind = str(meta.get("kind", ""))
		if kind != "wall_birth":
			kept.append(z)
	JuiceDirector.telegraphs.zones = kept


func _clear_all_echoes() -> void:
	for y in range(GRID_H):
		for x in range(GRID_W):
			if grid[y][x] == Tile.ECHO_WALL:
				grid[y][x] = Tile.FLOOR


func _trigger_rewrite() -> void:
	# The rewrite is a deterministic transform of the path walked since last checkpoint.
	# We compute the transformed cells and mark them as pending echoes so the visual
	# has a moment to communicate causation — JUICE v2 telegraphs each cell first.
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
	pending_echoes.clear()
	for p in candidates:
		if _would_still_be_reachable(p):
			pending_echoes.append(p)
	pending_echo_timer = 0.0
	moves_since_checkpoint.clear()

	var world: Vector2 = _cell_center_local(player_pos)
	JuiceDirector.on_rewrite_commit(world, pending_echoes.size())
	for i in range(pending_echoes.size()):
		var p: Vector2i = pending_echoes[i]
		JuiceDirector.foreshadow_wall_birth(_cell_center_local(p), p, i, float(CELL_SIZE))


func _birth_echo(p: Vector2i, with_particles: bool = true) -> void:
	if not _in_bounds(p):
		return
	if grid[p.y][p.x] == Tile.FLOOR:
		grid[p.y][p.x] = Tile.ECHO_WALL
		if with_particles:
			JuiceDirector.on_wall_born(_cell_center_local(p))
	# Remove from pending list if present.
	var idx: int = pending_echoes.find(p)
	if idx >= 0:
		pending_echoes.remove_at(idx)


func _handle_fired_telegraph(z: Dictionary) -> void:
	var meta: Variant = z.get("meta", null)
	if typeof(meta) != TYPE_DICTIONARY:
		return
	var kind: String = str(meta.get("kind", ""))
	if kind == "wall_birth":
		var cell: Vector2i = meta.get("cell", Vector2i(-1, -1))
		_birth_echo(cell, true)
	elif kind == "lattice_pulse":
		_resolve_lattice_pulse_hit(z)


func _spawn_ambient_pulse() -> void:
	# Pick a floor cell near the player (not on player/goal) for a hostile telegraph.
	var candidates: Array = []
	for y in range(maxi(0, player_pos.y - 4), mini(GRID_H, player_pos.y + 5)):
		for x in range(maxi(0, player_pos.x - 4), mini(GRID_W, player_pos.x + 5)):
			var p := Vector2i(x, y)
			if p == player_pos or p == goal_pos:
				continue
			if grid[y][x] != Tile.FLOOR:
				continue
			var d: int = absi(x - player_pos.x) + absi(y - player_pos.y)
			if d >= 2 and d <= 5:
				candidates.append(p)
	if candidates.is_empty():
		return
	var pick: Vector2i = candidates[randi() % candidates.size()]
	JuiceDirector.spawn_lattice_pulse(_cell_center_local(pick), float(CELL_SIZE) * 1.35, 0.75)


func _resolve_lattice_pulse_hit(z: Dictionary) -> void:
	var center := Vector2(float(z["x"]), float(z["y"]))
	var radius: float = float(z["radius"])
	var player_w: Vector2 = _cell_center_local(player_pos)
	var dist: float = player_w.distance_to(center)
	if dist <= radius:
		JuiceDirector.on_player_struck(player_w)
	else:
		var miss: float = maxf(0.0, 1.0 - (dist - radius) / 40.0)
		if miss > 0.0:
			JuiceDirector.on_near_miss(miss)


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
	JuiceDirector.flash.fire(0.35, 0.4, Color(0.34, 0.95, 0.69))
	JuiceDirector.shake.bump(0.18)
	# Small delay so the goal tile animation reads before the transition.
	var t := get_tree().create_timer(0.35)
	t.timeout.connect(func():
		emit_signal("chamber_won", int(chamber.get("id", 0)), move_count)
	)


func _in_bounds(p: Vector2i) -> bool:
	return p.x >= 0 and p.x < GRID_W and p.y >= 0 and p.y < GRID_H


func _cell_center_local(p: Vector2i) -> Vector2:
	return Vector2((float(p.x) + 0.5) * float(CELL_SIZE), (float(p.y) + 0.5) * float(CELL_SIZE))


# ---------------- rendering ----------------

func _draw() -> void:
	var vp_size: Vector2 = get_viewport_rect().size
	var grid_px: Vector2 = Vector2(GRID_W * CELL_SIZE, GRID_H * CELL_SIZE)

	# Background wash (untransformed — full viewport).
	draw_rect(Rect2(Vector2.ZERO, vp_size), COLOR_BG, true)

	# Camera spring + shake (real-time systems) applied as a draw transform.
	var shake: Vector3 = JuiceDirector.shake_offset()
	var zoom: float = JuiceDirector.camera.zoom
	var cam: Vector2 = JuiceDirector.camera.pos
	var origin: Vector2 = vp_size * 0.5 - cam * zoom + Vector2(shake.x, shake.y)

	# Slight rotation from shake about screen center.
	if absf(shake.z) > 0.0001:
		draw_set_transform(vp_size * 0.5, shake.z, Vector2.ONE)
		origin = origin - vp_size * 0.5
		# Re-apply after rotate: draw in rotated space with origin relative to center.
		_draw_world(origin, zoom)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		_draw_world(origin, zoom)

	# Flash overlay (screen space).
	var flash_col: Color = JuiceDirector.flash_modulate()
	if flash_col.a > 0.001:
		draw_rect(Rect2(Vector2.ZERO, vp_size), flash_col, true)


func _draw_world(origin: Vector2, zoom: float) -> void:
	var cs: float = float(CELL_SIZE) * zoom

	# Tiles
	for y in range(GRID_H):
		for x in range(GRID_W):
			var t: int = grid[y][x]
			var rect := Rect2(origin + Vector2(float(x) * cs, float(y) * cs), Vector2(cs, cs))
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
					var inner := rect.grow(-2.0 * zoom)
					draw_rect(inner, COLOR_WALL_HI, false, 1.0)
				Tile.CHECKPOINT:
					var r := (6.0 + sin(goal_pulse_t * 3.0) * 1.5) * zoom
					draw_circle(rect.get_center(), r, COLOR_CHECKPOINT)
					draw_arc(rect.get_center(), r + 3.0 * zoom, 0.0, TAU, 24, COLOR_CHECKPOINT, 1.0, true)
				Tile.CHECKPOINT_USED:
					draw_circle(rect.get_center(), 3.0 * zoom, COLOR_CHECKPOINT_USED)
				Tile.GOAL:
					var pulse: float = 0.5 + 0.5 * sin(goal_pulse_t * 2.5)
					var gcol: Color = COLOR_GOAL.lerp(COLOR_GOAL_PULSE, pulse)
					draw_rect(rect.grow(-4.0 * zoom), gcol, true)
					draw_rect(rect.grow(-8.0 * zoom), COLOR_FLOOR, true)
					draw_rect(rect.grow(-11.0 * zoom), gcol, true)
				Tile.ECHO_WALL:
					var inner2 := rect.grow(-3.0 * zoom)
					draw_rect(inner2, COLOR_ECHO_SOFT, true)

	# Ghost trail — the path walked since last checkpoint (diegetic footstep preview).
	for i in range(moves_since_checkpoint.size()):
		var p: Vector2i = moves_since_checkpoint[i]
		var r := Rect2(
			origin + Vector2(float(p.x) * cs + 12.0 * zoom, float(p.y) * cs + 12.0 * zoom),
			Vector2(cs - 24.0 * zoom, cs - 24.0 * zoom)
		)
		draw_rect(r, COLOR_GHOST, true)
	# Ghost trail lines (connecting) — dashed promise of walls-to-be.
	if moves_since_checkpoint.size() >= 2:
		var pts: PackedVector2Array = PackedVector2Array()
		for p2 in moves_since_checkpoint:
			pts.append(origin + Vector2((float(p2.x) + 0.5) * cs, (float(p2.y) + 0.5) * cs))
		for i in range(pts.size() - 1):
			draw_line(pts[i], pts[i + 1], COLOR_GHOST_LINE, 2.0 * zoom, true)

	# Pending echoes (soft fill under telegraph rings).
	if pending_echoes.size() > 0:
		var t_norm: float = clamp(pending_echo_timer / maxf(0.001, pending_echo_settle_time), 0.0, 1.0)
		var pulse: float = 0.25 + 0.55 * (1.0 - abs(sin(t_norm * PI * 2.0)))
		for p3 in pending_echoes:
			var r2 := Rect2(origin + Vector2(float(p3.x) * cs, float(p3.y) * cs), Vector2(cs, cs))
			var c: Color = COLOR_ECHO
			c.a = pulse
			draw_rect(r2.grow(-2.0 * zoom), c, true)

	# Player
	var pr := Rect2(
		origin + Vector2(float(player_pos.x) * cs + 6.0 * zoom, float(player_pos.y) * cs + 6.0 * zoom),
		Vector2(cs - 12.0 * zoom, cs - 12.0 * zoom)
	)
	draw_rect(pr, COLOR_PLAYER, true)
	draw_rect(pr.grow(1.0 * zoom), Color(0, 0, 0, 0.5), false, 1.0)

	# Juice FX in the same camera space (telegraphs + particles use local cell coords).
	draw_set_transform(origin, 0.0, Vector2(zoom, zoom))
	JuiceDirector.draw_fx(self)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
