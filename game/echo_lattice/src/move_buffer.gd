## MoveBuffer — the last N player moves, hashed deterministically.
##
## Echo Lattice's central conceit is that the maze is a pure function of
## the player's recent behaviour. That function has three inputs:
##
##   1. A world seed (per chamber, authored).
##   2. The move buffer's canonical hash (this file).
##   3. The habit profile derived from the buffer (see `habit_profile.gd`).
##
## Everything downstream — grammar selection, transform ordering, tile
## flavour — reads from these three values. Keeping the hash stable is a
## release-gate invariant tracked in the QA matrix.
##
## Move codes are stable across saves:
##
##   0 = UP, 1 = RIGHT, 2 = DOWN, 3 = LEFT, 4 = INTERACT.
##
## The buffer is a bounded ring: pushing past `capacity` drops the oldest
## move first. Interact moves participate in the hash (they change the
## chamber the same way movement does) but are ignored by directional
## statistics like `left_right_bias()` and `backtrack_rate()`.
class_name MoveBuffer
extends RefCounted

const UP: int = 0
const RIGHT: int = 1
const DOWN: int = 2
const LEFT: int = 3
const INTERACT: int = 4

const DEFAULT_CAPACITY: int = 30

var capacity: int = DEFAULT_CAPACITY
var moves: PackedByteArray = PackedByteArray()


func _init(cap: int = DEFAULT_CAPACITY) -> void:
	assert(cap > 0, "MoveBuffer capacity must be positive")
	capacity = cap
	moves = PackedByteArray()


func push(m: int) -> void:
	assert(m >= 0 and m <= 4, "invalid move code")
	moves.append(m)
	if moves.size() > capacity:
		# PackedByteArray has no pop_front; slice off the head instead.
		moves = moves.slice(moves.size() - capacity, moves.size())


func extend(seq) -> void:
	# Accepts anything iterable-of-int (Array, PackedByteArray, PackedInt32Array…).
	for m in seq:
		push(int(m))


func clear() -> void:
	moves = PackedByteArray()


func size() -> int:
	return moves.size()


func get_moves() -> PackedByteArray:
	# Callers should treat the return value as immutable. GDScript's
	# PackedByteArray is value-typed, so a fresh copy is returned here.
	return moves.duplicate()


func equals(other: MoveBuffer) -> bool:
	if other == null:
		return false
	if other.moves.size() != moves.size():
		return false
	for i in range(moves.size()):
		if moves[i] != other.moves[i]:
			return false
	return true


func hash_code() -> int:
	# Deterministic djb2 over (capacity, len, bytes). We fold capacity in so
	# that "up × 2" recorded in a 4-slot buffer does not collide with "up × 2"
	# recorded in a 30-slot buffer — they represent different habits.
	var h: int = 5381
	h = ((h << 5) + h) ^ capacity
	h = ((h << 5) + h) ^ moves.size()
	for b in moves:
		h = ((h << 5) + h) ^ int(b)
	# Fold to unsigned 32 bits so the value round-trips through saves and
	# is stable across host word sizes.
	return h & 0xFFFFFFFF


func left_right_bias() -> float:
	# Returns a value in [-1, +1]. -1 means every directional move was LEFT,
	# +1 means every directional move was RIGHT, 0 means balanced or empty.
	var l: int = 0
	var r: int = 0
	for m in moves:
		if m == LEFT:
			l += 1
		elif m == RIGHT:
			r += 1
	var total: int = l + r
	if total == 0:
		return 0.0
	return float(r - l) / float(total)


func straight_run_rate() -> float:
	# Fraction of adjacent directional pairs (m[i-1], m[i]) that repeat the
	# same direction. Interact moves and their neighbours are skipped.
	# Returned as a float in [0, 1]; 0 when there are fewer than two dir moves.
	var pairs: int = 0
	var repeats: int = 0
	var prev: int = -1
	for m in moves:
		if m == INTERACT:
			prev = -1
			continue
		if prev != -1:
			pairs += 1
			if m == prev:
				repeats += 1
		prev = m
	if pairs == 0:
		return 0.0
	return float(repeats) / float(pairs)


func backtrack_rate() -> float:
	# Fraction of directional pairs where the second move is the exact
	# reverse of the first (U↔D, L↔R). Interact resets the pair state.
	var pairs: int = 0
	var undos: int = 0
	var prev: int = -1
	for m in moves:
		if m == INTERACT:
			prev = -1
			continue
		if prev != -1:
			pairs += 1
			if _is_reverse(prev, m):
				undos += 1
		prev = m
	if pairs == 0:
		return 0.0
	return float(undos) / float(pairs)


static func _is_reverse(a: int, b: int) -> bool:
	return (a == UP and b == DOWN) \
		or (a == DOWN and b == UP) \
		or (a == LEFT and b == RIGHT) \
		or (a == RIGHT and b == LEFT)
