extends Node
class_name ChamberCatalog
##
## Static catalog of Echo Lattice chambers. Data-in-code so the
## meta shell can be exercised before any content lives on disk.
##
## Each chamber is a Dictionary:
##
##   id            String   stable key; also used in unlock lists
##   display_name  String
##   subtitle      String
##   difficulty    int      1..5, purely cosmetic today
##   par_time_sec  int      target clear time (used in stats screen)
##   tags          Array    e.g. ["intro", "hostile"]
##   unlock        Dict     see below
##
## `unlock` shapes:
##   { "kind": "always" }                          always available
##   { "kind": "chamber_cleared", "chamber_id": ".." }
##   { "kind": "runs_completed", "count": N }
##

const CHAMBERS: Array[Dictionary] = [
	{
		"id": "ec_01_boot",
		"display_name": "Booting the Lattice",
		"subtitle": "Onboarding. Learn the pulse.",
		"difficulty": 1,
		"par_time_sec": 90,
		"tags": ["intro"],
		"unlock": {"kind": "always"},
	},
	{
		"id": "ec_02_hum",
		"display_name": "The Hum",
		"subtitle": "First hostile echo.",
		"difficulty": 2,
		"par_time_sec": 120,
		"tags": ["hostile"],
		"unlock": {"kind": "chamber_cleared", "chamber_id": "ec_01_boot"},
	},
	{
		"id": "ec_03_signal",
		"display_name": "Signal Bleed",
		"subtitle": "Cross-talk between chambers.",
		"difficulty": 3,
		"par_time_sec": 180,
		"tags": ["hostile", "puzzle"],
		"unlock": {"kind": "chamber_cleared", "chamber_id": "ec_02_hum"},
	},
	{
		"id": "ec_04_silence",
		"display_name": "Room 4 Is Silent",
		"subtitle": "Absence is a signal too.",
		"difficulty": 4,
		"par_time_sec": 240,
		"tags": ["stealth"],
		"unlock": {"kind": "runs_completed", "count": 5},
	},
	{
		"id": "ec_05_choir",
		"display_name": "The Choir",
		"subtitle": "Endgame. Everything at once.",
		"difficulty": 5,
		"par_time_sec": 360,
		"tags": ["hostile", "puzzle", "boss"],
		"unlock": {"kind": "chamber_cleared", "chamber_id": "ec_04_silence"},
	},
]


static func all() -> Array[Dictionary]:
	return CHAMBERS


static func get_by_id(chamber_id: String) -> Dictionary:
	for c in CHAMBERS:
		if String(c.get("id", "")) == chamber_id:
			return c
	return {}


static func exists(chamber_id: String) -> bool:
	return not get_by_id(chamber_id).is_empty()


## Returns true if the chamber's `unlock` requirement is currently
## satisfied given the SaveService state. `already_unlocked` is
## always considered satisfied.
static func is_available(chamber_id: String, save: Node) -> bool:
	if save == null:
		return false
	if save.is_chamber_unlocked(chamber_id):
		return true
	var chamber := get_by_id(chamber_id)
	if chamber.is_empty():
		return false
	var unlock: Dictionary = chamber.get("unlock", {"kind": "always"})
	return _requirement_met(unlock, save)


static func _requirement_met(unlock: Dictionary, save: Node) -> bool:
	match String(unlock.get("kind", "always")):
		"always":
			return true
		"chamber_cleared":
			var chamber_id := String(unlock.get("chamber_id", ""))
			if chamber_id.is_empty():
				return false
			var clears: Dictionary = save.stats().get("clears_per_chamber", {})
			return int(clears.get(chamber_id, 0)) > 0
		"runs_completed":
			var need := int(unlock.get("count", 0))
			return int(save.stats().get("runs_completed", 0)) >= need
		_:
			return false


## Human-readable unlock hint used on locked cards.
static func unlock_hint(chamber_id: String) -> String:
	var chamber := get_by_id(chamber_id)
	if chamber.is_empty():
		return "Unknown chamber"
	var unlock: Dictionary = chamber.get("unlock", {"kind": "always"})
	match String(unlock.get("kind", "always")):
		"always":
			return "Available"
		"chamber_cleared":
			var other := get_by_id(String(unlock.get("chamber_id", "")))
			return "Clear \"%s\" to unlock" % String(other.get("display_name", "?"))
		"runs_completed":
			return "Complete %d runs to unlock" % int(unlock.get("count", 0))
		_:
			return "Locked"


## Called by GameSession on run completion. Promotes any chambers
## whose unlock requirement is now satisfied into the persistent
## unlocks list.
static func refresh_unlocks(save: Node) -> Array[String]:
	var newly: Array[String] = []
	for c in CHAMBERS:
		var id := String(c.get("id", ""))
		if save.is_chamber_unlocked(id):
			continue
		var unlock: Dictionary = c.get("unlock", {"kind": "always"})
		if _requirement_met(unlock, save):
			if save.unlock_chamber(id):
				newly.append(id)
	return newly
