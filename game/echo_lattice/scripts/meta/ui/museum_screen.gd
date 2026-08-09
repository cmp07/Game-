extends Control
## Museum of Selves — browse archived habit fossils; race a prior self.


signal back_pressed()
signal race_self(self_id: String)

var _list: VBoxContainer


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

	root.add_child(MetaUiTheme.make_label("MUSEUM OF SELVES", 28, MetaUiTheme.ACCENT))
	root.add_child(MetaUiTheme.make_label(
		"Each clear leaves a fossil. Browse who you were — or race the echo.",
		14, MetaUiTheme.MUTED
	))

	var scroll := MetaUiTheme.make_scroll()
	root.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_list)

	root.add_child(MetaUiTheme.make_button("Back")).pressed.connect(func(): back_pressed.emit())

	if has_node("/root/MetaV2"):
		var mv = get_node("/root/MetaV2")
		mv.museum_updated.connect(func(_r): refresh())
		mv.save_updated.connect(refresh)
		refresh()


func refresh() -> void:
	for c in _list.get_children():
		c.queue_free()
	if not has_node("/root/MetaV2"):
		return
	var selves: Array = get_node("/root/MetaV2").museum_selves()
	if selves.is_empty():
		_list.add_child(MetaUiTheme.make_label("No selves archived yet. Clear a chamber.", 15, MetaUiTheme.MUTED))
		return
	for row in selves:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		_list.add_child(_card(row))


func _card(row: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	var vb := VBoxContainer.new()
	panel.add_child(vb)
	vb.add_child(MetaUiTheme.make_label(str(row.get("title", "Self")), 16, MetaUiTheme.TEXT))
	var habit: Dictionary = row.get("habit", {})
	vb.add_child(MetaUiTheme.make_label(
		"%s · %s · %s · moves %d · %s%s" % [
			str(row.get("chamber_id", "")),
			MetaUiTheme.stars_text(int(row.get("stars", 0))),
			str(habit.get("archetype", "?")),
			int(row.get("moves", 0)),
			str(row.get("mode", "standard")),
			" · NG+" if bool(row.get("ng_plus", false)) else "",
		],
		13, MetaUiTheme.MUTED
	))
	var btn := MetaUiTheme.make_button("Race this self")
	var sid := str(row.get("id", ""))
	btn.pressed.connect(func(): race_self.emit(sid))
	vb.add_child(btn)
	return panel
