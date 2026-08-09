extends Node
##
## Chamber book — façade over JSON content for Echo Lattice v2 complete.
##
## Loads authored chambers from res://content/chambers/ via ChamberLoader.
## Campaign order comes from acts.json (35 chambers + optional hard variants).
## Keeps the elevated playable API: get_chamber, act_for_chamber, daily wing.
##
## Glyph legend (24×14):
##   '#' wall (immovable)
##   '.' floor
##   'P' player start (counts as floor)
##   'G' goal tile
##   'C' checkpoint (walkable; triggers a lattice rewrite the first time entered)
##
## Transforms:
##   "none" | "mirror_v" | "mirror_h" | "rotate_180" | "thicken"
##   | "mirror_v_then_h" | "invert"
##

const _Loader = preload("res://scripts/chamber_loader.gd")
const GRID_W: int = 24
const GRID_H: int = 14

var _records: Array = []          # normalized loader records
var _playable: Array = []         # playable dictionaries
var _by_content_id: Dictionary = {}
var _campaign: Array = []         # campaign progression (excludes hard)
var _loaded: bool = false


func _ready() -> void:
	reload()


func reload() -> void:
	_records = _Loader.load_all()
	_playable.clear()
	_by_content_id.clear()
	_campaign.clear()
	# Prefer acts.json campaign_order when present so progression is explicit.
	var order: Array = _campaign_order_ids()
	if not order.is_empty():
		var by_id: Dictionary = {}
		for rec in _records:
			by_id[str(rec.get("content_id", ""))] = rec
		for cid in order:
			var rec2: Dictionary = by_id.get(str(cid), {})
			if rec2.is_empty():
				push_error("ChamberBook: acts.json missing chamber %s" % str(cid))
				continue
			var play2: Dictionary = _to_playable(rec2)
			_playable.append(play2)
			_by_content_id[str(cid)] = play2
			_campaign.append(play2)
		# Append hard variants after campaign (not in progression).
		for rec3 in _records:
			if str(rec3.get("role", "")) == "hard":
				var play3: Dictionary = _to_playable(rec3)
				_playable.append(play3)
				_by_content_id[str(rec3.get("content_id", ""))] = play3
	else:
		for rec in _records:
			var play: Dictionary = _to_playable(rec)
			_playable.append(play)
			_by_content_id[str(rec.get("content_id", ""))] = play
			if str(rec.get("role", "")) != "hard":
				_campaign.append(play)
	_loaded = true
	print("ChamberBook: loaded %d chambers (%d campaign)" % [_playable.size(), _campaign.size()])


func _to_playable(rec: Dictionary) -> Dictionary:
	var play: Dictionary = _Loader.to_playable(rec)
	# BalanceTuning keys acts as "1"/"2"/"3". Map content act_index 0..3 → 1..3.
	var act_idx: int = int(rec.get("act_index", 0))
	play["act"] = clampi(act_idx + 1, 1, 3)
	play["act_index"] = act_idx
	play["act_name"] = str(rec.get("act", ""))
	return play


func _campaign_order_ids() -> Array:
	var path := "res://content/acts.json"
	if not FileAccess.file_exists(path):
		return []
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return []
	return parsed.get("campaign_order", [])


func get_chamber(idx: int) -> Dictionary:
	if not _loaded:
		reload()
	# Campaign progression uses non-hard chambers so hard variants stay optional.
	if idx < 0 or idx >= _campaign.size():
		return {}
	return _campaign[idx]


func get_chamber_by_content_id(content_id: String) -> Dictionary:
	if not _loaded:
		reload()
	return _by_content_id.get(content_id, {})


func get_all_records() -> Array:
	if not _loaded:
		reload()
	return _records


func chamber_count() -> int:
	if not _loaded:
		reload()
	return _campaign.size()


func total_authored_count() -> int:
	if not _loaded:
		reload()
	return _playable.size()


func act_for_chamber(idx: int) -> int:
	var data: Dictionary = get_chamber(idx)
	if data.is_empty():
		return 1
	return int(data.get("act", 1))


## Daily wing: five chamber indices derived from YYYYMMDD seed.
func daily_chamber_indices(seed_int: int, count: int = 5) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_int
	var pool: Array = []
	for i in range(chamber_count()):
		pool.append(i)
	# Fisher–Yates
	for i in range(pool.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
	var out: Array = []
	for i in range(mini(count, pool.size())):
		out.append(pool[i])
	out.sort()
	return out


func acts_summary() -> Array:
	if not _loaded:
		reload()
	var path := "res://content/acts.json"
	if not FileAccess.file_exists(path):
		return []
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return []
	return parsed.get("acts", [])
