@tool
class_name ChamberLoader
extends RefCounted

## Loads Echo Lattice chamber JSON files into [Chamber] resources.
##
## Two entry points:
##   - [method load_from_path] loads one JSON file.
##   - [method load_all] scans a directory and returns every chamber it can
##     load, sorted by id (numerical prefix keeps campaign order).
##
## Fail-closed: chambers that don't pass [Chamber.validate] are dropped and
## logged. Never returns a partially-initialised chamber.

const _DEFAULT_CONTENT_DIR := "res://game/echo_lattice/content/chambers"


static func load_from_path(path: String) -> Chamber:
	var text := ""
	if path.begins_with("res://") or path.begins_with("user://"):
		if not FileAccess.file_exists(path):
			push_error("ChamberLoader: file does not exist: %s" % path)
			return null
		var f := FileAccess.open(path, FileAccess.READ)
		if f == null:
			push_error("ChamberLoader: could not open file: %s" % path)
			return null
		text = f.get_as_text()
	else:
		var f := FileAccess.open(path, FileAccess.READ)
		if f == null:
			push_error("ChamberLoader: could not open path: %s" % path)
			return null
		text = f.get_as_text()

	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("ChamberLoader: %s did not parse as an object" % path)
		return null

	var chamber := _from_dict(parsed as Dictionary)
	if chamber == null:
		return null
	var errors := chamber.validate()
	if errors.size() > 0:
		for e in errors:
			push_error("ChamberLoader: %s -> %s" % [path, e])
		return null
	return chamber


static func load_all(dir_path: String = _DEFAULT_CONTENT_DIR) -> Array[Chamber]:
	var out: Array[Chamber] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_error("ChamberLoader: could not open dir: %s" % dir_path)
		return out
	dir.list_dir_begin()
	var name := dir.get_next()
	var files: Array[String] = []
	while name != "":
		if not dir.current_is_dir() and name.ends_with(".json"):
			files.append(name)
		name = dir.get_next()
	dir.list_dir_end()
	files.sort()
	for f in files:
		var chamber := load_from_path("%s/%s" % [dir_path, f])
		if chamber != null:
			out.append(chamber)
	return out


static func _from_dict(d: Dictionary) -> Chamber:
	var c := Chamber.new()
	c.id           = str(d.get("id", ""))
	c.title        = str(d.get("title", ""))
	c.subtitle     = str(d.get("subtitle", ""))
	c.teaches      = str(d.get("teaches", ""))
	c.difficulty   = int(d.get("difficulty", 0))
	c.tick_budget  = int(d.get("tick_budget", 1))
	c.par_ticks    = d.get("par_ticks", null)
	c.par_tiles    = d.get("par_tiles", null)
	c.source_dir   = str(d.get("source_dir", "S"))
	c.intro        = str(d.get("intro", ""))
	c.outro        = str(d.get("outro", ""))
	c.music_cue    = d.get("music_cue", null)
	c.legend       = d.get("legend", {}) as Dictionary
	c.goal         = d.get("goal", {}) as Dictionary
	c.player_tools = d.get("player_tools", {}) as Dictionary
	c.variations   = d.get("variations", {}) as Dictionary

	var hints_in: Array = d.get("hints", [])
	for h in hints_in:
		c.hints.append(str(h))

	var tags_in: Array = d.get("tags", [])
	for t in tags_in:
		c.tags.append(str(t))

	var lat: Dictionary = d.get("lattice", {}) as Dictionary
	c.rows = int(lat.get("rows", 0))
	c.cols = int(lat.get("cols", 0))
	var raw_cells: Array = lat.get("cells", [])
	for r in raw_cells:
		c.cells.append(str(r))
	return c
