extends CanvasLayer
## Combine UI — pick any two Fragments; the loom always answers (bind / strain / snap).

var _selected: Array[int] = []

@onready var _title: Label = %Title
@onready var _slots: HBoxContainer = %Slots
@onready var _result: Label = %Result
@onready var _combine_btn: Button = %CombineBtn
@onready var _close_btn: Button = %CloseBtn


func _ready() -> void:
	visible = false
	layer = 30
	_title.text = "Spindle · any two may try"
	_style_yard_tag()
	_combine_btn.pressed.connect(_on_combine)
	_close_btn.pressed.connect(hide_panel)
	Loom.inventory_changed.connect(_rebuild_slots)
	Loom.combine_ui_requested.connect(show_panel)
	_rebuild_slots()


func _style_yard_tag() -> void:
	## Stamped job tag — paper, not glass Godot panel.
	var dim: ColorRect = get_node_or_null("Dim") as ColorRect
	if dim:
		dim.color = Color(0.91, 0.87, 0.78, 0.35)
	var panel: PanelContainer = get_node_or_null("Panel") as PanelContainer
	if panel:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.910, 0.875, 0.784, 1)
		sb.border_color = Color(0.110, 0.094, 0.078, 0.85)
		sb.set_border_width_all(2)
		sb.content_margin_left = 18
		sb.content_margin_right = 18
		sb.content_margin_top = 16
		sb.content_margin_bottom = 16
		sb.corner_radius_top_left = 2
		sb.corner_radius_top_right = 2
		sb.corner_radius_bottom_left = 2
		sb.corner_radius_bottom_right = 2
		panel.add_theme_stylebox_override("panel", sb)
	_combine_btn.flat = true
	_close_btn.flat = true
	_combine_btn.add_theme_color_override("font_color", Color(0.545, 0.227, 0.122, 1))
	_close_btn.add_theme_color_override("font_color", Color(0.22, 0.18, 0.14, 1))


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("combine"):
		hide_panel()
		get_viewport().set_input_as_handled()


func show_panel() -> void:
	_selected.clear()
	_rebuild_slots()
	_result.text = "Select any two — bind, strain, or snap."
	visible = true


## Photo helper — open panel with a pre-selected pair (indices into inventory).
func stage_photo_selection(indices: Array) -> void:
	_selected.clear()
	for idx in indices:
		_selected.append(int(idx))
	_rebuild_slots()
	_preview()
	visible = true


func hide_panel() -> void:
	visible = false
	_selected.clear()


func _rebuild_slots() -> void:
	for child in _slots.get_children():
		child.queue_free()
	for i in Loom.fragment_inventory.size():
		var family: String = Loom.fragment_inventory[i]
		var btn := Button.new()
		btn.text = family
		btn.custom_minimum_size = Vector2(120, 56)
		btn.toggle_mode = true
		btn.button_pressed = _selected.has(i)
		var idx := i
		btn.toggled.connect(func(on: bool) -> void: _on_slot_toggled(idx, on))
		_slots.add_child(btn)
	if Loom.fragment_inventory.is_empty():
		var empty := Label.new()
		empty.text = "No Fragments in hand."
		_slots.add_child(empty)
	_preview()


func _on_slot_toggled(index: int, on: bool) -> void:
	if on:
		if not _selected.has(index):
			_selected.append(index)
		while _selected.size() > 2:
			var dropped: int = _selected.pop_front()
			if dropped < _slots.get_child_count() and _slots.get_child(dropped) is Button:
				(_slots.get_child(dropped) as Button).set_pressed_no_signal(false)
	else:
		_selected.erase(index)
	_preview()


func _preview() -> void:
	if _selected.size() < 2:
		_result.text = "Select any two — bind, strain, or snap."
		return
	var a: String = Loom.fragment_inventory[_selected[0]]
	var b: String = Loom.fragment_inventory[_selected[1]]
	var recipe := Loom.find_recipe(a, b)
	if bool(recipe.get("ok", false)):
		_result.text = "May bind: %s" % str(recipe.get("label", "Thread"))
	else:
		_result.text = "May %s: %s" % [
			str(recipe.get("outcome", "strain")),
			str(recipe.get("tell", recipe.get("label", "fray"))),
		]


func _on_combine() -> void:
	if _selected.size() != 2:
		_result.text = "Pick exactly two Fragments."
		return
	var result := Loom.combine_indices(_selected[0], _selected[1])
	if not result.get("ok", false):
		_result.text = str(result.get("tell", result.get("reason", "Bind failed — interesting.")))
		_selected.clear()
		_rebuild_slots()
		return
	_selected.clear()
	_rebuild_slots()
	var thread: Dictionary = result.get("thread", {})
	_result.text = "Spun %s. Close and tension at the gap (Space)." % str(thread.get("label", "Thread"))
