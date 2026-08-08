## HabitProfile — labels a MoveBuffer with one of three player archetypes.
##
## The archetype is what biases which transform pack the generator draws
## from at the next checkpoint. Labels are intentionally coarse; if the
## buffer is empty or perfectly balanced the profile is `NEUTRAL`.
##
##   DASH_HEAVY — long straight runs; low backtrack rate.
##   LOOPY      — moderate straight runs but repeated bigrams (loopy paths).
##   HESITANT   — high backtrack rate; often reverses the previous move.
##   NEUTRAL    — no clear signal (empty or below-threshold buffer).
##
## Thresholds are cheap constants tuned to feel readable in-play. They
## are part of the hashable rule surface — changes require a version bump
## and a regression pass through `docs/ECHO_LATTICE/09_QA.md`.
class_name HabitProfile
extends RefCounted

const DASH_HEAVY: String = "DASH_HEAVY"
const LOOPY: String = "LOOPY"
const HESITANT: String = "HESITANT"
const NEUTRAL: String = "NEUTRAL"

const MIN_SAMPLE_SIZE: int = 4
const HESITANT_THRESHOLD: float = 0.35
const DASH_THRESHOLD: float = 0.55
const LOOPY_THRESHOLD: float = 0.35


static func classify(buffer: MoveBuffer) -> String:
	if buffer == null:
		return NEUTRAL
	if buffer.size() < MIN_SAMPLE_SIZE:
		return NEUTRAL
	var back: float = buffer.backtrack_rate()
	var run: float = buffer.straight_run_rate()
	# Hesitancy dominates: if you reverse a lot, that's the loudest signal
	# regardless of how straight your other moves were.
	if back >= HESITANT_THRESHOLD:
		return HESITANT
	if run >= DASH_THRESHOLD:
		return DASH_HEAVY
	if run >= LOOPY_THRESHOLD:
		return LOOPY
	return NEUTRAL


static func all_labels() -> Array:
	return [DASH_HEAVY, LOOPY, HESITANT, NEUTRAL]
