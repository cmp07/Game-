class_name ChamberRuntime
extends RefCounted

## Runtime state machine for one chamber play (v2).
##
## Wires together Lattice + PathRecorder + HabitSignature + RewriteEngine +
## active rewrites. Callers step through the loop by sending discrete ticks:
##
##   * `move(dir)`           — try to walk one 4-adjacent cell.
##   * `undo()`              — retract the last MOVE.
##   * `checkpoint()`        — fired automatically when a MOVE lands on a
##                             CHECKPOINT cell (external callers can also fire
##                             it explicitly for tests).
##   * `reset()`             — restore the seed lattice, keep meta stats.
##
## The runtime enforces:
##
##   * cap on `active_rewrites` — when exceeded, oldest SOFT is auto-reversed;
##     if all active are HARD, they're marked `retired` and stop counting
##     against the cap but their patches remain.
##   * reversal counters per active SOFT rewrite — see COUNTERPLAY_KINDS.
##   * "wall yourself in" safety at commit time, delegated to RewriteEngine.
##   * WISP dissolution — walking onto a WISP marks it "consumed"; leaving
##     the WISP cell dissolves it back to FLOOR.
##   * telegraph timer — checkpoints emit `signal_telegraph` with a candidate
##     preview BEFORE commit. The runtime exposes a `commit_telegraphed()`
##     hook so higher layers can insert a UI delay ("2 seconds where the game
##     is fair"). If commit isn't called, the rewrite auto-commits after the
##     next `move` — always fair, never surprise.

const HARDNESS_HARD := "hard"
const HARDNESS_SOFT := "soft"

class ActiveRewrite:
	extends RefCounted
	var rewrite: Dictionary                ## snapshot from RewriteEngine
	var previous_cells: Dictionary = {}    ## Vector2i -> int, for reversal
	var counter_kind: String = "none"
	var counter_threshold: int = 0
	var counter_axis: Vector2i = Vector2i.ZERO
	var counter_cells: Array = []
	var counter_progress: int = 0
	var retired: bool = false              ## HARD past the cap; still applied
	var hardness: String = HARDNESS_SOFT

	func is_reversible() -> bool:
		return not retired and hardness == HARDNESS_SOFT and counter_kind != "none"

	func to_data() -> Dictionary:
		return {
			"name": rewrite.get("name", "?"),
			"hardness": hardness,
			"counter_kind": counter_kind,
			"counter_progress": counter_progress,
			"counter_threshold": counter_threshold,
			"retired": retired,
		}


var lattice: Lattice
var _seed_lattice: Lattice
var recorder: PathRecorder
var config: RewriteEngine.Config
var rng: RandomNumberGenerator
var player_pos: Vector2i = Vector2i(-1, -1)
var tempo_left: int = 9999
var cap: int = 2
var active: Array[ActiveRewrite] = []
var events: Array = []                     ## chronological event log
var last_result: RewriteEngine.EngineResult
var pending_telegraph: Dictionary = {}     ## queued rewrite awaiting commit

signal signal_moved(pos: Vector2i)
signal signal_telegraph(rewrite: Dictionary)
signal signal_committed(rewrite: Dictionary, combo: Dictionary)
signal signal_reversed(rewrite: Dictionary)
signal signal_near_miss(cell: Vector2i)
signal signal_won()


func _init(seed_lat: Lattice, cfg: RewriteEngine.Config = null, seed: int = 0) -> void:
	assert(seed_lat != null, "ChamberRuntime: seed_lat is required")
	assert(seed_lat.start != Vector2i(-1, -1), "seed_lat lacks a START tile")
	_seed_lattice = seed_lat.clone()
	lattice = seed_lat.clone()
	recorder = PathRecorder.new()
	config = cfg if cfg != null else RewriteEngine.Config.for_mode("standard")
	rng = RandomNumberGenerator.new()
	rng.seed = seed
	player_pos = seed_lat.start
	recorder.record_step(player_pos)


# -----------------------------------------------------------------------------
# Movement ticks
# -----------------------------------------------------------------------------

func move(dir: Vector2i) -> bool:
	var target := player_pos + dir
	if not lattice.in_bounds(target):
		return false
	if not lattice.is_passable(target):
		return false
	# WISP dissolve — leaving the current cell drops any WISP behind.
	_dissolve_wisp_if_any(player_pos)
	player_pos = target
	recorder.record_step(player_pos)
	tempo_left = max(0, tempo_left - 1)
	events.append({"kind": "move", "pos": player_pos, "dir": dir})
	signal_moved.emit(player_pos)
	_advance_counterplay(dir)
	_auto_commit_pending()
	_check_win()
	_maybe_checkpoint(player_pos)
	return true


func undo() -> bool:
	if recorder.length() < 2:
		return false
	var prev := recorder.positions()[recorder.length() - 2]
	if not lattice.is_passable(prev):
		return false
	# Emulate the exit event for wisp dissolution.
	_dissolve_wisp_if_any(player_pos)
	player_pos = prev
	recorder.record_undo()
	tempo_left = max(0, tempo_left - 1)
	events.append({"kind": "undo", "pos": player_pos})
	signal_moved.emit(player_pos)
	_advance_counterplay(Vector2i.ZERO, true)
	_auto_commit_pending()
	return true


func reset() -> void:
	lattice = _seed_lattice.clone()
	recorder.clear()
	player_pos = _seed_lattice.start
	recorder.record_step(player_pos)
	tempo_left = 9999
	active.clear()
	pending_telegraph = {}
	events.append({"kind": "reset"})


# -----------------------------------------------------------------------------
# Motif / rewrite lifecycle
# -----------------------------------------------------------------------------

## Force a checkpoint at the current player_pos regardless of cell kind.
## Useful for tests and for author-driven "pulse" motifs.
func checkpoint() -> RewriteEngine.EngineResult:
	recorder.record_motif_boundary()
	var sig := HabitSignature.extract(recorder, lattice)
	var result := RewriteEngine.apply(
			lattice, sig, recorder.positions(), player_pos, rng, config)
	last_result = result
	if result.applied:
		pending_telegraph = {
			"rewrite": result.rewrite,
			"combo": result.combo,
			"near_miss": result.near_miss,
			"near_miss_cell": result.near_miss_cell,
			"post_lattice": result.lattice,
		}
		signal_telegraph.emit(result.rewrite)
	events.append({"kind": "motif", "reason": result.reason, "applied": result.applied})
	return result


## Commit whatever is queued in `pending_telegraph`. Called automatically on
## the next `move` if the caller doesn't invoke it — always fair.
func commit_telegraphed() -> void:
	if pending_telegraph.is_empty():
		return
	var preview: Dictionary = pending_telegraph
	pending_telegraph = {}
	var post_lat: Lattice = preview.get("post_lattice", lattice)
	# Take the diff between old + new lattice for reversal.
	var old_snap := _snapshot_diff(lattice, post_lat)
	lattice = post_lat
	var rw: Dictionary = preview["rewrite"]
	_activate_rewrite(rw, old_snap)
	var combo: Dictionary = preview.get("combo", {})
	if not combo.is_empty():
		_activate_rewrite(combo, {})
		signal_committed.emit(rw, combo)
	else:
		signal_committed.emit(rw, {})
	if preview.get("near_miss", false):
		signal_near_miss.emit(preview.get("near_miss_cell", Vector2i(-1, -1)))


func _auto_commit_pending() -> void:
	if not pending_telegraph.is_empty():
		commit_telegraphed()


func _activate_rewrite(rewrite: Dictionary, previous: Dictionary) -> void:
	var a := ActiveRewrite.new()
	a.rewrite = rewrite
	a.hardness = String(rewrite.get("hardness", HARDNESS_SOFT))
	a.previous_cells = previous
	var cp: Dictionary = rewrite.get("counterplay", {})
	a.counter_kind = String(cp.get("kind", "none"))
	a.counter_threshold = int(cp.get("threshold", 0))
	if cp.has("axis"):
		a.counter_axis = cp["axis"]
	if cp.has("cells"):
		a.counter_cells = cp["cells"]
	elif cp.has("cell"):
		a.counter_cells = [cp["cell"]]
	active.append(a)
	_enforce_cap()


func _enforce_cap() -> void:
	# Retire oldest soft if we're over cap.
	while _active_counting() > cap:
		var idx := -1
		for i in range(active.size()):
			var a := active[i]
			if a.retired:
				continue
			if a.hardness == HARDNESS_SOFT:
				idx = i
				break
		if idx >= 0:
			_reverse_at(idx)
			continue
		# Fall through: retire the oldest hard.
		for i in range(active.size()):
			var a := active[i]
			if not a.retired:
				a.retired = true
				break
		break


func _active_counting() -> int:
	var n := 0
	for a in active:
		if not a.retired:
			n += 1
	return n


func _reverse_at(index: int) -> void:
	if index < 0 or index >= active.size():
		return
	var a := active[index]
	if not a.previous_cells.is_empty():
		for pos in a.previous_cells.keys():
			var v: int = a.previous_cells[pos]
			# Skip terminals; they should not have changed.
			if pos == lattice.start or pos == lattice.goal:
				continue
			lattice.set_cell(pos, v)
	active.remove_at(index)
	events.append({"kind": "reverse", "name": a.rewrite.get("name", "?")})
	signal_reversed.emit(a.rewrite)


# -----------------------------------------------------------------------------
# Counterplay accumulator
# -----------------------------------------------------------------------------

func _advance_counterplay(dir: Vector2i, is_undo: bool = false) -> void:
	if active.is_empty():
		return
	var to_remove: Array[int] = []
	for i in range(active.size()):
		var a := active[i]
		if not a.is_reversible():
			continue
		var progressed := false
		match a.counter_kind:
			"perpendicular_moves":
				if not is_undo and dir != Vector2i.ZERO and dir.x != a.counter_axis.x and dir.y != a.counter_axis.y:
					var perp_ok := (a.counter_axis.x != 0 and dir.x == 0) or (a.counter_axis.y != 0 and dir.y == 0)
					if perp_ok:
						a.counter_progress += 1
						progressed = true
			"away_from_axis":
				if not is_undo and dir != Vector2i.ZERO:
					var axis: Vector2i = a.counter_axis
					var away := (axis.x != 0 and dir.x == 0) or (axis.y != 0 and dir.y == 0)
					if away:
						a.counter_progress += 1
						progressed = true
			"undo_burst":
				if is_undo:
					a.counter_progress += 1
					progressed = true
			"re_enter":
				for c in a.counter_cells:
					var cell: Vector2i = c
					if player_pos == cell:
						a.counter_progress += 1
						progressed = true
						break
			"walk_through":
				for c in a.counter_cells:
					var cell: Vector2i = c
					if player_pos == cell:
						a.counter_progress += 1
						progressed = true
						break
			"into_region":
				for c in a.counter_cells:
					var cell: Vector2i = c
					if player_pos == cell:
						a.counter_progress += 1
						progressed = true
						break
		if progressed and a.counter_progress >= a.counter_threshold:
			to_remove.append(i)
	# Remove in reverse order to preserve indices.
	to_remove.sort()
	to_remove.reverse()
	for idx in to_remove:
		_reverse_at(idx)


# -----------------------------------------------------------------------------
# Wisp / checkpoint plumbing
# -----------------------------------------------------------------------------

func _dissolve_wisp_if_any(pos: Vector2i) -> void:
	if not lattice.in_bounds(pos):
		return
	if lattice.get_cell(pos) == Lattice.Cell.WISP:
		lattice.set_cell(pos, Lattice.Cell.FLOOR)
		events.append({"kind": "wisp_dissolved", "pos": pos})


func _maybe_checkpoint(pos: Vector2i) -> void:
	if not lattice.in_bounds(pos):
		return
	if lattice.get_cell(pos) != Lattice.Cell.CHECKPOINT:
		return
	lattice.set_cell(pos, Lattice.Cell.CHECKPOINT_USED)
	checkpoint()


func _check_win() -> void:
	if player_pos == lattice.goal:
		events.append({"kind": "win"})
		signal_won.emit()


# -----------------------------------------------------------------------------
# Utility
# -----------------------------------------------------------------------------

## Return a dict of cells that differ between `old` and `new`, keyed by
## Vector2i -> old_cell. Used to record reversal state for soft rewrites.
static func _snapshot_diff(old: Lattice, new: Lattice) -> Dictionary:
	var diff := {}
	if old == null or new == null:
		return diff
	if old.width != new.width or old.height != new.height:
		return diff
	for y in range(old.height):
		for x in range(old.width):
			var pos := Vector2i(x, y)
			if old.get_cell(pos) != new.get_cell(pos):
				diff[pos] = old.get_cell(pos)
	return diff


func summary() -> String:
	return "Chamber(pos=%s, tempo=%d, active=%d, hash=%d)" % [
		player_pos, tempo_left, active.size(), lattice.fingerprint(),
	]
