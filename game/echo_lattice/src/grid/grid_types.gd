class_name GridTypes
extends RefCounted
## Integer cell kinds for Echo Lattice logical grid (no string names in hot path).

enum Cell {
	EMPTY = 0,
	FLOOR = 1,
	WALL = 2,
	KEY = 3,
	DOOR = 4,
	DOOR_OPEN = 5,
	CHECKPOINT = 6,
	EXIT = 7,
	SPAWN = 8,
	PROP = 9,
}

const NEIGHBOR_OFFSETS: Array[Vector2i] = [
	Vector2i(0, -1), ## N
	Vector2i(1, 0), ## E
	Vector2i(0, 1), ## S
	Vector2i(-1, 0), ## W
]


static func is_solid(kind: int) -> bool:
	return kind == Cell.WALL or kind == Cell.DOOR


static func is_walkable(kind: int) -> bool:
	return kind == Cell.FLOOR \
		or kind == Cell.KEY \
		or kind == Cell.DOOR_OPEN \
		or kind == Cell.CHECKPOINT \
		or kind == Cell.EXIT \
		or kind == Cell.SPAWN \
		or kind == Cell.PROP


static func blocks_los(kind: int) -> bool:
	return kind == Cell.WALL
