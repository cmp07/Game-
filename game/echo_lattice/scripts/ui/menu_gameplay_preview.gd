extends Control
##
## Decorative title-menu gameplay loop — Field Ledger film plate media.
## Preferred: silent SubViewport mini-chamber (scripted walk + rewrite slam).
## Fallback: looping Theora (.ogv) or PNG frame strip from media/menu_preview/.
## Never steals focus / mouse / authorship (GameState / AudioDirector muted).
##
## Layout contract: this Control is sized to the film-plate media well by menu.gd.
## The SubViewport must match that well and the board must COVER it — never a
## native-resolution postage stamp inside a hollow cream plate (#163 regression).
##

const PREVIEW_CHAMBER_ID: int = 2
## Native board pixels (24×32 / 14×32). Used as the unscaled chamber draw size;
## runtime SubViewport is resized to the media well and the board is cover-scaled.
const BOARD_W: int = 768
const BOARD_H: int = 448
## Back-compat aliases (density tests / older call sites).
const VIEW_W: int = BOARD_W
const VIEW_H: int = BOARD_H
const STEP_SEC: float = 0.11
const HOLD_AFTER_SLAM_SEC: float = 0.55
const HOLD_END_SEC: float = 0.70
const OGV_PATH: String = "res://media/menu_preview/menu_preview.ogv"
const FRAME_GLOB_PREFIX: String = "res://media/menu_preview/frame_%02d.png"
const FRAME_COUNT: int = 10
const FRAME_SEC: float = 0.18

enum Mode { LIVE, VIDEO, FRAMES, STILL }

var _mode: int = Mode.STILL
var _paused: bool = false
var _host: SubViewportContainer
var _sv: SubViewport
var _chamber: Node2D = null
var _video: VideoStreamPlayer = null
var _frame_rect: TextureRect = null
var _frames: Array = []  ## Texture2D
var _frame_i: int = 0
var _frame_t: float = 0.0
var _step_t: float = 0.0
var _hold_t: float = 0.0
var _phase: String = "walk"  ## walk | slam | post | end


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	# Top-left anchors — menu.gd drives position/size to the media well.
	# FULL_RECT fought explicit sizing and left the SubViewport at board-native
	# 768×448 stamped into a much larger plate (#163 hollow-plate root cause).
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 0.0
	anchor_bottom = 0.0
	_build_chrome()
	if _reduce_motion():
		_start_still_or_frames(true)
	elif not _start_live():
		if not _start_video():
			_start_still_or_frames(false)
	_fit_media_to_size(size)
	set_process(true)


func sync_media_rect(media: Rect2) -> void:
	## Called by menu._sync_preview_layout — plate well == preview Control == filled board.
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 0.0
	anchor_bottom = 0.0
	position = media.position
	size = media.size
	_fit_media_to_size(media.size)


func pause_preview() -> void:
	_paused = true
	if _video != null:
		_video.paused = true
	if _chamber != null:
		_chamber.set_process(false)


func resume_preview() -> void:
	if _reduce_motion():
		return
	_paused = false
	if _video != null:
		_video.paused = false
		if not _video.is_playing():
			_video.play()
	if _chamber != null:
		_chamber.set_process(true)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_fit_media_to_size(size)
	elif what == NOTIFICATION_VISIBILITY_CHANGED:
		if not is_visible_in_tree():
			pause_preview()
		elif not _reduce_motion():
			resume_preview()
	elif what == NOTIFICATION_EXIT_TREE:
		pause_preview()


func _build_chrome() -> void:
	_host = SubViewportContainer.new()
	_host.name = "FilmHost"
	_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_host.focus_mode = Control.FOCUS_NONE
	_host.stretch = true
	_host.anchor_left = 0.0
	_host.anchor_top = 0.0
	_host.anchor_right = 0.0
	_host.anchor_bottom = 0.0
	_host.position = Vector2.ZERO
	add_child(_host)


func _fit_media_to_size(sz: Vector2) -> void:
	if sz.x < 8.0 or sz.y < 8.0:
		return
	if _host != null and is_instance_valid(_host):
		_host.position = Vector2.ZERO
		_host.size = sz
		_host.stretch = true
	if _sv != null and is_instance_valid(_sv):
		var w: int = maxi(64, int(round(sz.x)))
		var h: int = maxi(64, int(round(sz.y)))
		if _sv.size.x != w or _sv.size.y != h:
			_sv.size = Vector2i(w, h)
		_cover_scale_chamber(Vector2(float(w), float(h)))
	if _video != null and is_instance_valid(_video):
		_video.position = Vector2.ZERO
		_video.size = sz
	if _frame_rect != null and is_instance_valid(_frame_rect):
		_frame_rect.position = Vector2.ZERO
		_frame_rect.size = sz


func _cover_scale_chamber(vp: Vector2) -> void:
	## Scale the native board so it COVERS the SubViewport — no cream letterbox.
	if _chamber == null or not is_instance_valid(_chamber):
		return
	var grid_px := Vector2(float(BOARD_W), float(BOARD_H))
	if grid_px.x < 1.0 or grid_px.y < 1.0 or vp.x < 1.0 or vp.y < 1.0:
		return
	var s: float = maxf(vp.x / grid_px.x, vp.y / grid_px.y)
	_chamber.scale = Vector2(s, s)
	_chamber.position = ((vp - grid_px * s) * 0.5).floor()
	if _chamber.has_method("queue_redraw"):
		_chamber.queue_redraw()


func _start_live() -> bool:
	_sv = SubViewport.new()
	_sv.name = "PreviewViewport"
	var boot_w: int = maxi(BOARD_W, int(round(size.x))) if size.x >= 8.0 else BOARD_W
	var boot_h: int = maxi(BOARD_H, int(round(size.y))) if size.y >= 8.0 else BOARD_H
	_sv.size = Vector2i(boot_w, boot_h)
	_sv.transparent_bg = false
	_sv.handle_input_locally = false
	_sv.gui_disable_input = true
	_sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_host.add_child(_sv)

	var ch := Node2D.new()
	ch.set_script(load("res://scripts/chamber.gd"))
	ch.set("menu_preview_mode", true)
	ch.set("preview_chamber_id", PREVIEW_CHAMBER_ID)
	_sv.add_child(ch)
	_chamber = ch
	if _chamber.has_method("configure_as_menu_preview"):
		_chamber.configure_as_menu_preview(PREVIEW_CHAMBER_ID)
	if _chamber.grid.is_empty():
		_chamber.queue_free()
		_chamber = null
		_sv.queue_free()
		_sv = null
		return false
	_prime_mid_walk()
	_cover_scale_chamber(Vector2(_sv.size))
	_mode = Mode.LIVE
	_phase = "walk"
	_step_t = 0.0
	return true


func _start_video() -> bool:
	if not ResourceLoader.exists(OGV_PATH):
		return false
	_video = VideoStreamPlayer.new()
	_video.name = "PreviewVideo"
	_video.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_video.focus_mode = Control.FOCUS_NONE
	_video.expand = true
	_video.volume_db = -80.0
	_video.anchor_left = 0.0
	_video.anchor_top = 0.0
	_video.anchor_right = 0.0
	_video.anchor_bottom = 0.0
	_video.position = Vector2.ZERO
	_video.size = size if size.x >= 8.0 else Vector2(BOARD_W, BOARD_H)
	# Prefer placing video as a direct child so it fills the film window.
	add_child(_video)
	move_child(_video, 0)
	var stream: Resource = load(OGV_PATH)
	if stream == null:
		_video.queue_free()
		_video = null
		return false
	_video.stream = stream
	_video.finished.connect(func():
		if not _paused and is_visible_in_tree():
			_video.play()
	)
	_video.play()
	_mode = Mode.VIDEO
	if _host != null:
		_host.visible = false
	return true


func _start_still_or_frames(still_only: bool) -> void:
	_frames.clear()
	for i in range(FRAME_COUNT):
		var path: String = FRAME_GLOB_PREFIX % i
		if ResourceLoader.exists(path):
			var tex: Texture2D = load(path) as Texture2D
			if tex != null:
				_frames.append(tex)
	_frame_rect = TextureRect.new()
	_frame_rect.name = "PreviewFrames"
	_frame_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame_rect.focus_mode = Control.FOCUS_NONE
	_frame_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_frame_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_frame_rect.anchor_left = 0.0
	_frame_rect.anchor_top = 0.0
	_frame_rect.anchor_right = 0.0
	_frame_rect.anchor_bottom = 0.0
	_frame_rect.position = Vector2.ZERO
	_frame_rect.size = size if size.x >= 8.0 else Vector2(BOARD_W, BOARD_H)
	add_child(_frame_rect)
	move_child(_frame_rect, 0)
	if _host != null:
		_host.visible = false
	if _frames.is_empty():
		_mode = Mode.STILL
		return
	# Mid-loop slam frame reads as "player playing" even when frozen.
	_frame_i = mini(6, _frames.size() - 1) if still_only else 0
	_frame_rect.texture = _frames[_frame_i]
	_mode = Mode.STILL if still_only else Mode.FRAMES


func _reduce_motion() -> bool:
	var store := get_node_or_null("/root/SettingsStore")
	if store != null and store.has_method("get_value"):
		return bool(store.get_value("accessibility", "reduce_motion", false))
	return false


func _process(delta: float) -> void:
	if _paused or not is_visible_in_tree():
		return
	if _mode == Mode.FRAMES:
		_process_frames(delta)
	elif _mode == Mode.LIVE and _chamber != null:
		_process_live(delta)


func _process_frames(delta: float) -> void:
	if _frames.size() < 2 or _frame_rect == null:
		return
	_frame_t += delta
	if _frame_t < FRAME_SEC:
		return
	_frame_t = 0.0
	_frame_i = (_frame_i + 1) % _frames.size()
	_frame_rect.texture = _frames[_frame_i]


func _process_live(delta: float) -> void:
	if _chamber.is_rewrite_locking():
		_phase = "slam"
		return
	if _phase == "slam":
		_phase = "post"
		_hold_t = 0.0
		return
	if _phase == "post":
		_hold_t += delta
		if _hold_t >= HOLD_AFTER_SLAM_SEC:
			_phase = "walk_more"
			_step_t = 0.0
		return
	if _phase == "end":
		_hold_t += delta
		if _hold_t >= HOLD_END_SEC:
			_reset_live_loop()
		return
	_step_t += delta
	if _step_t < STEP_SEC:
		return
	_step_t = 0.0
	var target: Vector2i = _nearest_checkpoint() if _phase == "walk" else _chamber.goal_pos
	if _phase == "walk":
		var dist: int = absi(_chamber.player_pos.x - target.x) + absi(_chamber.player_pos.y - target.y)
		if dist <= 0:
			# Step onto checkpoint if not yet triggered.
			pass
		var step: Vector2i = _bfs_next_step(target)
		if step == Vector2i.ZERO:
			_phase = "end"
			_hold_t = 0.0
			return
		_chamber._try_move(step)
		if _chamber.is_rewrite_locking():
			_phase = "slam"
		return
	if _phase == "walk_more":
		var step2: Vector2i = _bfs_next_step(_chamber.goal_pos)
		if step2 == Vector2i.ZERO:
			_phase = "end"
			_hold_t = 0.0
			return
		# Stop short of the goal — never complete a win on the title shell.
		var dist2: int = (
			absi(_chamber.player_pos.x - _chamber.goal_pos.x)
			+ absi(_chamber.player_pos.y - _chamber.goal_pos.y)
		)
		if dist2 <= 3:
			_phase = "end"
			_hold_t = 0.0
			return
		_chamber._try_move(step2)


func _reset_live_loop() -> void:
	if _chamber == null:
		return
	if _chamber.has_method("reset_chamber"):
		_chamber.reset_chamber()
	_prime_mid_walk()
	_phase = "walk"
	_step_t = 0.0
	_hold_t = 0.0
	if _sv != null:
		_cover_scale_chamber(Vector2(_sv.size))


func _prime_mid_walk() -> void:
	## Instant chalk densify so frame 0 already shows a player in motion.
	if _chamber == null:
		return
	var target: Vector2i = _nearest_checkpoint()
	var guard: int = 0
	while guard < 80:
		var dist: int = absi(_chamber.player_pos.x - target.x) + absi(_chamber.player_pos.y - target.y)
		if dist <= 7:
			break
		var step: Vector2i = _bfs_next_step(target)
		if step == Vector2i.ZERO:
			break
		_chamber._try_move(step)
		if _chamber.is_rewrite_locking():
			# Should not fire this early — flush if it did.
			if _chamber.has_method("_flush_pending_echoes"):
				_chamber._flush_pending_echoes()
		guard += 1


func _nearest_checkpoint() -> Vector2i:
	var best: Vector2i = _chamber.goal_pos
	var best_d: int = 9999
	for y in range(_chamber.grid.size()):
		for x in range(_chamber.grid[y].size()):
			if int(_chamber.grid[y][x]) == 2:  # Tile.CHECKPOINT
				var d: int = absi(_chamber.player_pos.x - x) + absi(_chamber.player_pos.y - y)
				if d < best_d:
					best_d = d
					best = Vector2i(x, y)
	return best


func _bfs_next_step(target: Vector2i) -> Vector2i:
	if _chamber == null or target == _chamber.player_pos:
		return Vector2i.ZERO
	var w: int = ChamberBook.GRID_W
	var h: int = ChamberBook.GRID_H
	var start: Vector2i = _chamber.player_pos
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
			var cell: int = int(_chamber.grid[n.y][n.x])
			if cell == 1 or cell == 5:  # WALL / ECHO_WALL
				continue
			came_from[n] = cur
			q.append(n)
	if not found:
		return Vector2i.ZERO
	var cur2: Vector2i = target
	while came_from[cur2] != start:
		cur2 = came_from[cur2]
	return cur2 - start
