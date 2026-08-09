extends Node
##
## Main — the root router.
##
## Owns a single container child which we swap between menu, chamber, chamber win,
## and wing-colophon screens. Keeps scene loads explicit and Godot-project-simple.
##

const MENU_SCENE:     PackedScene = preload("res://scenes/menu.tscn")
const CHAMBER_SCENE:  PackedScene = preload("res://scenes/chamber.tscn")
const WIN_SCENE:      PackedScene = preload("res://scenes/chamber_won.tscn")
const END_SCENE:      PackedScene = preload("res://scenes/end_screen.tscn")
const MUSEUM_SCENE:   PackedScene = preload("res://scenes/museum_screen.tscn")
const SUBTITLE_SCENE: PackedScene = preload("res://scenes/ui/subtitle_overlay.tscn")
const BOOT_SCENE:     PackedScene = preload("res://scenes/boot_title.tscn")

@onready var stage: Node = $Stage

var _subtitle_overlay: CanvasLayer = null
var _boot_shown: bool = false


func _ready() -> void:
	_ensure_subtitle_overlay()
	var all_args: PackedStringArray = OS.get_cmdline_user_args()
	for a in OS.get_cmdline_args():
		all_args.append(a)
	if all_args.has("--battery"):
		DeckProfile.set_battery_mode(true)
	# Headless self-test — run when launched with `-- --selftest`.
	if all_args.has("--selftest"):
		var ok: bool = await _run_self_test()
		get_tree().quit(0 if ok else 1)
		return
	# Steam Deck 1280×800 / 16:10 layout QA — `-- --deck-layout-check`.
	if all_args.has("--deck-layout-check"):
		var deck_ok: bool = await _run_deck_layout_check()
		get_tree().quit(0 if deck_ok else 1)
		return
	# Screenshot capture — `-- --screenshot menu|chamber:N|won:N|end --out DIR`.
	# SEC-03: `--out` must resolve under user:// or the project tree (see
	# `_resolve_screenshot_out_dir`). Capture scripts under tools/ are non-retail.
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
		var safe_out: String = _resolve_screenshot_out_dir(out_dir)
		if safe_out == "":
			printerr("screenshot --out rejected (must be user:// or under project root): %s" % out_dir)
			get_tree().quit(2)
			return
		await _capture_screenshot(kind, safe_out)
		get_tree().quit(0)
		return
	# Cold-boot Field Ledger title plate once, then menu (QW-1).
	await _show_boot_title_if_needed()
	show_menu()


func _show_boot_title_if_needed() -> void:
	if _boot_shown:
		return
	_boot_shown = true
	_clear_stage()
	var boot: Node = BOOT_SCENE.instantiate()
	stage.add_child(boot)
	if boot.has_signal("finished"):
		await boot.finished
	else:
		await get_tree().create_timer(1.2).timeout
	if is_instance_valid(boot):
		boot.queue_free()
	# Let the free apply before menu instantiate.
	await get_tree().process_frame


func _ensure_subtitle_overlay() -> void:
	if _subtitle_overlay != null and is_instance_valid(_subtitle_overlay):
		return
	_subtitle_overlay = SUBTITLE_SCENE.instantiate()
	add_child(_subtitle_overlay)


## SEC-03: allow only user:// or absolute paths inside the project directory.
## Rejects `..`, empty, and absolute paths outside those roots.
static func _resolve_screenshot_out_dir(out_dir: String) -> String:
	var raw := out_dir.strip_edges()
	if raw == "":
		return ""
	if raw.find("..") >= 0:
		return ""
	if raw.begins_with("user://"):
		var rest := raw.substr("user://".length())
		if rest.find("..") >= 0 or rest.begins_with("/") or rest.begins_with("\\"):
			return ""
		# Normalize to a concrete absolute path under userdata.
		return ProjectSettings.globalize_path(raw)
	var project_root: String = ProjectSettings.globalize_path("res://").trim_suffix("/").trim_suffix("\\")
	var abs_out: String = raw
	if not raw.is_absolute_path():
		abs_out = project_root.path_join(raw)
	abs_out = abs_out.simplify_path()
	var root_norm: String = project_root.simplify_path()
	if abs_out == root_norm:
		return abs_out
	var prefix: String = root_norm.rstrip("/\\") + "/"
	var abs_norm: String = abs_out.replace("\\", "/")
	var prefix_norm: String = prefix.replace("\\", "/")
	if abs_norm.begins_with(prefix_norm):
		return abs_out
	return ""


static func _safe_screenshot_filename(kind: String) -> String:
	var out := ""
	for i in range(kind.length()):
		var ch: String = kind.substr(i, 1)
		var code: int = ch.unicode_at(0)
		var ok_char := (
			(code >= 48 and code <= 57) # 0-9
			or (code >= 65 and code <= 90) # A-Z
			or (code >= 97 and code <= 122) # a-z
			or ch == "_" or ch == "-" or ch == "."
		)
		if ch == ":":
			out += "_"
		elif ok_char:
			out += ch
		else:
			out += "_"
	if out == "" or out == "." or out == "..":
		return "shot"
	if out.length() > 64:
		out = out.substr(0, 64)
	return out


func _capture_screenshot(kind: String, out_dir: String) -> void:
	DirAccess.make_dir_recursive_absolute(out_dir)
	if kind == "menu":
		# Fresh-boot menu: no prior save, so Continue is disabled.
		SaveManager.wipe()
		GameState.current_chamber = 0
		GameState.best_moves.clear()
		GameState.completed.clear()
		GameState.run_cleared.clear()
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
		GameState.habit_identity_unlocked = true
		# Seed a legible habit answer so media agents capture Clear Stamp copy.
		GameState.note_habit_answer("looper", "fossilize_hot_cell", 2)
		show_chamber_won(idx, 42)
	elif kind.begins_with("rewrite:"):
		# Drive to the first checkpoint, then freeze the origami slam.
		# `rewrite:CHAMBER` freezes at 0.55 (lift/slot trailer still).
		# `rewrite:CHAMBER:T` freezes at normalized slam progress T (GIF frames).
		var rewrite_rest: String = kind.substr("rewrite:".length())
		var rewrite_parts: PackedStringArray = rewrite_rest.split(":")
		var idx2: int = int(rewrite_parts[0]) if rewrite_parts.size() > 0 else 2
		var freeze_t: float = 0.55
		if rewrite_parts.size() > 1:
			freeze_t = clampf(float(rewrite_parts[1]), 0.0, 1.0)
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
			chamber.freeze_rewrite_at(freeze_t)
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
		GameState.run_cleared.clear()
		GameState.habit_profile = {"up": 0, "down": 0, "left": 0, "right": 0}
		GameState.move_ring.clear()
		GameState.run_started = false
		var entry: Dictionary = GameState.today_daily_entry()
		var dkey: String = str(entry.get("date", GameState._today_label()))
		GameState.daily_best_stars[dkey] = 9
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
	# Menu paper-slot settle is ≤180 ms — wait enough frames at 60 Hz.
	var settle_frames: int = 16 if kind == "menu" or kind == "daily" else 6
	for _f in range(settle_frames):
		await get_tree().process_frame
	var img: Image = get_viewport().get_texture().get_image()
	var safe_name: String = _safe_screenshot_filename(kind)
	var path: String = "%s/%s.png" % [out_dir, safe_name]
	img.save_png(path)
	print("saved %s" % path)


func _run_deck_layout_check() -> bool:
	print("== Echo Lattice Steam Deck layout check (1280x800 / 16:10) ==")
	var ok := true
	DeckProfile.force_deck_window_for_qa()
	for _warm in range(4):
		await get_tree().process_frame

	var screens: Array = [
		{"name": "menu", "fn": Callable(self, "show_menu")},
		{"name": "chamber", "fn": Callable(self, "_deck_show_chamber")},
		{"name": "won", "fn": Callable(self, "_deck_show_won")},
		{"name": "end", "fn": Callable(self, "_deck_show_end")},
	]
	for entry in screens:
		var show_fn: Callable = entry["fn"]
		show_fn.call()
		for _f in range(6):
			await get_tree().process_frame
		var report: Dictionary = DeckProfile.layout_report(self)
		var aspect: float = float(report.get("aspect", 0.0))
		print("  %s viewport=%sx%s aspect=%.3f offenders=%d" % [
			str(entry["name"]),
			str(report.get("viewport", {}).get("w", "?")),
			str(report.get("viewport", {}).get("h", "?")),
			aspect,
			(report.get("offenders", []) as Array).size(),
		])
		## With stretch/aspect=expand, Deck native window yields ~16:10 logical size.
		if absf(aspect - 1.6) > 0.08:
			printerr("  %s aspect %.3f is not near 16:10" % [str(entry["name"]), aspect])
			ok = false
		if not bool(report.get("ok", false)):
			printerr("  %s layout offenders: %s" % [str(entry["name"]), str(report.get("offenders", []))])
			ok = false
		## Glyph path must not require a keyboard — footer / HUD must resolve.
		if str(entry["name"]) == "menu" and has_node("/root/InputGlyphs"):
			InputGlyphs.last_device = InputGlyphs.Device.GAMEPAD
			var line: String = InputGlyphs.controls_line()
			if line.find("D-Pad") < 0 and line.find("Stick") < 0:
				printerr("  menu gamepad glyph line missing stick/D-Pad: %s" % line)
				ok = false
			if line.to_lower().find("wasd") >= 0:
				printerr("  menu still showing WASD while gamepad preferred")
				ok = false
		## Field Index plate must frame index actions (not float empty / clip brand).
		if str(entry["name"]) == "menu":
			if not _verify_menu_field_index_layout():
				ok = false

	## No on-screen keyboard requirement: project must not instantiate text fields.
	if _tree_has_text_entry(self):
		printerr("  found LineEdit/TextEdit — OSK would be required on Deck")
		ok = false
	else:
		print("  OSK: not required (no text-entry controls)")

	print("  TDP target (doc): %dW verified / %dW battery (active recommend %dW)" % [
		DeckProfile.TDP_TARGET_WATTS, DeckProfile.TDP_BATTERY_WATTS,
		DeckProfile.recommended_tdp_watts()
	])
	print("  FPS target: %d verified / %d battery" % [
		DeckProfile.TARGET_FPS_VERIFIED, DeckProfile.TARGET_FPS_BATTERY
	])
	if DeckProfile.TDP_TARGET_WATTS != 7 or DeckProfile.TARGET_FPS_VERIFIED != 60:
		printerr("  DeckProfile Verified defaults must be 60 FPS @ 7W")
		ok = false
	print("result: %s" % ("OK" if ok else "FAIL"))
	return ok


func _verify_menu_field_index_layout() -> bool:
	## Assert CardColumn actions sit inside the drawn Field Index plate.
	var menu_node: Node = null
	if stage != null:
		for child in stage.get_children():
			if child != null and child.has_method("verify_field_index_layout"):
				menu_node = child
				break
	if menu_node == null:
		printerr("  menu Field Index: menu node missing verify_field_index_layout")
		return false
	var ok: bool = bool(menu_node.call("verify_field_index_layout"))
	if ok:
		print("  menu Field Index: actions framed inside card")
	else:
		printerr("  menu Field Index: layout failed (card vs CardColumn)")
	return ok


func _deck_show_chamber() -> void:
	GameState.start_new_run()
	GameState.current_chamber = 0
	GameState.queue_pos = 0
	show_chamber()


func _deck_show_won() -> void:
	GameState.start_new_run()
	GameState.current_chamber = 0
	GameState.queue_pos = 0
	GameState.last_clear_stars = 3
	GameState.last_clear_bfs_par = 20
	GameState.best_moves[0] = 24
	GameState.best_stars[0] = 3
	show_chamber_won(0, 24)


func _deck_show_end() -> void:
	GameState.start_new_run()
	for i in range(mini(3, ChamberBook.chamber_count())):
		GameState.record_chamber_win(i, 30 + i)
	show_end_screen()


func _tree_has_text_entry(node: Node) -> bool:
	if node is LineEdit or node is TextEdit:
		return true
	for c in node.get_children():
		if _tree_has_text_entry(c):
			return true
	return false


func _run_self_test() -> bool:
	print("== Echo Lattice self-test%s ==" % (" [DEMO]" if DemoBuild.is_demo() else ""))
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
	if DemoBuild.is_demo():
		ok = _selftest_demo_scope(acts) and ok
	ok = _selftest_onboarding_path() and ok
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
	GameState.identity_stamps.clear()
	GameState.last_identity_stamp = {}
	GameState.habit_identity_unlocked = false
	GameState.clear_museum()
	GameState.tutorial_flags.clear()
	GameState.start_new_run()
	if DemoBuild.is_demo():
		var expect_n: int = DemoBuild.allowed_campaign_ids().size()
		if ChamberBook.chamber_count() != expect_n:
			printerr("demo expects %d campaign chambers, got %d" % [
				expect_n, ChamberBook.chamber_count()
			])
			ok = false
		if GameState.run_queue.size() != expect_n:
			printerr("demo run_queue expected %d got %d" % [expect_n, GameState.run_queue.size()])
			ok = false
	elif ChamberBook.chamber_count() < 35:
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

	# Habit rewrite wire — signature → archetype bias → soft/hard gated cells.
	ok = _selftest_habit_rewrite_wire() and ok

	GameState.record_chamber_win(0, 42, 20, {}, [Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)], 0)
	if not GameState.completed.has(0):
		printerr("record_chamber_win did not mark completed"); ok = false
	if int(GameState.best_moves.get(0, -1)) != 42:
		printerr("best_moves not updated"); ok = false
	if GameState.last_clear_stars < 1:
		printerr("stars not awarded"); ok = false
	if GameState.is_habit_identity_visible():
		printerr("habit identity should stay sealed before Mirror Birth"); ok = false
	if GameState.museum_count() != 1:
		printerr("museum archive expected 1 self after clear, got %d" % GameState.museum_count()); ok = false
	if GameState.last_museum_self.is_empty():
		printerr("last_museum_self empty after clear"); ok = false
	elif str(GameState.last_museum_self.get("outcome", "")) != "clear":
		printerr("museum self outcome must be clear"); ok = false
	# Cap ring buffer — 49th clear drops oldest.
	for i in range(MuseumOfSelves.DEFAULT_CAP):
		GameState.record_chamber_win(0, 40, 20, {}, [Vector2i(i % 8, 1), Vector2i((i + 1) % 8, 1)], 0)
	if GameState.museum_count() > MuseumOfSelves.DEFAULT_CAP:
		printerr("museum cap exceeded: %d" % GameState.museum_count()); ok = false
	SaveManager.save_to_disk()
	var museum_snapshot: int = GameState.museum_count()
	GameState.clear_museum()
	if not SaveManager.load_from_disk():
		printerr("museum save reload failed"); ok = false
	elif GameState.museum_count() != museum_snapshot:
		printerr("museum did not persist across save/load (%d vs %d)" % [
			GameState.museum_count(), museum_snapshot
		])
		ok = false

	# Identity ledger stamp — intentional silhouette outranks thrash scribble.
	var face: Array = [
		Vector2i(2, 1), Vector2i(4, 1),
		Vector2i(1, 2), Vector2i(2, 2), Vector2i(4, 2), Vector2i(5, 2),
		Vector2i(1, 3), Vector2i(3, 3), Vector2i(5, 3),
		Vector2i(1, 4), Vector2i(5, 4),
		Vector2i(2, 5), Vector2i(3, 5), Vector2i(4, 5),
		Vector2i(2, 6), Vector2i(4, 6),
	]
	var scribble: Array = [
		Vector2i(0, 0), Vector2i(3, 1), Vector2i(7, 4), Vector2i(2, 6),
		Vector2i(11, 2), Vector2i(1, 9), Vector2i(8, 8),
	]
	var face_stamp: Dictionary = IdentityStamp.evaluate(face, "mirror_v", 18, 20, {
		"teaches": "identity", "identity": "induction_signature", "role": "boss", "slug": "identity_induction"
	})
	var scribble_stamp: Dictionary = IdentityStamp.evaluate(scribble, "mirror_v", 8, 28, {
		"teaches": "identity", "identity": "induction_signature", "role": "boss"
	})
	if float(face_stamp.get("portrait", 0.0)) <= float(scribble_stamp.get("portrait", 0.0)):
		printerr("identity portrait failed to prefer intentional silhouette"); ok = false
	if IdentityStamp.merge_stars(1, face_stamp) < 2:
		printerr("identity stamp should be able to lift stars via portrait"); ok = false
	GameState.reveal_habit_identity()
	if not GameState.is_habit_identity_visible():
		printerr("habit identity should unlock after Mirror Birth reveal"); ok = false

	# Daily wing: calendar / catalog authority (not YYYYMMDD-only shuffle).
	GameState.start_daily_run()
	var daily_entry: Dictionary = DailyCalendar.today_utc()
	var daily_n: int = mini(5, maxi(1, ChamberBook.daily_eligible_indices().size()))
	if GameState.run_queue.size() != daily_n and GameState.run_queue.size() != mini(5, ChamberBook.chamber_count()):
		# Wing is capped by eligible pool (or campaign fallback); accept either bound.
		if GameState.run_queue.is_empty() or GameState.run_queue.size() > 5:
			printerr("daily wing size unexpected: %d" % GameState.run_queue.size()); ok = false
	if str(daily_entry.get("source", "")) == "calendar_90" or str(daily_entry.get("source", "")) == "catalog_hash":
		if GameState.daily_source != str(daily_entry.get("source", "")):
			printerr("daily_source mismatch"); ok = false
		if GameState.daily_friend_code != str(daily_entry.get("friend_code", "")):
			printerr("daily_friend_code not wired from calendar"); ok = false
		var featured: int = ChamberBook.index_for_content_id(str(daily_entry.get("chamber_id", "")))
		if featured >= 0 and GameState.run_queue.size() > 0 and int(GameState.run_queue[0]) != featured:
			printerr("daily wing must lead with calendar chamber"); ok = false
	for idx in GameState.run_queue:
		var ch: Dictionary = ChamberBook.get_chamber(int(idx))
		if ch.is_empty():
			printerr("daily wing has unresolvable chamber %s" % str(idx)); ok = false
			continue
		var cid: String = str(ch.get("content_id", ""))
		# Featured may be force-included; fillers must be daily_eligible.
		if cid != GameState.daily_chamber_id and not bool(ch.get("daily_eligible", false)):
			printerr("daily wing filler not daily_eligible: %s" % cid); ok = false
	# Endless: seeded catalog batch + pressure climb (never marks wing complete).
	GameState.start_endless_run()
	if GameState.run_mode != "endless":
		printerr("start_endless_run did not set run_mode"); ok = false
	if GameState.run_queue.is_empty():
		printerr("endless queue empty"); ok = false
	if GameState.is_run_complete():
		printerr("endless should never report run complete at start"); ok = false
	var endless_q1: Array = GameState.run_queue.duplicate()
	var pressure0: float = GameState.rewrite_pressure()
	GameState.endless_depth = 8
	var pressure1: float = GameState.rewrite_pressure()
	if pressure1 <= pressure0:
		printerr("endless rewrite pressure should rise with depth"); ok = false
	GameState.endless_depth = 0
	GameState.record_chamber_win(int(GameState.run_queue[0]), 20, 18)
	if GameState.endless_depth != 1:
		printerr("endless_depth expected 1 after clear got %d" % GameState.endless_depth); ok = false
	if not GameState.advance_chamber():
		printerr("endless advance_chamber should keep climbing"); ok = false
	var t_soft: String = ChamberBook.endless_pressure_transform("mirror_v", 0.2, 1)
	var t_hard: String = ChamberBook.endless_pressure_transform("mirror_v", 0.9, 1)
	if t_soft != "mirror_v":
		printerr("low pressure should keep mirror_v"); ok = false
	if t_hard != "mirror_v_then_h":
		printerr("high pressure should stack mirrors"); ok = false
	# Determinism: same seed+depth → same batch.
	var batch_a: Array = ChamberBook.endless_chamber_batch(424242, 0, 5, {})
	var batch_b: Array = ChamberBook.endless_chamber_batch(424242, 0, 5, {})
	if batch_a != batch_b or batch_a.is_empty():
		printerr("endless batch not deterministic"); ok = false
	if endless_q1.is_empty():
		printerr("endless start queue vanished"); ok = false
	GameState.start_new_run()
	# Re-assert the lifetime best survived the mode switch.
	GameState.best_moves[0] = 42
	GameState.best_stars[0] = maxi(1, int(GameState.best_stars.get(0, 1)))

	# Save/load round-trip (atomic path + bak).
	SaveManager.save_to_disk()
	if not FileAccess.file_exists(SaveManager.SAVE_PATH):
		printerr("save.json missing after save_to_disk"); ok = false
	GameState.best_moves.clear()
	GameState.best_stars.clear()
	SaveManager.load_from_disk()
	if int(GameState.best_moves.get(0, -1)) != 42:
		printerr("best_moves lost through save/load: %s" % str(GameState.best_moves))
		ok = false
	# Corrupt primary, ensure .bak recovery keeps progress.
	SaveManager.save_to_disk()
	var corrupt := FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
	if corrupt:
		corrupt.store_string("{not-json")
		corrupt.close()
	GameState.best_moves.clear()
	if not SaveManager.load_from_disk():
		printerr("bak recovery failed after corrupt primary"); ok = false
	elif int(GameState.best_moves.get(0, -1)) != 42:
		printerr("bak recovery lost best_moves"); ok = false

	# Continue UX — finished wing disables Continue; mid-run skips cleared rooms.
	GameState.start_new_run()
	GameState.completed.clear()
	GameState.run_cleared.clear()
	GameState.best_moves.clear()
	GameState.best_stars.clear()
	for i in range(GameState.run_queue.size()):
		GameState.completed[int(GameState.run_queue[i])] = true
		GameState.run_cleared[int(GameState.run_queue[i])] = true
	GameState.queue_pos = GameState.run_queue.size()
	if GameState.can_continue():
		printerr("can_continue should be false after wing complete"); ok = false
	# Lifetime completed must not poison a fresh run / Daily Continue skip.
	GameState.start_new_run()
	if not GameState.run_cleared.is_empty():
		printerr("start_new_run should clear run_cleared"); ok = false
	if GameState.queue_pos != 0 or GameState.current_chamber != int(GameState.run_queue[0]):
		printerr("start_new_run should resume at queue head despite lifetime completed")
		ok = false
	GameState.continue_run()
	if GameState.queue_pos != 0:
		printerr("Continue after Start New must not skip via lifetime completed, queue_pos=%d" % GameState.queue_pos)
		ok = false
	GameState.completed.clear()
	GameState.run_cleared.clear()
	GameState.best_moves.clear()
	GameState.best_stars.clear()
	GameState.start_new_run()
	GameState.record_chamber_win(int(GameState.run_queue[0]), 10, 8)
	GameState.continue_run()
	if GameState.queue_pos != 1:
		printerr("continue_run should skip run_cleared chamber 0, queue_pos=%d" % GameState.queue_pos)
		ok = false
	# Parked-on-last after clearing every room without advancing queue_pos.
	GameState.start_new_run()
	for i in range(GameState.run_queue.size()):
		GameState.run_cleared[int(GameState.run_queue[i])] = true
	GameState.queue_pos = maxi(0, GameState.run_queue.size() - 1)
	if GameState.can_continue():
		printerr("can_continue should be false when all remaining rooms are run_cleared")
		ok = false

	# Accessibility end-to-end (colorblind / flash / remap / subtitles / UI scale).
	if not has_node("/root/AccessibilityService") or not has_node("/root/SettingsStore") or not has_node("/root/ActionRemap"):
		printerr("a11y autoloads missing"); ok = false
	else:
		var a11y: Node = get_node("/root/AccessibilityService")
		var store: Node = get_node("/root/SettingsStore")
		var remap: Node = get_node("/root/ActionRemap")
		store.reset_section("accessibility")
		a11y.set_colorblind_mode(FossilPalette.Mode.PROTANOPIA)
		if a11y.colorblind_mode() != FossilPalette.Mode.PROTANOPIA:
			printerr("colorblind mode did not stick"); ok = false
		var echo_c: Color = a11y.role_color(FossilPalette.FossilRole.ECHO_WALL)
		if echo_c.is_equal_approx(Palette.RUST_FOSSIL):
			printerr("protanopia echo wall should diverge from default rust"); ok = false
		a11y.set_reduce_flash(true)
		var gated: Dictionary = FlashGate.gate(Color.WHITE, 1.0, 0.1, a11y)
		if gated.is_empty() or float(gated.get("intensity", 1.0)) > 0.26:
			printerr("reduce_flash did not cap intensity: %s" % str(gated)); ok = false
		a11y.set_ui_scale(1.25)
		if abs(a11y.ui_scale() - 1.25) > 0.001:
			printerr("ui_scale did not stick"); ok = false
		a11y.set_subtitles_enabled(true)
		_ensure_subtitle_overlay()
		if _subtitle_overlay == null or not _subtitle_overlay.has_method("show_line"):
			printerr("subtitle overlay missing"); ok = false
		else:
			_subtitle_overlay.show_line("rewrite_begin", 0.05)
		remap.reset_to_defaults()
		if not InputMap.has_action("ghost_assist"):
			printerr("ghost_assist action missing after remap"); ok = false
		var labels: PackedStringArray = remap.get_binding_labels("undo")
		if labels.is_empty():
			printerr("undo binding labels empty"); ok = false
		## Pad defaults must survive keyboard remap reset (B+Start menu, LB ghost).
		var pause_btns: Array = []
		var ghost_btns: Array = []
		for ev in InputMap.action_get_events("pause_menu"):
			if ev is InputEventJoypadButton:
				pause_btns.append((ev as InputEventJoypadButton).button_index)
		for ev in InputMap.action_get_events("ghost_assist"):
			if ev is InputEventJoypadButton:
				ghost_btns.append((ev as InputEventJoypadButton).button_index)
		if not (JOY_BUTTON_B in pause_btns and JOY_BUTTON_START in pause_btns):
			printerr("pause_menu pad defaults missing B+Start: %s" % str(pause_btns)); ok = false
		if JOY_BUTTON_LEFT_SHOULDER not in ghost_btns:
			printerr("ghost_assist pad default missing LB: %s" % str(ghost_btns)); ok = false
		if DeckProfile.recommended_tdp_watts() != DeckProfile.TDP_TARGET_WATTS:
			printerr("DeckProfile default TDP should be 7W verified"); ok = false
		a11y.set_reduce_flash(false)
		a11y.set_ui_scale(1.0)
		a11y.set_colorblind_mode(FossilPalette.Mode.DEFAULT)
		print("  a11y colorblind/flash/remap/subtitles/ui_scale OK")

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
			# Softlock guard: while rewrite is pending, movement must not apply.
			chamber.pending_echoes = [Vector2i(1, 1)]
			chamber.pending_echo_timer = 0.0
			var locked_pos: Vector2i = chamber.player_pos
			var locked_moves: int = chamber.move_count
			chamber._try_move(Vector2i(1, 0))
			if chamber.player_pos != locked_pos or chamber.move_count != locked_moves:
				printerr("movement leaked during rewrite lock"); ok = false
			if not chamber.is_rewrite_locking():
				printerr("is_rewrite_locking false with pending echoes"); ok = false
			chamber.pending_echoes.clear()
		inst.queue_free()

	# Perf P0/P1: baked grain + particle pool caps (docs/AUDIT/PERFORMANCE.md).
	ok = _selftest_perf_budgets() and ok

	# V3-T0/T1: latin type stack vendored + wired (no Godot-default brand path).
	ok = _selftest_type_kit() and ok

	# Field Index plate must frame CardColumn actions at design viewports.
	ok = await _selftest_field_index_layout() and ok

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


func _selftest_field_index_layout() -> bool:
	## Brand menu: Field Index card frames index actions at 16:9, Deck 16:10, editor.
	var ok := true
	var sizes: Array = [Vector2i(1920, 1080), Vector2i(1280, 800), Vector2i(960, 560)]
	for sz in sizes:
		show_menu()
		for _f in range(4):
			await get_tree().process_frame
		var menu_node: Control = null
		if stage != null:
			for child in stage.get_children():
				if child is Control and child.has_method("verify_field_index_layout"):
					menu_node = child as Control
					break
		if menu_node == null:
			printerr("Field Index selftest: menu Control missing")
			return false
		# Force logical size so headless CI matches Partner / Deck viewports.
		menu_node.set_anchors_preset(Control.PRESET_TOP_LEFT)
		menu_node.position = Vector2.ZERO
		menu_node.size = Vector2(sz)
		if menu_node.has_method("_sync_field_index_layout"):
			menu_node.call("_sync_field_index_layout")
		for _f2 in range(6):
			await get_tree().process_frame
		if not bool(menu_node.call("verify_field_index_layout")):
			printerr("Field Index selftest failed at %dx%d" % [sz.x, sz.y])
			ok = false
		else:
			print("  Field Index layout OK @ %dx%d" % [sz.x, sz.y])
	return ok


func _selftest_type_kit() -> bool:
	## ART_DIRECTION_V3 §3 — IBM Plex latin stack via LedgerType; brand/seed roles resolve.
	var ok := true
	if not has_node("/root/LedgerType"):
		printerr("LedgerType autoload missing"); return false
	if not LedgerType.is_latin_ready():
		printerr("LedgerType latin faces not loaded (fonts/latin/)")
		ok = false
	else:
		print("  LedgerType display/body/mono loaded")
	var required: Array = [
		"res://fonts/latin/IBMPlexSansCondensed-SemiBold.ttf",
		"res://fonts/latin/IBMPlexSerif-Regular.ttf",
		"res://fonts/latin/IBMPlexMono-Regular.ttf",
		"res://fonts/latin/OFL.txt",
	]
	for path in required:
		if not FileAccess.file_exists(str(path)):
			printerr("missing vendored font/license: %s" % str(path))
			ok = false
	if LedgerType.display == null or LedgerType.mono == null:
		printerr("LedgerType display/mono faces returned null")
		ok = false
	# LedgerType boots ThemeDB.fallback_font to the display face on latin.
	if LedgerType.display != null and ThemeDB.fallback_font != LedgerType.display:
		if not str(LocaleManager.current_locale).begins_with("zh"):
			printerr("ThemeDB.fallback_font is not LedgerType display on latin locale")
			ok = false
	# ArtKit material helpers present (letterpress / page / title-card materials).
	if not ArtKit.has_method("draw_letterpress_wall") or not ArtKit.has_method("draw_ledger_page"):
		printerr("ArtKit missing letterpress/page material helpers")
		ok = false
	elif not ArtKit.has_method("draw_seal_stamp") or not ArtKit.has_method("draw_index_card"):
		printerr("ArtKit missing seal/index-card title materials")
		ok = false
	elif not ArtKit.has_method("draw_desk_margin"):
		printerr("ArtKit missing desk margin helper")
		ok = false
	else:
		print("  ArtKit letterpress + ledger page + title materials OK")
	return ok


func _selftest_perf_budgets() -> bool:
	## Cloud-safe checks for grain bake + Juice particle pool (no GPU timing).
	var ok := true
	if not has_node("/root/ArtKit"):
		printerr("ArtKit autoload missing"); return false
	# Force-bake the seeds used by chamber + menu draw paths.
	var seeds: Array = [3, 11, 19, 42]
	for s in seeds:
		var tex: Texture2D = ArtKit.grain_texture(int(s))
		if tex == null:
			printerr("grain bake failed for seed %s" % str(s)); ok = false
		elif not ArtKit.has_baked_grain(int(s)):
			printerr("grain cache miss after bake seed %s" % str(s)); ok = false
	if ArtKit.baked_grain_seed_count() < seeds.size():
		printerr("expected ≥%d baked grain seeds, got %d" % [seeds.size(), ArtKit.baked_grain_seed_count()])
		ok = false
	else:
		print("  grain bake: %d seeds cached (tiled ImageTexture)" % ArtKit.baked_grain_seed_count())

	ok = _selftest_tech_art_v3() and ok

	if not has_node("/root/Juice"):
		printerr("Juice autoload missing"); return false
	Juice.reset_transient()
	# Over-cap burst must steal-oldest, never grow past PARTICLE_CAP.
	var cap: int = int(Juice.PARTICLE_CAP)
	for _i in range(cap + 80):
		Juice.spawn_burst(Vector2(10, 10), Palette.RUST_FOSSIL, 1)
	var live: int = Juice.live_particle_count()
	if live > cap:
		printerr("particle pool exceeded cap: %d > %d" % [live, cap]); ok = false
	else:
		print("  particle pool: live=%d cap=%d (steal-oldest OK)" % [live, cap])
	Juice.reset_transient()
	if Juice.live_particle_count() != 0:
		printerr("reset_transient did not clear particles"); ok = false
	return ok


func _selftest_tech_art_v3() -> bool:
	## Cloud-safe TECH ART v3 contracts — no GPU ms. Flag stays off by default.
	var ok := true
	if not has_node("/root/SettingsStore"):
		printerr("SettingsStore missing for tech_art_v3"); return false
	var flagged_raw: Variant = SettingsStore.get_value("graphics", "tech_art_v3", null)
	if flagged_raw == null:
		printerr("graphics.tech_art_v3 missing from settings defaults"); ok = false
	elif bool(flagged_raw):
		printerr("tech_art_v3 must default false for CI / Deck-safe ship"); ok = false
	else:
		print("  tech_art_v3: default OFF (CI-safe)")
	if TechArt.v3_enabled():
		printerr("TechArt.v3_enabled unexpected true under defaults"); ok = false

	for path in [
		TechArt.PAPER_GRAIN_SHADER,
		TechArt.INK_BLEED_SHADER,
		TechArt.PAPER_GRAIN_PAGE_MAT,
		TechArt.PAPER_GRAIN_MENU_MAT,
		TechArt.INK_BLEED_SLAM_MAT,
		TechArt.GRAIN_TEX_PATH,
		TechArt.BLEED_LUT_PATH,
	]:
		if not ResourceLoader.exists(path):
			printerr("tech_art_v3 missing resource: %s" % path); ok = false

	var page_mat: Resource = load(TechArt.PAPER_GRAIN_PAGE_MAT)
	if page_mat is ShaderMaterial:
		var opacity: float = float((page_mat as ShaderMaterial).get_shader_parameter("opacity"))
		if opacity > TechArt.MAX_GRAIN_OPACITY + 0.0001:
			printerr("paper_grain_page opacity %.3f exceeds %.2f" % [opacity, TechArt.MAX_GRAIN_OPACITY])
			ok = false
		else:
			print("  paper grain material opacity=%.3f (≤ %.2f)" % [opacity, TechArt.MAX_GRAIN_OPACITY])
	else:
		printerr("paper_grain_page.tres is not a ShaderMaterial"); ok = false

	var b0: float = SlamShaderDriver.bleed_for_local_t(0.40)
	var b_slot: float = SlamShaderDriver.bleed_for_local_t(0.64)
	var b_end: float = SlamShaderDriver.bleed_for_local_t(1.0)
	if b0 > 0.001 or b_slot < 0.05 or b_slot > 0.16 or b_end < 0.99:
		printerr("ink bleed timing map unexpected: 0.40→%.3f 0.64→%.3f 1.0→%.3f" % [b0, b_slot, b_end])
		ok = false
	else:
		print("  ink bleed timing: crease=0 slot≈%.2f end=%.2f" % [b_slot, b_end])

	var shared_a: ShaderMaterial = SlamShaderDriver.shared_bleed_material()
	var shared_b: ShaderMaterial = SlamShaderDriver.shared_bleed_material()
	if shared_a == null or shared_a != shared_b:
		printerr("ink bleed material must be a single shared instance"); ok = false
	else:
		print("  ink bleed: shared ShaderMaterial (no hot-path duplicate)")

	# Host smoke: mount grain layer under a throwaway Control, then free.
	var host := Control.new()
	host.size = Vector2(960, 560)
	add_child(host)
	TechArt.set_v3_enabled(true, false)
	var layer: PaperGrainLayer = PaperGrainLayer.attach_to(host, 42, 0.09, Vector2.ZERO, false)
	if layer == null or not is_instance_valid(layer):
		printerr("PaperGrainLayer.attach_to failed"); ok = false
	else:
		var clamped: float = float(layer.grain_opacity)
		if clamped > TechArt.MAX_GRAIN_OPACITY + 0.0001:
			printerr("PaperGrainLayer failed to clamp opacity (got %.3f)" % clamped); ok = false
		else:
			print("  PaperGrainLayer: opacity clamped to %.3f" % clamped)
	TechArt.set_v3_enabled(false, false)
	host.queue_free()
	return ok



func _selftest_habit_rewrite_wire() -> bool:
	var ok := true
	var dirs: Array = []
	for _i in range(16):
		dirs.append("right")
	var visits := {
		Vector2i(1, 5): 1,
		Vector2i(2, 5): 1,
		Vector2i(3, 5): 1,
		Vector2i(4, 5): 2,
	}
	var pick: Dictionary = HabitRewriteLever.select_echo_cells(
		dirs, visits, [], {}, 1, 0, "standard", -1.0
	)
	# Act I chamber 0: hard counters gated → soft place_deflector lever.
	if str(pick.get("op", "")) != "place_deflector":
		printerr("habit wire: expected place_deflector in Act I, got %s" % str(pick.get("op", "")))
		ok = false
	if pick.get("cells", []).is_empty():
		printerr("habit wire: expected at least one habit cell")
		ok = false
	var arch := HabitArchetype.classify({
		"total_steps": 30,
		"unique_cells": 12,
		"dominant_bias": 0.3,
		"turn_rate": 0.4,
		"backtrack_rate": 0.25,
		"straight_streaks": [3, 2, 2],
	})
	if arch.id != HabitArchetype.ID_LOOP:
		printerr("habit wire: looper classify failed (%s)" % arch.id)
		ok = false
	var cands: Array = [
		{"name": "place_deflector", "score": 5.0, "meta": {}},
		{"name": "fossilize_hot_cell", "score": 5.0, "meta": {}},
	]
	var biased: Array = RewriteScoreBias.apply(cands, {
		"total_steps": 30,
		"unique_cells": 12,
		"dominant_bias": 0.3,
		"turn_rate": 0.4,
		"backtrack_rate": 0.25,
		"straight_streaks": [3, 2, 2],
	})
	if biased.is_empty() or str(biased[0].get("name", "")) != "fossilize_hot_cell":
		printerr("habit wire: RewriteScoreBias did not prefer fossilize for looper")
		ok = false
	if ok:
		print("habit rewrite wire: ok (deflector + score bias)")
	return ok


func _selftest_demo_scope(acts: Array) -> bool:
	var ok := true
	var expect: PackedStringArray = DemoBuild.allowed_campaign_ids()
	if ChamberBook.chamber_count() != expect.size():
		printerr("demo chamber_count %d != %d" % [ChamberBook.chamber_count(), expect.size()])
		ok = false
	if acts.size() != 1 or str(acts[0].get("id", "")) != DemoBuild.ACT_ID:
		printerr("demo acts_summary must expose Induction only"); ok = false
	var mirror: Dictionary = ChamberBook.get_chamber_by_content_id(DemoBuild.MIRROR_BIRTH_ID)
	if mirror.is_empty():
		printerr("demo missing Mirror Birth (%s)" % DemoBuild.MIRROR_BIRTH_ID); ok = false
	elif str(mirror.get("title", "")) != "Mirror Birth":
		printerr("Mirror Birth title mismatch: %s" % str(mirror.get("title", ""))); ok = false
	for i in range(ChamberBook.chamber_count()):
		var data: Dictionary = ChamberBook.get_chamber(i)
		var act_idx: int = int(data.get("act_index", -1))
		if act_idx != 0:
			printerr("demo spoiler: chamber %d has act_index %d" % [i, act_idx]); ok = false
	# Late-act content must not be addressable.
	for spoil in ["09_twin_rail", "17_identity_reflection", "26_identity_pressure", "33_nameplate"]:
		if not ChamberBook.get_chamber_by_content_id(spoil).is_empty():
			printerr("demo spoiler leak: %s still loaded" % spoil); ok = false
	# Placeholder AppID / itch / DRM-free builds must not surface a live CTA.
	if DemoBuild.wishlist_url().find("YOUR_APP_ID") >= 0:
		printerr("demo wishlist URL still contains YOUR_APP_ID"); ok = false
	if DemoBuild.wishlist_cta_enabled() and DemoBuild.wishlist_url().is_empty():
		printerr("wishlist CTA enabled with empty URL"); ok = false
	print("demo scope: Act I (%d) + Mirror Birth + wishlist gates OK" % expect.size())
	return ok


func _selftest_onboarding_path() -> bool:
	## Guarantee Quiet Span → Echo Plate → Mirror Birth fits a 0–3 min first-hook path.
	## Budget: shortest-path sum ≤ 90 steps (~90s deliberate / well under 3 minutes).
	var ok := true
	var budget := 0
	var ids: PackedStringArray = PackedStringArray([
		"00_quiet_span", "01_echo_plate", DemoBuild.MIRROR_BIRTH_ID,
	])
	for cid in ids:
		var data: Dictionary = ChamberBook.get_chamber_by_content_id(cid)
		if data.is_empty():
			printerr("onboarding missing chamber %s" % cid)
			ok = false
			continue
		var sp: int = _bfs_shortest_len(data)
		if sp < 0:
			printerr("onboarding %s has no path to goal" % cid)
			ok = false
			continue
		budget += sp
		print("  onboarding shortest path %s = %d" % [cid, sp])
		var hints = data.get("hints", [])
		if typeof(hints) != TYPE_ARRAY or hints.is_empty():
			printerr("onboarding %s missing teach hints[]" % cid)
			ok = false
	var echo: Dictionary = ChamberBook.get_chamber_by_content_id("01_echo_plate")
	if not echo.is_empty():
		var rows: Array = echo.get("map", [])
		var cps := 0
		for row in rows:
			cps += str(row).count("C")
		if cps < 1:
			printerr("Echo Plate must teach a checkpoint plate (C)"); ok = false
		if int(echo.get("rewrite_cap", 99)) != 0:
			printerr("Echo Plate rewrite_cap must be 0 (literacy, no fossils)"); ok = false
	var mirror: Dictionary = ChamberBook.get_chamber_by_content_id(DemoBuild.MIRROR_BIRTH_ID)
	if not mirror.is_empty() and str(mirror.get("transform", "")) != "mirror_v":
		printerr("Mirror Birth must teach mirror_v"); ok = false
	if budget > 90:
		printerr("onboarding shortest-path sum %d exceeds 90-move / ~3min budget" % budget)
		ok = false
	elif ok:
		print("  onboarding path budget OK (%d steps across Quiet Span→Mirror Birth)" % budget)
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
	return _bfs_shortest_len(data) >= 0


static func _bfs_shortest_len(data: Dictionary) -> int:
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
	var seen := {}
	var q: Array = [start]
	var dist := {start: 0}
	seen[start] = true
	while q.size() > 0:
		var p: Vector2i = q.pop_front()
		if p == goal:
			return int(dist[p])
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
			dist[n] = int(dist[p]) + 1
			q.append(n)
	return -1


func _clear_stage() -> void:
	if has_node("/root/Juice") and Juice.has_method("reset_transient"):
		Juice.reset_transient()
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
	if m.has_signal("endless_pressed"):
		m.connect("endless_pressed", Callable(self, "_on_menu_endless"))
	if m.has_signal("hard_pressed"):
		m.connect("hard_pressed", Callable(self, "_on_menu_hard"))
	if m.has_signal("museum_pressed"):
		m.connect("museum_pressed", Callable(self, "_on_menu_museum"))
	if has_node("/root/SteamService"):
		SteamService.set_menu_presence()


func show_museum() -> void:
	_clear_stage()
	var m: Node = MUSEUM_SCENE.instantiate()
	stage.add_child(m)
	if m.has_signal("back_pressed"):
		m.connect("back_pressed", Callable(self, "show_menu"))
	if m.has_signal("race_self"):
		m.connect("race_self", Callable(self, "_on_museum_race_self"))


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
	if e.has_signal("museum_pressed"):
		e.connect("museum_pressed", Callable(self, "_on_end_museum"))
	if has_node("/root/SteamService"):
		SteamService.set_end_presence()


# ---------- menu callbacks ----------

func _on_menu_start_new() -> void:
	GameState.start_new_run()
	show_chamber()


func _on_menu_continue() -> void:
	GameState.continue_run()
	if GameState.is_run_complete():
		show_end_screen()
	else:
		show_chamber()


func _on_menu_daily() -> void:
	GameState.start_daily_run()
	show_chamber()


func _on_menu_endless() -> void:
	GameState.start_endless_run()
	show_chamber()


func _on_menu_hard() -> void:
	if not GameState.can_start_hard_run():
		return
	GameState.start_hard_run()
	show_chamber()


func _on_menu_museum() -> void:
	show_museum()


func _on_museum_race_self(self_id: String) -> void:
	## Optional chalk overlay race — launches a real chamber, never combat.
	if not GameState.start_ghost_race(self_id):
		return
	show_chamber()


func _on_menu_quit() -> void:
	get_tree().quit()


# ---------- chamber callbacks ----------

func _on_chamber_won(chamber_id: int, moves: int) -> void:
	show_chamber_won(chamber_id, moves)


func _on_menu_requested() -> void:
	if GameState.run_mode == "ghost":
		GameState.clear_ghost_race()
		show_museum()
		return
	show_menu()


# ---------- win-screen callbacks ----------

func _on_win_next() -> void:
	if GameState.run_mode == "ghost":
		GameState.clear_ghost_race()
		show_museum()
		return
	var advanced: bool = GameState.advance_chamber()
	if advanced:
		show_chamber()
	else:
		show_end_screen()


func _on_win_replay() -> void:
	show_chamber()


func _on_win_menu() -> void:
	if GameState.run_mode == "ghost":
		GameState.clear_ghost_race()
		show_museum()
		return
	show_menu()


# ---------- end-screen callbacks ----------

func _on_end_restart() -> void:
	GameState.start_new_run()
	show_chamber()


func _on_end_menu() -> void:
	show_menu()

func _on_end_museum() -> void:
	show_museum()

