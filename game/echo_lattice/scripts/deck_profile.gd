extends Node
##
## DeckProfile — Steam Deck detection, battery-friendly display defaults,
## and 16:10 / 1280×800 layout helpers for Verified prep.
##
## TDP cannot be set from the game; recommended watts live in docs/RELEASE/STEAM_DECK.md.
##

## Verified performance targets (native Linux x86_64, Compatibility renderer).
const TARGET_FPS_VERIFIED: int = 60
const TARGET_FPS_BATTERY: int = 40
const DECK_WIDTH: int = 1280
const DECK_HEIGHT: int = 800
## Soft recommendation for SteamOS TDP slider (documentation / QA only).
const TDP_TARGET_WATTS: int = 7
const TDP_BATTERY_WATTS: int = 4

## When true, prefer the lower FPS cap (battery-friendly). Off by default; Deck
## still gets vsync + 60 FPS so Verified frames stay locked.
var battery_mode: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	apply_runtime_defaults()


func is_steam_deck() -> bool:
	if OS.get_environment("SteamDeck") == "1":
		return true
	if OS.get_environment("STEAMDECK") == "1":
		return true
	## SteamOS user home is a strong Deck signal for native Linux builds.
	if OS.get_name() == "Linux" and DirAccess.dir_exists_absolute("/home/deck"):
		return true
	## Flatpak / Steam Runtime sometimes expose the board name.
	var board := OS.get_environment("BOARD_NAME").to_lower()
	if board.find("jupiter") >= 0 or board.find("galileo") >= 0:
		return true
	return false


func is_deck_sized_window() -> bool:
	var win := get_window()
	if win == null:
		return false
	var sz: Vector2i = win.size
	return sz.x == DECK_WIDTH and sz.y == DECK_HEIGHT


func apply_runtime_defaults() -> void:
	## Headless CI must not touch display mode.
	if DisplayServer.get_name() == "headless":
		Engine.max_fps = 0
		return

	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

	if is_steam_deck():
		## Fullscreen matches Steam Deck gamepad-first launch expectations.
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		_apply_fps_cap()
		## Prefer gamepad glyphs immediately on Deck even before the first press.
		if has_node("/root/InputGlyphs"):
			InputGlyphs.last_device = InputGlyphs.Device.GAMEPAD
	else:
		## Desktop: uncapped with vsync still on (monitor refresh). Battery mode
		## remains available for QA via --battery.
		if battery_mode:
			_apply_fps_cap()
		else:
			Engine.max_fps = 0


func _apply_fps_cap() -> void:
	Engine.max_fps = TARGET_FPS_BATTERY if battery_mode else TARGET_FPS_VERIFIED


func set_battery_mode(enabled: bool) -> void:
	battery_mode = enabled
	if DisplayServer.get_name() == "headless":
		return
	if enabled or is_steam_deck():
		_apply_fps_cap()
	elif not enabled and not is_steam_deck():
		Engine.max_fps = 0


func force_deck_window_for_qa() -> void:
	## Used by --deck-layout-check. Resize the root window to Deck native.
	if DisplayServer.get_name() == "headless":
		return
	var win := get_window()
	if win == null:
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	win.size = Vector2i(DECK_WIDTH, DECK_HEIGHT)
	win.content_scale_size = Vector2i(DECK_WIDTH, DECK_HEIGHT)


func layout_report(root: Node) -> Dictionary:
	## Collect on-screen Control rects and flag anything outside the viewport
	## (with a small safe margin for Deck bezel / Steam overlay).
	var vp: Viewport = root.get_viewport()
	if vp == null:
		return {"ok": false, "reason": "no viewport"}
	var vp_rect: Rect2 = vp.get_visible_rect()
	var margin := 8.0
	var safe := Rect2(
		vp_rect.position + Vector2(margin, margin),
		vp_rect.size - Vector2(margin * 2.0, margin * 2.0)
	)
	var offenders: Array = []
	_collect_offenders(root, safe, offenders)
	return {
		"ok": offenders.is_empty(),
		"viewport": {"w": vp_rect.size.x, "h": vp_rect.size.y},
		"aspect": vp_rect.size.x / maxf(1.0, vp_rect.size.y),
		"offenders": offenders,
		"deck_native": int(vp_rect.size.x) == DECK_WIDTH and int(vp_rect.size.y) == DECK_HEIGHT,
		"is_16_10": absf((vp_rect.size.x / maxf(1.0, vp_rect.size.y)) - 1.6) < 0.03,
	}


func _collect_offenders(node: Node, safe: Rect2, out: Array) -> void:
	if node is Control:
		var c: Control = node
		if c.is_visible_in_tree() and c.get_rect().size.x > 1.0 and c.get_rect().size.y > 1.0:
			var r: Rect2 = c.get_global_rect()
			## Ignore zero-alpha decorative full-rect backgrounds that intentionally
			## fill the viewport — only flag interactive / labeled chrome that clips.
			var is_chrome: bool = (
				c is Button or c is Label or c.focus_mode != Control.FOCUS_NONE
			)
			if is_chrome and not safe.encloses(r) and not safe.intersects(r):
				out.append({
					"path": str(c.get_path()),
					"rect": {"x": r.position.x, "y": r.position.y, "w": r.size.x, "h": r.size.y},
				})
			elif is_chrome and (r.position.x < safe.position.x - 1.0
					or r.position.y < safe.position.y - 1.0
					or r.end.x > safe.end.x + 1.0
					or r.end.y > safe.end.y + 1.0):
				## Partially clipped.
				if not safe.encloses(r):
					out.append({
						"path": str(c.get_path()),
						"rect": {"x": r.position.x, "y": r.position.y, "w": r.size.x, "h": r.size.y},
						"clip": true,
					})
	for child in node.get_children():
		_collect_offenders(child, safe, out)
