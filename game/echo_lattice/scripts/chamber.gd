extends Node2D
##
## Chamber — one playable room of Echo Lattice (VISUAL v2).
##
## Materials follow the art bible: ink on paper, fossilization not radiance.
## The rewrite is a 12-beat origami slam with a single cadmium_warn heartbeat.
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

var walked: Dictionary = {}  ## Vector2i -> true — paper darkens under footprints
var traverse_count: Dictionary = {}  ## Vector2i -> int — rust colonization intensity

var chamber: Dictionary = {}
var transform_name: String = "none"

var goal_pulse_t: float = 0.0
var has_won: bool = false
var lantern_t: float = 0.0

var tex_floor_fresh: Texture2D
var tex_floor_walked: Texture2D
var tex_wall_fresh: Texture2D
var tex_wall_fossil: Texture2D
var tex_wall_folding: Texture2D
var tex_player: Texture2D
var tex_chalk: Texture2D
var tex_rust: Array = []


func _ready() -> void:
	_load_art()
	set_process(true)
	set_process_input(true)
	load_chamber(GameState.current_chamber)


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
			for p in pending_echoes:
				if _in_bounds(p) and grid[p.y][p.x] == Tile.FLOOR:
					grid[p.y][p.x] = Tile.ECHO_WALL
			pending_echoes.clear()
			pending_echo_timer = 0.0
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
	has_won = false
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
	walked[target] = true
	traverse_count[target] = int(traverse_count.get(target, 0)) + 1
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
	_flush_pending_echoes()
	var frame: Dictionary = undo_stack.pop_back()
	player_pos = frame["prev_pos"]
	move_count = max(0, move_count - 1)
	while moves_since_checkpoint.size() > int(frame["moves_since_cp_len"]):
		moves_since_checkpoint.pop_back()
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
	for p in pending_echoes:
		if _in_bounds(p) and grid[p.y][p.x] == Tile.FLOOR:
			grid[p.y][p.x] = Tile.ECHO_WALL
	pending_echoes.clear()
	pending_echo_timer = 0.0
	rewrite_freeze = false


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
	rewrite_freeze = false
	moves_since_checkpoint.clear()


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
		_:
			pass
	return out


func _on_win() -> void:
	if has_won:
		return
	has_won = true
	GameState.record_chamber_win(int(chamber.get("id", 0)), move_count)
	var t := get_tree().create_timer(0.35)
	t.timeout.connect(func():
		emit_signal("chamber_won", int(chamber.get("id", 0)), move_count)
	)


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

	# Pending rewrite origami slam.
	if pending_echoes.size() > 0:
		_draw_rewrite_slam(offset, vp_size, page)

	# Player — surveyor stamp + chest-lantern warm spot.
	_draw_player(offset)


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
			draw_rect(rect, Palette.RUST_FOSSIL, true)
			_blit(tex_wall_fossil, rect, Palette.RUST_FOSSIL)
			var rust_i: int = (p.x * 3 + p.y * 7) % max(1, tex_rust.size())
			if tex_rust.size() > 0 and tex_rust[rust_i] != null:
				draw_texture_rect(tex_rust[rust_i], rect.grow(-2.0), false)
			draw_rect(rect.grow(-1.0), Palette.RUST_DEEP, false, 1.5)
		Tile.FLOOR, Tile.CHECKPOINT, Tile.CHECKPOINT_USED, Tile.GOAL:
			var base_floor: Color = Palette.PAPER_BONE if (p.x + p.y) % 2 == 0 else Palette.PAPER_DEEP.lerp(Palette.PAPER_BONE, 0.55)
			if is_walked:
				draw_rect(rect, Palette.PAPER_DEEP, true)
				_blit(tex_floor_walked, rect, Palette.PAPER_DEEP)
			else:
				draw_rect(rect, base_floor, true)
				_blit(tex_floor_fresh, rect, base_floor)
			# Habit colonization — rust flecks on over-walked floors (never on unwalked).
			var tc: int = int(traverse_count.get(p, 0))
			if tc >= 3 and tex_rust.size() > 0:
				var ri: int = (p.x + p.y) % tex_rust.size()
				if tex_rust[ri] != null:
					var rc: Color = Color(1, 1, 1, clampf(0.25 + 0.12 * float(tc - 2), 0.25, 0.7))
					draw_texture_rect(tex_rust[ri], rect.grow(-6.0), false, rc)
		_:
			draw_rect(rect, Palette.PAPER_BONE, true)

	# Fine ledger sub-grid on floors.
	if t != Tile.WALL and t != Tile.ECHO_WALL:
		var gcol: Color = Palette.INK_SOFT
		gcol.a = 0.12
		draw_rect(rect, gcol, false, 1.0)

	match t:
		Tile.CHECKPOINT:
			# Printed stamp — slate teal, no aura.
			var stamp := rect.grow(-7.0)
			draw_rect(stamp, Palette.SLATE_TEAL, false, 2.0)
			draw_rect(stamp.grow(-3.0), Palette.SLATE_TEAL, false, 1.0)
			# Tiny § mark via crossed bars.
			var c: Vector2 = rect.get_center()
			draw_line(c + Vector2(-4, 0), c + Vector2(4, 0), Palette.SLATE_TEAL, 1.5, true)
			draw_line(c + Vector2(0, -4), c + Vector2(0, 4), Palette.SLATE_TEAL, 1.5, true)
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
	# Chalk footprints on each buffer tile.
	for i in range(moves_since_checkpoint.size()):
		var p: Vector2i = moves_since_checkpoint[i]
		var rect := Rect2(offset + Vector2(p.x * CELL_SIZE + 6, p.y * CELL_SIZE + 6), Vector2(CELL_SIZE - 12, CELL_SIZE - 12))
		if tex_chalk != null:
			var a: float = 0.35 + 0.45 * (float(i + 1) / float(moves_since_checkpoint.size()))
			draw_texture_rect(tex_chalk, rect, false, Color(1, 1, 1, a))
		else:
			draw_rect(rect.grow(-4.0), Color(Palette.CHALK_WHITE.r, Palette.CHALK_WHITE.g, Palette.CHALK_WHITE.b, 0.55), true)
	# Dashed chalk connector.
	if moves_since_checkpoint.size() >= 2:
		var chalk := Color(Palette.CHALK_WHITE.r, Palette.CHALK_WHITE.g, Palette.CHALK_WHITE.b, 0.65)
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

	if t_norm < REWRITE_HEARTBEAT / REWRITE_DURATION:
		# Single heartbeat — paper margin flash only.
		var flash_a: float = 1.0 - (t_norm / (REWRITE_HEARTBEAT / REWRITE_DURATION))
		var warn := Color(Palette.CADMIUM_WARN.r, Palette.CADMIUM_WARN.g, Palette.CADMIUM_WARN.b, 0.55 * flash_a)
		draw_rect(Rect2(0, 0, vp_size.x, 10), warn, true)
		draw_rect(Rect2(0, vp_size.y - 10, vp_size.x, 10), warn, true)
		draw_rect(Rect2(0, 0, 10, vp_size.y), warn, true)
		draw_rect(Rect2(vp_size.x - 10, 0, 10, vp_size.y), warn, true)
		# Thin rule around the page.
		var page_warn := Color(Palette.CADMIUM_WARN.r, Palette.CADMIUM_WARN.g, Palette.CADMIUM_WARN.b, 0.85 * flash_a)
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
			var warn_edge := Color(Palette.CADMIUM_WARN.r, Palette.CADMIUM_WARN.g, Palette.CADMIUM_WARN.b, 0.35 * crease_a)
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
			draw_rect(slotted, Palette.RUST_FOSSIL, true)
			_blit(tex_wall_fossil, slotted, Palette.RUST_FOSSIL)
			draw_rect(slotted.grow(-1.0), Palette.RUST_DEEP, false, 1.5)
		else:
			# Rust bleed from the joins.
			var bleed: float = (local_t - 0.78) / 0.22
			draw_rect(base, Palette.RUST_FOSSIL, true)
			_blit(tex_wall_fossil, base, Palette.RUST_FOSSIL)
			var rust_i: int = (p.x * 3 + p.y * 7) % max(1, tex_rust.size())
			if tex_rust.size() > 0 and tex_rust[rust_i] != null:
				draw_texture_rect(tex_rust[rust_i], base.grow(-2.0 + 2.0 * (1.0 - bleed)), false, Color(1, 1, 1, 0.4 + 0.6 * bleed))
			draw_rect(base.grow(-1.0), Palette.RUST_DEEP, false, 1.5)

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
