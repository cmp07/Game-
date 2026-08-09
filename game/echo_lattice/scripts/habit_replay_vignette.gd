extends Control
##
## Field Ledger replay vignette — chalk handwriting draws itself from a Museum self.
## Atmosphere only: paper plate + dashed path. In-chamber race is a separate overlay.
##

var _path: Array = []  ## Vector2i
var _title: String = ""
var _archetype: String = ""
var _progress: float = 0.0
var _playing: bool = false
var _stamp: Dictionary = {}


func set_self_row(row: Dictionary) -> void:
	if row.is_empty():
		clear_vignette()
		return
	_title = str(row.get("title", ""))
	var habit: Dictionary = row.get("habit", {}) if typeof(row.get("habit", null)) == TYPE_DICTIONARY else {}
	_archetype = str(habit.get("archetype", ""))
	_stamp = row.get("stamp", {}) if typeof(row.get("stamp", null)) == TYPE_DICTIONARY else {}
	var ghost: Dictionary = row.get("ghost", {}) if typeof(row.get("ghost", null)) == TYPE_DICTIONARY else {}
	_path = MuseumOfSelves.unpack_path(ghost)
	_progress = 0.0
	_playing = _path.size() >= 2
	visible = true
	set_process(_playing)
	queue_redraw()


func clear_vignette() -> void:
	_path.clear()
	_title = ""
	_archetype = ""
	_stamp = {}
	_progress = 0.0
	_playing = false
	set_process(false)
	queue_redraw()


func replay() -> void:
	if _path.size() < 2:
		return
	_progress = 0.0
	_playing = true
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	if not _playing:
		return
	_progress += delta * 10.0
	if _progress >= float(_path.size()) + 2.0:
		_progress = float(_path.size()) + 2.0
		_playing = false
		set_process(false)
	queue_redraw()


func _draw() -> void:
	var plate := Rect2(Vector2.ZERO, size)
	if plate.size.x < 4.0 or plate.size.y < 4.0:
		return
	draw_rect(plate, Palette.PAPER_DEEP, true)
	draw_rect(plate.grow(-1.0), Palette.PAPER_BONE, true)
	draw_rect(plate, Palette.INK_SOFT, false, 1.5)
	ArtKit.draw_ledger_grid(self, plate.grow(-4.0), 14)
	ArtKit.draw_paper_grain(self, plate, 11, 0.05)

	var pad := 12.0
	var inner := Rect2(pad, pad + 18.0, maxf(8.0, size.x - pad * 2.0), maxf(8.0, size.y - pad * 2.0 - 22.0))
	var type_font: Font = ThemeDB.fallback_font
	if has_node("/root/LedgerType"):
		type_font = LedgerType.font_or_fallback("mono")
	if _title != "":
		draw_string(
			type_font,
			Vector2(pad, 16.0),
			_title,
			HORIZONTAL_ALIGNMENT_LEFT, int(size.x - pad * 2.0), 12, Palette.SLATE_TEAL
		)

	if _path.is_empty():
		draw_string(
			type_font,
			inner.position + Vector2(0, 20),
			tr("museum.vignette_empty"),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Palette.INK_SOFT
		)
		return

	var bounds := _path_bounds(_path)
	var bw: float = float(maxi(1, bounds.size.x))
	var bh: float = float(maxi(1, bounds.size.y))
	var cell: float = minf(inner.size.x / bw, inner.size.y / bh)
	var origin := Vector2(
		inner.position.x + (inner.size.x - cell * bw) * 0.5,
		inner.position.y + (inner.size.y - cell * bh) * 0.5
	)

	# Soft stamp plate under the path when a ledger portrait exists.
	if typeof(_stamp.get("mask", null)) == TYPE_DICTIONARY:
		_draw_mask_wash(origin, cell, bounds)

	var visible: int = mini(_path.size(), maxi(1, int(_progress)))
	var chalk := Color(Palette.CHALK_WHITE.r, Palette.CHALK_WHITE.g, Palette.CHALK_WHITE.b, 0.82)
	var rust := Color(Palette.RUST_FOSSIL.r, Palette.RUST_FOSSIL.g, Palette.RUST_FOSSIL.b, 0.55)
	for i in range(maxi(0, visible - 1)):
		var a: Vector2i = _path[i]
		var b: Vector2i = _path[i + 1]
		var pa := origin + Vector2(float(a.x - bounds.position.x) + 0.5, float(a.y - bounds.position.y) + 0.5) * cell
		var pb := origin + Vector2(float(b.x - bounds.position.x) + 0.5, float(b.y - bounds.position.y) + 0.5) * cell
		var col: Color = chalk if i < visible - 3 else rust
		ArtKit.draw_dashed_line(self, pa, pb, col, 1.8, 3.5, 2.5)
	if visible > 0:
		var tip: Vector2i = _path[mini(visible - 1, _path.size() - 1)]
		var tip_p := origin + Vector2(float(tip.x - bounds.position.x) + 0.5, float(tip.y - bounds.position.y) + 0.5) * cell
		draw_circle(tip_p, maxf(2.0, cell * 0.22), Palette.RUST_FOSSIL)


func _draw_mask_wash(origin: Vector2, cell: float, bounds: Rect2i) -> void:
	var mask: Dictionary = _stamp.get("mask", {})
	var rows: Array = mask.get("rows", [])
	if rows.is_empty():
		return
	var ink := Color(Palette.RUST_FOSSIL.r, Palette.RUST_FOSSIL.g, Palette.RUST_FOSSIL.b, 0.18)
	for y in range(rows.size()):
		var line: String = str(rows[y])
		for x in range(line.length()):
			if line.substr(x, 1) != "#":
				continue
			# Center mask near path bounds without fighting the chalk.
			var gx: float = float(bounds.position.x) + float(x) * 0.35
			var gy: float = float(bounds.position.y) + float(y) * 0.35
			var r := Rect2(
				origin + Vector2(gx - float(bounds.position.x), gy - float(bounds.position.y)) * cell,
				Vector2(cell * 0.55, cell * 0.55)
			)
			draw_rect(r, ink, true)


func _path_bounds(path: Array) -> Rect2i:
	var min_x := 999
	var max_x := -1
	var min_y := 999
	var max_y := -1
	for p in path:
		var v: Vector2i = p
		min_x = mini(min_x, v.x)
		max_x = maxi(max_x, v.x)
		min_y = mini(min_y, v.y)
		max_y = maxi(max_y, v.y)
	return Rect2i(min_x, min_y, maxi(1, max_x - min_x + 1), maxi(1, max_y - min_y + 1))
