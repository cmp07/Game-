extends Control
##
## Main menu — Play (mode select), Continue (campaign), Quit.
##

signal play_pressed()
signal continue_pressed()
signal quit_pressed()

@onready var continue_button: Button = %ContinueButton
@onready var play_button: Button = %PlayButton
@onready var quit_button: Button = %QuitButton
@onready var subtitle: Label = %Subtitle


func _ready() -> void:
	var has: bool = GameState.has_progress() and (
		ModeService.active_mode == ModeService.Mode.CAMPAIGN
		or ModeService.active_mode == ModeService.Mode.NONE
	)
	continue_button.disabled = not has
	continue_button.modulate = Color(1, 1, 1, 1.0 if has else 0.45)
	if has:
		subtitle.text = "Campaign · Chamber %d of %d" % [
			GameState.current_chamber + 1, ChamberBook.chamber_count()
		]
	else:
		subtitle.text = "Pick a mode. Induction lands by chamber 2."
	play_button.grab_focus()

	play_button.pressed.connect(func(): emit_signal("play_pressed"))
	continue_button.pressed.connect(func():
		if has:
			emit_signal("continue_pressed")
	)
	quit_button.pressed.connect(func(): emit_signal("quit_pressed"))
