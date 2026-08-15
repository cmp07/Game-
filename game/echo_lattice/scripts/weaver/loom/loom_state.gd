extends Node
## Autoload: gather → combine → weave session state (extends scaffold stub).
## Authority: docs/WEAVER/32_FIRST_FIVE.md · 17_MVP.md · 02_CORE_LOOP.md · PLAYER_SHAPED.md

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
const RECIPE_PATH := "res://content/weaver/recipes.json"
## Player-shaped void memory — local rules + seeded emergence (no online LLM).
const PLAYER_SEED_PATH := "user://weaver_player_seed.json"
const PLAYER_SEED_VERSION := 1
const PLAYER_SEED_ACTIONS_MAX := 32
const PLAYER_SEED_WEIGHT_CAP := 64

var recipes: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var pending_selftest: bool = false
var pending_screenshot: bool = false
var api_selftest_result: Dictionary = {}
## Void memory fingerprint — persists across sessions; drives emergence picks.
var base_seed: int = 0
var player_seed: int = 0
var law_weights: Dictionary = {}
var recent_actions: Array = []
var session_count: int = 0
var _persist_player_seed: bool = true


func _ready() -> void:
	_rng.randomize()
	load_recipes()
	var args := OS.get_cmdline_user_args()
	if args.has("--selftest"):
		# Field-driven self-test path — isolate void memory from disk.
		_persist_player_seed = false
		pending_selftest = true
		pending_screenshot = args.has("--screenshot")
		reset_player_seed(7)
		api_selftest_result = selftest_loop(7)
	elif args.has("--weaver-selftest") or args.has("--weaver-photos"):
		# Main owns these runners; still avoid writing player seed during CI captures.
		_persist_player_seed = false
		reset_player_seed(7)
	else:
		load_player_seed()
		session_count += 1
		_recompute_player_seed()
		save_player_seed()


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
	remember_action("bind", {
		"thread": str(thread.get("type", "Brace")),
		"from": [a, b],
	})
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
	remember_action("tension", {"structures": structures_standing})
	threads_changed.emit(thread_count)
	structure_seated.emit()
	prompt_changed.emit("Structure seated across the void. Geometry fills — Fragments will return.")
	return true


func emit_from_structure(at: Vector2) -> String:
	var structure: Dictionary = recipes.get("structure", {})
	var kinds: Array = structure.get("emit_kinds", ["Anchor", "Span"])
	if kinds.is_empty():
		kinds = ["Anchor", "Span"]
	var kind := str(kinds[emergence_index(kinds.size(), structures_standing)])
	remember_action("emit", {"kind": kind})
	fragment_emitted.emit(kind, at)
	return kind


func reset_player_seed(seed: int = 0) -> void:
	base_seed = seed if seed != 0 else int(Time.get_unix_time_from_system()) & 0x7fffffff
	if base_seed == 0:
		base_seed = 1
	law_weights = {}
	recent_actions = []
	session_count = 0
	_recompute_player_seed()


func load_player_seed() -> bool:
	if not FileAccess.file_exists(PLAYER_SEED_PATH):
		reset_player_seed()
		return false
	var file := FileAccess.open(PLAYER_SEED_PATH, FileAccess.READ)
	if file == null:
		reset_player_seed()
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		reset_player_seed()
		return false
	var data: Dictionary = parsed
	base_seed = int(data.get("base_seed", 0))
	if base_seed == 0:
		reset_player_seed()
		return false
	player_seed = int(data.get("player_seed", base_seed))
	session_count = int(data.get("session_count", 0))
	var weights: Variant = data.get("law_weights", {})
	law_weights = weights if typeof(weights) == TYPE_DICTIONARY else {}
	var actions: Variant = data.get("recent_actions", [])
	recent_actions = actions if typeof(actions) == TYPE_ARRAY else []
	_recompute_player_seed()
	return true


func save_player_seed() -> bool:
	if not _persist_player_seed:
		return false
	var data := {
		"version": PLAYER_SEED_VERSION,
		"base_seed": base_seed,
		"player_seed": player_seed,
		"law_weights": law_weights,
		"recent_actions": recent_actions,
		"session_count": session_count,
		"updated_at": Time.get_unix_time_from_system(),
	}
	var file := FileAccess.open(PLAYER_SEED_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Weaver: could not write player seed.")
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true


func remember_action(kind: String, payload: Dictionary = {}) -> void:
	## Actions leave laws — bump void memory, recompute player_seed, persist.
	var law := _law_for_action(kind, payload)
	if law != "":
		var w: int = int(law_weights.get(law, 0)) + 1
		law_weights[law] = mini(w, PLAYER_SEED_WEIGHT_CAP)
	var entry := {
		"kind": kind,
		"law": law,
		"at": Time.get_unix_time_from_system(),
	}
	for key in payload.keys():
		entry[key] = payload[key]
	recent_actions.append(entry)
	while recent_actions.size() > PLAYER_SEED_ACTIONS_MAX:
		recent_actions.pop_front()
	_recompute_player_seed()
	save_player_seed()


func emergence_index(n: int, salt: int = 0) -> int:
	## Seeded pick among authored bricks — same player_seed + salt → same index.
	if n <= 0:
		return 0
	var mixed: int = int(player_seed) ^ int(salt * 2654435761)
	mixed = mixed & 0x7fffffff
	if mixed == 0:
		mixed = 1
	return mixed % n


func _law_for_action(kind: String, payload: Dictionary) -> String:
	match kind:
		"bind":
			var thread := str(payload.get("thread", "Brace")).to_lower()
			if thread.find("brace") >= 0:
				return "brace_bias"
			return "bind_%s" % thread
		"tension":
			return "span_hunger" if structures_standing > 1 else "anchor_nest"
		"emit":
			var emit_kind := str(payload.get("kind", "")).to_lower()
			if emit_kind == "span":
				return "span_hunger"
			if emit_kind == "anchor":
				return "anchor_nest"
			return "inhabit_dwell"
		"abandon":
			return "abandon_scar"
		_:
			return "inhabit_dwell"


func _recompute_player_seed() -> void:
	var mix: int = base_seed if base_seed != 0 else 1
	var keys: Array = law_weights.keys()
	keys.sort()
	for key in keys:
		mix = _mix64(mix, str(key).hash())
		mix = _mix64(mix, int(law_weights[key]))
	mix = _mix64(mix, recent_actions.size())
	mix = _mix64(mix, session_count)
	player_seed = mix & 0x7fffffff
	if player_seed == 0:
		player_seed = 1
	_rng.seed = player_seed


func _mix64(a: int, b: int) -> int:
	var x: int = (a & 0xffffffff) ^ (b & 0xffffffff)
	x = int(x * 2246822519) & 0xffffffff
	x ^= x >> 13
	x = int(x * 3266489917) & 0xffffffff
	x ^= x >> 16
	return x & 0x7fffffff


func selftest_loop(seed: int = 7) -> Dictionary:
	_persist_player_seed = false
	reset_player_seed(seed)
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
		"player_seed": player_seed,
		"law_weights": law_weights.duplicate(),
	}
