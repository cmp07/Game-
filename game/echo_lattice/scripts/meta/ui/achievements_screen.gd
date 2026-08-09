extends Control
## Achievements roster — milestone unlocks only.


signal back_pressed()

var _list: VBoxContainer
var _header: Label


func _ready() -> void:
	MetaUiTheme.apply_root(self)
	var bg := ColorRect.new()
	bg.color = MetaUiTheme.BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)

	root.add_child(MetaUiTheme.make_label("ACHIEVEMENTS", 28, MetaUiTheme.ACCENT))
	_header = MetaUiTheme.make_label("", 14, MetaUiTheme.MUTED)
	root.add_child(_header)

	var scroll := MetaUiTheme.make_scroll()
	root.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_list)

	var back := MetaUiTheme.make_button("Back")
	back.pressed.connect(func(): back_pressed.emit())
	root.add_child(back)

	if has_node("/root/MetaV2"):
		var mv = get_node("/root/MetaV2")
		mv.save_updated.connect(refresh)
		mv.achievement_unlocked.connect(func(_id): refresh())
		refresh()


func refresh() -> void:
	for c in _list.get_children():
		c.queue_free()
	if not has_node("/root/MetaV2"):
		return
	var mv = get_node("/root/MetaV2")
	var cat: Array = mv.achievements.catalog()
	var have := mv.achievements.unlocked_ids(mv.get_save())
	_header.text = "%d / %d unlocked · milestone-only (no grind)" % [have.size(), cat.size()]
	for entry in cat:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var id := str(entry.get("id", ""))
		var unlocked := id in have
		var title := str(entry.get("title", id))
		if bool(entry.get("secret", false)) and not unlocked:
			title = "???"
		var line := MetaUiTheme.make_label(
			"%s  %s — %s" % ["◆" if unlocked else "◇", title, str(entry.get("desc", "")) if unlocked or not bool(entry.get("secret", false)) else "Hidden"],
			14,
			MetaUiTheme.GOOD if unlocked else MetaUiTheme.MUTED
		)
		_list.add_child(line)
