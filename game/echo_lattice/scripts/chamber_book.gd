extends Node
##
## Chamber book — façade over JSON content (playable v2).
##
## Loads authored chambers from res://content/chambers/ via ChamberLoader.
## Exposes the PR #48 API: get_chamber(idx) → {id,title,caption,transform,map}.
##
## Glyph legend (24×14):
##   '#' wall (immovable)
##   '.' floor
##   'P' player start (counts as floor)
##   'G' goal tile
##   'C' checkpoint (walkable; triggers a lattice rewrite the first time entered)
##
## Transforms:
##   "none" | "mirror_v" | "mirror_h" | "rotate_180" | "thicken" | "mirror_v_then_h"
##

const _Loader = preload("res://scripts/chamber_loader.gd")
const GRID_W: int = 24
const GRID_H: int = 14

var _records: Array = []          # normalized loader records
var _playable: Array = []         # PR #48 dictionaries
var _by_content_id: Dictionary = {}
var _campaign: Array = []         # indices into _playable for campaign (excludes hard)
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
			var play2: Dictionary = _Loader.to_playable(rec2)
			_playable.append(play2)
			_by_content_id[str(cid)] = play2
			_campaign.append(play2)
		# Append hard variants after campaign (not in progression).
		for rec3 in _records:
			if str(rec3.get("role", "")) == "hard":
				var play3: Dictionary = _Loader.to_playable(rec3)
				_playable.append(play3)
				_by_content_id[str(rec3.get("content_id", ""))] = play3
	else:
		for rec in _records:
			var play: Dictionary = _Loader.to_playable(rec)
			_playable.append(play)
			_by_content_id[str(rec.get("content_id", ""))] = play
			if str(rec.get("role", "")) != "hard":
				_campaign.append(play)
	_loaded = true
	print("ChamberBook: loaded %d chambers (%d campaign)" % [_playable.size(), _campaign.size()])


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
