extends Control
##
## Stub shell for Zen / Speedrun / Hotseat (local) — not playable yet.
##

signal back_pressed()

@onready var title_label: Label = %Title
@onready var body_label: Label = %Body
@onready var back_button: Button = %BackButton


func _ready() -> void:
	back_button.pressed.connect(func(): emit_signal("back_pressed"))
	back_button.grab_focus()


func configure(mode_id: String) -> void:
	var mode: int = ModeService.mode_from_id(mode_id)
	title_label.text = ModeService.title_for(mode).to_upper()
	match mode:
		ModeService.Mode.ZEN:
			body_label.text = "Quiet chambers. No streak. No clock.\nShell reserved — play Campaign for now."
		ModeService.Mode.SPEEDRUN:
			body_label.text = "Timed clears with a live split strip.\nShell reserved — play Campaign for now."
		ModeService.Mode.HOTSEAT:
			body_label.text = "Local pass-the-pad turns on one machine.\nShell reserved — no netcode."
		_:
			body_label.text = "Mode stub."
