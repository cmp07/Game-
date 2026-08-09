class_name SteamGodotSteamBackend
extends SteamBackend
##
## Thin GodotSteam adapter. Only used when ClassDB has `Steam` and the
## steam_enabled feature flag is on. Soft-fails every call if the singleton
## is missing mid-session so gameplay never hard-crashes.
##

var _steam: Object = null
var _ready: bool = false


func backend_name() -> String:
	return "godotsteam"


func is_steam_available() -> bool:
	return _ready and _steam != null


func init_steam(app_id: int) -> bool:
	_steam = _resolve_steam()
	if _steam == null:
		push_warning("SteamGodotSteamBackend: Steam singleton unavailable; staying inert.")
		return false
	# GodotSteam 4.x: steamInit(boolean, app_id) or steamInitEx — probe methods.
	var ok := false
	if _steam.has_method("steamInitEx"):
		var result = _steam.call("steamInitEx", app_id, true)
		# steamInitEx returns a dictionary in recent GodotSteam builds.
		if typeof(result) == TYPE_DICTIONARY:
			ok = int(result.get("status", 1)) == 0
		else:
			ok = bool(result)
	elif _steam.has_method("steamInit"):
		ok = bool(_steam.call("steamInit", true, app_id))
	else:
		push_warning("SteamGodotSteamBackend: no steamInit* method on Steam.")
		return false
	_ready = ok
	if ok and _steam.has_signal("overlay_toggled"):
		if not _steam.is_connected("overlay_toggled", Callable(self, "_on_overlay")):
			_steam.connect("overlay_toggled", Callable(self, "_on_overlay"))
	elif ok and _steam.has_signal("overlay_activated"):
		if not _steam.is_connected("overlay_activated", Callable(self, "_on_overlay")):
			_steam.connect("overlay_activated", Callable(self, "_on_overlay"))
	if ok:
		stats_ready.emit()
	return ok


func shutdown_steam() -> void:
	if _steam != null and _steam.has_method("steamShutdown"):
		_steam.call("steamShutdown")
	_ready = false


func run_callbacks() -> void:
	if _steam != null and _steam.has_method("run_callbacks"):
		_steam.call("run_callbacks")


func unlock_achievement(api_name: String) -> bool:
	if not is_steam_available() or api_name == "":
		return false
	if _steam.has_method("setAchievement"):
		_steam.call("setAchievement", api_name)
		return store_stats()
	return false


func clear_achievement(api_name: String) -> bool:
	if not is_steam_available():
		return false
	if _steam.has_method("clearAchievement"):
		_steam.call("clearAchievement", api_name)
		return store_stats()
	return false


func store_stats() -> bool:
	if not is_steam_available():
		return false
	if _steam.has_method("storeStats"):
		return bool(_steam.call("storeStats"))
	return false


func set_rich_presence(key: String, value: String) -> bool:
	if not is_steam_available():
		return false
	if _steam.has_method("setRichPresence"):
		return bool(_steam.call("setRichPresence", key, value))
	return false


func clear_rich_presence() -> bool:
	if not is_steam_available():
		return false
	if _steam.has_method("clearRichPresence"):
		_steam.call("clearRichPresence")
		return true
	return false


func cloud_enabled_for_account() -> bool:
	if not is_steam_available():
		return false
	if _steam.has_method("isCloudEnabledForAccount"):
		return bool(_steam.call("isCloudEnabledForAccount"))
	return false


func cloud_file_exists(remote_path: String) -> bool:
	if not is_steam_available():
		return false
	if _steam.has_method("fileExists"):
		return bool(_steam.call("fileExists", remote_path))
	return false


func cloud_read_file(remote_path: String) -> PackedByteArray:
	if not is_steam_available():
		return PackedByteArray()
	if _steam.has_method("fileRead"):
		var result = _steam.call("fileRead", remote_path, 0)
		if typeof(result) == TYPE_PACKED_BYTE_ARRAY:
			return result
		if typeof(result) == TYPE_STRING:
			return str(result).to_utf8_buffer()
	return PackedByteArray()


func cloud_write_file(remote_path: String, data: PackedByteArray) -> bool:
	if not is_steam_available():
		return false
	var ok := false
	if _steam.has_method("fileWrite"):
		ok = bool(_steam.call("fileWrite", remote_path, data, data.size()))
	cloud_synced.emit(ok)
	return ok


func cloud_delete_file(remote_path: String) -> bool:
	if not is_steam_available():
		return false
	if _steam.has_method("fileDelete"):
		return bool(_steam.call("fileDelete", remote_path))
	return false


func _on_overlay(active: bool) -> void:
	overlay_toggled.emit(active)


static func is_godotsteam_present() -> bool:
	if Engine.has_singleton("Steam"):
		return true
	if ClassDB.class_exists("Steam"):
		return true
	return false


func _resolve_steam() -> Object:
	if Engine.has_singleton("Steam"):
		return Engine.get_singleton("Steam")
	# Some GodotSteam installs expose an autoload node named Steam.
	var tree := Engine.get_main_loop()
	if tree is SceneTree:
		var root: Node = (tree as SceneTree).root
		if root != null and root.has_node("Steam"):
			return root.get_node("Steam")
	return null
