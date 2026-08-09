extends Control
##
## End-of-slice screen — plays after the final chamber's win screen.
##

signal restart_pressed()
signal menu_pressed()

@onready var stats_label: Label = %Stats
@onready var restart_button: Button = %RestartButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	restart_button.pressed.connect(func(): emit_signal("restart_pressed"))
	menu_button.pressed.connect(func(): emit_signal("menu_pressed"))
	menu_button.grab_focus()
	stats_label.text = _summary()


func _summary() -> String:
	var total_best: int = 0
	var beat: int = 0
	for i in range(ChamberBook.chamber_count()):
		if GameState.best_moves.has(i):
			total_best += int(GameState.best_moves[i])
			beat += 1
	var dom: String = GameState.dominant_habit()
	var hp: Dictionary = GameState.habit_profile
	return "You escaped %d / %d chambers.\nTotal best moves: %d\nYour habit signature: %s\n(u:%d  d:%d  l:%d  r:%d)" % [
		beat, ChamberBook.chamber_count(), total_best, dom,
		int(hp.get("up", 0)), int(hp.get("down", 0)),
		int(hp.get("left", 0)), int(hp.get("right", 0)),
	]
