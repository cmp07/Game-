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
		# Demo builds omit hard variants — they spoil later-act transforms.
		if not DemoBuild.is_demo():
			for rec3 in _records:
				if str(rec3.get("role", "")) == "hard":
					var play3: Dictionary = _to_playable(rec3)
					_playable.append(play3)
					_by_content_id[str(rec3.get("content_id", ""))] = play3
	else:
		for rec in _records:
			var cid: String = str(rec.get("content_id", ""))
			if not DemoBuild.allows_content_id(cid):
				continue
			if DemoBuild.is_demo() and str(rec.get("role", "")) == "hard":
				continue
			var play: Dictionary = _to_playable(rec)
			_playable.append(play)
			_by_content_id[cid] = play
			if str(rec.get("role", "")) != "hard":
				_campaign.append(play)
	_loaded = true
	var demo_tag: String = " [DEMO]" if DemoBuild.is_demo() else ""
	print("ChamberBook: loaded %d chambers (%d campaign)%s" % [
		_playable.size(), _campaign.size(), demo_tag
	])


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
	var order: Array = parsed.get("campaign_order", [])
	# Demo / Next Fest: Act I only — no late-act spoilers in the run queue.
	return DemoBuild.filter_campaign_ids(order)


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


func campaign_index_for_content_id(content_id: String) -> int:
	if not _loaded:
		reload()
	var want: String = str(content_id)
	if want == "":
		return -1
	for i in range(_campaign.size()):
		if str(_campaign[i].get("content_id", "")) == want:
			return i
	return -1


## Rewrite pressure 0..1 from endless depth (clears this run).
static func endless_rewrite_pressure(depth: int) -> float:
	return clampf(0.18 + float(maxi(0, depth)) * 0.055, 0.18, 0.95)


static func endless_min_act_for_pressure(pressure: float) -> int:
	if pressure >= 0.72:
		return 3
	if pressure >= 0.48:
		return 2
	return 1


## Endless batch: deterministic chambers from the daily seed catalog with rising act floor.
## `avoid` maps campaign index -> true for chambers already queued this run (until reshuffle).
func endless_chamber_batch(seed_int: int, depth: int, count: int = 5, avoid: Dictionary = {}) -> Array:
	if not _loaded:
		reload()
	var pressure: float = endless_rewrite_pressure(depth)
	var min_act: int = endless_min_act_for_pressure(pressure)
	var prefer_hard: bool = pressure >= 0.55
	var pool: Array = _endless_catalog_pool(min_act, avoid)
	if pool.is_empty() and not avoid.is_empty():
		# Full reshuffle once the catalog wing is exhausted.
		pool = _endless_catalog_pool(min_act, {})
	if pool.is_empty() and min_act > 1:
		pool = _endless_catalog_pool(1, avoid)
	if pool.is_empty():
		# Last resort: any campaign chamber (demo / sparse books).
		for i in range(chamber_count()):
			if avoid.has(i):
				continue
			pool.append({"idx": i, "hard": false, "act": act_for_chamber(i)})
	if pool.is_empty():
		for i in range(chamber_count()):
			pool.append({"idx": i, "hard": false, "act": act_for_chamber(i)})
	if pool.is_empty():
		return []

	var rng := RandomNumberGenerator.new()
	rng.seed = _endless_batch_seed(seed_int, depth)
	# Weight hard-flagged catalog rows upward as rewrite pressure rises.
	if prefer_hard:
		var hard_first: Array = []
		var soft_rest: Array = []
		for e in pool:
			if bool(e.get("hard", false)):
				hard_first.append(e)
			else:
				soft_rest.append(e)
		_shuffle_entries(hard_first, rng)
		_shuffle_entries(soft_rest, rng)
		pool = hard_first + soft_rest
	else:
		_shuffle_entries(pool, rng)

	var out: Array = []
	var seen: Dictionary = {}
	for e in pool:
		var idx: int = int(e.get("idx", -1))
		if idx < 0 or seen.has(idx):
			continue
		seen[idx] = true
		out.append(idx)
		if out.size() >= count:
			break
	# Pad from campaign if catalog yielded fewer than requested.
	if out.size() < count:
		var pad: Array = []
		for i in range(chamber_count()):
			if seen.has(i) or avoid.has(i):
				continue
			if act_for_chamber(i) < min_act:
				continue
			pad.append(i)
		_shuffle_int_array(pad, rng)
		for idx2 in pad:
			out.append(idx2)
			if out.size() >= count:
				break
	return out


func _endless_catalog_pool(min_act: int, avoid: Dictionary) -> Array:
	var catalog: Dictionary = DailySeeds.load_catalog()
	var seeds: Array = catalog.get("seeds", [])
	var pool: Array = []
	var seen: Dictionary = {}
	for entry in seeds:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var cid: String = str(entry.get("chamber_id", ""))
		var cidx: int = campaign_index_for_content_id(cid)
		if cidx < 0 or avoid.has(cidx) or seen.has(cidx):
			continue
		var act_id: int = act_for_chamber(cidx)
		if act_id < min_act:
			continue
		var varn: Variant = entry.get("variation", {})
		var hard: bool = false
		if typeof(varn) == TYPE_DICTIONARY:
			hard = bool(varn.get("hard", false))
		seen[cidx] = true
		pool.append({"idx": cidx, "hard": hard, "act": act_id})
	return pool


static func _endless_batch_seed(seed_int: int, depth: int) -> int:
	# Mix run seed with depth so each append batch is stable under Continue.
	var mixed: int = int(seed_int) ^ int(depth * 2654435761) ^ 0xE11D15
	return mixed & 0x7FFFFFFF


static func _shuffle_entries(arr: Array, rng: RandomNumberGenerator) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


static func _shuffle_int_array(arr: Array, rng: RandomNumberGenerator) -> void:
	_shuffle_entries(arr, rng)


## Escalate authored transform as rewrite pressure rises (still softlock-guarded).
static func endless_pressure_transform(authored: String, pressure: float, mix_seed: int) -> String:
	var t: String = authored
	if t == "" or t == "none":
		return t
	if pressure < 0.45:
		return t
	var rng := RandomNumberGenerator.new()
	rng.seed = mix_seed & 0x7FFFFFFF
	if pressure >= 0.75:
		match t:
			"mirror_v", "mirror_h":
				return "mirror_v_then_h"
			"rotate_180":
				return "rotate_180" if rng.randf() < 0.55 else "mirror_v_then_h"
			"thicken":
				return "thicken"
			_:
				return t
	# Mid pressure: occasionally stack mirrors.
	if t == "mirror_v" or t == "mirror_h":
		if rng.randf() < clampf((pressure - 0.45) / 0.30, 0.0, 0.85):
			return "mirror_v_then_h"
	return t


func acts_summary() -> Array:
	if not _loaded:
		reload()
	var path := "res://content/acts.json"
	if not FileAccess.file_exists(path):
		return []
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return []
	var acts: Array = parsed.get("acts", [])
	if not DemoBuild.is_demo():
		return acts
	# Demo: expose Induction only — hide Reflection / Pressure / Mastery blurbs.
	var out: Array = []
	for a in acts:
		if str(a.get("id", "")) == DemoBuild.ACT_ID:
			var copy: Dictionary = a.duplicate(true)
			copy["hard_variants"] = []
			out.append(copy)
	return out
