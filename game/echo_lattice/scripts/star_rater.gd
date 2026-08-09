class_name StarRater
extends RefCounted

## Computes 1–3 stars from moves vs BFS par using BalanceTuning thresholds.


static func rate(moves: int, bfs_len: int, act_id: int, mode_id: String = "standard", bal: BalanceTuning = null) -> int:
	var cuts := thresholds(bfs_len, act_id, mode_id, bal)
	var stars := 1
	if moves <= int(cuts["two"]):
		stars = 2
	if moves <= int(cuts["three"]):
		stars = 3
	return stars


static func thresholds(bfs_len: int, act_id: int, mode_id: String = "standard", bal: BalanceTuning = null) -> Dictionary:
	var tuning := bal if bal != null else BalanceTuning.load_default()
	var stars_cfg: Dictionary = tuning.stars_config()
	var thr: Dictionary = stars_cfg.get("thresholds", {})
	var padding := int(stars_cfg.get("bfs_par_padding", 2))
	var bfs_par := maxi(1, bfs_len) + padding
	var act_mult := float(tuning.act(act_id).get("star_par_multiplier", 1.0))
	var mode_slack := float(tuning.mode(mode_id).get("star_slack", 1.0))
	var three_mult := float(thr.get("three_star_mult", 1.15))
	var two_mult := float(thr.get("two_star_mult", 1.55))
	var three_cut := int(ceil(float(bfs_par) * three_mult * act_mult * mode_slack))
	var two_cut := int(ceil(float(bfs_par) * two_mult * act_mult * mode_slack))
	# Guarantee 3★ cut is never looser than 2★ cut.
	if three_cut > two_cut:
		three_cut = two_cut
	return {
		"bfs_par": bfs_par,
		"three": three_cut,
		"two": two_cut,
		"one": null,
	}


static func explain(moves: int, bfs_len: int, act_id: int, mode_id: String = "standard", bal: BalanceTuning = null) -> String:
	var cuts := thresholds(bfs_len, act_id, mode_id, bal)
	var stars := rate(moves, bfs_len, act_id, mode_id, bal)
	return "stars=%d moves=%d bfs_par=%d two<=%d three<=%d" % [
		stars, moves, int(cuts["bfs_par"]), int(cuts["two"]), int(cuts["three"]),
	]
