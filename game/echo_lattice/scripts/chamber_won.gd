extends Control
##
## Chamber-won screen — the beat between chambers.
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
	var next_idx: int = chamber_id + 1
	var is_last: bool = next_idx >= ChamberBook.chamber_count()
	var next_text: String = "→ Next Chamber" if not is_last else "→ Finish Slice"
	next_button.text = next_text
	stats_label.text = "Moves this run: %d\nBest ever: %d\n\nHabit so far: %s" % [
		moves, best, _habit_summary()
	]


func _habit_summary() -> String:
	var hp: Dictionary = GameState.habit_profile
	var total: int = int(hp.get("up", 0)) + int(hp.get("down", 0)) + int(hp.get("left", 0)) + int(hp.get("right", 0))
	if total <= 0:
		return "unwritten"
	return "%s-leaning" % GameState.dominant_habit()
