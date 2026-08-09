extends Control
##
## Main menu — three actions: Start New, Continue (if save exists), Quit.
## Emits signals; the router owns navigation.
##

signal start_new_pressed()
signal continue_pressed()
signal quit_pressed()

@onready var continue_button: Button = %ContinueButton
@onready var start_button: Button = %StartButton
@onready var quit_button: Button = %QuitButton
@onready var subtitle: Label = %Subtitle


func _ready() -> void:
	var has: bool = GameState.has_progress()
	continue_button.disabled = not has
	continue_button.modulate = Color(1, 1, 1, 1.0 if has else 0.45)
	if has:
		subtitle.text = "Chamber %d of %d" % [GameState.current_chamber + 1, ChamberBook.chamber_count()]
	else:
		subtitle.text = "A vertical slice — %d chambers." % ChamberBook.chamber_count()
	start_button.grab_focus()

	start_button.pressed.connect(func(): emit_signal("start_new_pressed"))
	continue_button.pressed.connect(func():
		if has:
			emit_signal("continue_pressed")
	)
	quit_button.pressed.connect(func(): emit_signal("quit_pressed"))
