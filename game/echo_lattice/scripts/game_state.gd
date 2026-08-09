extends Node
##
## GameState — global run state for Echo Lattice v2.
## Tracks chambers, habit profile, stars, daily challenge, and endless mode.
##

signal chamber_changed(new_index: int)

const MOVE_BUFFER_MAX: int = 30
const ENDLESS_BATCH: int = 5

var current_chamber: int = 0
var best_moves: Dictionary = {}    # chamber_id -> int
var best_stars: Dictionary = {}    # chamber_id -> int (1..3)
var completed: Dictionary = {}     # chamber_id -> true (lifetime clears)
var run_cleared: Dictionary = {}   # chamber_id -> true (clears in the active wing only)
var run_started: bool = false

# "standard" full book, "daily" five-chamber wing, or "endless" catalog climb
var run_mode: String = "standard"
var daily_seed: int = 0
var daily_label: String = ""
var daily_friend_code: String = ""
var daily_chamber_id: String = ""
var daily_source: String = ""
var daily_variation: Dictionary = {}
var run_queue: Array = []          # chamber indices for this run
var queue_pos: int = 0
var daily_best_stars: Dictionary = {}  # date_str (or legacy seed_str) -> total stars
var last_clear_stars: int = 0
var last_clear_bfs_par: int = 0
var last_identity_stamp: Dictionary = {}
## Best portrait stamp per chamber index (ledger gallery).
var identity_stamps: Dictionary = {}
## Habit identity HUD unlocks after a Mirror Birth (or Looking Glass) moment.
var habit_identity_unlocked: bool = false

# Endless: deterministic seeded climb through DailySeeds catalog + rewrite pressure.
var endless_seed: int = 0
var endless_depth: int = 0           # clears this endless run
var endless_best_depth: int = 0      # lifetime best depth
var endless_label: String = ""

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
	_clear_daily_meta()
	endless_seed = 0
	endless_depth = 0
	endless_label = ""
	run_queue.clear()
	for i in range(ChamberBook.chamber_count()):
		run_queue.append(i)
	queue_pos = 0
	current_chamber = int(run_queue[0]) if run_queue.size() > 0 else 0
	run_cleared.clear()
	habit_profile = {"up": 0, "down": 0, "left": 0, "right": 0}
	move_ring.clear()
	run_started = true
	SaveManager.save_to_disk()


func start_daily_run() -> void:
	run_mode = "daily"
	var entry: Dictionary = DailyCalendar.today_utc()
	_apply_daily_entry(entry)
	endless_seed = 0
	endless_depth = 0
	endless_label = ""
	run_queue = ChamberBook.daily_wing_for_entry(entry, 5)
	queue_pos = 0
	current_chamber = int(run_queue[0]) if run_queue.size() > 0 else 0
	run_cleared.clear()
	habit_profile = {"up": 0, "down": 0, "left": 0, "right": 0}
	move_ring.clear()
	run_started = true
	SaveManager.save_to_disk()


func start_endless_run() -> void:
	run_mode = "endless"
	_clear_daily_meta()
	endless_seed = _new_endless_seed()
	endless_label = "E-%s" % _endless_seed_label(endless_seed)
	endless_depth = 0
	run_queue = ChamberBook.endless_chamber_batch(endless_seed, 0, ENDLESS_BATCH, {})
	queue_pos = 0
	current_chamber = int(run_queue[0]) if run_queue.size() > 0 else 0
	run_cleared.clear()
	habit_profile = {"up": 0, "down": 0, "left": 0, "right": 0}
	move_ring.clear()
	run_started = true
	SaveManager.save_to_disk()


func continue_run() -> void:
	run_started = true
	if run_queue.is_empty():
		if run_mode == "daily" and (daily_seed != 0 or daily_label != ""):
			run_queue = ChamberBook.daily_wing_for_entry(_daily_entry_from_state(), 5)
		elif run_mode == "endless" and endless_seed != 0:
			run_queue = ChamberBook.endless_chamber_batch(endless_seed, endless_depth, ENDLESS_BATCH, {})
			queue_pos = 0
		else:
			run_mode = "standard"
			for i in range(ChamberBook.chamber_count()):
				run_queue.append(i)
	if run_mode == "endless":
		# Queue position is authoritative — chamber ids may repeat after reshuffle.
		_ensure_endless_lookahead()
		if queue_pos < run_queue.size():
			current_chamber = int(run_queue[queue_pos])
		elif run_queue.size() > 0:
			current_chamber = int(run_queue[run_queue.size() - 1])
		SaveManager.save_to_disk()
		return
	# Skip chambers cleared in *this* wing so Continue never soft-loops a
	# finished room — but never consult lifetime `completed`, or New Game /
	# Daily would jump over still-unplayed queue entries.
	while queue_pos < run_queue.size() and run_cleared.has(int(run_queue[queue_pos])):
		queue_pos += 1
	if queue_pos >= run_queue.size():
		# Wing already finished — keep queue_pos past the end so can_continue()
		# stays false (do not park on the last chamber).
		if run_queue.size() > 0:
			current_chamber = int(run_queue[run_queue.size() - 1])
	else:
		current_chamber = int(run_queue[queue_pos])
	SaveManager.save_to_disk()


func is_run_complete() -> bool:
	## Endless never completes; other modes finish after Advance past the wing.
	if run_mode == "endless":
		return false
	return run_queue.size() > 0 and queue_pos >= run_queue.size()


func can_continue() -> bool:
	if is_run_complete():
		return false
	if run_mode == "endless":
		return run_started and endless_seed != 0 and run_queue.size() > 0
	if run_queue.size() > 0:
		# Treat "every remaining queue entry is cleared this wing" as finished so
		# a parked legacy save (queue_pos on last cleared room) cannot Continue.
		var i: int = queue_pos
		while i < run_queue.size() and run_cleared.has(int(run_queue[i])):
			i += 1
		if i >= run_queue.size():
			return false
	return run_started or completed.size() > 0 or queue_pos > 0 or current_chamber > 0


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


func record_chamber_win(chamber_id: int, moves: int, bfs_par: int = -1, stamp: Dictionary = {}) -> void:
	completed[chamber_id] = true
	run_cleared[chamber_id] = true
	var prev: int = int(best_moves.get(chamber_id, 999999))
	if moves < prev:
		best_moves[chamber_id] = moves
	var act_id: int = ChamberBook.act_for_chamber(chamber_id)
	var par: int = bfs_par if bfs_par > 0 else moves
	var star_mode: String = "endless" if run_mode == "endless" else "standard"
	var stars: int = StarRater.rate(moves, par, act_id, star_mode)
	var data: Dictionary = ChamberBook.get_chamber(chamber_id)
	if not stamp.is_empty() and IdentityStamp.affects_stars(data):
		stars = IdentityStamp.merge_stars(stars, stamp)
	last_clear_stars = stars
	last_clear_bfs_par = par
	last_identity_stamp = stamp.duplicate(true) if not stamp.is_empty() else {}
	if not stamp.is_empty():
		_store_best_stamp(chamber_id, stamp)
	if IdentityStamp.is_birth_moment(data) or IdentityStamp.is_identity_chamber(data):
		habit_identity_unlocked = true
	var prev_stars: int = int(best_stars.get(chamber_id, 0))
	if stars > prev_stars:
		best_stars[chamber_id] = stars
	if run_mode == "daily":
		_update_daily_stars()
	elif run_mode == "endless":
		endless_depth += 1
		if endless_depth > endless_best_depth:
			endless_best_depth = endless_depth
		_ensure_endless_lookahead()
	SaveManager.save_to_disk()
	if Engine.get_main_loop() is SceneTree:
		var root: Node = (Engine.get_main_loop() as SceneTree).root
		if root != null and root.has_node("SteamService"):
			root.get_node("SteamService").notify_chamber_cleared(chamber_id, moves)


func reveal_habit_identity() -> void:
	## Called mid-chamber after a Mirror Birth rewrite slam settles.
	if habit_identity_unlocked:
		return
	habit_identity_unlocked = true
	SaveManager.save_to_disk()


func is_habit_identity_visible() -> bool:
	return habit_identity_unlocked


func habit_hand_id() -> String:
	## Diegetic Field Ledger hand from the move ring / habit profile.
	var sig := _habit_signature_dict()
	var arch := HabitArchetype.classify(sig)
	return arch.id


func _habit_signature_dict() -> Dictionary:
	var total: int = 0
	var best: int = 0
	for k in habit_profile.keys():
		var v: int = int(habit_profile[k])
		total += v
		best = maxi(best, v)
	var dominant_bias: float = 0.0 if total <= 0 else float(best) / float(total)
	var turns: int = 0
	var backtracks: int = 0
	var streak: int = 0
	var longest: int = 0
	var prev := ""
	for i in range(move_ring.size()):
		var d: String = str(move_ring[i])
		if prev != "" and d != prev:
			turns += 1
			if _is_opposite(prev, d):
				backtracks += 1
			streak = 1
		else:
			streak += 1
		longest = maxi(longest, streak)
		prev = d
	var n: int = move_ring.size()
	var turn_rate: float = 0.0 if n <= 1 else float(turns) / float(n - 1)
	var backtrack_rate: float = 0.0 if n <= 1 else float(backtracks) / float(n - 1)
	return {
		"total_steps": maxi(total, n),
		"unique_cells": maxi(1, int(round(float(maxi(total, n)) * (1.0 - backtrack_rate * 0.5)))),
		"dominant_bias": dominant_bias,
		"turn_rate": turn_rate,
		"backtrack_rate": backtrack_rate,
		"straight_streaks": [longest],
	}


func _store_best_stamp(chamber_id: int, stamp: Dictionary) -> void:
	var prev: Dictionary = identity_stamps.get(chamber_id, {})
	if prev.is_empty() or float(stamp.get("portrait", 0.0)) >= float(prev.get("portrait", 0.0)):
		identity_stamps[chamber_id] = stamp.duplicate(true)


static func _is_opposite(a: String, b: String) -> bool:
	return (a == "up" and b == "down") or (a == "down" and b == "up") \
		or (a == "left" and b == "right") or (a == "right" and b == "left")


func last_stars(chamber_id: int, moves: int, bfs_par: int) -> int:
	var act_id: int = ChamberBook.act_for_chamber(chamber_id)
	var star_mode: String = "endless" if run_mode == "endless" else "standard"
	return StarRater.rate(moves, bfs_par, act_id, star_mode)


func advance_chamber() -> bool:
	queue_pos += 1
	if run_mode == "endless":
		_ensure_endless_lookahead()
		if queue_pos >= run_queue.size():
			# Should be unreachable after lookahead; keep climbing if pool empty.
			if run_queue.size() > 0:
				current_chamber = int(run_queue[run_queue.size() - 1])
			return false
		current_chamber = int(run_queue[queue_pos])
		SaveManager.save_to_disk()
		emit_signal("chamber_changed", current_chamber)
		return true
	if queue_pos >= run_queue.size():
		if run_queue.size() > 0:
			current_chamber = int(run_queue[run_queue.size() - 1])
		return false
	current_chamber = int(run_queue[queue_pos])
	SaveManager.save_to_disk()
	emit_signal("chamber_changed", current_chamber)
	return true


func chambers_in_run() -> int:
	if run_mode == "endless":
		# HUD "current / total" — show depth ladder, not a false finite wing.
		return maxi(endless_depth + 1, queue_pos + 1)
	return run_queue.size() if run_queue.size() > 0 else ChamberBook.chamber_count()


func run_progress_index() -> int:
	if run_mode == "endless":
		return endless_depth
	return queue_pos


func rewrite_pressure() -> float:
	if run_mode != "endless":
		return 0.0
	return ChamberBook.endless_rewrite_pressure(endless_depth)


func active_balance_mode() -> String:
	if run_mode == "endless":
		return "endless"
	return "standard"


func endless_transform_for(authored: String) -> String:
	if run_mode != "endless":
		return authored
	var mix: int = int(endless_seed) ^ int(endless_depth * 40503) ^ int(current_chamber * 9973)
	return ChamberBook.endless_pressure_transform(authored, rewrite_pressure(), mix)


func has_progress() -> bool:
	## Menu "Continue" affordance — false when the wing is already finished.
	return can_continue()


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


func active_seed_int() -> int:
	## Live ledger seed for the diegetic HUD header.
	if run_mode == "daily" and daily_seed != 0:
		return daily_seed
	if run_mode == "endless" and endless_seed != 0:
		return endless_seed
	var data: Dictionary = ChamberBook.get_chamber(current_chamber)
	var chamber_seed: int = int(data.get("seed", 0))
	if chamber_seed != 0:
		return chamber_seed
	return current_chamber + 1

func seed_display_string() -> String:
	## Art bible: seed string in mono, four groups of four.
	return format_seed_groups(active_seed_int())

static func format_seed_groups(seed_int: int) -> String:
	var n: int = abs(seed_int) & 0xFFFFFFFF
	var g0: int = (n >> 16) & 0xFFFF
	var g1: int = n & 0xFFFF
	var mix: int = (n * 0x9E3779B9) & 0xFFFFFFFF
	var g2: int = (mix >> 16) & 0xFFFF
	var g3: int = mix & 0xFFFF
	if g0 == 0:
		# Small chamber seeds still read as four groups (derived + raw).
		return "%04X · %04X · %04X · %04X" % [g2, g3, g1 ^ g2, g1]
	return "%04X · %04X · %04X · %04X" % [g0, g1, g2, g3]

func today_daily_entry() -> Dictionary:
	return DailyCalendar.today_utc()

func daily_best_for_today() -> int:
	var entry: Dictionary = today_daily_entry()
	var date_key: String = str(entry.get("date", _today_label()))
	if daily_best_stars.has(date_key):
		return int(daily_best_stars[date_key])
	# Legacy saves keyed daily_best_stars by YYYYMMDD int string.
	var legacy: String = str(_today_seed())
	return int(daily_best_stars.get(legacy, 0))

func _apply_daily_entry(entry: Dictionary) -> void:
	if entry.is_empty():
		daily_label = _today_label()
		daily_seed = _today_seed()
		daily_friend_code = ""
		daily_chamber_id = ""
		daily_source = "legacy_yyyymmdd"
		daily_variation = {}
		return
	daily_label = str(entry.get("date", _today_label()))
	daily_seed = int(entry.get("seed", 0))
	daily_friend_code = str(entry.get("friend_code", ""))
	daily_chamber_id = str(entry.get("chamber_id", ""))
	daily_source = str(entry.get("source", ""))
	var variation: Variant = entry.get("variation", {})
	if typeof(variation) == TYPE_DICTIONARY:
		daily_variation = (variation as Dictionary).duplicate(true)
	else:
		daily_variation = {}

func _daily_entry_from_state() -> Dictionary:
	return {
		"date": daily_label,
		"seed": daily_seed,
		"chamber_id": daily_chamber_id,
		"friend_code": daily_friend_code,
		"source": daily_source,
		"variation": daily_variation,
	}

func _clear_daily_meta() -> void:
	daily_seed = 0
	daily_label = ""
	daily_friend_code = ""
	daily_chamber_id = ""
	daily_source = ""
	daily_variation = {}

func _update_daily_stars() -> void:
	var key: String = daily_label if daily_label != "" else str(daily_seed)
	var total: int = 0
	for idx in run_queue:
		total += int(best_stars.get(int(idx), 0))
	var prev: int = int(daily_best_stars.get(key, 0))
	if total > prev:
		daily_best_stars[key] = total


func _ensure_endless_lookahead() -> void:
	if run_mode != "endless" or endless_seed == 0:
		return
	# Keep at least one unplayed chamber ahead of the current slot.
	while queue_pos >= run_queue.size() - 1:
		var avoid: Dictionary = {}
		for idx in run_queue:
			avoid[int(idx)] = true
		var batch: Array = ChamberBook.endless_chamber_batch(
			endless_seed, endless_depth, ENDLESS_BATCH, avoid
		)
		if batch.is_empty():
			break
		var grew := false
		for idx2 in batch:
			run_queue.append(int(idx2))
			grew = true
		if not grew:
			break
		# Safety: avoid infinite append if catalog collapses to duplicates.
		if run_queue.size() > endless_depth + ENDLESS_BATCH * 8:
			break


func _new_endless_seed() -> int:
	# UTC unix seconds mixed with a small salt — stable once saved.
	var unix: int = int(Time.get_unix_time_from_system())
	return int((unix * 2654435761) ^ 0xE11D15) & 0x7FFFFFFF


func _endless_seed_label(seed_int: int) -> String:
	return "%04X" % (int(seed_int) & 0xFFFF)


func _today_seed() -> int:
	## UTC YYYYMMDD — legacy key / screenshot helper only. Live Daily uses catalog seed.
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
