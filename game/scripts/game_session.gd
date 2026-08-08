extends Node
##
## GameSession (autoload)
##
## Thin runtime shell that connects the meta menu to an in-progress
## run. The actual gameplay scene doesn't exist yet — this file
## encodes the contract the run scene must fulfil:
##
##   1. Read `active_chamber_id`, `active_seed`, `active_mode`.
##   2. Deterministically seed its RNG with `active_seed`.
##   3. Call `end_run("clear" | "death" | "abandoned", stats)` when
##      the run ends. GameSession forwards that to SaveService and
##      returns the player to the meta menu.
##

const ChamberCatalogScript := preload("res://scripts/chamber_catalog.gd")

const META_MAIN_SCENE := "res://scenes/meta/main_menu.tscn"
const RUN_SCENE := "res://scenes/game/run.tscn"

signal run_started(chamber_id: String, seed: int, mode: String)
signal run_ended(record: Dictionary, newly_unlocked: Array)

var active_chamber_id: String = ""
var active_seed: int = 0
var active_mode: String = ""
var active_modifiers: PackedStringArray = PackedStringArray()

var _active_run: Dictionary = {}


func start_run(chamber_id: String, seed: int, mode: String = "standard", modifiers: PackedStringArray = PackedStringArray()) -> void:
	if not ChamberCatalogScript.exists(chamber_id):
		push_warning("GameSession.start_run: unknown chamber_id %s" % chamber_id)
		return
	active_chamber_id = chamber_id
	active_seed = seed
	active_mode = mode
	active_modifiers = modifiers
	_active_run = SaveService.record_run_start(chamber_id, seed, mode, modifiers)
	emit_signal("run_started", chamber_id, seed, mode)

	if ResourceLoader.exists(RUN_SCENE):
		get_tree().change_scene_to_file(RUN_SCENE)
	# If the run scene doesn't exist yet the caller (menu) stays
	# put; this is expected in the meta-only milestone.


func end_run(outcome: String, run_stats: Dictionary = {}) -> Dictionary:
	if _active_run.is_empty():
		return {}
	var record := SaveService.record_run_end(_active_run, outcome, run_stats)
	var newly := ChamberCatalogScript.refresh_unlocks(SaveService)
	_active_run = {}
	active_chamber_id = ""
	active_seed = 0
	active_mode = ""
	active_modifiers = PackedStringArray()
	emit_signal("run_ended", record, newly)

	if get_tree() != null and ResourceLoader.exists(META_MAIN_SCENE):
		get_tree().change_scene_to_file(META_MAIN_SCENE)
	return record


func abandon_active_run() -> void:
	if _active_run.is_empty():
		return
	end_run("abandoned")
