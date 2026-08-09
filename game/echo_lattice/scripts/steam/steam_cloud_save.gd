class_name SteamCloudSave
extends RefCounted
##
## Optional Steam Cloud bridge for user://save.json.
## Local disk remains authoritative; cloud is best-effort sync.
## SEC-02: remote payloads are schema-validated before replacing local save.
##

const LOCAL_SAVE: String = "user://save.json"
const LOCAL_SAVE_CLOUD_TMP: String = "user://save.json.cloud.tmp"

signal pulled(ok: bool)
signal pushed(ok: bool)


func pull_if_newer(backend: SteamBackend, remote_path: String) -> bool:
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
	if bytes.size() > SaveManager.SAVE_MAX_BYTES:
		push_warning("SteamCloudSave: remote save exceeds size cap; refusing pull.")
		pulled.emit(false)
		return false
	var remote_text := bytes.get_string_from_utf8()
	if remote_text.strip_edges() == "":
		pulled.emit(false)
		return false
	var validation: Dictionary = SaveManager.validate_save_text(remote_text)
	if not bool(validation.get("ok", false)):
		push_warning(
			"SteamCloudSave: remote save failed schema validation (%s); refusing pull."
			% str(validation.get("reason", "unknown"))
		)
		pulled.emit(false)
		return false
	# Prefer cloud when local missing; otherwise last-write-wins by mtime approx.
	if FileAccess.file_exists(LOCAL_SAVE):
		var local := FileAccess.open(LOCAL_SAVE, FileAccess.READ)
		if local != null:
			var local_text := local.get_as_text()
			local.close()
			if local_text == remote_text:
				pulled.emit(true)
				return true
			# Keep local if both exist and differ — Steam Cloud path config +
			# Partner conflict policy can refine this later. Still allow force
			# via empty local.
			if local_text.strip_edges() != "":
				pulled.emit(false)
				return false
	if not _atomic_write_local(remote_text):
		pulled.emit(false)
		return false
	pulled.emit(true)
	return true


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
	var validation: Dictionary = SaveManager.validate_save_text(text)
	if not bool(validation.get("ok", false)):
		push_warning(
			"SteamCloudSave: refusing to push invalid local save (%s)."
			% str(validation.get("reason", "unknown"))
		)
		pushed.emit(false)
		return false
	var ok: bool = backend.cloud_write_file(remote_path, text.to_utf8_buffer())
	pushed.emit(ok)
	return ok


func _atomic_write_local(payload: String) -> bool:
	var tmp := FileAccess.open(LOCAL_SAVE_CLOUD_TMP, FileAccess.WRITE)
	if tmp == null:
		push_warning("SteamCloudSave: could not open cloud tmp for write.")
		return false
	tmp.store_string(payload)
	tmp.close()
	var abs_path: String = ProjectSettings.globalize_path(LOCAL_SAVE)
	var abs_tmp: String = ProjectSettings.globalize_path(LOCAL_SAVE_CLOUD_TMP)
	var ren: Error = DirAccess.rename_absolute(abs_tmp, abs_path)
	if ren != OK:
		var direct := FileAccess.open(LOCAL_SAVE, FileAccess.WRITE)
		if direct == null:
			push_warning("SteamCloudSave: atomic rename failed (%s)." % ren)
			return false
		direct.store_string(payload)
		direct.close()
		if FileAccess.file_exists(LOCAL_SAVE_CLOUD_TMP):
			DirAccess.remove_absolute(abs_tmp)
	return true
