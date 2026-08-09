class_name SteamStubBackend
extends SteamBackend
##
## Offline / no-Steam backend. Records calls for tests; never touches steam_api.
##

var _init_ok: bool = true
var _app_id: int = 0
var unlocked: Dictionary = {}  # api_name -> true
var presence: Dictionary = {}  # key -> value
var cloud_files: Dictionary = {}  # path -> PackedByteArray
var overlay_active: bool = false
var call_log: Array = []


func backend_name() -> String:
	return "stub"


func is_steam_available() -> bool:
	return false


func init_steam(app_id: int) -> bool:
	_app_id = app_id
	_init_ok = true
	_log("init", {"app_id": app_id})
	stats_ready.emit()
	return true


func shutdown_steam() -> void:
	_log("shutdown", {})


func unlock_achievement(api_name: String) -> bool:
	if api_name == "":
		return false
	unlocked[api_name] = true
	_log("unlock_achievement", {"api_name": api_name})
	return true


func clear_achievement(api_name: String) -> bool:
	unlocked.erase(api_name)
	_log("clear_achievement", {"api_name": api_name})
	return true


func store_stats() -> bool:
	_log("store_stats", {"count": unlocked.size()})
	return true


func set_rich_presence(key: String, value: String) -> bool:
	presence[key] = value
	_log("set_rich_presence", {"key": key, "value": value})
	return true


func clear_rich_presence() -> bool:
	presence.clear()
	_log("clear_rich_presence", {})
	return true


func cloud_enabled_for_account() -> bool:
	return true


func cloud_file_exists(remote_path: String) -> bool:
	return cloud_files.has(remote_path)


func cloud_read_file(remote_path: String) -> PackedByteArray:
	if not cloud_files.has(remote_path):
		return PackedByteArray()
	return cloud_files[remote_path]


func cloud_write_file(remote_path: String, data: PackedByteArray) -> bool:
	cloud_files[remote_path] = data
	_log("cloud_write", {"path": remote_path, "bytes": data.size()})
	cloud_synced.emit(true)
	return true


func cloud_delete_file(remote_path: String) -> bool:
	cloud_files.erase(remote_path)
	_log("cloud_delete", {"path": remote_path})
	return true


## Test / debug helper — simulate Steam overlay open/close.
func simulate_overlay(active: bool) -> void:
	overlay_active = active
	_log("overlay", {"active": active})
	overlay_toggled.emit(active)


func _log(op: String, payload: Dictionary) -> void:
	var row := {"op": op}
	for k in payload.keys():
		row[k] = payload[k]
	call_log.append(row)
