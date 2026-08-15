extends RefCounted
## Game-as-cloth metaphor stub — authority: docs/WEAVER/GAME_AS_CLOTH.md
## Player weaves the game/universe into being. Features unlock as structures of play:
## new verbs appear because you wove them (not via skill trees or shed-building menus).
##
## Stub: seating play-structure `echo_loom` unlocks verb `echo`.

signal verb_unlocked(verb_id: String, structure_id: String)

## Starting hand verbs (FIRST_FIVE fence). Echo is locked until woven.
const BASE_VERBS: Array[String] = ["recover", "bind", "tension", "inhabit"]

## Play-structure id → verb id it seats into the cloth.
const PLAY_STRUCTURE_VERBS := {
	"echo_loom": "echo",
}

var unlocked_verbs: Array[String] = []
var seated_play_structures: Array[String] = []


func _init() -> void:
	reset()


func reset() -> void:
	unlocked_verbs = BASE_VERBS.duplicate()
	seated_play_structures.clear()


func has_verb(verb_id: String) -> bool:
	return unlocked_verbs.has(verb_id)


func is_play_structure(structure_id: String) -> bool:
	return PLAY_STRUCTURE_VERBS.has(structure_id)


func verb_for_structure(structure_id: String) -> String:
	return str(PLAY_STRUCTURE_VERBS.get(structure_id, ""))


func seat_play_structure(structure_id: String) -> Dictionary:
	## Seat a structure of play. Unlocks its verb into the player's hands.
	## Metaphor lock: verbs appear because you wove them — not from a menu.
	if not is_play_structure(structure_id):
		return {"ok": false, "reason": "Not a play-structure.", "verb": ""}
	if seated_play_structures.has(structure_id):
		var already: String = verb_for_structure(structure_id)
		return {"ok": true, "reason": "Already woven.", "verb": already, "already": true}
	var verb: String = verb_for_structure(structure_id)
	seated_play_structures.append(structure_id)
	if verb != "" and not unlocked_verbs.has(verb):
		unlocked_verbs.append(verb)
		verb_unlocked.emit(verb, structure_id)
	return {"ok": true, "reason": "Verb woven into the cloth.", "verb": verb, "already": false}


func selftest() -> Dictionary:
	reset()
	assert(has_verb("recover"))
	assert(has_verb("bind"))
	assert(not has_verb("echo"))
	var fail := seat_play_structure("span_structure")
	assert(not bool(fail.get("ok", true)))
	var woven := seat_play_structure("echo_loom")
	assert(bool(woven.get("ok", false)))
	assert(str(woven.get("verb", "")) == "echo")
	assert(has_verb("echo"))
	var again := seat_play_structure("echo_loom")
	assert(bool(again.get("already", false)))
	return {
		"ok": true,
		"verbs": unlocked_verbs.duplicate(),
		"play_structures": seated_play_structures.duplicate(),
		"unlocked": "echo",
	}
