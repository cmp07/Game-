extends Node
##
## DiegeticPA — short transit-board / toast lines. No text walls.
## Lines come from data/tutorial/diegetic_lines.json (≤14 words).
##

signal line_played(id: String, text: String, channel: String)

const LINES_PATH := "res://data/tutorial/diegetic_lines.json"
const DEFAULT_HOLD := 3.2

var _lines_by_id: Dictionary = {}
var _queue: Array = []
var _busy: bool = false
var _current_text: String = ""
var _current_channel: String = ""
var _hold_left: float = 0.0


func _ready() -> void:
	set_process(true)
	_load_lines()


func _process(delta: float) -> void:
	if not _busy:
		if _queue.size() > 0:
			_show_next()
		return
	_hold_left -= delta
	if _hold_left <= 0.0:
		_busy = false
		_current_text = ""
		_current_channel = ""
		emit_signal("line_played", "", "", "")


func _load_lines() -> void:
	_lines_by_id.clear()
	if not FileAccess.file_exists(LINES_PATH):
		return
	var f := FileAccess.open(LINES_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var arr = parsed.get("lines", [])
	if typeof(arr) != TYPE_ARRAY:
		return
	for item in arr:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var id: String = str(item.get("id", ""))
		if id != "":
			_lines_by_id[id] = item


func play(id: String, force: bool = false) -> void:
	if id == "" or not _lines_by_id.has(id):
		return
	var entry: Dictionary = _lines_by_id[id]
	var once_flag: String = str(entry.get("once_flag", ""))
	if once_flag != "" and not force and GameState.has_tutorial_flag(once_flag):
		return
	if once_flag != "":
		GameState.set_tutorial_flag(once_flag)
	_queue.append(entry)


func play_text(text: String, channel: String = "toast", hold: float = DEFAULT_HOLD) -> void:
	if text.strip_edges() == "":
		return
	_queue.append({
		"id": "",
		"text": text,
		"channel": channel,
		"hold": hold,
	})


func clear() -> void:
	_queue.clear()
	_busy = false
	_current_text = ""
	_current_channel = ""
	_hold_left = 0.0


func current_text() -> String:
	return _current_text


func current_channel() -> String:
	return _current_channel


func _show_next() -> void:
	var entry: Dictionary = _queue.pop_front()
	_current_text = str(entry.get("text", ""))
	_current_channel = str(entry.get("channel", "toast"))
	_hold_left = float(entry.get("hold", DEFAULT_HOLD))
	_busy = true
	emit_signal("line_played", str(entry.get("id", "")), _current_text, _current_channel)
