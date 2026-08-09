class_name SteamCloudSave
extends RefCounted
##
## Optional Steam Cloud bridge for user://save.json.
## Local disk remains authoritative when timestamps are equal/unknown.
## Prefer cloud only when remote schema `updated_at` is strictly newer.
##

const LOCAL_SAVE: String = "user://save.json"

signal pulled(ok: bool)
signal pushed(ok: bool)


func pull_if_newer(backend: SteamBackend, remote_path: String, force: bool = false) -> bool:
	if backend == null or not backend.cloud_enabled_for_account():
		pulled.emit(false)
		return false
	if not backend.cloud_file_exists(remote_path):
		pulled.emit(false)
		return false
	var bytes: PackedByteArray = backend.cloud_read_file(remote_path)
	if bytes.is_empty():
		pulled.emit(false)
		return false
	var remote_text := bytes.get_string_from_utf8()
	if remote_text.strip_edges() == "":
		pulled.emit(false)
		return false
	if FileAccess.file_exists(LOCAL_SAVE) and not force:
		var local := FileAccess.open(LOCAL_SAVE, FileAccess.READ)
		if local != null:
			var local_text := local.get_as_text()
			local.close()
			if local_text == remote_text:
				pulled.emit(true)
				return true
			if local_text.strip_edges() != "":
				var local_ts := _updated_at_from_json(local_text)
				var remote_ts := _updated_at_from_json(remote_text)
				# Strictly newer remote wins. Equal/missing timestamps ⇒ prefer local
				# (safe default while Cloud is optional / unmarketed).
				if remote_ts <= 0.0 or remote_ts <= local_ts:
					pulled.emit(false)
					return false
	var out := FileAccess.open(LOCAL_SAVE, FileAccess.WRITE)
	if out == null:
		pulled.emit(false)
		return false
	out.store_string(remote_text)
	out.close()
	pulled.emit(true)
	return true


func force_pull(backend: SteamBackend, remote_path: String) -> bool:
	return pull_if_newer(backend, remote_path, true)


func push_local(backend: SteamBackend, remote_path: String) -> bool:
	if backend == null or not backend.cloud_enabled_for_account():
		pushed.emit(false)
		return false
	if not FileAccess.file_exists(LOCAL_SAVE):
		pushed.emit(false)
		return false
	var f := FileAccess.open(LOCAL_SAVE, FileAccess.READ)
	if f == null:
		pushed.emit(false)
		return false
	var text := f.get_as_text()
	f.close()
	var ok: bool = backend.cloud_write_file(remote_path, text.to_utf8_buffer())
	pushed.emit(ok)
	return ok


func _updated_at_from_json(text: String) -> float:
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return 0.0
	var data: Dictionary = parsed
	if data.has("updated_at"):
		return float(data.get("updated_at", 0.0))
	return 0.0
