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
	if idx >= 0 and idx < _campaign.size():
		return _campaign[idx]
	# Daily can address authored hard variants by content index (id).
	for play in _playable:
		if int(play.get("id", -1)) == idx:
			return play
	return {}


func get_chamber_by_content_id(content_id: String) -> Dictionary:
	if not _loaded:
		reload()
	return _by_content_id.get(content_id, {})


func index_for_content_id(content_id: String) -> int:
	## Authored chamber index (campaign slot or hard-variant id), or -1.
	var play: Dictionary = get_chamber_by_content_id(content_id)
	if play.is_empty():
		return -1
	return int(play.get("id", -1))


func is_addressable_chamber(idx: int) -> bool:
	return not get_chamber(idx).is_empty()


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


func daily_eligible_indices() -> Array:
	## Authored indices flagged daily_eligible and present in the active book.
	if not _loaded:
		reload()
	var out: Array = []
	var seen: Dictionary = {}
	for play in _playable:
		if not bool(play.get("daily_eligible", false)):
			continue
		var idx: int = int(play.get("id", -1))
		if idx < 0 or seen.has(idx):
			continue
		seen[idx] = true
		out.append(idx)
	out.sort()
	return out


## Legacy helper — whole-book Fisher–Yates. Prefer daily_wing_for_entry.
func daily_chamber_indices(seed_int: int, count: int = 5) -> Array:
	return _shuffle_pick(_all_campaign_indices(), seed_int, count, -1)


## Calendar / catalog entry → five-chamber daily wing.
## Featured chamber_id leads; remaining slots come from daily_eligible only.
func daily_wing_for_entry(entry: Dictionary, count: int = 5) -> Array:
	if not _loaded:
		reload()
	var seed_int: int = int(entry.get("seed", 0))
	var featured_cid: String = str(entry.get("chamber_id", ""))
	var featured_idx: int = index_for_content_id(featured_cid)
	var pool: Array = daily_eligible_indices()
	# Calendar is authoritative: ensure featured is in the pool when loaded.
	if featured_idx >= 0 and not pool.has(featured_idx):
		pool.append(featured_idx)
		pool.sort()
	if pool.is_empty():
		# Last resort (empty catalog / broken book): campaign shuffle.
		return _shuffle_pick(_all_campaign_indices(), seed_int if seed_int != 0 else 1, count, -1)
	if featured_idx < 0:
		# Demo / missing content — eligible-only wing from catalog seed.
		return _shuffle_pick(pool, seed_int if seed_int != 0 else 1, count, -1)
	var out: Array = [featured_idx]
	var rest: Array = _shuffle_pick(pool, seed_int if seed_int != 0 else 1, count, featured_idx)
	for idx in rest:
		if out.size() >= count:
			break
		if not out.has(idx):
			out.append(idx)
	return out


func _all_campaign_indices() -> Array:
	var pool: Array = []
	for i in range(chamber_count()):
		pool.append(i)
	return pool


func _shuffle_pick(pool_in: Array, seed_int: int, count: int, exclude_idx: int) -> Array:
	var pool: Array = []
	for v in pool_in:
		var idx: int = int(v)
		if exclude_idx >= 0 and idx == exclude_idx:
			continue
		pool.append(idx)
	if pool.is_empty():
		return []
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_int
	for i in range(pool.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
	var out: Array = []
	for i in range(mini(count, pool.size())):
		out.append(pool[i])
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
