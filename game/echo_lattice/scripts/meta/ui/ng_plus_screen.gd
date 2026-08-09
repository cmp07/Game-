extends Control
## NG+ unlock status, toggle, and active modifiers.


signal back_pressed()

var _status: Label
var _mods: Label
var _toggle: Button


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

	v.add_child(MetaUiTheme.make_label("NEW GAME PLUS", 28, MetaUiTheme.ACCENT))
	v.add_child(MetaUiTheme.make_label(
		"Clear Act I once. Return with tighter habits — the lattice remembers harder.",
		14, MetaUiTheme.MUTED
	))
	_status = MetaUiTheme.make_label("", 16)
	_mods = MetaUiTheme.make_label("", 14, MetaUiTheme.MUTED)
	v.add_child(_status)
	v.add_child(_mods)
	_toggle = MetaUiTheme.make_button("Activate NG+")
	_toggle.pressed.connect(_on_toggle)
	v.add_child(_toggle)
	v.add_child(MetaUiTheme.make_button("Back")).pressed.connect(func(): back_pressed.emit())

	if has_node("/root/MetaV2"):
		var mv = get_node("/root/MetaV2")
		mv.save_updated.connect(refresh)
		mv.ng_plus_unlocked.connect(refresh)
		refresh()


func refresh() -> void:
	if not has_node("/root/MetaV2"):
		return
	var mv = get_node("/root/MetaV2")
	var s: Dictionary = mv.get_save()
	var unlocked := bool(s.get("profile", {}).get("ng_plus_unlocked", false))
	var active := bool(s.get("ng_plus", {}).get("active", false))
	var cycles := int(s.get("profile", {}).get("ng_plus_cycles", 0))
	_status.text = "Unlocked: %s · Active: %s · Cycles: %d" % [
		"yes" if unlocked else "no (clear Act I)",
		"yes" if active else "no",
		cycles,
	]
	_toggle.disabled = not unlocked
	_toggle.text = "Deactivate NG+" if active else "Activate NG+"
	var mods: Array = NgPlusService.active_modifiers(s, mv.cfg) if active else []
	if mods.is_empty():
		_mods.text = "No modifiers active."
	else:
		var lines: PackedStringArray = []
		for m in mods:
			lines.append("- %s (scale %s)" % [str(m.get("id", "?")), str(m.get("scale", 1))])
		_mods.text = "\n".join(lines)


func _on_toggle() -> void:
	if not has_node("/root/MetaV2"):
		return
	var mv = get_node("/root/MetaV2")
	var active := bool(mv.get_save().get("ng_plus", {}).get("active", false))
	mv.set_ng_plus_active(not active)
