extends Node
##
## ModeService — Campaign / Daily / Endless Shift (+ stubs).
## Pure Echo Lattice: same chamber grammar, different run shells.
##

enum Mode {
	NONE,
	CAMPAIGN,
	DAILY,
	ENDLESS,
	ZEN,
	SPEEDRUN,
	HOTSEAT,
}

const MODE_IDS := {
	Mode.CAMPAIGN: "campaign",
	Mode.DAILY: "daily",
	Mode.ENDLESS: "endless",
	Mode.ZEN: "zen",
	Mode.SPEEDRUN: "speedrun",
	Mode.HOTSEAT: "hotseat",
}

const MODE_TITLES := {
	Mode.CAMPAIGN: "Campaign",
	Mode.DAILY: "Daily",
	Mode.ENDLESS: "Endless Shift",
	Mode.ZEN: "Zen",
	Mode.SPEEDRUN: "Speedrun",
	Mode.HOTSEAT: "Hotseat",
}

const MODE_BLURBS := {
	Mode.CAMPAIGN: "Ten chambers. Habits rewrite the maze.",
	Mode.DAILY: "One shared seed. Local judge.",
	Mode.ENDLESS: "Clear, shift, repeat. Streak scores.",
	Mode.ZEN: "No pressure. Coming later.",
	Mode.SPEEDRUN: "Clock on. Coming later.",
	Mode.HOTSEAT: "Pass the pad. Local only. Coming later.",
}

## Daily pool — authored chambers that already teach rewrite (skip silent induction).
const DAILY_POOL: Array = [2, 3, 4, 5, 6, 7, 8, 9]
## Endless starts after induction spectacle and cycles the rewrite wing.
const ENDLESS_POOL: Array = [2, 3, 4, 5, 6, 7, 8, 9]

const DAILY_SEED_NAMESPACE := "echo-lattice/daily/v1|"

var active_mode: int = Mode.NONE
var run_seed: int = 0
var daily_datestamp: String = ""
var endless_index: int = 0
var endless_clears: int = 0
var endless_best: int = 0
var daily_best_moves: Dictionary = {}  # datestamp -> moves
var last_daily_date: String = ""
var last_daily_moves: int = -1


func mode_id(mode: int) -> String:
	return str(MODE_IDS.get(mode, "none"))


func mode_from_id(id: String) -> int:
	for k in MODE_IDS.keys():
		if MODE_IDS[k] == id:
			return int(k)
	return Mode.NONE


func is_stub(mode: int) -> bool:
	return mode == Mode.ZEN or mode == Mode.SPEEDRUN or mode == Mode.HOTSEAT


func is_playable(mode: int) -> bool:
	return mode == Mode.CAMPAIGN or mode == Mode.DAILY or mode == Mode.ENDLESS


func title_for(mode: int) -> String:
	return str(MODE_TITLES.get(mode, "Unknown"))


func blurb_for(mode: int) -> String:
	return str(MODE_BLURBS.get(mode, ""))


func utc_datestamp(unix_secs: int = -1) -> String:
	var t: int = unix_secs if unix_secs >= 0 else int(Time.get_unix_time_from_system())
	var d: Dictionary = Time.get_datetime_dict_from_unix_time(t)
	return "%04d-%02d-%02d" % [int(d.year), int(d.month), int(d.day)]


func daily_seed_for(datestamp: String = "") -> int:
	var stamp: String = datestamp if datestamp != "" else utc_datestamp()
	return _fnv1a64(DAILY_SEED_NAMESPACE + stamp)


func pick_daily_chamber(seed: int = -1) -> int:
	var s: int = seed if seed >= 0 else daily_seed_for()
	if DAILY_POOL.is_empty():
		return 0
	var idx: int = int(absi(s) % DAILY_POOL.size())
	return int(DAILY_POOL[idx])


func has_played_daily_today() -> bool:
	return last_daily_date == utc_datestamp() and last_daily_moves >= 0


func begin_mode(mode: int) -> Dictionary:
	active_mode = mode
	endless_index = 0
	endless_clears = 0
	match mode:
		Mode.CAMPAIGN:
			run_seed = int(Time.get_unix_time_from_system())
			daily_datestamp = ""
			GameState.start_new_run()
			GameState.current_chamber = 0
			return {"chamber": 0, "seed": run_seed}
		Mode.DAILY:
			daily_datestamp = utc_datestamp()
			run_seed = daily_seed_for(daily_datestamp)
			var ch: int = pick_daily_chamber(run_seed)
			GameState.start_new_run()
			GameState.current_chamber = ch
			DiegeticPA.play("pa.daily.seed")
			return {"chamber": ch, "seed": run_seed, "datestamp": daily_datestamp}
		Mode.ENDLESS:
			run_seed = int(Time.get_unix_time_from_system())
			daily_datestamp = ""
			GameState.start_new_run()
			var ch2: int = int(ENDLESS_POOL[0])
			GameState.current_chamber = ch2
			endless_index = 0
			return {"chamber": ch2, "seed": run_seed}
		_:
			return {}


func continue_campaign() -> void:
	active_mode = Mode.CAMPAIGN
	GameState.continue_run()


func on_chamber_cleared(chamber_id: int, moves: int) -> Dictionary:
	## Returns routing hint: {kind: "next"|"end"|"daily_done"|"endless_next", ...}
	match active_mode:
		Mode.CAMPAIGN:
			var advanced: bool = GameState.advance_chamber()
			if advanced:
				return {"kind": "next", "chamber": GameState.current_chamber}
			return {"kind": "end"}
		Mode.DAILY:
			last_daily_date = daily_datestamp if daily_datestamp != "" else utc_datestamp()
			last_daily_moves = moves
			var prev: int = int(daily_best_moves.get(last_daily_date, 999999))
			if moves < prev:
				daily_best_moves[last_daily_date] = moves
			SaveManager.save_to_disk()
			return {
				"kind": "daily_done",
				"chamber": chamber_id,
				"moves": moves,
				"datestamp": last_daily_date,
				"seed": run_seed,
			}
		Mode.ENDLESS:
			endless_clears += 1
			if endless_clears > endless_best:
				endless_best = endless_clears
			endless_index = (endless_index + 1) % ENDLESS_POOL.size()
			var next_ch: int = int(ENDLESS_POOL[endless_index])
			GameState.current_chamber = next_ch
			SaveManager.save_to_disk()
			return {
				"kind": "endless_next",
				"chamber": next_ch,
				"clears": endless_clears,
				"best": endless_best,
			}
		_:
			return {"kind": "end"}


func reset_active() -> void:
	active_mode = Mode.NONE
	run_seed = 0
	daily_datestamp = ""
	endless_index = 0
	endless_clears = 0


func to_save_dict() -> Dictionary:
	return {
		"active_mode": mode_id(active_mode),
		"run_seed": run_seed,
		"daily_datestamp": daily_datestamp,
		"endless_index": endless_index,
		"endless_clears": endless_clears,
		"endless_best": endless_best,
		"daily_best_moves": daily_best_moves,
		"last_daily_date": last_daily_date,
		"last_daily_moves": last_daily_moves,
	}


func from_save_dict(d: Dictionary) -> void:
	active_mode = mode_from_id(str(d.get("active_mode", "none")))
	run_seed = int(d.get("run_seed", 0))
	daily_datestamp = str(d.get("daily_datestamp", ""))
	endless_index = int(d.get("endless_index", 0))
	endless_clears = int(d.get("endless_clears", 0))
	endless_best = int(d.get("endless_best", 0))
	var dbm = d.get("daily_best_moves", {})
	if typeof(dbm) == TYPE_DICTIONARY:
		daily_best_moves = dbm.duplicate(true)
	last_daily_date = str(d.get("last_daily_date", ""))
	last_daily_moves = int(d.get("last_daily_moves", -1))


static func _fnv1a64(text: String) -> int:
	## 64-bit FNV-1a, returned as signed 63-bit-safe positive int for GDScript.
	var hash_v: int = 1469598103934665603
	var prime: int = 1099511628211
	for i in range(text.length()):
		hash_v ^= text.unicode_at(i)
		hash_v = (hash_v * prime) & 0x7FFFFFFFFFFFFFFF
	return hash_v


static func absi(v: int) -> int:
	return v if v >= 0 else -v
