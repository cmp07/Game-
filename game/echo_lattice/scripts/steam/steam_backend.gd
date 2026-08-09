class_name SteamBackend
extends RefCounted
##
## Abstract Steamworks backend. Stub and GodotSteam impls share this surface.
##

signal overlay_toggled(active: bool)
signal stats_ready()
signal cloud_synced(ok: bool)


func backend_name() -> String:
	return "base"


func is_steam_available() -> bool:
	return false


func init_steam(app_id: int) -> bool:
	return false


func shutdown_steam() -> void:
	pass


func run_callbacks() -> void:
	pass


func unlock_achievement(api_name: String) -> bool:
	return false


func clear_achievement(api_name: String) -> bool:
	return false


func store_stats() -> bool:
	return false


func set_rich_presence(key: String, value: String) -> bool:
	return false


func clear_rich_presence() -> bool:
	return false


func cloud_enabled_for_account() -> bool:
	return false


func cloud_file_exists(remote_path: String) -> bool:
	return false


func cloud_read_file(remote_path: String) -> PackedByteArray:
	return PackedByteArray()


func cloud_write_file(remote_path: String, data: PackedByteArray) -> bool:
	return false


func cloud_delete_file(remote_path: String) -> bool:
	return false
