extends Control
## META v2 hub — short-run entry + retention navigation.


signal open_museum()
signal open_achievements()
signal open_weekly()
signal open_ng_plus()
signal start_short_run(kind: String)
signal start_daily()
signal back_pressed()

var _summary: Label
var _streak: Label
var _stars: Label


func _ready() -> void:
	MetaUiTheme.apply_root(self)
	var bg := ColorRect.new()
	bg.color = MetaUiTheme.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	add_child(margin)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	margin.add_child(v)

	v.add_child(MetaUiTheme.make_label("ECHO LATTICE", 36, MetaUiTheme.ACCENT))
	v.add_child(MetaUiTheme.make_label("Meta Retention · Short runs that leave fossils.", 16, MetaUiTheme.MUTED))

	_summary = MetaUiTheme.make_label("", 15)
	_streak = MetaUiTheme.make_label("", 15, MetaUiTheme.MUTED)
	_stars = MetaUiTheme.make_label("", 15, MetaUiTheme.ACCENT)
	v.add_child(_summary)
	v.add_child(_streak)
	v.add_child(_stars)

	v.add_child(_spacer(8))
	v.add_child(MetaUiTheme.make_label("SHORT RUN", 18, MetaUiTheme.TEXT))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	v.add_child(row)
	row.add_child(_nav_btn("Standard · ~12 min", func(): start_short_run.emit("standard")))
	row.add_child(_nav_btn("Daily", func(): start_daily.emit()))
	row.add_child(_nav_btn("Weekly", func(): open_weekly.emit()))

	v.add_child(_spacer(8))
	v.add_child(MetaUiTheme.make_label("RETENTION", 18, MetaUiTheme.TEXT))
	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", 10)
	v.add_child(row2)
	row2.add_child(_nav_btn("Museum of Selves", func(): open_museum.emit()))
	row2.add_child(_nav_btn("Achievements", func(): open_achievements.emit()))
	row2.add_child(_nav_btn("NG+", func(): open_ng_plus.emit()))

	v.add_child(_spacer(16))
	v.add_child(_nav_btn("Back", func(): back_pressed.emit()))

	if has_node("/root/MetaV2"):
		var mv = get_node("/root/MetaV2")
		mv.save_updated.connect(refresh)
		refresh()


func refresh() -> void:
	if not has_node("/root/MetaV2"):
		return
	var mv = get_node("/root/MetaV2")
	var s: Dictionary = mv.get_save()
	var museum_n := int(s.get("museum", {}).get("selves", []).size())
	var ach_n := int(s.get("unlocks", {}).get("achievements", []).size())
	_summary.text = "Museum %d · Achievements %d/%d · NG+ %s" % [
		museum_n,
		ach_n,
		mv.achievements.catalog().size(),
		"ON" if bool(s.get("ng_plus", {}).get("active", false)) else ("unlocked" if bool(s.get("profile", {}).get("ng_plus_unlocked", false)) else "locked"),
	]
	_streak.text = "Play streak %d (best %d) · Daily clear %d (best %d)" % [
		int(s.get("streaks", {}).get("play_current", 0)),
		int(s.get("streaks", {}).get("play_best", 0)),
		int(s.get("streaks", {}).get("daily_clear_current", 0)),
		int(s.get("streaks", {}).get("daily_clear_best", 0)),
	]
	_stars.text = "Stars %d  %s" % [mv.star_total(), MetaUiTheme.stars_text(mini(3, mv.star_total()))]


func _nav_btn(text: String, cb: Callable) -> Button:
	var b := MetaUiTheme.make_button(text)
	b.pressed.connect(cb)
	return b


func _spacer(h: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c
