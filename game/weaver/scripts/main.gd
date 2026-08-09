extends Control
## Boot composition: brand, one line, one CTA into the frayed-field stub.
## Headless: `-- --selftest [--screenshot]` skips the title into the field.
## Cloud capture: `-- --gameplay-demo` (alias `--demo`) skips title into paced loop.


func _ready() -> void:
	if Loom.pending_selftest or Loom.pending_gameplay_demo:
		call_deferred("_enter_field")
		return
	Loom.reset()


func _enter_field() -> void:
	get_tree().change_scene_to_file("res://scenes/field.tscn")


func _on_begin_pressed() -> void:
	_enter_field()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("weave"):
		_on_begin_pressed()
		get_viewport().set_input_as_handled()


func _run_photo_pack() -> void:
	## Capture title, then hand off to field (pending_photos stays true).
	print("== The Weaver — standalone photo pack ==")
	for _f in range(16):
		await get_tree().process_frame
	var out_dir := ProjectSettings.globalize_path("res://").path_join("../../docs/WEAVER/media/photos")
	DirAccess.make_dir_recursive_absolute(out_dir)
	var img: Image = get_viewport().get_texture().get_image()
	if img != null:
		var path := out_dir.path_join("01_menu_yard_enter.png")
		img.save_png(path)
		print("weaver-photos: wrote %s" % path)
	get_tree().change_scene_to_file("res://scenes/field.tscn")
