extends Node
##
## Session-level state.
##
## Anything that survives a scene change but not a game restart lives here:
## - which chamber the player is currently in
## - whether the game is paused
## - a monotonically increasing run id used to tag habit records
## - simple settings the player toggled this session
##
## Persistent data (save files, long-term habit history) belongs in
## HabitTracker or a future SaveSystem, not here.
##

const RUN_ID_KEY := "run_id"

var run_id: int = 0
var current_chamber_id: StringName = &""
var paused: bool = false
var debug_overlay_enabled: bool = false

var _session_flags: Dictionary = {}


func _ready() -> void:
	run_id = Time.get_unix_time_from_system()
	EventBus.chamber_entered.connect(_on_chamber_entered)
	EventBus.chamber_exited.connect(_on_chamber_exited)
	EventBus.game_paused.connect(_on_game_paused)


func set_flag(key: StringName, value: Variant) -> void:
	_session_flags[key] = value


func get_flag(key: StringName, default_value: Variant = null) -> Variant:
	return _session_flags.get(key, default_value)


func toggle_pause() -> void:
	paused = not paused
	get_tree().paused = paused
	EventBus.game_paused.emit(paused)


func toggle_debug_overlay() -> void:
	debug_overlay_enabled = not debug_overlay_enabled


func _on_chamber_entered(chamber_id: StringName) -> void:
	current_chamber_id = chamber_id


func _on_chamber_exited(_chamber_id: StringName) -> void:
	current_chamber_id = &""


func _on_game_paused(is_paused: bool) -> void:
	paused = is_paused
