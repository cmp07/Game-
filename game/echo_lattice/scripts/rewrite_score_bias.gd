class_name RewriteScoreBias
extends RefCounted

## Applies archetype counter weights to RewriteEngine candidate lists.
## Pure helper — does not mutate lattices; call before attempt order sort.


static func apply(candidates: Array, sig, bal: BalanceTuning = null) -> Array:
	var tuning := bal if bal != null else BalanceTuning.load_default()
	var arch := HabitArchetype.classify(sig, tuning)
	var weights := HabitArchetype.counter_weights(arch, tuning)
	var blend := float(tuning.rewrite_engine_config().get("archetype_weight_blend", 0.65))
	var out: Array = []
	for c in candidates:
		var copy: Dictionary = c.duplicate(true)
		var base := float(copy.get("score", 0.0))
		var op := str(copy.get("name", ""))
		copy["score"] = HabitArchetype.blend_score(base, op, weights, blend)
		copy["meta"] = copy.get("meta", {}).duplicate(true)
		copy["meta"]["archetype"] = arch.id
		copy["meta"]["archetype_weight"] = float(weights.get(op, 1.0))
		copy["meta"]["score_before_bias"] = base
		out.append(copy)
	out.sort_custom(func(a, b): return float(a["score"]) > float(b["score"]))
	return out
