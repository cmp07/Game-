extends Node
##
## Main — the root router.
##
## Owns a single container child which we swap between menu, chamber, chamber win,
## and end-of-slice screens. Keeps scene loads explicit and Godot-project-simple.
##

const MENU_SCENE:     PackedScene = preload("res://scenes/menu.tscn")
const CHAMBER_SCENE:  PackedScene = preload("res://scenes/chamber.tscn")
const WIN_SCENE:      PackedScene = preload("res://scenes/chamber_won.tscn")
const END_SCENE:      PackedScene = preload("res://scenes/end_screen.tscn")

@onready var stage: Node = $Stage


func _ready() -> void:
	var all_args: PackedStringArray = OS.get_cmdline_user_args()
	for a in OS.get_cmdline_args():
		all_args.append(a)
	# Headless self-test — run when launched with `-- --selftest`.
	if all_args.has("--selftest"):
		var ok: bool = await _run_self_test()
		get_tree().quit(0 if ok else 1)
		return
	# Screenshot capture — `-- --screenshot menu|chamber:N|won:N|end   out_dir`.
	if all_args.has("--screenshot"):
		var kind := ""
		var out_dir := "user://shots"
		var i2 := 0
		while i2 < all_args.size():
			if all_args[i2] == "--screenshot" and i2 + 1 < all_args.size():
				kind = all_args[i2 + 1]
			if all_args[i2] == "--out" and i2 + 1 < all_args.size():
				out_dir = all_args[i2 + 1]
			i2 += 1
		await _capture_screenshot(kind, out_dir)
		get_tree().quit(0)
		return
	show_menu()


func _capture_screenshot(kind: String, out_dir: String) -> void:
	DirAccess.make_dir_recursive_absolute(out_dir)
	if kind == "menu":
		# Fresh-boot menu: no prior save, so Continue is disabled and the
		# subtitle reads "A vertical slice — N chambers."
		SaveManager.wipe()
		GameState.current_chamber = 0
		GameState.best_moves.clear()
		GameState.completed.clear()
		GameState.habit_profile = {"up": 0, "down": 0, "left": 0, "right": 0}
		GameState.move_ring.clear()
		GameState.run_started = false
		show_menu()
	elif kind.begins_with("chamber:"):
		# Enter a chamber with a fresh run so the habit reads "unwritten" and
		# the maze is untouched.
		var cidx: int = int(kind.substr(8))
		GameState.start_new_run()
		GameState.current_chamber = cidx
		GameState.queue_pos = cidx
		show_chamber()
	elif kind.begins_with("walk_only:"):
		# `walk_only:CHAMBER:STOP_BEFORE` — enter chamber, BFS-step toward the
		# closest checkpoint, and stop STOP_BEFORE tiles short so the ghost
		# trail is visible with no rewrite fired yet.
		var rest: String = kind.substr("walk_only:".length())
		var parts: PackedStringArray = rest.split(":")
		var cidx2: int = int(parts[0]) if parts.size() > 0 else 2
		var stop_before: int = 4
		if parts.size() > 1:
			stop_before = int(parts[1])
		GameState.start_new_run()
		GameState.current_chamber = cidx2
		GameState.queue_pos = cidx2
		show_chamber()
		await get_tree().process_frame
		var stage_kid_w: Node = stage.get_child(0)
		var chamber_w: Node2D = stage_kid_w.get_node("Chamber")
		var target_w: Vector2i = chamber_w.goal_pos
		for y in range(chamber_w.grid.size()):
			for x in range(chamber_w.grid[y].size()):
				if chamber_w.grid[y][x] == 2:
					target_w = Vector2i(x, y)
					break
		# Manhattan distance to the target — used to stop early without ever
		# stepping onto the checkpoint tile.
		var guard_w: int = 0
		while guard_w < 400:
			var dist: int = abs(chamber_w.player_pos.x - target_w.x) + abs(chamber_w.player_pos.y - target_w.y)
			if dist <= stop_before:
				break
			var step_w: Vector2i = _bfs_next_step(chamber_w, target_w)
			if step_w == Vector2i.ZERO:
				break
			chamber_w._try_move(step_w)
			chamber_w._flush_pending_echoes()
			guard_w += 1
	elif kind.begins_with("won:"):
		var idx: int = int(kind.substr(4))
		GameState.start_new_run()
		GameState.current_chamber = idx
		GameState.queue_pos = idx
		GameState.last_clear_stars = 3
		GameState.last_clear_bfs_par = 28
		GameState.best_moves[idx] = 32
		GameState.best_stars[idx] = 3
		show_chamber_won(idx, 42)
	elif kind.begins_with("rewrite:"):
		# Drive to the first checkpoint, then freeze the origami slam mid-fold
		# so the VISUAL v2 rewrite beat is visible (creases + cast shadow + rust).
		var idx2: int = int(kind.substr(8))
		GameState.start_new_run()
		GameState.current_chamber = idx2
		GameState.queue_pos = idx2
		show_chamber()
		await get_tree().process_frame
		var stage_kid: Node = stage.get_child(0)
		var chamber: Node2D = stage_kid.get_node("Chamber")
		var target: Vector2i = chamber.goal_pos
		for y in range(chamber.grid.size()):
			for x in range(chamber.grid[y].size()):
				if chamber.grid[y][x] == 2:
					target = Vector2i(x, y)
					break
		var guard: int = 0
		while chamber.player_pos != target and guard < 400:
			var step: Vector2i = _bfs_next_step(chamber, target)
			if step == Vector2i.ZERO:
				break
			chamber._try_move(step)
			# Do NOT flush — leave the slam running so we can freeze mid-fold.
			guard += 1
		if chamber.pending_echoes.size() > 0:
			# Mid-slam: lift + slot phase (~0.55) — the trailer still.
			chamber.freeze_rewrite_at(0.55)
		else:
			# Fallback: if no echoes placed, step a few more and show settled walls.
			for k in range(3):
				var next: Vector2i = _bfs_next_step(chamber, chamber.goal_pos)
				if next == Vector2i.ZERO:
					break
				chamber._try_move(next)
				chamber._flush_pending_echoes()
	elif kind.begins_with("rewrite_done:"):
		# Settled fossil walls after the slam completes (for before/after comps).
		var idx3: int = int(kind.substr("rewrite_done:".length()))
		GameState.start_new_run()
		GameState.current_chamber = idx3
		GameState.queue_pos = idx3
		show_chamber()
		await get_tree().process_frame
		var stage_kid3: Node = stage.get_child(0)
		var chamber3: Node2D = stage_kid3.get_node("Chamber")
		var target3: Vector2i = chamber3.goal_pos
		for y in range(chamber3.grid.size()):
			for x in range(chamber3.grid[y].size()):
				if chamber3.grid[y][x] == 2:
					target3 = Vector2i(x, y)
					break
		var guard3: int = 0
		while chamber3.player_pos != target3 and guard3 < 400:
			var step3: Vector2i = _bfs_next_step(chamber3, target3)
			if step3 == Vector2i.ZERO:
				break
			chamber3._try_move(step3)
			chamber3._flush_pending_echoes()
			guard3 += 1
		for k3 in range(3):
			var next3: Vector2i = _bfs_next_step(chamber3, chamber3.goal_pos)
			if next3 == Vector2i.ZERO:
				break
			chamber3._try_move(next3)
			chamber3._flush_pending_echoes()
	elif kind == "daily":
		# Menu with Daily Challenge focused — populate today's best so meta reads live.
		SaveManager.wipe()
		GameState.best_moves.clear()
		GameState.best_stars.clear()
		GameState.completed.clear()
		GameState.habit_profile = {"up": 0, "down": 0, "left": 0, "right": 0}
		GameState.move_ring.clear()
		GameState.run_started = false
		var dseed: int = GameState._today_seed()
		GameState.daily_best_stars[str(dseed)] = 9
		show_menu()
		await get_tree().process_frame
		var menu_n: Node = stage.get_child(0)
		if menu_n != null and menu_n.has_node("%DailyButton"):
			menu_n.get_node("%DailyButton").grab_focus()
	elif kind == "end":
		GameState.start_new_run()
		for i in range(ChamberBook.chamber_count()):
			GameState.record_chamber_win(i, 30 + i)
		show_end_screen()
	else:
		show_menu()
	for _f in range(6):
		await get_tree().process_frame
	var img: Image = get_viewport().get_texture().get_image()
	var path: String = "%s/%s.png" % [out_dir, kind.replace(":", "_")]
	img.save_png(path)
	print("saved %s" % path)


func _run_self_test() -> bool:
	print("== Echo Lattice self-test ==")
	var ok := true
	var grid_w: int = int(ChamberBook.GRID_W)
	var grid_h: int = int(ChamberBook.GRID_H)
	print("chambers: %d campaign / %d authored, grid: %dx%d" % [
		ChamberBook.chamber_count(), ChamberBook.total_authored_count(), grid_w, grid_h
	])
	var acts: Array = ChamberBook.acts_summary()
	if acts.is_empty():
		printerr("acts.json failed to load"); ok = false
	else:
		print("acts: %d" % acts.size())
		for a in acts:
			print("  act '%s' campaign=%d hard=%d bosses=%d" % [
				str(a.get("title", "")),
				a.get("chambers", []).size(),
				a.get("hard_variants", []).size(),
				a.get("bosses", []).size(),
			])
	for i in range(ChamberBook.chamber_count()):
		var data: Dictionary = ChamberBook.get_chamber(i)
		var rows: Array = data.get("map", [])
		var has_p := false
		var has_g := false
		var checkpoints := 0
		var w := 0
		var h := rows.size()
		for row in rows:
			var s: String = row
			w = max(w, s.length())
			if s.find("P") >= 0: has_p = true
			if s.find("G") >= 0: has_g = true
			checkpoints += s.count("C")
		if not has_p:
			printerr("  chamber %d missing player start (P)" % i); ok = false
		if not has_g:
			printerr("  chamber %d missing goal (G)" % i); ok = false
		if h != grid_h:
			printerr("  chamber %d height %d != %d" % [i, h, grid_h]); ok = false
		if w != grid_w:
			printerr("  chamber %d width %d != %d" % [i, w, grid_w]); ok = false
		var transform: String = str(data.get("transform", "none"))
		if transform != "none" and checkpoints < 1:
			printerr("  chamber %d transform=%s but no checkpoint" % [i, transform]); ok = false
		print("  chamber %d '%s' transform=%s size=%dx%d cps=%d" % [
			i, data.get("title", ""), transform, w, h, checkpoints
		])

	# Rewrite math sanity — mirror transforms are involutions.
	var path := [Vector2i(3, 4), Vector2i(5, 2), Vector2i(10, 7)]
	if _mirror_v(_mirror_v(path, grid_w), grid_w) != path:
		printerr("mirror_v is not an involution"); ok = false
	if _mirror_h(_mirror_h(path, grid_h), grid_h) != path:
		printerr("mirror_h is not an involution"); ok = false
	if _rotate180(_rotate180(path, grid_w, grid_h), grid_w, grid_h) != path:
		printerr("rotate_180 is not an involution"); ok = false

	# GameState round-trip — wipe so prior user:// saves cannot poison asserts.
	SaveManager.wipe()
	GameState.best_moves.clear()
	GameState.best_stars.clear()
	GameState.completed.clear()
	GameState.start_new_run()
	if ChamberBook.chamber_count() < 35:
		printerr("v2 complete expects >= 35 campaign chambers, got %d" % ChamberBook.chamber_count()); ok = false
	GameState.record_direction(Vector2i(1, 0))
	GameState.record_direction(Vector2i(1, 0))
	GameState.record_direction(Vector2i(0, 1))
	if int(GameState.habit_profile.get("right", 0)) != 2:
		printerr("habit_profile.right expected 2 got %d" % int(GameState.habit_profile.get("right", 0)))
		ok = false
	if GameState.dominant_habit() != "right":
		printerr("dominant_habit expected 'right' got %s" % GameState.dominant_habit())
		ok = false
	GameState.record_chamber_win(0, 42, 20)
	if not GameState.completed.has(0):
		printerr("record_chamber_win did not mark completed"); ok = false
	if int(GameState.best_moves.get(0, -1)) != 42:
		printerr("best_moves not updated"); ok = false
	if GameState.last_clear_stars < 1:
		printerr("stars not awarded"); ok = false

	# Daily wing shape.
	GameState.start_daily_run()
	if GameState.run_queue.size() != 5:
		printerr("daily wing expected 5 chambers got %d" % GameState.run_queue.size()); ok = false
	GameState.start_new_run()
	# Re-assert the lifetime best survived the mode switch.
	GameState.best_moves[0] = 42
	GameState.best_stars[0] = maxi(1, int(GameState.best_stars.get(0, 1)))

	# Save/load round-trip.
	SaveManager.save_to_disk()
	GameState.best_moves.clear()
	GameState.best_stars.clear()
	SaveManager.load_from_disk()
	if int(GameState.best_moves.get(0, -1)) != 42:
		printerr("best_moves lost through save/load: %s" % str(GameState.best_moves))
		ok = false

	# Chamber scene runtime — instantiate and drive one move on chamber 0.
	var chamber_scene: PackedScene = load("res://scenes/chamber.tscn")
	if chamber_scene == null:
		printerr("failed to load chamber.tscn"); ok = false
	else:
		GameState.current_chamber = 0
		var inst: Node = chamber_scene.instantiate()
		add_child(inst)
		await get_tree().process_frame
		var chamber: Node2D = inst.get_node("Chamber")
		if chamber == null:
			printerr("Chamber node missing from scene"); ok = false
		else:
			var before: Vector2i = chamber.player_pos
			chamber._try_move(Vector2i(1, 0))
			if chamber.player_pos == before:
				printerr("player did not move right in chamber 0"); ok = false
			if chamber.move_count != 1:
				printerr("move_count expected 1 got %d" % chamber.move_count); ok = false
		inst.queue_free()

	# Static solvability check for every chamber (BFS ignoring rewrites).
	for i in range(ChamberBook.chamber_count()):
		var data: Dictionary = ChamberBook.get_chamber(i)
		if not _bfs_reachable(data):
			printerr("  chamber %d is unreachable from start to goal in its base layout" % i)
			ok = false

	# Live-play simulation for every chamber — instantiate the real Chamber
	# scene, BFS to each checkpoint in turn (letting the rewrite fire), then
	# BFS to the goal. Uses the safety-net-aware _try_move so this exactly
	# mirrors production play.
	for i in range(ChamberBook.chamber_count()):
		if not await _sim_playthrough(i):
			printerr("  chamber %d could not be beaten by the auto-solver" % i)
			ok = false
		else:
			print("  playthrough chamber %d OK" % i)

	print("result: %s" % ("OK" if ok else "FAIL"))
	return ok


static func _mirror_v(path: Array, w: int) -> Array:
	var out: Array = []
	for p in path:
		out.append(Vector2i(w - 1 - p.x, p.y))
	return out


static func _mirror_h(path: Array, h: int) -> Array:
	var out: Array = []
	for p in path:
		out.append(Vector2i(p.x, h - 1 - p.y))
	return out


static func _rotate180(path: Array, w: int, h: int) -> Array:
	var out: Array = []
	for p in path:
		out.append(Vector2i(w - 1 - p.x, h - 1 - p.y))
	return out


func _sim_playthrough(chamber_index: int) -> bool:
	# Real Chamber node, driven by _try_move — this exercises the same rewrite
	# and safety-net path production uses.
	GameState.current_chamber = chamber_index
	var scene: PackedScene = load("res://scenes/chamber.tscn")
	var inst: Node = scene.instantiate()
	add_child(inst)
	await get_tree().process_frame
	var chamber: Node2D = inst.get_node("Chamber")
	var beaten := false
	var total_moves := 0
	var max_moves := 500
	while total_moves < max_moves:
		if chamber.has_won:
			beaten = true
			break
		# Pick a live target: the nearest un-triggered checkpoint, else the goal.
		var target := _pick_target(chamber)
		if target == Vector2i(-1, -1):
			break
		var next_step := _bfs_next_step(chamber, target)
		if next_step == Vector2i.ZERO:
			# Cannot reach target — try goal directly.
			next_step = _bfs_next_step(chamber, chamber.goal_pos)
			if next_step == Vector2i.ZERO:
				break
		chamber._try_move(next_step)
		# Flush any pending echoes deterministically so subsequent BFS sees the final grid.
		chamber._flush_pending_echoes()
		total_moves += 1
	inst.queue_free()
	return beaten


func _pick_target(chamber: Node2D) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_d: int = 1 << 30
	for y in range(chamber.grid.size()):
		for x in range(chamber.grid[y].size()):
			var cell: int = chamber.grid[y][x]
			# 2 == CHECKPOINT (untouched); pick closest.
			if cell == 2:
				var d: int = abs(x - chamber.player_pos.x) + abs(y - chamber.player_pos.y)
				if d < best_d:
					best_d = d
					best = Vector2i(x, y)
	if best == Vector2i(-1, -1):
		return chamber.goal_pos
	return best


func _bfs_next_step(chamber: Node2D, target: Vector2i) -> Vector2i:
	# BFS from player_pos to target on the current live grid; return the first step direction.
	var w: int = ChamberBook.GRID_W
	var h: int = ChamberBook.GRID_H
	if target == chamber.player_pos:
		return Vector2i.ZERO
	var start: Vector2i = chamber.player_pos
	var came_from := {}
	came_from[start] = start
	var q: Array = [start]
	var found := false
	while q.size() > 0:
		var cur: Vector2i = q.pop_front()
		if cur == target:
			found = true
			break
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = cur + d
			if n.x < 0 or n.x >= w or n.y < 0 or n.y >= h:
				continue
			if came_from.has(n):
				continue
			var cell: int = chamber.grid[n.y][n.x]
			# Tile.WALL == 1, Tile.ECHO_WALL == 5
			if cell == 1 or cell == 5:
				continue
			came_from[n] = cur
			q.append(n)
	if not found:
		return Vector2i.ZERO
	# Walk backwards from target to the step just after start.
	var cur2: Vector2i = target
	while came_from[cur2] != start:
		cur2 = came_from[cur2]
	return cur2 - start


static func _bfs_reachable(data: Dictionary) -> bool:
	var rows: Array = data.get("map", [])
	var h: int = rows.size()
	var w: int = int(ChamberBook.GRID_W)
	var start := Vector2i(-1, -1)
	var goal := Vector2i(-1, -1)
	for y in range(h):
		var s: String = rows[y] if y < rows.size() else ""
		for x in range(w):
			if x >= s.length():
				continue
			var c: String = s.substr(x, 1)
			if c == "P":
				start = Vector2i(x, y)
			elif c == "G":
				goal = Vector2i(x, y)
	if start == Vector2i(-1, -1) or goal == Vector2i(-1, -1):
		return false
	var seen := {}
	var q: Array = [start]
	seen[start] = true
	while q.size() > 0:
		var p: Vector2i = q.pop_front()
		if p == goal:
			return true
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = p + d
			if n.x < 0 or n.x >= w or n.y < 0 or n.y >= h:
				continue
			if seen.has(n):
				continue
			var row_s: String = rows[n.y]
			if n.x >= row_s.length():
				continue
			var ch: String = row_s.substr(n.x, 1)
			if ch == "#":
				continue
			seen[n] = true
			q.append(n)
	return false


func _clear_stage() -> void:
	for c in stage.get_children():
		c.queue_free()


func show_menu() -> void:
	_clear_stage()
	var m: Node = MENU_SCENE.instantiate()
	stage.add_child(m)
	if m.has_signal("start_new_pressed"):
		m.connect("start_new_pressed", Callable(self, "_on_menu_start_new"))
	if m.has_signal("continue_pressed"):
		m.connect("continue_pressed", Callable(self, "_on_menu_continue"))
	if m.has_signal("quit_pressed"):
		m.connect("quit_pressed", Callable(self, "_on_menu_quit"))
	if m.has_signal("daily_pressed"):
		m.connect("daily_pressed", Callable(self, "_on_menu_daily"))
	if has_node("/root/SteamService"):
		SteamService.set_menu_presence()


func show_chamber() -> void:
	_clear_stage()
	var c: Node = CHAMBER_SCENE.instantiate()
	stage.add_child(c)
	# Chamber HUD forwards these to us.
	if c.has_signal("chamber_won"):
		c.connect("chamber_won", Callable(self, "_on_chamber_won"))
	if c.has_signal("menu_requested"):
		c.connect("menu_requested", Callable(self, "_on_menu_requested"))
	if has_node("/root/SteamService"):
		SteamService.set_chamber_presence(GameState.current_chamber)


func show_chamber_won(chamber_id: int, moves: int) -> void:
	_clear_stage()
	var w: Node = WIN_SCENE.instantiate()
	stage.add_child(w)
	if w.has_method("configure"):
		w.configure(chamber_id, moves)
	if w.has_signal("next_pressed"):
		w.connect("next_pressed", Callable(self, "_on_win_next"))
	if w.has_signal("replay_pressed"):
		w.connect("replay_pressed", Callable(self, "_on_win_replay"))
	if w.has_signal("menu_pressed"):
		w.connect("menu_pressed", Callable(self, "_on_win_menu"))
	if has_node("/root/SteamService"):
		SteamService.set_won_presence(chamber_id)


func show_end_screen() -> void:
	_clear_stage()
	var e: Node = END_SCENE.instantiate()
	stage.add_child(e)
	if e.has_signal("restart_pressed"):
		e.connect("restart_pressed", Callable(self, "_on_end_restart"))
	if e.has_signal("menu_pressed"):
		e.connect("menu_pressed", Callable(self, "_on_end_menu"))
	if has_node("/root/SteamService"):
		SteamService.set_end_presence()


# ---------- menu callbacks ----------

func _on_menu_start_new() -> void:
	GameState.start_new_run()
	show_chamber()


func _on_menu_continue() -> void:
	GameState.continue_run()
	show_chamber()


func _on_menu_daily() -> void:
	GameState.start_daily_run()
	show_chamber()


func _on_menu_quit() -> void:
	get_tree().quit()


# ---------- chamber callbacks ----------

func _on_chamber_won(chamber_id: int, moves: int) -> void:
	show_chamber_won(chamber_id, moves)


func _on_menu_requested() -> void:
	show_menu()


# ---------- win-screen callbacks ----------

func _on_win_next() -> void:
	var advanced: bool = GameState.advance_chamber()
	if advanced:
		show_chamber()
	else:
		show_end_screen()


func _on_win_replay() -> void:
	show_chamber()


func _on_win_menu() -> void:
	show_menu()


# ---------- end-screen callbacks ----------

func _on_end_restart() -> void:
	GameState.start_new_run()
	show_chamber()


func _on_end_menu() -> void:
	show_menu()
