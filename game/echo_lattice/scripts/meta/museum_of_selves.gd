class_name MuseumOfSelves
extends RefCounted
## Archives cleared-run habit fossils for browsing / ghost races.


static func ensure(save: Dictionary, cfg: Dictionary) -> Dictionary:
	if not save.has("museum") or typeof(save["museum"]) != TYPE_DICTIONARY:
		save["museum"] = {"selves": [], "cap": int(cfg.get("museum", {}).get("cap", 48))}
	var museum: Dictionary = save["museum"]
	if not museum.has("selves") or typeof(museum["selves"]) != TYPE_ARRAY:
		museum["selves"] = []
	if not museum.has("cap"):
		museum["cap"] = int(cfg.get("museum", {}).get("cap", 48))
	return museum


static func maybe_archive(
	save: Dictionary,
	cfg: Dictionary,
	run: Dictionary,
	outcome: String,
	run_stats: Dictionary
) -> Dictionary:
	var museum_cfg: Dictionary = cfg.get("museum", {})
	if not bool(museum_cfg.get("archive_on_clear", true)):
		return {}
	if outcome != "clear":
		return {}
	var museum := ensure(save, cfg)
	var habit: Dictionary = run_stats.get("habit", {})
	if habit.is_empty():
		habit = {
			"dominant": str(run_stats.get("dominant", "none")),
			"dominant_bias": float(run_stats.get("dominant_bias", 0.0)),
			"turn_rate": float(run_stats.get("turn_rate", 0.0)),
			"backtrack_rate": float(run_stats.get("backtrack_rate", 0.0)),
			"archetype": str(run_stats.get("archetype", "balanced")),
			"fingerprint": int(run_stats.get("fingerprint", 0)),
		}
	var chamber_id := str(run.get("chamber_id", ""))
	var chamber_name := str(cfg.get("chambers", {}).get(chamber_id, {}).get("name", chamber_id))
	var archetype := str(habit.get("archetype", "balanced"))
	var templates: Dictionary = museum_cfg.get("title_templates", {})
	var tmpl: String = str(templates.get(archetype, templates.get("default", "A Self from {chamber}")))
	var title := tmpl.replace("{chamber}", chamber_name)

	var path: Array = run_stats.get("path", [])
	var stride := int(museum_cfg.get("ghost_stride", 2))
	var compact: Array = []
	if typeof(path) == TYPE_ARRAY and path.size() > 0:
		var i := 0
		while i < path.size():
			compact.append(path[i])
			i += maxi(1, stride)
		if compact.is_empty() or compact[compact.size() - 1] != path[path.size() - 1]:
			compact.append(path[path.size() - 1])

	var self_row := {
		"id": "self_%s_%04d" % [
			SeedClock.daily_datestamp().replace("-", ""),
			museum["selves"].size() + 1,
		],
		"created_at": Time.get_datetime_string_from_system(true),
		"chamber_id": chamber_id,
		"mode": str(run.get("mode", "standard")),
		"seed": int(run.get("seed", 0)),
		"stars": int(run_stats.get("stars", 1)),
		"moves": int(run_stats.get("moves", run.get("duration_sec", 0))),
		"undos": int(run_stats.get("undos", 0)),
		"outcome": outcome,
		"ng_plus": bool(save.get("ng_plus", {}).get("active", false)),
		"habit": habit,
		"ghost": {"stride": stride, "path": compact},
		"title": title,
	}
	var selves: Array = museum["selves"]
	selves.push_front(self_row)
	var cap := int(museum.get("cap", 48))
	while selves.size() > cap:
		selves.pop_back()
	museum["selves"] = selves
	save["museum"] = museum
	return self_row


static func count(save: Dictionary) -> int:
	return int(save.get("museum", {}).get("selves", []).size())


static func get_self(save: Dictionary, self_id: String) -> Dictionary:
	for row in save.get("museum", {}).get("selves", []):
		if typeof(row) == TYPE_DICTIONARY and str(row.get("id", "")) == self_id:
			return row
	return {}


static func list_selves(save: Dictionary) -> Array:
	return save.get("museum", {}).get("selves", [])
