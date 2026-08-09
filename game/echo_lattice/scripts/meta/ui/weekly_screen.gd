extends Control
## Weekly seed challenge screen.


signal back_pressed()
signal play_weekly(chamber_id: String, seed: int)

var _body: Label
var _streak: Label
var _play: Button


func _ready() -> void:
	MetaUiTheme.apply_root(self)
	var bg := ColorRect.new()
	bg.color = MetaUiTheme.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	margin.add_child(v)

	v.add_child(MetaUiTheme.make_label("WEEKLY SEED", 28, MetaUiTheme.ACCENT))
	v.add_child(MetaUiTheme.make_label(
		"One shared chamber for the ISO week. Offline. Comparable with friends.",
		14, MetaUiTheme.MUTED
	))
	_body = MetaUiTheme.make_label("", 16)
	_streak = MetaUiTheme.make_label("", 14, MetaUiTheme.MUTED)
	v.add_child(_body)
	v.add_child(_streak)
	_play = MetaUiTheme.make_button("Play Weekly")
	_play.pressed.connect(_on_play)
	v.add_child(_play)
	v.add_child(MetaUiTheme.make_button("Back")).pressed.connect(func(): back_pressed.emit())

	if has_node("/root/MetaV2"):
		get_node("/root/MetaV2").save_updated.connect(refresh)
		refresh()


func refresh() -> void:
	if not has_node("/root/MetaV2"):
		return
	var ch: Dictionary = get_node("/root/MetaV2").weekly_challenge()
	_body.text = "Week %s\nChamber %s\nSeed %d\nChamber RNG %d" % [
		str(ch.get("week_id", "")),
		str(ch.get("chamber_id", "")),
		int(ch.get("seed", 0)),
		int(ch.get("chamber_seed", 0)),
	]
	_streak.text = "Weekly clear streak %d (best %d)%s" % [
		int(ch.get("streak_current", 0)),
		int(ch.get("streak_best", 0)),
		" · already recorded this week" if bool(ch.get("played", false)) else "",
	]
	_play.text = "Retry Weekly (overwrites)" if bool(ch.get("played", false)) else "Play Weekly"


func _on_play() -> void:
	if not has_node("/root/MetaV2"):
		return
	var ch: Dictionary = get_node("/root/MetaV2").weekly_challenge()
	play_weekly.emit(str(ch.get("chamber_id", "")), int(ch.get("chamber_seed", 0)))
