extends Node
class_name CrashLogHookImpl
##
## Local crash / log hook. Append-only JSONL under user://logs/.
## Optional upload is intentionally a no-op unless upload_url is set AND
## settings.crash_upload_opt_in is true (network client not bundled in 1.0).
##
## Autoload name: CrashLogHook (see project.godot).
##

const SCHEMA_VERSION: int = 1
const CRASH_PATH: String = "user://logs/echo_lattice_crash.jsonl"
const SESSION_PATH: String = "user://logs/echo_lattice_session.jsonl"
const LAST_SESSION_PATH: String = "user://logs/last_session.json"
const SESSION_RING_MAX: int = 200

signal event_written(channel: String, row: Dictionary)

var build_id: String = "dev"
var upload_url: String = ""
var opt_in_upload: bool = false
var context: Dictionary = {}

var _session_lines: PackedStringArray = PackedStringArray()
var _upload_attempts_today: int = 0
var _upload_day: String = ""
var _configured: bool = false


func _ready() -> void:
	var ver := str(ProjectSettings.get_setting("application/config/version", "dev"))
	configure(ver, "")
	var store := get_node_or_null("/root/SettingsStore")
	if store != null and store.has_method("get_value"):
		set_opt_in_upload(bool(store.get_value("support", "crash_upload_opt_in", false)))


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		mark_clean_shutdown()


func configure(p_build_id: String, p_upload_url: String = "") -> void:
	build_id = p_build_id
	upload_url = p_upload_url
	_ensure_log_dir()
	var unclean := _last_session_was_unclean()
	if not _configured:
		breadcrumb("boot", {
			"upload_configured": upload_url != "",
			"prior_session_unclean": unclean,
		})
		_configured = true
	# Mark boot as open until clean shutdown is written.
	_write_last_session(false)


func set_context(ctx: Dictionary) -> void:
	context = ctx.duplicate(true)


func set_opt_in_upload(enabled: bool) -> void:
	opt_in_upload = enabled


func breadcrumb(scene: String, detail: Dictionary = {}) -> void:
	var row := _base_row("session", "breadcrumb")
	row["scene"] = scene
	for k in detail.keys():
		row[k] = detail[k]
	_append(SESSION_PATH, row)
	_remember_session_line(JSON.stringify(row))
	event_written.emit("session", row)


func report_engine_error(message: String, stack: PackedStringArray = PackedStringArray()) -> void:
	var row := _base_row("crash", "engine_error")
	row["fingerprint"] = message
	row["stack"] = _stack_to_array(stack)
	row["signature"] = _signature("engine_error", message, row["stack"])
	row["context"] = context.duplicate(true)
	_append(CRASH_PATH, row)
	event_written.emit("crash", row)


func report_softlock(detail: Dictionary = {}) -> void:
	var row := _base_row("crash", "softlock")
	row["fingerprint"] = str(detail.get("reason", "softlock_assert_failed"))
	row["detail"] = detail.duplicate(true)
	row["context"] = context.duplicate(true)
	row["signature"] = _signature("softlock", str(row["fingerprint"]), [])
	_append(CRASH_PATH, row)
	event_written.emit("crash", row)


func mark_clean_shutdown() -> void:
	_write_last_session(true)
	breadcrumb("shutdown", {"clean": true})


func _write_last_session(clean: bool) -> void:
	_ensure_log_dir()
	var payload := {
		"schema_version": SCHEMA_VERSION,
		"build_id": build_id,
		"t_unix_ms": Time.get_unix_time_from_system() * 1000.0,
		"clean": clean,
	}
	var f := FileAccess.open(LAST_SESSION_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(payload))
		f.close()


func _last_session_was_unclean() -> bool:
	if not FileAccess.file_exists(LAST_SESSION_PATH):
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LAST_SESSION_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return true
	return not bool((parsed as Dictionary).get("clean", false))


func export_crash_pack(dest_dir: String, include_balance_tail: bool = false) -> String:
	_ensure_log_dir()
	var stamp := Time.get_datetime_string_from_system(true, true).replace(":", "").replace("-", "")
	var folder := dest_dir.path_join("echo_lattice_crash_%s" % stamp)
	DirAccess.make_dir_recursive_absolute(folder)

	_write_text(folder.path_join("meta.json"), JSON.stringify({
		"schema_version": SCHEMA_VERSION,
		"build_id": build_id,
		"exported_at_utc": Time.get_datetime_string_from_system(true, true),
		"os": OS.get_name(),
		"godot": Engine.get_version_info().get("string", ""),
		"upload_url_configured": upload_url != "",
		"opt_in_upload": opt_in_upload,
	}, "\t"))

	_copy_if_exists(CRASH_PATH, folder.path_join("crash.jsonl"))
	_copy_if_exists(SESSION_PATH, folder.path_join("session.jsonl"))
	_write_text(folder.path_join("save_head.json"), JSON.stringify(_redacted_save_head(), "\t"))

	if include_balance_tail:
		var bal := "user://telemetry/echo_lattice_balance.jsonl"
		if FileAccess.file_exists(bal):
			_write_text(folder.path_join("balance_tail.jsonl"), _tail_lines(bal, 100))

	return folder


func maybe_upload_latest() -> Dictionary:
	## 1.0: local-only. Returns status without performing network I/O.
	if upload_url == "":
		return {"ok": false, "reason": "upload_url_empty"}
	if not opt_in_upload:
		return {"ok": false, "reason": "opt_in_false"}
	var today := _utc_date()
	if _upload_day != today:
		_upload_day = today
		_upload_attempts_today = 0
	if _upload_attempts_today >= 3:
		return {"ok": false, "reason": "rate_limited"}
	# Network client intentionally omitted for 1.0 fence.
	return {"ok": false, "reason": "upload_client_not_bundled", "would_post_to": upload_url}


func _base_row(channel: String, kind: String) -> Dictionary:
	return {
		"channel": channel,
		"schema_version": SCHEMA_VERSION,
		"t_unix_ms": Time.get_unix_time_from_system() * 1000.0,
		"build_id": build_id,
		"godot": Engine.get_version_info().get("string", ""),
		"os": OS.get_name(),
		"kind": kind,
	}


func _append(path: String, row: Dictionary) -> void:
	_ensure_log_dir()
	var f := FileAccess.open(path, FileAccess.READ_WRITE)
	if f == null:
		f = FileAccess.open(path, FileAccess.WRITE_READ)
	if f == null:
		push_error("CrashLogHook: cannot open %s" % path)
		return
	f.seek_end()
	f.store_line(JSON.stringify(row))
	f.flush()
	f.close()


func _ensure_log_dir() -> void:
	var dir := ProjectSettings.globalize_path("user://logs")
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)


func _stack_to_array(stack: PackedStringArray) -> Array:
	var out: Array = []
	var n: int = mini(stack.size(), 32)
	for i in range(n):
		out.append(stack[i])
	return out


func _signature(kind: String, fingerprint: String, stack: Array) -> String:
	var top := str(stack[0]) if not stack.is_empty() else ""
	var raw := "%s|%s|%s" % [kind, fingerprint, top]
	return "sig_%08x" % (raw.hash() & 0xFFFFFFFF)


func _remember_session_line(line: String) -> void:
	_session_lines.append(line)
	if _session_lines.size() > SESSION_RING_MAX:
		_session_lines = _session_lines.slice(_session_lines.size() - SESSION_RING_MAX)


func _redacted_save_head() -> Dictionary:
	var path := "user://save.json"
	if not FileAccess.file_exists(path):
		return {"present": false}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"present": true, "parse_ok": false}
	var save: Dictionary = parsed
	var unlocks: Dictionary = save.get("unlocks", {})
	return {
		"present": true,
		"parse_ok": true,
		"version": save.get("version", 0),
		"unlocks_chambers": (unlocks.get("chambers", []) as Array).size(),
		"unlocks_cosmetics": (unlocks.get("cosmetics", []) as Array).size(),
		"last_daily_date": save.get("stats", {}).get("last_daily_date", save.get("seeds", {}).get("last_daily_date", "")),
		"museum_count": (save.get("museum", {}).get("selves", []) as Array).size(),
		# profile.name intentionally omitted
	}


func _copy_if_exists(src: String, dest: String) -> void:
	if not FileAccess.file_exists(src):
		_write_text(dest, "")
		return
	_write_text(dest, FileAccess.get_file_as_string(src))


func _write_text(path: String, text: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(text)
		f.close()


func _tail_lines(path: String, n: int) -> String:
	var raw := FileAccess.get_file_as_string(path)
	var lines := raw.split("\n", false)
	if lines.size() <= n:
		return raw if raw.ends_with("\n") else raw + "\n"
	var slice := lines.slice(lines.size() - n)
	return "\n".join(slice) + "\n"


func _utc_date() -> String:
	var t: Dictionary = Time.get_datetime_dict_from_system(true)
	return "%04d-%02d-%02d" % [int(t.year), int(t.month), int(t.day)]
