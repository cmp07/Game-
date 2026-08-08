## Grammar — the pure rewrite rules that turn a stored lattice into a
## chamber that reflects how the player has been playing.
##
## Every function here is pure: it takes a `Lattice` and returns a **new**
## `Lattice`. Nothing here mutates its inputs. That is a hard rule so
## replays, ghost paths and "undo" all remain trivial.
##
## Transforms come in two flavours:
##
##   • Isometries (`mirror_h`, `mirror_v`, `rotate_180`, `identity`) —
##     they permute cells without adding or removing walls. Solvability
##     is preserved by construction because the start→door topology is
##     unchanged (only its coordinates move).
##
##   • Content edits (`thicken_walls`, `carve_floor`) — they can break
##     solvability if applied naively. The `safe_apply` wrapper reverts
##     any transform whose output fails `is_valid()` or `is_solvable()`.
##
## Transform decks are picked deterministically from the move buffer
## hash so a given (seed, move buffer) always produces the same chamber.
class_name Grammar
extends RefCounted

const T_IDENTITY: String = "identity"
const T_MIRROR_H: String = "mirror_h"
const T_MIRROR_V: String = "mirror_v"
const T_ROTATE_180: String = "rotate_180"
const T_THICKEN: String = "thicken_walls"
const T_CARVE: String = "carve_floor"


static func all_transforms() -> Array:
	return [T_IDENTITY, T_MIRROR_H, T_MIRROR_V, T_ROTATE_180, T_THICKEN, T_CARVE]


static func identity(lattice: Lattice) -> Lattice:
	return lattice.clone()


static func mirror_h(lattice: Lattice) -> Lattice:
	# Flip along the vertical axis (columns reverse; rows stay put).
	var out: Lattice = Lattice.new(lattice.width, lattice.height, Lattice.WALL)
	for y in range(lattice.height):
		for x in range(lattice.width):
			out.set_cell(lattice.width - 1 - x, y, lattice.get_cell(x, y))
	return out


static func mirror_v(lattice: Lattice) -> Lattice:
	# Flip along the horizontal axis (rows reverse; columns stay put).
	var out: Lattice = Lattice.new(lattice.width, lattice.height, Lattice.WALL)
	for y in range(lattice.height):
		for x in range(lattice.width):
			out.set_cell(x, lattice.height - 1 - y, lattice.get_cell(x, y))
	return out


static func rotate_180(lattice: Lattice) -> Lattice:
	# Definitionally the composition of mirror_h and mirror_v. Kept as its
	# own function so decks can select it without leaking two picks worth
	# of entropy from the move buffer hash.
	return mirror_h(mirror_v(lattice))


static func thicken_walls(lattice: Lattice, seed: int) -> Lattice:
	# Every FLOOR cell that (a) is not START/DOOR and (b) is orthogonally
	# adjacent to a WALL flips to WALL with probability ~1/3, chosen
	# deterministically from `seed` and the cell coordinate.
	# May break connectivity; callers should route through `safe_apply`.
	var out: Lattice = lattice.clone()
	for y in range(lattice.height):
		for x in range(lattice.width):
			var v: int = lattice.get_cell(x, y)
			if v != Lattice.FLOOR:
				continue
			if not _has_wall_neighbour(lattice, x, y):
				continue
			var r: int = _cell_rng(seed, x, y)
			if (r % 3) == 0:
				out.set_cell(x, y, Lattice.WALL)
	return out


static func carve_floor(lattice: Lattice, seed: int) -> Lattice:
	# The inverse of `thicken_walls`: every WALL cell that (a) is not on
	# the outer border and (b) has at least one walkable neighbour flips
	# to FLOOR with probability ~1/4. Can duplicate no start or door
	# because it never writes those cell codes. Widens shortcuts.
	var out: Lattice = lattice.clone()
	for y in range(lattice.height):
		for x in range(lattice.width):
			var v: int = lattice.get_cell(x, y)
			if v != Lattice.WALL:
				continue
			if x == 0 or y == 0 or x == lattice.width - 1 or y == lattice.height - 1:
				continue
			if not _has_walkable_neighbour(lattice, x, y):
				continue
			var r: int = _cell_rng(seed, x, y)
			if (r % 4) == 0:
				out.set_cell(x, y, Lattice.FLOOR)
	return out


static func apply(name: String, lattice: Lattice, seed: int) -> Lattice:
	# Dispatcher used by `apply_deck` and the QA harness. Kept here so
	# transform names in save files remain the single source of truth.
	match name:
		T_IDENTITY:
			return identity(lattice)
		T_MIRROR_H:
			return mirror_h(lattice)
		T_MIRROR_V:
			return mirror_v(lattice)
		T_ROTATE_180:
			return rotate_180(lattice)
		T_THICKEN:
			return thicken_walls(lattice, seed)
		T_CARVE:
			return carve_floor(lattice, seed)
		_:
			push_error("Grammar.apply: unknown transform '%s'" % name)
			return lattice.clone()


static func safe_apply(name: String, lattice: Lattice, seed: int) -> Lattice:
	# Applies `name`; if the result loses `is_valid()` or solvability, the
	# original lattice is returned untouched. This is what the generator
	# calls at every checkpoint so the player never sees a broken chamber.
	var candidate: Lattice = apply(name, lattice, seed)
	if not candidate.is_valid():
		return lattice.clone()
	if not Solver.is_solvable(candidate):
		return lattice.clone()
	return candidate


static func apply_deck(lattice: Lattice, transforms: Array, seed: int) -> Lattice:
	# Applies a sequence of transforms via `safe_apply`. Each step uses a
	# per-step seed derived from `seed` and the transform index so that
	# `[mirror_h, thicken]` and `[thicken, mirror_h]` don't accidentally
	# share the same thicken RNG stream.
	var current: Lattice = lattice.clone()
	for i in range(transforms.size()):
		var step_seed: int = _mix_seed(seed, i, String(transforms[i]).hash())
		current = safe_apply(String(transforms[i]), current, step_seed)
	return current


static func _has_wall_neighbour(lattice: Lattice, x: int, y: int) -> bool:
	var neigh: Array = [
		Vector2i(x, y - 1),
		Vector2i(x + 1, y),
		Vector2i(x, y + 1),
		Vector2i(x - 1, y),
	]
	for n in neigh:
		if not lattice.in_bounds(n.x, n.y):
			return true
		if lattice.get_cell(n.x, n.y) == Lattice.WALL:
			return true
	return false


static func _has_walkable_neighbour(lattice: Lattice, x: int, y: int) -> bool:
	var neigh: Array = [
		Vector2i(x, y - 1),
		Vector2i(x + 1, y),
		Vector2i(x, y + 1),
		Vector2i(x - 1, y),
	]
	for n in neigh:
		if lattice.is_walkable(n.x, n.y):
			return true
	return false


static func _cell_rng(seed: int, x: int, y: int) -> int:
	# 32-bit MurmurHash3-style mixer. Deterministic, well-distributed, and
	# — critically — it destroys the "add-one-to-i shifts every bucket by
	# a constant" symmetry that a naive djb2 has when combined with the
	# large-prime coordinate hashes. Without that property, mirror ∘ carve
	# and carve ∘ mirror can collide by construction on axis-symmetric
	# input; the order-sensitivity test in test_habit_rewrite_invariants
	# guards against that regression.
	var h: int = _mix32(seed ^ (x * 0x9E3779B1))
	h = _mix32(h ^ (y * 0x85EBCA6B))
	return h & 0x7FFFFFFF


static func _mix_seed(seed: int, i: int, name_hash: int) -> int:
	var h: int = _mix32(seed ^ (i * 0xC2B2AE35))
	h = _mix32(h ^ name_hash)
	return h & 0x7FFFFFFF


static func _mix32(v: int) -> int:
	# Finalizer from Murmur3, masked to 32 bits after each step to keep the
	# output stable across word sizes.
	var h: int = v & 0xFFFFFFFF
	h = ((h ^ (h >> 16)) * 0x85EBCA6B) & 0xFFFFFFFF
	h = ((h ^ (h >> 13)) * 0xC2B2AE35) & 0xFFFFFFFF
	h = (h ^ (h >> 16)) & 0xFFFFFFFF
	return h
