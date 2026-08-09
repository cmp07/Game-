extends Control
##
## Main menu — Start, Continue, Daily Challenge, Quit.
##

signal start_new_pressed()
signal continue_pressed()
signal daily_pressed()
signal quit_pressed()

@onready var continue_button: Button = %ContinueButton
@onready var start_button: Button = %StartButton
@onready var daily_button: Button = %DailyButton
@onready var quit_button: Button = %QuitButton
@onready var subtitle: Label = %Subtitle
@onready var meta_label: Label = %MetaLabel


func _ready() -> void:
	var has: bool = GameState.has_progress()
	continue_button.disabled = not has
	continue_button.modulate = Color(1, 1, 1, 1.0 if has else 0.45)
	var stars: int = GameState.total_stars_earned()
	if has:
		subtitle.text = "Chamber %d of %d  ·  %d★ earned" % [
			GameState.run_progress_index() + 1,
			GameState.chambers_in_run(),
			stars,
		]
	else:
		subtitle.text = "v2 elevated slice — %d chambers · stars + daily" % ChamberBook.chamber_count()
	var today: String = GameState._today_label()
	var dseed: int = GameState._today_seed()
	var dbest: int = int(GameState.daily_best_stars.get(str(dseed), 0))
	meta_label.text = "Daily %s  ·  best %d★ / 15" % [today, dbest]
	start_button.grab_focus()

	start_button.pressed.connect(func(): emit_signal("start_new_pressed"))
	continue_button.pressed.connect(func():
		if has:
			emit_signal("continue_pressed")
	)
	daily_button.pressed.connect(func(): emit_signal("daily_pressed"))
	quit_button.pressed.connect(func(): emit_signal("quit_pressed"))
	if has_node("/root/AudioDirector"):
		AudioDirector.fire("ui.click")
