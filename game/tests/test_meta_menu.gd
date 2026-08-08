extends Node
##
## Smoke test: instance every meta menu scene, drive one full run
## through the SaveService pipeline, and verify no scene throws
## during _ready().
##
## Run:
##   godot --headless --path game res://tests/test_meta_menu.tscn
##
## We use a scene (not a `-s` script) so the project's autoloads
## (SaveService, GameSession) are wired up before compile time.
##

const SCENES := [
	"res://scenes/meta/main_menu.tscn",
	"res://scenes/meta/chamber_select.tscn",
	"res://scenes/meta/daily_screen.tscn",
	"res://scenes/meta/stats_screen.tscn",
	"res://scenes/meta/run_history.tscn",
	"res://scenes/meta/options_screen.tscn",
]

var failures: Array[String] = []


func _ready() -> void:
	print("[test_meta_menu] booting")
	SaveService.autosave_enabled = false
	SaveService.wipe(true)

	# Populate some data so every screen has something to render.
	var run: Dictionary = SaveService.record_run_start("ec_01_boot", 12345, "standard")
	OS.delay_msec(10)
	SaveService.record_run_end(run, "clear", {})
	load("res://scripts/chamber_catalog.gd").refresh_unlocks(SaveService)
	var run2: Dictionary = SaveService.record_run_start("ec_02_hum", 12346, "daily")
	OS.delay_msec(10)
	SaveService.record_run_end(run2, "death", {})

	for path in SCENES:
		_check_scene(path)

	if failures.is_empty():
		print("[test_meta_menu] OK  all scenes instantiated")
		get_tree().quit(0)
	else:
		for f in failures:
			push_error("  - " + f)
		get_tree().quit(1)


func _check_scene(path: String) -> void:
	print("  -> " + path)
	if not ResourceLoader.exists(path):
		failures.append("missing: " + path)
		return
	var scene := load(path) as PackedScene
	if scene == null:
		failures.append("failed to load: " + path)
		return
	var inst := scene.instantiate()
	if inst == null:
		failures.append("failed to instantiate: " + path)
		return
	# Add to a detached subtree so we don't clobber the current
	# main scene. _ready() still fires when parented.
	add_child(inst)
	inst.queue_free()
