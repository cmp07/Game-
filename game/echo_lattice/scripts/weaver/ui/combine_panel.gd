extends CanvasLayer
## Combine UI — pick two Fragments, spin a Brace Thread.

var _selected: Array[int] = []

@onready var _title: Label = %Title
@onready var _slots: HBoxContainer = %Slots
@onready var _result: Label = %Result
@onready var _combine_btn: Button = %CombineBtn
@onready var _close_btn: Button = %CloseBtn


func _ready() -> void:
	visible = false
	layer = 30
	_title.text = "Combine · spin a Brace Thread"
	_combine_btn.pressed.connect(_on_combine)
	_close_btn.pressed.connect(hide_panel)
	Loom.inventory_changed.connect(_rebuild_slots)
	Loom.combine_ui_requested.connect(show_panel)
	_rebuild_slots()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("combine"):
		hide_panel()
		get_viewport().set_input_as_handled()


func show_panel() -> void:
	_selected.clear()
	_rebuild_slots()
	_result.text = "Select two Fragments (FIRST_FIVE: Anchor + Span)."
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
		_result.text = "Select two Fragments (FIRST_FIVE: Anchor + Span)."
		return
	var a: String = Loom.fragment_inventory[_selected[0]]
	var b: String = Loom.fragment_inventory[_selected[1]]
	var recipe := Loom.find_recipe(a, b)
	_result.text = "Will spin: %s" % str(recipe.get("label", "Brace Thread"))


func _on_combine() -> void:
	if _selected.size() != 2:
		_result.text = "Pick exactly two Fragments."
		return
	var result := Loom.combine_indices(_selected[0], _selected[1])
	if not result.get("ok", false):
		_result.text = str(result.get("reason", "Combine failed."))
		return
	_selected.clear()
	_rebuild_slots()
	var thread: Dictionary = result.get("thread", {})
	_result.text = "Spun %s. Close and weave at the void (Space)." % str(thread.get("label", "Thread"))
