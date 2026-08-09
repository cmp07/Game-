extends Control
##
## Daily clear / retry result card.
##

signal again_pressed()
signal menu_pressed()

@onready var title_label: Label = %Title
@onready var stats_label: Label = %Stats
@onready var again_button: Button = %AgainButton
@onready var menu_button: Button = %MenuButton


func _ready() -> void:
	again_button.pressed.connect(func(): emit_signal("again_pressed"))
	menu_button.pressed.connect(func(): emit_signal("menu_pressed"))
	menu_button.grab_focus()


func configure(payload: Dictionary) -> void:
	title_label.text = "DAILY FILED"
	var moves: int = int(payload.get("moves", 0))
	var stamp: String = str(payload.get("datestamp", ModeService.utc_datestamp()))
	var seed: int = int(payload.get("seed", 0))
	var best: int = int(ModeService.daily_best_moves.get(stamp, moves))
	stats_label.text = "%s\nMoves: %d\nBest today: %d\nSeed: %d" % [stamp, moves, best, seed]
