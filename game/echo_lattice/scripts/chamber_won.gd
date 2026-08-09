extends Control
##
## Chamber-won screen — stars + habit beat between chambers.
##

signal next_pressed()
signal replay_pressed()
signal menu_pressed()

@onready var title_label: Label = %Title
@onready var subtitle_label: Label = %Subtitle
@onready var stats_label: Label = %Stats
@onready var next_button: Button = %NextButton
@onready var replay_button: Button = %ReplayButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	next_button.pressed.connect(func(): emit_signal("next_pressed"))
	replay_button.pressed.connect(func(): emit_signal("replay_pressed"))
	menu_button.pressed.connect(func(): emit_signal("menu_pressed"))
	next_button.grab_focus()


func configure(chamber_id: int, moves: int) -> void:
	var data: Dictionary = ChamberBook.get_chamber(chamber_id)
	title_label.text = "Chamber Cleared"
	subtitle_label.text = str(data.get("title", ""))
	var best: int = int(GameState.best_moves.get(chamber_id, moves))
	var stars: int = GameState.last_clear_stars
	var best_stars: int = int(GameState.best_stars.get(chamber_id, stars))
	var star_str: String = _stars_glyph(stars)
	var is_last: bool = GameState.run_progress_index() + 1 >= GameState.chambers_in_run()
	var next_text: String = "→ Next Chamber" if not is_last else "→ Finish Wing"
	if GameState.run_mode == "daily":
		next_text = "→ Next Daily" if not is_last else "→ Daily Complete"
	next_button.text = next_text
	var mode_line: String = ""
	if GameState.run_mode == "daily":
		mode_line = "\nDaily %s" % GameState.daily_label
	stats_label.text = "%s\nMoves: %d  (best %d)\nBest stars: %d★\nPar path: %d%s\n\nHabit: %s" % [
		star_str, moves, best, best_stars, GameState.last_clear_bfs_par, mode_line, _habit_summary()
	]


func _habit_summary() -> String:
	var hp: Dictionary = GameState.habit_profile
	var total: int = int(hp.get("up", 0)) + int(hp.get("down", 0)) + int(hp.get("left", 0)) + int(hp.get("right", 0))
	if total <= 0:
		return "unwritten"
	return "%s-leaning" % GameState.dominant_habit()


func _stars_glyph(n: int) -> String:
	var out := ""
	for i in range(3):
		out += "*" if i < n else "-"
	return out + " (%d/3)" % n
