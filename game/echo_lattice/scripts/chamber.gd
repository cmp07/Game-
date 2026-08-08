@tool
class_name Chamber
extends Resource

## Strongly-typed representation of one Echo Lattice chamber.
##
## Loaded from JSON by [ChamberLoader]. The JSON layout is documented in
## docs/ECHO_LATTICE/04_CONTENT_BIBLE.md and validated by
## game/echo_lattice/content/schema/chamber.schema.json.
##
## Fail-closed contract: any Chamber returned by the loader has already
## passed structural and semantic validation. Instances constructed directly
## via `new()` are considered untrusted until `validate()` returns OK.

const DIRECTIONS := ["N", "S", "E", "W"]

const PREDICATES := ["reach", "light_all", "pattern", "count"]

const TEACHES := [
	"emit", "rewrite", "turn", "fork", "merge",
	"filter", "delay", "silence", "resonance", "composition",
]

@export var id: String = ""
@export var title: String = ""
@export var subtitle: String = ""
@export var teaches: String = ""
@export var difficulty: int = 0
@export var tick_budget: int = 1
@export var par_ticks: Variant = null
@export var par_tiles: Variant = null
@export var source_dir: String = "S"
@export var rows: int = 0
@export var cols: int = 0
@export var cells: PackedStringArray = PackedStringArray()
@export var legend: Dictionary = {}
@export var goal: Dictionary = {}
@export var player_tools: Dictionary = {}
@export var hints: PackedStringArray = PackedStringArray()
@export var intro: String = ""
@export var outro: String = ""
@export var music_cue: Variant = null
@export var tags: PackedStringArray = PackedStringArray()
@export var variations: Dictionary = {}


func cell(row: int, col: int) -> String:
	if row < 0 or row >= rows or col < 0 or col >= cols:
		push_error("Chamber.cell out of bounds: (%d, %d) on %dx%d" % [row, col, rows, cols])
		return ""
	return cells[row].substr(col, 1)


func tool_count(tool_name: String) -> int:
	if not player_tools.has(tool_name):
		return 0
	var entry: Variant = player_tools[tool_name]
	if entry is Dictionary and entry.has("count"):
		return int(entry["count"])
	return 0


## Runs the same semantic checks the Python validator does. Returns an empty
## array on success, or an array of human-readable error strings on failure.
func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()

	if id.is_empty():
		errors.append("id is empty")
	if title.is_empty():
		errors.append("title is empty")
	if not TEACHES.has(teaches):
		errors.append("teaches must be one of %s (got %s)" % [str(TEACHES), teaches])
	if tick_budget < 1:
		errors.append("tick_budget must be >= 1 (got %d)" % tick_budget)
	if not DIRECTIONS.has(source_dir):
		errors.append("source_dir must be one of N/S/E/W (got %s)" % source_dir)

	if rows < 3 or rows > 12:
		errors.append("rows out of range [3, 12] (got %d)" % rows)
	if cols < 3 or cols > 12:
		errors.append("cols out of range [3, 12] (got %d)" % cols)

	if cells.size() != rows:
		errors.append("cells row count %d != rows %d" % [cells.size(), rows])
	else:
		for i in range(cells.size()):
			if cells[i].length() != cols:
				errors.append("row %d has length %d, expected %d" % [i, cells[i].length(), cols])

	var canonical_glyphs := {
		".": true, "#": true, "S": true, "G": true,
		"o": true, "O": true,
		">": true, "<": true, "^": true, "v": true,
		"+": true, "x": true, "~": true, "?": true, "*": true,
	}
	var seen_source := 0
	var seen_goal := 0
	for row in cells:
		for i in range(row.length()):
			var ch: String = row.substr(i, 1)
			if not (legend.has(ch) or canonical_glyphs.has(ch)):
				errors.append("glyph %s not in legend or canonical set" % ch)
			if ch == "S":
				seen_source += 1
			if ch == "G":
				seen_goal += 1

	if seen_source < 1:
		errors.append("chamber must contain at least one source (S)")

	if not goal.has("predicate"):
		errors.append("goal.predicate is missing")
	elif not PREDICATES.has(goal["predicate"]):
		errors.append("goal.predicate must be one of %s (got %s)" % [str(PREDICATES), goal["predicate"]])
	else:
		var pred: String = goal["predicate"]
		if (pred == "reach" or pred == "light_all") and seen_goal < 1:
			errors.append("goal.predicate=%s requires at least one G on the grid" % pred)

	if not variations.has("budget_deltas"):
		errors.append("variations.budget_deltas is required")
	else:
		var deltas: Array = variations["budget_deltas"]
		for d in deltas:
			if tick_budget + int(d) < 1:
				errors.append("budget_delta %d would push tick_budget below 1" % int(d))

	return errors
