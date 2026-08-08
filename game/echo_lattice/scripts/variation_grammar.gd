@tool
class_name VariationGrammar
extends RefCounted

## Applies a variation sequence to a base [Chamber] and returns a new Chamber.
##
## Grammar reference: game/echo_lattice/content/grammar/variations.json
## Spec: docs/ECHO_LATTICE/04_CONTENT_BIBLE.md §5
##
## Every transform respects the base chamber's `variations.allow_*` gates;
## a transform blocked by its gate is silently dropped, not silently
## fatal, because variation sequences are usually machine-generated and it's
## more useful to fall back to the base than to reject the whole variant.

const _DEFAULT_GRAMMAR_PATH := "res://game/echo_lattice/content/grammar/variations.json"


static func load_grammar(path: String = _DEFAULT_GRAMMAR_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("VariationGrammar: grammar file missing: %s" % path)
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed as Dictionary


## `sequence` is an Array of Dictionaries, each with exactly one key from:
## rotate | reflect | palette | budget_delta | swap_glyph.
static func apply(base: Chamber, sequence: Array) -> Chamber:
	if base == null:
		return null
	var out := _clone(base)
	for step in sequence:
		if typeof(step) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = step
		if d.has("rotate") and _bool(out.variations.get("allow_rotate", false)):
			out = _rotate(out, int(d["rotate"]))
		elif d.has("reflect") and _bool(out.variations.get("allow_reflect", false)):
			out = _reflect(out, str(d["reflect"]))
		elif d.has("palette") and _bool(out.variations.get("allow_palette_swap", false)):
			out = _palette(out, str(d["palette"]))
		elif d.has("budget_delta"):
			out = _budget_delta(out, int(d["budget_delta"]))
		elif d.has("swap_glyph"):
			out = _swap_glyph(out, d["swap_glyph"] as Dictionary)
	return out


static func _clone(base: Chamber) -> Chamber:
	var c := Chamber.new()
	c.id           = base.id
	c.title        = base.title
	c.subtitle     = base.subtitle
	c.teaches      = base.teaches
	c.difficulty   = base.difficulty
	c.tick_budget  = base.tick_budget
	c.par_ticks    = base.par_ticks
	c.par_tiles    = base.par_tiles
	c.source_dir   = base.source_dir
	c.intro        = base.intro
	c.outro        = base.outro
	c.music_cue    = base.music_cue
	c.rows         = base.rows
	c.cols         = base.cols
	c.cells        = base.cells.duplicate()
	c.legend       = base.legend.duplicate(true)
	c.goal         = base.goal.duplicate(true)
	c.player_tools = base.player_tools.duplicate(true)
	c.variations   = base.variations.duplicate(true)
	c.hints        = base.hints.duplicate()
	c.tags         = base.tags.duplicate()
	return c


static func _rotate(c: Chamber, degrees: int) -> Chamber:
	var d := ((degrees % 360) + 360) % 360
	if d == 0:
		return c
	var grid := _cells_to_matrix(c)
	for _i in range(d / 90):
		grid = _rotate90(grid)
	c.rows = grid.size()
	c.cols = grid[0].size() if grid.size() > 0 else 0
	c.cells = _matrix_to_cells(grid)
	c.source_dir = _rotate_dir(c.source_dir, d)
	c.goal = _rotate_goal(c.goal, c.rows, c.cols, d)
	return c


static func _reflect(c: Chamber, axis: String) -> Chamber:
	if axis == "none":
		return c
	var grid := _cells_to_matrix(c)
	match axis:
		"horizontal":
			grid.reverse()
		"vertical":
			for row in grid:
				row.reverse()
		"diagonal":
			var t: Array = []
			for j in range(c.cols):
				var new_row: Array = []
				for i in range(c.rows):
					new_row.append(grid[i][j])
				t.append(new_row)
			grid = t
			var swap := c.rows
			c.rows = c.cols
			c.cols = swap
	c.cells = _matrix_to_cells(grid)
	c.goal = _reflect_goal(c.goal, c.rows, c.cols, axis)
	c.source_dir = _reflect_dir(c.source_dir, axis)
	return c


static func _palette(c: Chamber, palette_name: String) -> Chamber:
	if not c.variations.has("palette"):
		c.variations["palette"] = palette_name
	else:
		c.variations["palette"] = palette_name
	return c


static func _budget_delta(c: Chamber, delta: int) -> Chamber:
	c.tick_budget = max(1, c.tick_budget + delta)
	return c


static func _swap_glyph(c: Chamber, swap: Dictionary) -> Chamber:
	var from: String = str(swap.get("from", ""))
	var to: String = str(swap.get("to", ""))
	if from.is_empty() or to.is_empty() or from == to:
		return c
	if not c.legend.has(from):
		return c
	c.legend[to] = c.legend[from]
	c.legend.erase(from)
	var new_cells := PackedStringArray()
	for row in c.cells:
		new_cells.append(row.replace(from, to))
	c.cells = new_cells
	return c


static func _cells_to_matrix(c: Chamber) -> Array:
	var m: Array = []
	for row in c.cells:
		var r: Array = []
		for i in range(row.length()):
			r.append(row.substr(i, 1))
		m.append(r)
	return m


static func _matrix_to_cells(m: Array) -> PackedStringArray:
	var out := PackedStringArray()
	for r in m:
		out.append("".join(r))
	return out


static func _rotate90(m: Array) -> Array:
	var rows: int = m.size()
	if rows == 0:
		return m
	var cols: int = m[0].size()
	var out: Array = []
	for j in range(cols):
		var new_row: Array = []
		for i in range(rows - 1, -1, -1):
			new_row.append(m[i][j])
		out.append(new_row)
	return out


static func _rotate_dir(d: String, degrees: int) -> String:
	var order := ["N", "E", "S", "W"]
	var idx := order.find(d)
	if idx == -1:
		return d
	return order[(idx + degrees / 90) % 4]


static func _reflect_dir(d: String, axis: String) -> String:
	match axis:
		"horizontal":
			if d == "N": return "S"
			if d == "S": return "N"
			return d
		"vertical":
			if d == "E": return "W"
			if d == "W": return "E"
			return d
		"diagonal":
			if d == "N": return "W"
			if d == "W": return "N"
			if d == "S": return "E"
			if d == "E": return "S"
			return d
	return d


static func _rotate_goal(goal: Dictionary, rows: int, cols: int, degrees: int) -> Dictionary:
	if not goal.has("cells"):
		return goal
	var cells: Array = goal["cells"]
	var new_cells: Array = []
	for pair in cells:
		var r: int = int(pair[0])
		var c: int = int(pair[1])
		for _i in range(degrees / 90):
			var nr := c
			var nc := rows - 1 - r
			r = nr
			c = nc
		new_cells.append([r, c])
	goal["cells"] = new_cells
	return goal


static func _reflect_goal(goal: Dictionary, rows: int, cols: int, axis: String) -> Dictionary:
	if not goal.has("cells"):
		return goal
	var new_cells: Array = []
	for pair in goal["cells"]:
		var r: int = int(pair[0])
		var c: int = int(pair[1])
		match axis:
			"horizontal": r = rows - 1 - r
			"vertical":   c = cols - 1 - c
			"diagonal":
				var swap := r
				r = c
				c = swap
		new_cells.append([r, c])
	goal["cells"] = new_cells
	return goal


static func _bool(v: Variant) -> bool:
	if typeof(v) == TYPE_BOOL:
		return v
	if typeof(v) == TYPE_INT:
		return v != 0
	return false
