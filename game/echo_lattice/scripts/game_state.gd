extends Node
##
## GameState — global run state.
##
## Tracks which chamber the player is in, per-chamber best move counts,
## the aggregate habit profile, a global move buffer (last 30 moves),
## and induction / tutorial flags for the first-90s onboarding.
##

signal chamber_changed(new_index: int)

const MOVE_BUFFER_MAX: int = 30

var current_chamber: int = 0
var best_moves: Dictionary = {}    # chamber_id (int) -> int
var completed: Dictionary = {}     # chamber_id (int) -> true
var run_started: bool = false

# Habit profile — counts of each direction played across the whole run.
var habit_profile: Dictionary = {
	"up": 0,
	"down": 0,
	"left": 0,
	"right": 0,
}

# Cross-chamber ring buffer of the last MOVE_BUFFER_MAX directions
# stored as short strings ("u"/"d"/"l"/"r").
var move_ring: Array = []

# Tutorial / induction flags (persisted). Keys are strings from diegetic_lines.
var tutorial_flags: Dictionary = {}
var induction_complete: bool = false


func _ready() -> void:
	SaveManager.load_from_disk()


func start_new_run() -> void:
	current_chamber = 0
	best_moves.clear()
	completed.clear()
	habit_profile = {"up": 0, "down": 0, "left": 0, "right": 0}
	move_ring.clear()
	run_started = true
	SaveManager.save_to_disk()


func continue_run() -> void:
	run_started = true


func record_direction(dir: Vector2i) -> void:
	var key: String = _dir_key(dir)
	if key == "":
		return
	habit_profile[key] = int(habit_profile.get(key, 0)) + 1
	move_ring.append(key)
	if move_ring.size() > MOVE_BUFFER_MAX:
		move_ring.pop_front()


func record_chamber_win(chamber_id: int, moves: int) -> void:
	completed[chamber_id] = true
	var prev: int = int(best_moves.get(chamber_id, 999999))
	if moves < prev:
		best_moves[chamber_id] = moves
	# Induction graduation: clearing chamber 2 ("It Learned You") seals the teach.
	if chamber_id >= 2 and not induction_complete:
		induction_complete = true
		set_tutorial_flag("induction_complete")
	SaveManager.save_to_disk()


func advance_chamber() -> bool:
	current_chamber += 1
	if current_chamber >= ChamberBook.chamber_count():
		current_chamber = ChamberBook.chamber_count() - 1
		return false
	SaveManager.save_to_disk()
	emit_signal("chamber_changed", current_chamber)
	return true


func has_progress() -> bool:
	return completed.size() > 0 or current_chamber > 0


func dominant_habit() -> String:
	var best_key: String = ""
	var best_val: int = -1
	for k in habit_profile.keys():
		var v: int = int(habit_profile[k])
		if v > best_val:
			best_val = v
			best_key = k
	return best_key


func has_tutorial_flag(flag: String) -> bool:
	if flag == "":
		return false
	return bool(tutorial_flags.get(flag, false))


func set_tutorial_flag(flag: String) -> void:
	if flag == "":
		return
	tutorial_flags[flag] = true
	if flag == "induction_complete":
		induction_complete = true
	SaveManager.save_to_disk()


static func _dir_key(dir: Vector2i) -> String:
	if dir == Vector2i(0, -1):
		return "up"
	if dir == Vector2i(0, 1):
		return "down"
	if dir == Vector2i(-1, 0):
		return "left"
	if dir == Vector2i(1, 0):
		return "right"
	return ""
