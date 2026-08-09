extends Node
##
## Main — root router for menus, modes, chambers, results.
##

const MENU_SCENE:        PackedScene = preload("res://scenes/menu.tscn")
const MODE_SELECT_SCENE: PackedScene = preload("res://scenes/mode_select.tscn")
const MODE_STUB_SCENE:   PackedScene = preload("res://scenes/mode_stub.tscn")
const CHAMBER_SCENE:     PackedScene = preload("res://scenes/chamber.tscn")
const WIN_SCENE:         PackedScene = preload("res://scenes/chamber_won.tscn")
const DAILY_RESULT_SCENE: PackedScene = preload("res://scenes/daily_result.tscn")
const END_SCENE:         PackedScene = preload("res://scenes/end_screen.tscn")

@onready var stage: Node = $Stage

var _pending_route: Dictionary = {}


func _ready() -> void:
	var all_args: PackedStringArray = OS.get_cmdline_user_args()
	for a in OS.get_cmdline_args():
		all_args.append(a)
	if all_args.has("--selftest"):
		var ok: bool = await _run_self_test()
		get_tree().quit(0 if ok else 1)
		return
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
		show_menu()
	elif kind == "modes":
		show_mode_select()
	elif kind.begins_with("chamber:"):
		ModeService.active_mode = ModeService.Mode.CAMPAIGN
		GameState.current_chamber = int(kind.substr(8))
		show_chamber()
	elif kind.begins_with("won:"):
		var idx: int = int(kind.substr(4))
		ModeService.active_mode = ModeService.Mode.CAMPAIGN
		GameState.current_chamber = idx
		show_chamber_won(idx, 42)
	elif kind.begins_with("rewrite:"):
		var idx2: int = int(kind.substr(8))
		ModeService.active_mode = ModeService.Mode.CAMPAIGN
		GameState.current_chamber = idx2
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
			chamber._flush_pending_echoes()
			guard += 1
		for k in range(3):
			var next: Vector2i = _bfs_next_step(chamber, chamber.goal_pos)
			if next == Vector2i.ZERO:
				break
			chamber._try_move(next)
			chamber._flush_pending_echoes()
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
	print("== Echo Lattice self-test (onboard + modes) ==")
	var ok := true
	var grid_w: int = int(ChamberBook.GRID_W)
	var grid_h: int = int(ChamberBook.GRID_H)
	print("chambers: %d, grid: %dx%d" % [ChamberBook.chamber_count(), grid_w, grid_h])

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

	# Onboarding contract: chamber 2 is the spectacle rewrite.
	var c2: Dictionary = ChamberBook.get_chamber(2)
	if str(c2.get("transform", "none")) == "none":
		printerr("chamber 2 must rewrite (spectacle)"); ok = false
	if not bool(c2.get("spectacle", false)) and str(c2.get("title", "")).find("Mirror") < 0:
		printerr("chamber 2 should be the Mirror Birth spectacle"); ok = false
	# Chambers 0–1 stay silent so the first walls are the learn-me beat.
	if str(ChamberBook.get_chamber(0).get("transform", "")) != "none":
		printerr("chamber 0 should be transform=none"); ok = false
	if str(ChamberBook.get_chamber(1).get("transform", "")) != "none":
		printerr("chamber 1 should be transform=none"); ok = false

	# Induction path length budget — BFS shortest paths for chambers 0..2 must be short.
	var budget_moves := 0
	for i in range(3):
		var sp: int = _shortest_path_len(ChamberBook.get_chamber(i))
		if sp < 0:
			printerr("chamber %d has no path" % i); ok = false
		else:
			budget_moves += sp
			print("  induction shortest path chamber %d = %d" % [i, sp])
	if budget_moves > 90:
		printerr("induction shortest-path sum %d exceeds 90-move / ~90s budget" % budget_moves)
		ok = false
	else:
		print("  induction path budget OK (%d steps across chambers 0-2)" % budget_moves)

	# Rewrite math sanity.
	var path := [Vector2i(3, 4), Vector2i(5, 2), Vector2i(10, 7)]
	if _mirror_v(_mirror_v(path, grid_w), grid_w) != path:
		printerr("mirror_v is not an involution"); ok = false
	if _mirror_h(_mirror_h(path, grid_h), grid_h) != path:
		printerr("mirror_h is not an involution"); ok = false
	if _rotate180(_rotate180(path, grid_w, grid_h), grid_w, grid_h) != path:
		printerr("rotate_180 is not an involution"); ok = false

	# ModeService daily seed determinism.
	var s1: int = ModeService.daily_seed_for("2026-08-09")
	var s2: int = ModeService.daily_seed_for("2026-08-09")
	var s3: int = ModeService.daily_seed_for("2026-08-10")
	if s1 != s2:
		printerr("daily seed not stable"); ok = false
	if s1 == s3:
		printerr("daily seed collided across dates"); ok = false
	var ch_a: int = ModeService.pick_daily_chamber(s1)
	var ch_b: int = ModeService.pick_daily_chamber(s1)
	if ch_a != ch_b:
		printerr("daily chamber pick unstable"); ok = false
	if not ModeService.DAILY_POOL.has(ch_a):
		printerr("daily chamber not in pool"); ok = false
	print("  daily seed OK (%d → chamber %d)" % [s1, ch_a])

	# Mode begin / clear routing.
	var camp: Dictionary = ModeService.begin_mode(ModeService.Mode.CAMPAIGN)
	if int(camp.get("chamber", -1)) != 0:
		printerr("campaign should start at chamber 0"); ok = false
	var daily: Dictionary = ModeService.begin_mode(ModeService.Mode.DAILY)
	if not ModeService.DAILY_POOL.has(int(daily.get("chamber", -1))):
		printerr("daily begin picked outside pool"); ok = false
	var end_payload: Dictionary = ModeService.on_chamber_cleared(int(daily.get("chamber", 0)), 12)
	if str(end_payload.get("kind", "")) != "daily_done":
		printerr("daily clear should route daily_done"); ok = false
	var endls: Dictionary = ModeService.begin_mode(ModeService.Mode.ENDLESS)
	if not ModeService.ENDLESS_POOL.has(int(endls.get("chamber", -1))):
		printerr("endless begin outside pool"); ok = false
	var shift: Dictionary = ModeService.on_chamber_cleared(int(endls.get("chamber", 0)), 20)
	if str(shift.get("kind", "")) != "endless_next":
		printerr("endless clear should route endless_next"); ok = false
	if int(shift.get("clears", 0)) != 1:
		printerr("endless clears should be 1"); ok = false
	print("  mode routing OK")

	# Stubs flagged.
	if not ModeService.is_stub(ModeService.Mode.ZEN):
		printerr("zen should be stub"); ok = false
	if not ModeService.is_stub(ModeService.Mode.SPEEDRUN):
		printerr("speedrun should be stub"); ok = false
	if not ModeService.is_stub(ModeService.Mode.HOTSEAT):
		printerr("hotseat should be stub"); ok = false

	# Diegetic lines load.
	if DiegeticPA._lines_by_id.is_empty():
		printerr("diegetic lines failed to load"); ok = false
	else:
		print("  diegetic lines: %d" % DiegeticPA._lines_by_id.size())

	# GameState / save round-trip including tutorial flags + modes.
	ModeService.begin_mode(ModeService.Mode.CAMPAIGN)
	GameState.start_new_run()
	GameState.record_direction(Vector2i(1, 0))
	GameState.record_direction(Vector2i(1, 0))
	GameState.record_direction(Vector2i(0, 1))
	if int(GameState.habit_profile.get("right", 0)) != 2:
		printerr("habit_profile.right expected 2"); ok = false
	GameState.set_tutorial_flag("flag.test_roundtrip")
	GameState.record_chamber_win(2, 42)
	if not GameState.induction_complete:
		printerr("clearing chamber 2 should set induction_complete"); ok = false
	SaveManager.save_to_disk()
	GameState.tutorial_flags.clear()
	GameState.induction_complete = false
	GameState.best_moves.clear()
	ModeService.endless_best = -1
	SaveManager.load_from_disk()
	if not GameState.has_tutorial_flag("flag.test_roundtrip"):
		printerr("tutorial flag lost through save/load"); ok = false
	if not GameState.induction_complete:
		printerr("induction_complete lost through save/load"); ok = false
	if int(GameState.best_moves.get(2, -1)) != 42:
		printerr("best_moves lost through save/load"); ok = false

	# Live scene + self-trap undo path on chamber 2.
	var chamber_scene: PackedScene = load("res://scenes/chamber.tscn")
	if chamber_scene == null:
		printerr("failed to load chamber.tscn"); ok = false
	else:
		ModeService.active_mode = ModeService.Mode.CAMPAIGN
		GameState.current_chamber = 0
		var inst: Node = chamber_scene.instantiate()
		add_child(inst)
		await get_tree().process_frame
		var chamber: Node2D = inst.get_node("Chamber")
		if chamber == null:
			printerr("Chamber node missing"); ok = false
		else:
			var before: Vector2i = chamber.player_pos
			chamber._try_move(Vector2i(1, 0))
			if chamber.player_pos == before:
				printerr("player did not move right in chamber 0"); ok = false
		inst.queue_free()

	# Self-trap undo: drive chamber 2 to checkpoint, bump an echo wall, undo.
	ModeService.active_mode = ModeService.Mode.CAMPAIGN
	GameState.current_chamber = 2
	var inst2: Node = chamber_scene.instantiate()
	add_child(inst2)
	await get_tree().process_frame
	var ch2n: Node2D = inst2.get_node("Chamber")
	var target2 := _pick_target(ch2n)
	var guard2 := 0
	while ch2n.player_pos != target2 and guard2 < 400:
		var step2: Vector2i = _bfs_next_step(ch2n, target2)
		if step2 == Vector2i.ZERO:
			break
		ch2n._try_move(step2)
		ch2n._flush_pending_echoes()
		guard2 += 1
	if ch2n.rewrites_done < 1:
		printerr("chamber 2 rewrite did not fire during self-trap test"); ok = false
	else:
		# Probe four directions for a blocked echo bump.
		var bumped := false
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var npos: Vector2i = ch2n.player_pos + d
			if ch2n._in_bounds(npos) and ch2n.grid[npos.y][npos.x] == 5:
				ch2n._try_move(d)
				bumped = true
				break
		if bumped and not ch2n.self_trap_armed:
			printerr("self-trap not armed after echo bump"); ok = false
		elif bumped:
			print("  self-trap undo arm OK")
		else:
			print("  self-trap: no adjacent echo to bump (acceptable)")
	inst2.queue_free()

	# Solvability + full playthrough.
	for i in range(ChamberBook.chamber_count()):
		var data2: Dictionary = ChamberBook.get_chamber(i)
		if not _bfs_reachable(data2):
			printerr("  chamber %d unreachable in base layout" % i)
			ok = false
	for i in range(ChamberBook.chamber_count()):
		if not await _sim_playthrough(i):
			printerr("  chamber %d could not be beaten by the auto-solver" % i)
			ok = false
		else:
			print("  playthrough chamber %d OK" % i)

	# Mode select scene instantiates.
	var ms: PackedScene = load("res://scenes/mode_select.tscn")
	if ms == null:
		printerr("mode_select.tscn missing"); ok = false
	else:
		var msi: Node = ms.instantiate()
		add_child(msi)
		await get_tree().process_frame
		msi.queue_free()
		print("  mode_select scene OK")

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


func _shortest_path_len(data: Dictionary) -> int:
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
		return -1
	var dist := {}
	dist[start] = 0
	var q: Array = [start]
	while q.size() > 0:
		var p: Vector2i = q.pop_front()
		if p == goal:
			return int(dist[p])
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = p + d
			if n.x < 0 or n.x >= w or n.y < 0 or n.y >= h:
				continue
			if dist.has(n):
				continue
			var row_s: String = rows[n.y]
			if n.x >= row_s.length():
				continue
			if row_s.substr(n.x, 1) == "#":
				continue
			dist[n] = int(dist[p]) + 1
			q.append(n)
	return -1


func _sim_playthrough(chamber_index: int) -> bool:
	ModeService.active_mode = ModeService.Mode.CAMPAIGN
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
		var target := _pick_target(chamber)
		if target == Vector2i(-1, -1):
			break
		var next_step := _bfs_next_step(chamber, target)
		if next_step == Vector2i.ZERO:
			next_step = _bfs_next_step(chamber, chamber.goal_pos)
			if next_step == Vector2i.ZERO:
				break
		chamber._try_move(next_step)
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
			if cell == 2:
				var d: int = abs(x - chamber.player_pos.x) + abs(y - chamber.player_pos.y)
				if d < best_d:
					best_d = d
					best = Vector2i(x, y)
	if best == Vector2i(-1, -1):
		return chamber.goal_pos
	return best


func _bfs_next_step(chamber: Node2D, target: Vector2i) -> Vector2i:
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
			if cell == 1 or cell == 5:
				continue
			came_from[n] = cur
			q.append(n)
	if not found:
		return Vector2i.ZERO
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
	DiegeticPA.clear()
	_clear_stage()
	var m: Node = MENU_SCENE.instantiate()
	stage.add_child(m)
	if m.has_signal("play_pressed"):
		m.connect("play_pressed", Callable(self, "_on_menu_play"))
	if m.has_signal("continue_pressed"):
		m.connect("continue_pressed", Callable(self, "_on_menu_continue"))
	if m.has_signal("quit_pressed"):
		m.connect("quit_pressed", Callable(self, "_on_menu_quit"))


func show_mode_select() -> void:
	DiegeticPA.clear()
	_clear_stage()
	var m: Node = MODE_SELECT_SCENE.instantiate()
	stage.add_child(m)
	m.connect("mode_chosen", Callable(self, "_on_mode_chosen"))
	m.connect("back_pressed", Callable(self, "show_menu"))


func show_mode_stub(mode_id: String) -> void:
	_clear_stage()
	var s: Node = MODE_STUB_SCENE.instantiate()
	stage.add_child(s)
	if s.has_method("configure"):
		s.configure(mode_id)
	s.connect("back_pressed", Callable(self, "show_mode_select"))


func show_chamber() -> void:
	_clear_stage()
	var c: Node = CHAMBER_SCENE.instantiate()
	stage.add_child(c)
	if c.has_signal("chamber_won"):
		c.connect("chamber_won", Callable(self, "_on_chamber_won"))
	if c.has_signal("menu_requested"):
		c.connect("menu_requested", Callable(self, "_on_menu_requested"))


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


func show_daily_result(payload: Dictionary) -> void:
	_clear_stage()
	var d: Node = DAILY_RESULT_SCENE.instantiate()
	stage.add_child(d)
	if d.has_method("configure"):
		d.configure(payload)
	d.connect("again_pressed", Callable(self, "_on_daily_again"))
	d.connect("menu_pressed", Callable(self, "_on_end_menu"))


func show_end_screen() -> void:
	_clear_stage()
	var e: Node = END_SCENE.instantiate()
	stage.add_child(e)
	if e.has_signal("restart_pressed"):
		e.connect("restart_pressed", Callable(self, "_on_end_restart"))
	if e.has_signal("menu_pressed"):
		e.connect("menu_pressed", Callable(self, "_on_end_menu"))


func _on_menu_play() -> void:
	show_mode_select()


func _on_menu_continue() -> void:
	ModeService.continue_campaign()
	show_chamber()


func _on_menu_quit() -> void:
	get_tree().quit()


func _on_mode_chosen(mode_id: String) -> void:
	var mode: int = ModeService.mode_from_id(mode_id)
	if ModeService.is_stub(mode):
		show_mode_stub(mode_id)
		return
	if not ModeService.is_playable(mode):
		show_mode_select()
		return
	ModeService.begin_mode(mode)
	if mode == ModeService.Mode.CAMPAIGN and not GameState.induction_complete:
		DiegeticPA.play("title_card.induction")
	show_chamber()


func _on_chamber_won(chamber_id: int, moves: int) -> void:
	_pending_route = {"chamber_id": chamber_id, "moves": moves}
	show_chamber_won(chamber_id, moves)


func _on_menu_requested() -> void:
	show_menu()


func _on_win_next() -> void:
	var cleared_id: int = int(_pending_route.get("chamber_id", GameState.current_chamber))
	var moves: int = int(_pending_route.get("moves", 0))
	_pending_route = {}
	var route: Dictionary = ModeService.on_chamber_cleared(cleared_id, moves)
	match str(route.get("kind", "")):
		"next":
			show_chamber()
		"endless_next":
			DiegeticPA.play_text("SHIFT %d" % int(route.get("clears", 0)), "pa", 2.0)
			show_chamber()
		"daily_done":
			show_daily_result(route)
		"end":
			show_end_screen()
		_:
			show_menu()


func _on_win_replay() -> void:
	show_chamber()


func _on_win_menu() -> void:
	show_menu()


func _on_daily_again() -> void:
	ModeService.begin_mode(ModeService.Mode.DAILY)
	show_chamber()


func _on_end_restart() -> void:
	ModeService.begin_mode(ModeService.Mode.CAMPAIGN)
	show_chamber()


func _on_end_menu() -> void:
	ModeService.reset_active()
	show_menu()
