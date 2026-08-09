extends Node
##
## GameState — global run state for Echo Lattice v2.
## Tracks chambers, habit profile, stars, and daily challenge mode.
##

signal chamber_changed(new_index: int)

const MOVE_BUFFER_MAX: int = 30

var current_chamber: int = 0
var best_moves: Dictionary = {}    # chamber_id -> int
var best_stars: Dictionary = {}    # chamber_id -> int (1..3)
var completed: Dictionary = {}     # chamber_id -> true
var run_started: bool = false

# "standard" full book, or "daily" five-chamber wing
var run_mode: String = "standard"
var daily_seed: int = 0
var daily_label: String = ""
var run_queue: Array = []          # chamber indices for this run
var queue_pos: int = 0
var daily_best_stars: Dictionary = {}  # seed_str -> total stars
var last_clear_stars: int = 0
var last_clear_bfs_par: int = 0

var habit_profile: Dictionary = {
	"up": 0,
	"down": 0,
	"left": 0,
	"right": 0,
}

var move_ring: Array = []


func _ready() -> void:
	SaveManager.load_from_disk()


func start_new_run() -> void:
	run_mode = "standard"
	daily_seed = 0
	daily_label = ""
	run_queue.clear()
	for i in range(ChamberBook.chamber_count()):
		run_queue.append(i)
	queue_pos = 0
	current_chamber = int(run_queue[0])
	habit_profile = {"up": 0, "down": 0, "left": 0, "right": 0}
	move_ring.clear()
	run_started = true
	SaveManager.save_to_disk()


func start_daily_run() -> void:
	run_mode = "daily"
	daily_seed = _today_seed()
	daily_label = _today_label()
	run_queue = ChamberBook.daily_chamber_indices(daily_seed, 5)
	queue_pos = 0
	current_chamber = int(run_queue[0]) if run_queue.size() > 0 else 0
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
	var bal := BalanceTuning.load_default()
	var window: int = bal.habit_window(ChamberBook.act_for_chamber(current_chamber))
	if window < 8:
		window = MOVE_BUFFER_MAX
	if move_ring.size() > window:
		move_ring.pop_front()


func record_chamber_win(chamber_id: int, moves: int, bfs_par: int = -1) -> void:
	completed[chamber_id] = true
	var prev: int = int(best_moves.get(chamber_id, 999999))
	if moves < prev:
		best_moves[chamber_id] = moves
	var act_id: int = ChamberBook.act_for_chamber(chamber_id)
	var par: int = bfs_par if bfs_par > 0 else moves
	var stars: int = StarRater.rate(moves, par, act_id, "standard")
	last_clear_stars = stars
	last_clear_bfs_par = par
	var prev_stars: int = int(best_stars.get(chamber_id, 0))
	if stars > prev_stars:
		best_stars[chamber_id] = stars
	if run_mode == "daily":
		_update_daily_stars()
	SaveManager.save_to_disk()
	if Engine.get_main_loop() is SceneTree:
		var root: Node = (Engine.get_main_loop() as SceneTree).root
		if root != null and root.has_node("SteamService"):
			root.get_node("SteamService").notify_chamber_cleared(chamber_id, moves)


func last_stars(chamber_id: int, moves: int, bfs_par: int) -> int:
	var act_id: int = ChamberBook.act_for_chamber(chamber_id)
	return StarRater.rate(moves, bfs_par, act_id, "standard")


func advance_chamber() -> bool:
	queue_pos += 1
	if queue_pos >= run_queue.size():
		if run_queue.size() > 0:
			current_chamber = int(run_queue[run_queue.size() - 1])
		return false
	current_chamber = int(run_queue[queue_pos])
	SaveManager.save_to_disk()
	emit_signal("chamber_changed", current_chamber)
	return true


func chambers_in_run() -> int:
	return run_queue.size() if run_queue.size() > 0 else ChamberBook.chamber_count()


func run_progress_index() -> int:
	return queue_pos


func has_progress() -> bool:
	return completed.size() > 0 or queue_pos > 0 or current_chamber > 0


func total_stars_earned() -> int:
	var s: int = 0
	for k in best_stars.keys():
		s += int(best_stars[k])
	return s


func dominant_habit() -> String:
	var best_key: String = ""
	var best_val: int = -1
	for k in habit_profile.keys():
		var v: int = int(habit_profile[k])
		if v > best_val:
			best_val = v
			best_key = k
	return best_key


func _update_daily_stars() -> void:
	var key: String = str(daily_seed)
	var total: int = 0
	for idx in run_queue:
		total += int(best_stars.get(int(idx), 0))
	var prev: int = int(daily_best_stars.get(key, 0))
	if total > prev:
		daily_best_stars[key] = total


func _today_seed() -> int:
	var dt := Time.get_datetime_dict_from_system(true)
	return int(dt.year) * 10000 + int(dt.month) * 100 + int(dt.day)


func _today_label() -> String:
	var dt := Time.get_datetime_dict_from_system(true)
	return "%04d-%02d-%02d" % [int(dt.year), int(dt.month), int(dt.day)]


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
