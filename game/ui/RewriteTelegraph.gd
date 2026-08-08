extends PanelContainer
## RewriteTelegraph — a countdown card that previews the next rewrite and
## invites input from the player.
##
## GameState schedules a rewrite; we render it, tick the ETA down, and expose
## `game_rewrite` / `game_hold` bindings that the gameplay code will consume
## once the sim is wired up. Even without gameplay the UI feels alive: the
## countdown pulses, the accent color hints at severity, the prompt text
## adapts to controller vs keyboard.

@export var pulse_hz: float = 2.0
@export var accent: Color = Color(0.486275, 0.976471, 1.0)
@export var warn: Color = Color(1, 0.716, 0.298)
@export var bad: Color = Color(1, 0.478, 0.541)

@onready var _kind_label: Label = %Kind
@onready var _hint_label: Label = %Hint
@onready var _eta_label: Label = %Eta
@onready var _prompt_label: Label = %Prompt
@onready var _prompt_row: HBoxContainer = %PromptRow
@onready var _bar: ProgressBar = %Bar
@onready var _idle_label: Label = %IdleLabel
@onready var _active_root: VBoxContainer = %Active
@onready var _accent_bar: Panel = %AccentBar

var _rewrite: Dictionary = {}
var _initial_eta: float = 1.0


func _ready() -> void:
	GameState.rewrite_scheduled.connect(_on_scheduled)
	GameState.rewrite_resolved.connect(_on_resolved)
	set_process(true)
	_show_idle()


func _process(_delta: float) -> void:
	if _rewrite.is_empty():
		return
	var eta := float(_rewrite.get("eta", 0.0))
	_eta_label.text = "%0.1fs" % eta
	var t := 1.0 - clampf(eta / maxf(_initial_eta, 0.001), 0.0, 1.0)
	_bar.value = t * 100.0
	# Modulate color based on urgency.
	var c := accent
	if t > 0.7: c = bad
	elif t > 0.4: c = warn
	_accent_bar.self_modulate = c
	if not Accessibility.reduce_motion():
		var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.001 * TAU * pulse_hz)
		_prompt_label.modulate.a = 0.6 + 0.4 * pulse


func _on_scheduled(rewrite: Dictionary) -> void:
	_rewrite = rewrite.duplicate(true)
	_initial_eta = float(_rewrite.get("eta", 3.0))
	_kind_label.text = _pretty_kind(_rewrite.get("kind", "rewrite"))
	_hint_label.text = _pretty_hint(_rewrite.get("kind", "rewrite"))
	_prompt_label.text = _pretty_prompt()
	_idle_label.hide()
	_active_root.show()


func _on_resolved(_snap: Dictionary, _accepted: bool) -> void:
	_rewrite = {}
	_show_idle()


func _show_idle() -> void:
	_active_root.hide()
	_idle_label.show()


func _pretty_kind(kind: String) -> String:
	match kind:
		"echo": return "ECHO REWRITE"
		"drift": return "LATTICE DRIFT"
		"cascade": return "CASCADE"
		"prune": return "PRUNE"
	return kind.to_upper()


func _pretty_hint(kind: String) -> String:
	match kind:
		"echo": return "A stanza is repeating. Approve to reinforce, reject to break the loop."
		"drift": return "The lattice is drifting toward ossification. Steady it or let it slide."
		"cascade": return "A cascade is queued. Hold to defer, tap to accept."
		"prune": return "A branch will be pruned. Prune it early, or grow it out."
	return "An incoming rewrite. Choose to accept or hold."


func _pretty_prompt() -> String:
	var confirm := Settings.humanize_event(Settings.first_event_for("game_rewrite", "kbm"))
	var hold := Settings.humanize_event(Settings.first_event_for("game_hold", "kbm"))
	return "[%s] accept    [%s] hold" % [confirm, hold]
