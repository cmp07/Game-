extends Node
## Gameplay session state.
##
## The Echo Lattice loop we telegraph to the UI:
##   - `goal_text`       — the current stanza to complete.
##   - `habit`           — 0..100 meter. Low = brittle habits; high = ossified.
##                          Mid-band is the "readable" window where rewrites feel
##                          intentional instead of chaotic.
##   - `rewrite_incoming` — a queued Rewrite (kind + eta_seconds + payload).
##   - `phase`           — Idle / Playing / Paused / Won / Lost.
##
## Gameplay isn't implemented yet — this file exists so the UI can bind against
## real signals during the vertical-slice phase.

signal habit_changed(value: float, delta: float)
signal goal_changed(text: String)
signal rewrite_scheduled(rewrite: Dictionary)
signal rewrite_resolved(rewrite: Dictionary, accepted: bool)
signal phase_changed(phase: int)
signal tutorial_prompt(text: String, hold_ms: int)

enum Phase { IDLE, PLAYING, PAUSED, WON, LOST }

const HABIT_MIN := 0.0
const HABIT_MAX := 100.0
const HABIT_TARGET_LOW := 35.0
const HABIT_TARGET_HIGH := 65.0

var goal_text: String = "Learn the lattice."
var habit: float = 50.0
var phase: int = Phase.IDLE
var run_seconds: float = 0.0
var rewrite_incoming: Dictionary = {}

# Simulation clock only advances while playing (not paused / not on menus).
func _process(delta: float) -> void:
	if phase == Phase.PLAYING:
		run_seconds += delta
		if not rewrite_incoming.is_empty():
			rewrite_incoming["eta"] = maxf(0.0, float(rewrite_incoming.get("eta", 0.0)) - delta)


func start_new_run() -> void:
	habit = 50.0
	run_seconds = 0.0
	rewrite_incoming = {}
	goal_text = "Stabilize the first echo."
	set_phase(Phase.PLAYING)
	goal_changed.emit(goal_text)
	habit_changed.emit(habit, 0.0)
	tutorial_prompt.emit("Hold the lattice steady. Rewrites are your friend.", 4000)


func set_phase(new_phase: int) -> void:
	if phase == new_phase:
		return
	phase = new_phase
	phase_changed.emit(phase)


func set_goal(text: String) -> void:
	goal_text = text
	goal_changed.emit(text)


func adjust_habit(delta: float) -> void:
	var previous := habit
	habit = clampf(habit + delta, HABIT_MIN, HABIT_MAX)
	habit_changed.emit(habit, habit - previous)


func schedule_rewrite(kind: String, eta: float, payload: Dictionary = {}) -> void:
	rewrite_incoming = {
		"kind": kind,
		"eta": eta,
		"payload": payload,
	}
	rewrite_scheduled.emit(rewrite_incoming.duplicate(true))


func resolve_rewrite(accepted: bool) -> void:
	if rewrite_incoming.is_empty():
		return
	var snap := rewrite_incoming.duplicate(true)
	rewrite_incoming = {}
	rewrite_resolved.emit(snap, accepted)
	adjust_habit(-8.0 if accepted else 10.0)


func win() -> void:
	set_phase(Phase.WON)


func lose() -> void:
	set_phase(Phase.LOST)


func format_time(seconds: float) -> String:
	var whole := int(seconds)
	var m := whole / 60
	var s := whole % 60
	return "%02d:%02d" % [m, s]
