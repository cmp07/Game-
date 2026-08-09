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


static func from_balance(bal: BalanceTuning = null) -> LocalTelemetry:
	var tuning := bal if bal != null else BalanceTuning.load_default()
	var cfg: Dictionary = tuning.telemetry_config()
	var tel := LocalTelemetry.new()
	tel.enabled = bool(cfg.get("enabled_default", true))
	tel.path = str(cfg.get("path", tel.path))
	tel.schema_version = int(tuning.data.get("schema_version", 2))
	tel._flush_every = int(cfg.get("flush_every_events", 1))
	for ev in cfg.get("events", []):
		tel._allowed[str(ev)] = true
	return tel


func set_context(ctx: Dictionary) -> void:
	default_context = ctx.duplicate(true)


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
	for k in payload.keys():
		row[k] = payload[k]

	_append_line(JSON.stringify(row))
	_pending += 1
	event_emitted.emit(event_name, row)
	if _pending >= _flush_every:
		_pending = 0


func emit_softlock_assert_failed(detail: Dictionary = {}) -> void:
	emit("softlock_assert_failed", detail)


func _append_line(line: String) -> void:
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
