extends Node
##
## SteamService — Steamworks readiness facade (autoload).
##
## Default path is fully offline: stub backend + feature flags.
## When `steam_enabled` is true and GodotSteam is present, swaps to the real
## backend. Missing SDK / invalid AppID / Spacewar-in-release are fail-closed:
## Steam APIs stay disabled (no fake unlocks, no Spacewar 480).
##

signal backend_changed(name: String)
signal achievement_unlocked(api_name: String)
signal presence_changed(status: String)
signal overlay_paused(active: bool)

const FEATURES_PATH: String = "res://config/steam_features.json"
const SPACEWAR_APP_ID: int = 480

var features: Dictionary = {}
var backend: SteamBackend = null
var achievements: SteamAchievements = SteamAchievements.new()
var cloud: SteamCloudSave = SteamCloudSave.new()

var _overlay_was_tree_paused: bool = false
var _presence_status: String = ""
## True when steam_enabled requested GodotSteam but the SDK/singleton is absent.
var _steam_sdk_fail_closed: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_features()
	_select_backend()
	achievements.load_catalog()
	achievements.unlocked.connect(func(api: String): achievement_unlocked.emit(api))
	if backend != null:
		backend.overlay_toggled.connect(_on_overlay_toggled)
		var app_id: int = _resolve_app_id()
		# SEC-01: fail closed — never init Steam without a real (or explicitly
		# allowed Spacewar) AppID. Stub still records a no-op init at 0 for offline.
		if _steam_sdk_fail_closed:
			push_warning(
				"SteamService: skipping Steam init (GodotSteam SDK missing; fail-closed)."
			)
			backend.init_steam(0)
		elif app_id > 0:
			backend.init_steam(app_id)
		elif bool(features.get("steam_enabled", false)):
			push_warning(
				"SteamService: steam_enabled but no valid AppID; Steam stays disabled."
			)
		else:
			backend.init_steam(0)
	if bool(features.get("cloud_save_enabled", false)) and not _steam_sdk_fail_closed:
		cloud.pull_if_newer(backend, str(features.get("cloud_remote_path", "save.json")))
	set_menu_presence()


func _process(_delta: float) -> void:
	if backend != null and bool(features.get("steam_enabled", false)) and not _steam_sdk_fail_closed:
		backend.run_callbacks()


func is_using_steam() -> bool:
	return backend != null and backend.is_steam_available() and not _steam_sdk_fail_closed


func is_steam_sdk_fail_closed() -> bool:
	return _steam_sdk_fail_closed


func backend_name() -> String:
	return backend.backend_name() if backend != null else "none"


func reload_features() -> void:
	_load_features()
	_select_backend()


func unlock_achievement(api_name: String) -> bool:
	if _steam_sdk_fail_closed:
		return false
	if not bool(features.get("achievements_enabled", true)):
		return false
	if backend == null or api_name == "":
		return false
	var ok: bool = backend.unlock_achievement(api_name)
	if ok:
		backend.store_stats()
		achievement_unlocked.emit(api_name)
	return ok


func evaluate_achievements() -> PackedStringArray:
	if _steam_sdk_fail_closed:
		return PackedStringArray()
	if not bool(features.get("achievements_enabled", true)):
		return PackedStringArray()
	return achievements.evaluate_and_unlock(backend)


func set_rich_presence_status(status: String) -> void:
	if not bool(features.get("rich_presence_enabled", true)):
		return
	_presence_status = status
	if backend != null and not _steam_sdk_fail_closed:
		backend.set_rich_presence("steam_display", "#Status")
		backend.set_rich_presence("status", status)
	presence_changed.emit(status)


func clear_rich_presence() -> void:
	_presence_status = ""
	if backend != null:
		backend.clear_rich_presence()
	presence_changed.emit("")


func set_menu_presence() -> void:
	var tpl: Dictionary = features.get("presence", {})
	set_rich_presence_status(str(tpl.get("menu", "At the Field Ledger")))


func set_chamber_presence(chamber_id: int) -> void:
	var tpl: Dictionary = features.get("presence", {})
	var title := "Chamber %d" % chamber_id
	if has_node("/root/ChamberBook"):
		var data: Dictionary = ChamberBook.get_chamber(chamber_id)
		title = str(data.get("title", title))
	var status: String
	if has_node("/root/GameState") and GameState.run_mode == "daily":
		status = str(tpl.get("daily_template", "Daily {label}")).format({
			"label": GameState.daily_label,
		})
	elif has_node("/root/GameState") and GameState.run_mode == "endless":
		status = str(tpl.get("endless_template", "Endless {label} · depth {depth}")).format({
			"label": GameState.endless_label,
			"depth": GameState.endless_depth + 1,
		})
	else:
		status = str(tpl.get("chamber_template", "Chamber {index}: {title}")).format({
			"index": chamber_id + 1,
			"title": title,
		})
	set_rich_presence_status(status)


func set_won_presence(chamber_id: int) -> void:
	var tpl: Dictionary = features.get("presence", {})
	var title := "Chamber %d" % chamber_id
	if has_node("/root/ChamberBook"):
		var data: Dictionary = ChamberBook.get_chamber(chamber_id)
		title = str(data.get("title", title))
	set_rich_presence_status(str(tpl.get("won_template", "Cleared {title}")).format({
		"title": title,
	}))


func set_end_presence() -> void:
	var tpl: Dictionary = features.get("presence", {})
	set_rich_presence_status(str(tpl.get("end", "Wing complete")))


func notify_chamber_cleared(_chamber_id: int, _moves: int = 0) -> void:
	evaluate_achievements()
	if bool(features.get("cloud_save_enabled", false)):
		push_cloud_save()


func push_cloud_save() -> bool:
	if _steam_sdk_fail_closed:
		return false
	if not bool(features.get("cloud_save_enabled", false)):
		return false
	return cloud.push_local(backend, str(features.get("cloud_remote_path", "save.json")))


func pull_cloud_save() -> bool:
	if _steam_sdk_fail_closed:
		return false
	if not bool(features.get("cloud_save_enabled", false)):
		return false
	return cloud.pull_if_newer(backend, str(features.get("cloud_remote_path", "save.json")))


func force_pull_cloud_save() -> bool:
	## Debug / recovery: overwrite local with cloud regardless of updated_at.
	if _steam_sdk_fail_closed:
		return false
	if not bool(features.get("cloud_save_enabled", false)):
		return false
	return cloud.force_pull(backend, str(features.get("cloud_remote_path", "save.json")))


## Debug / tests: force stub overlay event.
func debug_simulate_overlay(active: bool) -> void:
	if backend is SteamStubBackend:
		(backend as SteamStubBackend).simulate_overlay(active)


func _on_overlay_toggled(active: bool) -> void:
	if not bool(features.get("overlay_pause_enabled", true)):
		overlay_paused.emit(active)
		return
	var tree := get_tree()
	if tree == null:
		return
	if active:
		_overlay_was_tree_paused = tree.paused
		tree.paused = true
		if has_node("/root/AdaptiveMusic"):
			AdaptiveMusic.set_paused(true)
	else:
		tree.paused = _overlay_was_tree_paused
		if has_node("/root/AdaptiveMusic") and not _overlay_was_tree_paused:
			AdaptiveMusic.set_paused(false)
	overlay_paused.emit(active)


func _load_features() -> void:
	features = {
		"steam_enabled": false,
		"achievements_enabled": true,
		"rich_presence_enabled": true,
		"cloud_save_enabled": false,
		"overlay_pause_enabled": true,
		"prefer_godotsteam_when_present": true,
		"app_id_placeholder": "YOUR_APP_ID",
		"spacewar_dev_app_id": 480,
		"allow_spacewar_dev": false,
		"wishlist_cta_enabled": true,
		"store_wishlist_url": "",
		"store_page_url": "",
		"cloud_remote_path": "save.json",
		"presence": {
			"menu": "At the Field Ledger",
			"chamber_template": "Chamber {index}: {title}",
			"daily_template": "Daily {label}",
			"endless_template": "Endless {label} · depth {depth}",
			"won_template": "Cleared {title}",
			"end": "Wing complete",
		},
	}
	if not FileAccess.file_exists(FEATURES_PATH):
		return
	var f := FileAccess.open(FEATURES_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		for k in parsed.keys():
			features[k] = parsed[k]


func _select_backend() -> void:
	_steam_sdk_fail_closed = false
	var steam_on: bool = bool(features.get("steam_enabled", false))
	var prefer_real: bool = bool(features.get("prefer_godotsteam_when_present", true))
	var sdk_present: bool = SteamGodotSteamBackend.is_godotsteam_present()
	if steam_on and prefer_real and sdk_present:
		backend = SteamGodotSteamBackend.new()
	else:
		backend = SteamStubBackend.new()
		if steam_on and prefer_real and not sdk_present:
			# Fail-closed without SDK: keep the offline stub for gameplay, but do
			# not fake Steam unlocks / cloud / presence as if the client were live.
			_steam_sdk_fail_closed = true
			var msg := (
				"SteamService: steam_enabled but GodotSteam SDK missing; "
				+ "fail-closed (Steam APIs disabled). See docs/RELEASE/GODOTSTEAM.md."
			)
			if _is_shipping_steam_context():
				push_error(msg)
			else:
				push_warning(msg)
	backend_changed.emit(backend.backend_name())


func _resolve_app_id() -> int:
	# steam_appid.txt beside executable wins for local exported builds.
	# Retail Steam launches should not ship this file (depot FileExclusion).
	var beside := OS.get_executable_path().get_base_dir().path_join("steam_appid.txt")
	if FileAccess.file_exists(beside):
		var f := FileAccess.open(beside, FileAccess.READ)
		if f != null:
			var raw := f.get_as_text().strip_edges()
			f.close()
			if raw.is_valid_int():
				var from_file: int = int(raw)
				if _is_allowed_app_id(from_file):
					return from_file
				push_warning(
					"SteamService: rejecting steam_appid.txt AppID %d (Spacewar/invalid without allow_spacewar_dev)."
					% from_file
				)
	var placeholder := str(features.get("app_id_placeholder", "YOUR_APP_ID"))
	if placeholder.is_valid_int():
		var from_cfg: int = int(placeholder)
		if _is_allowed_app_id(from_cfg):
			return from_cfg
		push_warning(
			"SteamService: rejecting configured AppID %d (Spacewar/invalid without allow_spacewar_dev)."
			% from_cfg
		)
	# SEC-01: never silently fall back to Spacewar 480. Only when the dedicated
	# flag is on and we are in editor/debug — never in shipping/release.
	if _spacewar_dev_allowed():
		return int(features.get("spacewar_dev_app_id", SPACEWAR_APP_ID))
	if bool(features.get("steam_enabled", false)):
		push_warning(
			"SteamService: no real AppID configured; refusing Spacewar fallback (fail-closed)."
		)
	return 0


func _is_allowed_app_id(app_id: int) -> bool:
	if app_id <= 0:
		return false
	if app_id == int(features.get("spacewar_dev_app_id", SPACEWAR_APP_ID)):
		return _spacewar_dev_allowed()
	return true


func _spacewar_dev_allowed() -> bool:
	if not bool(features.get("allow_spacewar_dev", false)):
		return false
	# Shipping/release exports must never resolve Spacewar even if the flag
	# were accidentally left true in a mis-copied config.
	if _is_shipping_steam_context():
		return false
	return OS.has_feature("editor") or OS.is_debug_build()


func _is_shipping_steam_context() -> bool:
	# custom_features="steam" on Steam-branded exports, or any non-editor release build.
	if OS.has_feature("steam"):
		return true
	return not OS.has_feature("editor") and not OS.is_debug_build()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		if bool(features.get("cloud_save_enabled", false)):
			push_cloud_save()
		if backend != null:
			backend.clear_rich_presence()
			backend.shutdown_steam()
