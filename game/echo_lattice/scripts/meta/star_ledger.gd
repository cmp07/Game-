class_name StarLedger
extends RefCounted
## Persists best-of stars per chamber. Never decreases.


static func apply_clear(save: Dictionary, chamber_id: String, stars: int) -> Dictionary:
	var awarded := clampi(stars, 1, 3)
	if not save.has("stars") or typeof(save["stars"]) != TYPE_DICTIONARY:
		save["stars"] = {"best": {}, "total_earned": 0}
	var block: Dictionary = save["stars"]
	if not block.has("best") or typeof(block["best"]) != TYPE_DICTIONARY:
		block["best"] = {}
	var best: Dictionary = block["best"]
	var prev := int(best.get(chamber_id, 0))
	if awarded > prev:
		best[chamber_id] = awarded
	block["total_earned"] = total(save)
	save["stars"] = block
	return {"previous": prev, "awarded": awarded, "best": int(best[chamber_id])}


static func best_for(save: Dictionary, chamber_id: String) -> int:
	var block: Dictionary = save.get("stars", {})
	var best: Dictionary = block.get("best", {})
	return int(best.get(chamber_id, 0))


static func total(save: Dictionary) -> int:
	var block: Dictionary = save.get("stars", {})
	var best: Dictionary = block.get("best", {})
	var sum := 0
	for k in best.keys():
		sum += int(best[k])
	return sum


static func chambers_with_stars(save: Dictionary, at_least: int = 1) -> PackedStringArray:
	var out: PackedStringArray = []
	var best: Dictionary = save.get("stars", {}).get("best", {})
	for k in best.keys():
		if int(best[k]) >= at_least:
			out.append(str(k))
	return out
