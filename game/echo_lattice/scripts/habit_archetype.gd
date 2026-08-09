class_name HabitArchetype
extends RefCounted

## Classifies a HabitSignature into right_leaner / looper / zigzagger / balanced
## using thresholds from BalanceTuning, and exposes counter score weights.

const ID_RIGHT := "right_leaner"
const ID_LOOP := "looper"
const ID_ZIG := "zigzagger"
const ID_BALANCED := "balanced"

var id: String = ID_BALANCED
var confidence: float = 0.0
var features: Dictionary = {}


static func classify(sig, bal: BalanceTuning = null) -> HabitArchetype:
	var tuning := bal if bal != null else BalanceTuning.load_default()
	var cfg: Dictionary = tuning.archetypes_config()
	var min_steps := int(cfg.get("classifier_window_min_steps", 12))
	var margin := float(cfg.get("confidence_margin", 0.08))

	var result := HabitArchetype.new()
	var feats := _features(sig)
	result.features = feats

	if int(feats.get("total_steps", 0)) < min_steps:
		result.id = ID_BALANCED
		result.confidence = 0.0
		return result

	var scores := {
		ID_RIGHT: _score_right(feats, cfg.get(ID_RIGHT, {})),
		ID_LOOP: _score_looper(feats, cfg.get(ID_LOOP, {})),
		ID_ZIG: _score_zig(feats, cfg.get(ID_ZIG, {})),
	}

	var best_id := ID_BALANCED
	var best_score := 0.0
	var second := 0.0
	for k in scores.keys():
		var s: float = float(scores[k])
		if s > best_score:
			second = best_score
			best_score = s
			best_id = k
		elif s > second:
			second = s

	if best_score < 1.0 or (best_score - second) < margin:
		result.id = ID_BALANCED
		result.confidence = best_score
		return result

	result.id = best_id
	result.confidence = best_score
	return result


static func counter_weights(arch: HabitArchetype, bal: BalanceTuning = null) -> Dictionary:
	var tuning := bal if bal != null else BalanceTuning.load_default()
	var cfg: Dictionary = tuning.archetypes_config().get(arch.id, {})
	var weights := {}
	for c in cfg.get("counters", []):
		weights[str(c.get("op", ""))] = float(c.get("weight", 1.0))
	for op in cfg.get("relief_ops", []):
		if not weights.has(op):
			weights[op] = 1.0
	return weights


static func blend_score(base_score: float, op_name: String, weights: Dictionary, blend: float) -> float:
	var w := float(weights.get(op_name, 1.0))
	var b := clampf(blend, 0.0, 1.0)
	return base_score * ((1.0 - b) + b * w)


static func _features(sig) -> Dictionary:
	# Duck-typed for HabitSignature; also accepts a Dictionary fixture in tests.
	var total_steps := 0
	var unique_cells := 0
	var dominant_bias := 0.0
	var turn_rate := 0.0
	var backtrack_rate := 0.0
	var longest_streak := 0

	if typeof(sig) == TYPE_DICTIONARY:
		total_steps = int(sig.get("total_steps", 0))
		unique_cells = int(sig.get("unique_cells", sig.get("unique_cell_count", 0)))
		dominant_bias = float(sig.get("dominant_bias", 0.0))
		turn_rate = float(sig.get("turn_rate", 0.0))
		backtrack_rate = float(sig.get("backtrack_rate", 0.0))
		var streaks: Array = sig.get("straight_streaks", sig.get("streaks", []))
		if streaks.size() > 0:
			longest_streak = int(streaks[0])
	else:
		total_steps = int(sig.total_steps)
		unique_cells = int(sig.unique_cell_count)
		dominant_bias = float(sig.dominant_bias)
		turn_rate = float(sig.turn_rate)
		backtrack_rate = float(sig.backtrack_rate)
		if sig.straight_streaks.size() > 0:
			longest_streak = int(sig.straight_streaks[0])

	var unique_ratio := 1.0
	var revisit_ratio := 0.0
	if total_steps > 0:
		unique_ratio = float(unique_cells) / float(total_steps)
		revisit_ratio = float(maxi(0, total_steps - unique_cells)) / float(total_steps)

	return {
		"total_steps": total_steps,
		"unique_cells": unique_cells,
		"unique_ratio": unique_ratio,
		"revisit_ratio": revisit_ratio,
		"dominant_bias": dominant_bias,
		"turn_rate": turn_rate,
		"backtrack_rate": backtrack_rate,
		"longest_streak": longest_streak,
	}


static func _score_right(feats: Dictionary, cfg: Dictionary) -> float:
	var d: Dictionary = cfg.get("detect", {})
	var score := 0.0
	if float(feats["dominant_bias"]) >= float(d.get("dominant_bias_min", 0.42)):
		score += 0.45
	if float(feats["turn_rate"]) <= float(d.get("turn_rate_max", 0.35)):
		score += 0.25
	if float(feats["backtrack_rate"]) <= float(d.get("backtrack_rate_max", 0.18)):
		score += 0.15
	if int(feats["longest_streak"]) >= int(d.get("longest_streak_min", 4)):
		score += 0.25
	return score


static func _score_looper(feats: Dictionary, cfg: Dictionary) -> float:
	var d: Dictionary = cfg.get("detect", {})
	var score := 0.0
	if float(feats["unique_ratio"]) <= float(d.get("unique_ratio_max", 0.55)):
		score += 0.35
	if float(feats["revisit_ratio"]) >= float(d.get("revisit_ratio_min", 0.35)):
		score += 0.35
	if float(feats["backtrack_rate"]) >= float(d.get("backtrack_rate_min", 0.12)):
		score += 0.2
	if float(feats["turn_rate"]) >= float(d.get("turn_rate_min", 0.28)):
		score += 0.15
	return score


static func _score_zig(feats: Dictionary, cfg: Dictionary) -> float:
	var d: Dictionary = cfg.get("detect", {})
	var score := 0.0
	if float(feats["turn_rate"]) >= float(d.get("turn_rate_min", 0.55)):
		score += 0.4
	if float(feats["dominant_bias"]) <= float(d.get("dominant_bias_max", 0.4)):
		score += 0.25
	if float(feats["backtrack_rate"]) <= float(d.get("backtrack_rate_max", 0.22)):
		score += 0.15
	if int(feats["longest_streak"]) <= int(d.get("longest_streak_max", 3)):
		score += 0.25
	return score


func summary() -> String:
	return "Archetype(%s conf=%.2f)" % [id, confidence]
