extends Node
## Autoload: gather → combine → weave session state (extends scaffold stub).
## Authority: docs/WEAVER/32_FIRST_FIVE.md · 17_MVP.md · 02_CORE_LOOP.md

signal fragments_changed(count: int)
signal threads_changed(count: int)
signal structure_seated
signal fragment_emitted(kind: String, at: Vector2)
signal prompt_changed(text: String)
signal inventory_changed
signal combine_ui_requested

var fragment_inventory: Array[String] = []
var thread_count: int = 0
var threads: Array[Dictionary] = []
var structure_built: bool = false
var structures_standing: int = 0
var fragments_gathered: int = 0
var combines_done: int = 0
var phase: String = "gather"

const MAX_CARRY := 4
const COMBINE_COST := 2
const RECIPE_PATH := "res://content/recipes.json"

var recipes: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var pending_selftest: bool = false
var pending_screenshot: bool = false
var pending_gameplay_demo: bool = false
var api_selftest_result: Dictionary = {}


func _ready() -> void:
	_rng.randomize()
	load_recipes()
	var args := OS.get_cmdline_user_args()
	if args.has("--photos") or args.has("--weaver-photos"):
		pending_photos = true
		pending_selftest = false
		pending_screenshot = false
	elif args.has("--selftest"):
		pending_selftest = true
		pending_screenshot = args.has("--screenshot")
		api_selftest_result = selftest_loop(7)
	if args.has("--gameplay-demo") or args.has("--demo"):
		pending_gameplay_demo = true


func load_recipes() -> void:
	var file := FileAccess.open(RECIPE_PATH, FileAccess.READ)
	if file == null:
		recipes = {}
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		recipes = parsed
	else:
		recipes = {}


func reset() -> void:
	fragment_inventory.clear()
	threads.clear()
	thread_count = 0
	structure_built = false
	structures_standing = 0
	fragments_gathered = 0
	combines_done = 0
	phase = "gather"
	fragments_changed.emit(0)
	threads_changed.emit(0)
	inventory_changed.emit()
	prompt_changed.emit("Walk the frayed field. Collect Fragments near the void.")


func can_carry() -> bool:
	return fragment_inventory.size() < MAX_CARRY


func add_fragment(family: String) -> bool:
	if not can_carry():
		prompt_changed.emit("Carry full (%d). Press C to open combine." % MAX_CARRY)
		return false
	fragment_inventory.append(family)
	fragments_gathered += 1
	fragments_changed.emit(fragment_inventory.size())
	inventory_changed.emit()
	if fragment_inventory.size() >= COMBINE_COST and phase == "gather":
		phase = "combine"
	prompt_changed.emit("Collected %s. Fragments: %d. Press C to combine into a Thread." % [
		family, fragment_inventory.size()
	])
	return true


func can_combine() -> bool:
	return fragment_inventory.size() >= COMBINE_COST


func find_recipe(a: String, b: String) -> Dictionary:
	var list: Array = recipes.get("combine_recipes", [])
	for entry in list:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var inputs: Array = entry.get("inputs", [])
		if inputs.size() != 2:
			continue
		var i0 := str(inputs[0])
		var i1 := str(inputs[1])
		if (i0 == a and i1 == b) or (i0 == b and i1 == a):
			return entry
	# FIRST_FIVE default: any two Fragments bind a Brace Thread.
	return {
		"id": "any_brace",
		"inputs": [a, b],
		"output_thread": "Brace",
		"label": "Brace Thread",
	}


func combine_indices(i: int, j: int) -> Dictionary:
	if i == j or i < 0 or j < 0 or i >= fragment_inventory.size() or j >= fragment_inventory.size():
		return {"ok": false, "reason": "Pick two different Fragments."}
	var a: String = fragment_inventory[i]
	var b: String = fragment_inventory[j]
	var recipe := find_recipe(a, b)
	var hi := maxi(i, j)
	var lo := mini(i, j)
	fragment_inventory.remove_at(hi)
	fragment_inventory.remove_at(lo)
	var thread := {
		"type": str(recipe.get("output_thread", "Brace")),
		"label": str(recipe.get("label", "Brace Thread")),
		"recipe_id": str(recipe.get("id", "")),
		"from": [a, b],
	}
	threads.append(thread)
	thread_count = threads.size()
	combines_done += 1
	phase = "weave"
	fragments_changed.emit(fragment_inventory.size())
	threads_changed.emit(thread_count)
	inventory_changed.emit()
	prompt_changed.emit("Bound %s + %s → %s. Stand in the void and press Space to weave." % [
		a, b, thread["label"]
	])
	return {"ok": true, "thread": thread}


func combine_two_into_thread() -> bool:
	## Quick-combine (oldest two) — also used when UI confirms a default pair.
	if fragment_inventory.size() < COMBINE_COST:
		prompt_changed.emit("Need two Fragments to bind a Thread.")
		return false
	var result := combine_indices(0, 1)
	return bool(result.get("ok", false))


func request_combine_ui() -> void:
	combine_ui_requested.emit()


func can_weave() -> bool:
	return thread_count > 0


func seat_structure() -> bool:
	if thread_count <= 0 or threads.is_empty():
		prompt_changed.emit("No Thread to tension. Combine Fragments first (C).")
		return false
	threads.pop_front()
	thread_count = threads.size()
	structure_built = true
	structures_standing += 1
	phase = "inhabit"
	threads_changed.emit(thread_count)
	structure_seated.emit()
	prompt_changed.emit("Structure seated across the void. It will shed Fragments — the loom answers.")
	return true


func emit_from_structure(at: Vector2) -> String:
	var structure: Dictionary = recipes.get("structure", {})
	var kinds: Array = structure.get("emit_kinds", ["Anchor", "Span"])
	if kinds.is_empty():
		kinds = ["Anchor", "Span"]
	var kind := str(kinds[_rng.randi_range(0, kinds.size() - 1)])
	fragment_emitted.emit(kind, at)
	return kind


func selftest_loop(seed: int = 7) -> Dictionary:
	_rng.seed = seed
	reset()
	var log: Array[String] = []
	assert(add_fragment("Anchor"))
	assert(add_fragment("Span"))
	log.append("gathered")
	var combo := combine_indices(0, 1)
	assert(combo.get("ok", false))
	log.append("combined")
	assert(seat_structure())
	log.append("woven")
	var emitted := emit_from_structure(Vector2(640, 360))
	assert(emitted != "")
	log.append("emitted:%s" % emitted)
	return {
		"ok": true,
		"phase": phase,
		"structures": structures_standing,
		"log": log,
		"fragments_gathered": fragments_gathered,
		"combines_done": combines_done,
	}
