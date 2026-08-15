extends Node
## Autoload: gather → open combine attempt → weave session state.
## Authority: docs/WEAVER/TRUE_NORTH.md · 36_OPEN_COMPONENT_GRAMMAR.md · GAME_AS_CLOTH.md · 32_FIRST_FIVE.md
## Metaphor: player weaves the game into being; play-structures unlock verbs (not shed-building).

signal fragments_changed(count: int)
signal threads_changed(count: int)
signal structure_seated
signal fragment_emitted(kind: String, at: Vector2)
signal prompt_changed(text: String)
signal inventory_changed
signal combine_ui_requested
signal bind_attempted(result: Dictionary)
signal verb_unlocked(verb_id: String, structure_id: String)

const GameAsClothScript := preload("res://scripts/loom/game_as_cloth.gd")
var cloth: RefCounted = null

var fragment_inventory: Array[String] = []
var thread_count: int = 0
var threads: Array[Dictionary] = []
var bind_log: Array[Dictionary] = []
var structure_built: bool = false
var structures_standing: int = 0
var fragments_gathered: int = 0
var combines_done: int = 0
var binds_failed: int = 0
var phase: String = "gather"

const MAX_CARRY := 4
const COMBINE_COST := 2
const RECIPE_PATH := "res://content/recipes.json"
const ATOMS_PATH := "res://content/atoms.json"

var recipes: Dictionary = {}
var atoms_data: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var pending_selftest: bool = false
var pending_screenshot: bool = false
var pending_gameplay_demo: bool = false
var pending_photos: bool = false
var api_selftest_result: Dictionary = {}


func _ready() -> void:
	cloth = GameAsClothScript.new()
	cloth.verb_unlocked.connect(_on_cloth_verb_unlocked)
	_rng.randomize()
	load_recipes()
	load_atoms()
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


func load_atoms() -> void:
	var path := ATOMS_PATH
	var from_recipes := str(recipes.get("atoms_path", ""))
	if from_recipes != "":
		path = from_recipes
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		atoms_data = {}
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		atoms_data = parsed
	else:
		atoms_data = {}


func reset() -> void:
	if cloth == null:
		cloth = GameAsClothScript.new()
		cloth.verb_unlocked.connect(_on_cloth_verb_unlocked)
	cloth.reset()
	fragment_inventory.clear()
	threads.clear()
	bind_log.clear()
	thread_count = 0
	structure_built = false
	structures_standing = 0
	fragments_gathered = 0
	combines_done = 0
	binds_failed = 0
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
	prompt_changed.emit("Collected %s. Fragments: %d. Press C — any two may try to bind." % [
		family, fragment_inventory.size()
	])
	return true


func can_combine() -> bool:
	return fragment_inventory.size() >= COMBINE_COST


## Resolve craft skins (Anchor/Span/…) onto open atoms (Matter/Space/…).
func resolve_atom(kind: String) -> String:
	var aliases: Dictionary = atoms_data.get("craft_aliases", {})
	if aliases.has(kind):
		return str(aliases[kind])
	for atom in atoms_data.get("atoms", []):
		if typeof(atom) == TYPE_DICTIONARY and str(atom.get("id", "")) == kind:
			return kind
	# Legacy / unknown: keep id so open attempt still answers.
	return kind


func _affinity_entry(atom_a: String, atom_b: String) -> Dictionary:
	var list: Array = atoms_data.get("combine_affinity", [])
	for entry in list:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var inputs: Array = entry.get("inputs", [])
		if inputs.size() != 2:
			continue
		var i0 := str(inputs[0])
		var i1 := str(inputs[1])
		if (i0 == atom_a and i1 == atom_b) or (i0 == atom_b and i1 == atom_a):
			return entry
	var fallback: Dictionary = atoms_data.get("default_unknown", {})
	if fallback.is_empty():
		return {
			"outcome": "strain",
			"fray": "Fray",
			"tell": "The loom tries — these atoms quarrel without a name yet.",
			"consume": "refund",
		}
	return fallback


## Preview / resolve a bind attempt for any two kinds (open grammar).
## Never silent — always returns outcome + tell. Does not mutate inventory.
func attempt_bind(kind_a: String, kind_b: String) -> Dictionary:
	var atom_a := resolve_atom(kind_a)
	var atom_b := resolve_atom(kind_b)
	var entry := _affinity_entry(atom_a, atom_b)
	var outcome := str(entry.get("outcome", "strain"))
	var result := {
		"ok": outcome == "bind",
		"outcome": outcome,
		"atoms": [atom_a, atom_b],
		"from": [kind_a, kind_b],
		"tell": str(entry.get("tell", "The loom answers.")),
		"consume": str(entry.get("consume", "consume" if outcome == "bind" else "refund")),
		"fray": str(entry.get("fray", "")),
		"emergent": str(entry.get("emergent", "")),
		"recipe_id": "affinity:%s+%s" % [atom_a, atom_b],
	}
	if outcome == "bind":
		result["output_thread"] = str(entry.get("output_thread", "Brace"))
		result["label"] = str(entry.get("label", "Thread"))
		result["thread"] = {
			"type": result["output_thread"],
			"label": result["label"],
			"recipe_id": result["recipe_id"],
			"from": [kind_a, kind_b],
			"atoms": [atom_a, atom_b],
			"emergent": result["emergent"],
		}
	return result


## Compatibility: recipe table first, then open affinity (may fail interestingly).
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
			return {
				"id": str(entry.get("id", "")),
				"inputs": [a, b],
				"output_thread": str(entry.get("output_thread", "Brace")),
				"label": str(entry.get("label", "Brace Thread")),
				"outcome": "bind",
				"ok": true,
				"tell": "Seam holds.",
				"emergent": "Span",
			}
	var attempt := attempt_bind(a, b)
	if bool(attempt.get("ok", false)):
		return {
			"id": str(attempt.get("recipe_id", "")),
			"inputs": [a, b],
			"output_thread": str(attempt.get("output_thread", "Brace")),
			"label": str(attempt.get("label", "Thread")),
			"outcome": "bind",
			"ok": true,
			"tell": str(attempt.get("tell", "")),
			"emergent": str(attempt.get("emergent", "")),
		}
	# Interesting failure — still a "recipe" preview for UI.
	return {
		"id": str(attempt.get("recipe_id", "fail")),
		"inputs": [a, b],
		"outcome": str(attempt.get("outcome", "strain")),
		"ok": false,
		"label": str(attempt.get("fray", "Fray")),
		"tell": str(attempt.get("tell", "")),
		"fray": str(attempt.get("fray", "")),
	}


func combine_indices(i: int, j: int) -> Dictionary:
	if i == j or i < 0 or j < 0 or i >= fragment_inventory.size() or j >= fragment_inventory.size():
		return {"ok": false, "outcome": "invalid", "reason": "Pick two different Fragments.", "tell": "Pick two different Fragments."}
	var a: String = fragment_inventory[i]
	var b: String = fragment_inventory[j]
	var attempt := attempt_bind(a, b)
	# Prefer explicit craft recipe when both skins are listed (FIRST_FIVE path).
	var recipe := find_recipe(a, b)
	if bool(recipe.get("ok", false)):
		attempt = attempt_bind(a, b)
		# If craft recipe exists, force bind using recipe labels even when affinity matches.
		if str(recipe.get("id", "")).begins_with("affinity:") == false and recipe.has("output_thread"):
			attempt["ok"] = true
			attempt["outcome"] = "bind"
			attempt["output_thread"] = recipe["output_thread"]
			attempt["label"] = recipe["label"]
			attempt["tell"] = str(recipe.get("tell", attempt.get("tell", "Seam holds.")))
			attempt["emergent"] = str(recipe.get("emergent", "Span"))
			attempt["consume"] = "consume"
			attempt["thread"] = {
				"type": str(recipe["output_thread"]),
				"label": str(recipe["label"]),
				"recipe_id": str(recipe.get("id", "")),
				"from": [a, b],
				"atoms": [resolve_atom(a), resolve_atom(b)],
				"emergent": str(recipe.get("emergent", "Span")),
			}

	var hi := maxi(i, j)
	var lo := mini(i, j)
	var consume := str(attempt.get("consume", "refund"))
	if bool(attempt.get("ok", false)) and consume != "refund":
		fragment_inventory.remove_at(hi)
		fragment_inventory.remove_at(lo)
		var thread: Dictionary = attempt.get("thread", {})
		threads.append(thread)
		thread_count = threads.size()
		combines_done += 1
		phase = "weave"
		fragments_changed.emit(fragment_inventory.size())
		threads_changed.emit(thread_count)
		inventory_changed.emit()
		prompt_changed.emit("Bound %s + %s → %s. Stand in the void and press Space to weave." % [
			a, b, thread.get("label", "Thread")
		])
		bind_log.append(attempt)
		bind_attempted.emit(attempt)
		return attempt

	# Interesting failure: refund by default (inventory unchanged).
	binds_failed += 1
	if phase == "gather":
		phase = "combine"
	prompt_changed.emit(str(attempt.get("tell", "Bind failed — the loom answered.")))
	bind_log.append(attempt)
	bind_attempted.emit(attempt)
	attempt["reason"] = str(attempt.get("tell", "Bind failed."))
	return attempt


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
	var used: Dictionary = threads.pop_front()
	thread_count = threads.size()
	structure_built = true
	structures_standing += 1
	phase = "inhabit"
	threads_changed.emit(thread_count)
	structure_seated.emit()
	var emergent := str(used.get("emergent", "Span"))
	if emergent == "" or emergent == "Span":
		prompt_changed.emit("Structure seated across the void. It will shed Fragments — the loom answers.")
	else:
		prompt_changed.emit("%s lean seated. It will shed Fragments — the loom answers." % emergent)
	return true


func emit_from_structure(at: Vector2) -> String:
	var structure: Dictionary = recipes.get("structure", {})
	var kinds: Array = structure.get("emit_kinds", ["Anchor", "Span"])
	if kinds.is_empty():
		kinds = ["Anchor", "Span"]
	var kind := str(kinds[_rng.randi_range(0, kinds.size() - 1)])
	fragment_emitted.emit(kind, at)
	return kind


func has_verb(verb_id: String) -> bool:
	if cloth == null:
		return false
	return cloth.has_verb(verb_id)

func seat_play_structure(structure_id: String) -> Dictionary:
	## Weave a structure of play — unlocks a verb into the cloth (GAME_AS_CLOTH.md).
	if cloth == null:
		cloth = GameAsClothScript.new()
		cloth.verb_unlocked.connect(_on_cloth_verb_unlocked)
	var result: Dictionary = cloth.seat_play_structure(structure_id)
	if bool(result.get("ok", false)) and not bool(result.get("already", false)):
		var verb := str(result.get("verb", ""))
		prompt_changed.emit("Wove play-structure %s — verb '%s' is now in your hands." % [
			structure_id, verb
		])
	return result

func _on_cloth_verb_unlocked(verb_id: String, structure_id: String) -> void:
	verb_unlocked.emit(verb_id, structure_id)

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
	# Open grammar: interesting failure must answer without consuming.
	assert(add_fragment("Light"))
	assert(add_fragment("Time"))
	var fail := combine_indices(0, 1)
	assert(not bool(fail.get("ok", true)))
	assert(str(fail.get("outcome", "")) in ["strain", "snap"])
	assert(fragment_inventory.size() == 2)
	log.append("failed_interestingly:%s" % str(fail.get("outcome", "")))
	fragment_inventory.clear()
	assert(seat_structure())
	log.append("woven")
	var emitted := emit_from_structure(Vector2(640, 360))
	assert(emitted != "")
	log.append("emitted:%s" % emitted)
	var cloth_result: Dictionary = cloth.selftest() if cloth else {}
	assert(bool(cloth_result.get("ok", false)))
	# Re-seat after cloth.selftest reset: prove Loom API unlocks echo via echo_loom.
	cloth.reset()
	var seat: Dictionary = seat_play_structure("echo_loom")
	assert(bool(seat.get("ok", false)))
	assert(has_verb("echo"))
	return {
		"ok": true,
		"phase": phase,
		"structures": structures_standing,
		"log": log,
		"fragments_gathered": fragments_gathered,
		"combines_done": combines_done,
		"binds_failed": binds_failed,
		"verbs": cloth.unlocked_verbs.duplicate() if cloth else [],
	}
