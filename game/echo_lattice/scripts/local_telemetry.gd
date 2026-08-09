class_name LocalTelemetry
extends RefCounted

## Append-only local JSONL telemetry for balance tuning.
## Never uploads. Path defaults to user://telemetry/echo_lattice_balance.jsonl.

signal event_emitted(name: String, payload: Dictionary)

var enabled: bool = true
var path: String = "user://telemetry/echo_lattice_balance.jsonl"
var schema_version: int = 2
var default_context: Dictionary = {}
var _flush_every: int = 1
var _pending: int = 0
var _allowed: Dictionary = {}


const SAFE_PATH_PREFIX := "user://telemetry/"
const DEFAULT_SAFE_PATH := "user://telemetry/echo_lattice_balance.jsonl"
## Drop these when include_pii is false (SEC-08).
const PII_KEYS := [
	"steam_id",
	"account_name",
	"player_name",
	"display_name",
	"email",
	"ip",
	"device_id",
	"hardware_id",
]

var include_pii: bool = false


static func from_balance(bal: BalanceTuning = null) -> LocalTelemetry:
	var tuning := bal if bal != null else BalanceTuning.load_default()
	var cfg: Dictionary = tuning.telemetry_config()
	var tel := LocalTelemetry.new()
	tel.enabled = bool(cfg.get("enabled_default", true))
	tel.path = sanitize_path(str(cfg.get("path", tel.path)))
	tel.include_pii = bool(cfg.get("include_pii", false))
	tel.schema_version = int(tuning.data.get("schema_version", 2))
	tel._flush_every = int(cfg.get("flush_every_events", 1))
	for ev in cfg.get("events", []):
		tel._allowed[str(ev)] = true
	return tel


static func sanitize_path(raw: String) -> String:
	## SEC-04: only user://telemetry/** (no abs paths, no ..).
	var p := raw.strip_edges().replace("\\", "/")
	if p == "" or p.contains(".."):
		return DEFAULT_SAFE_PATH
	if not p.begins_with(SAFE_PATH_PREFIX):
		return DEFAULT_SAFE_PATH
	# Reject empty filename / trailing slash only.
	var rest := p.substr(SAFE_PATH_PREFIX.length())
	if rest == "" or rest.ends_with("/"):
		return DEFAULT_SAFE_PATH
	return p


func set_context(ctx: Dictionary) -> void:
	default_context = _scrub_pii(ctx.duplicate(true))


func emit(event_name: String, payload: Dictionary = {}) -> void:
	if not enabled:
		return
	if not _allowed.is_empty() and not _allowed.has(event_name):
		push_warning("LocalTelemetry: dropping unknown event '%s'" % event_name)
		return

	var row := {
		"event": event_name,
		"schema_version": schema_version,
		"t_unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}
	for k in default_context.keys():
		row[k] = default_context[k]
	var scrubbed: Dictionary = _scrub_pii(payload)
	for k in scrubbed.keys():
		row[k] = scrubbed[k]

	_append_line(JSON.stringify(row))
	_pending += 1
	event_emitted.emit(event_name, row)
	if _pending >= _flush_every:
		_pending = 0


func emit_softlock_assert_failed(detail: Dictionary = {}) -> void:
	emit("softlock_assert_failed", detail)


func _scrub_pii(data: Dictionary) -> Dictionary:
	if include_pii:
		return data
	var out := {}
	for k in data.keys():
		var key := str(k)
		if key in PII_KEYS:
			continue
		out[k] = data[k]
	return out


func _append_line(line: String) -> void:
	path = sanitize_path(path)
	var dir := path.get_base_dir()
	if dir != "" and not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(dir)):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var f := FileAccess.open(path, FileAccess.READ_WRITE)
	if f == null:
		f = FileAccess.open(path, FileAccess.WRITE_READ)
	if f == null:
		push_error("LocalTelemetry: cannot open %s (%s)" % [path, FileAccess.get_open_error()])
		return
	f.seek_end()
	f.store_line(line)
	f.flush()
	f.close()
