extends Node
##
## SaveManager — flat JSON persistence in user://save.json.
## Kept small on purpose: current chamber, per-chamber best move counts,
## completed set, and habit profile.
##

const SAVE_PATH: String = "user://save.json"


func save_to_disk() -> void:
	var data := {
		"version": 1,
		"current_chamber": GameState.current_chamber,
		"best_moves": GameState.best_moves,
		"completed": GameState.completed,
		"habit_profile": GameState.habit_profile,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Echo Lattice: could not open save file for write.")
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func load_from_disk() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	GameState.current_chamber = int(parsed.get("current_chamber", 0))
	var best = parsed.get("best_moves", {})
	if typeof(best) == TYPE_DICTIONARY:
		GameState.best_moves = _stringify_int_keys(best)
	var done = parsed.get("completed", {})
	if typeof(done) == TYPE_DICTIONARY:
		GameState.completed = _stringify_int_keys(done)
	var habit = parsed.get("habit_profile", null)
	if typeof(habit) == TYPE_DICTIONARY:
		for k in ["up", "down", "left", "right"]:
			GameState.habit_profile[k] = int(habit.get(k, 0))


func wipe() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


static func _stringify_int_keys(d: Dictionary) -> Dictionary:
	# JSON round-trip converts int keys to strings; normalise back to int.
	var out := {}
	for k in d.keys():
		var ik: int
		if typeof(k) == TYPE_STRING:
			ik = int(k)
		else:
			ik = int(k)
		out[ik] = d[k]
	return out
