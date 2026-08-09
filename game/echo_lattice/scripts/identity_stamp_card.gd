extends Control
##
## Draws a Field Ledger portrait stamp from an IdentityStamp mask.
## Ink blot on paper — no cards-as-chrome beyond the stamp plate itself.
##

var _stamp: Dictionary = {}


func set_stamp(stamp: Dictionary) -> void:
	_stamp = stamp if stamp != null else {}
	queue_redraw()
	visible = not _stamp.is_empty() and typeof(_stamp.get("mask", null)) == TYPE_DICTIONARY


func _draw() -> void:
	if _stamp.is_empty():
		return
	var mask = _stamp.get("mask", {})
	if typeof(mask) != TYPE_DICTIONARY:
		return
	var rows: Array = mask.get("rows", [])
	if rows.is_empty():
		return
	var w: int = maxi(1, int(mask.get("w", str(rows[0]).length())))
	var h: int = maxi(1, int(mask.get("h", rows.size())))
	var pad := 10.0
	var plate := Rect2(Vector2.ZERO, size)
	# Soft paper plate with ink rule — the interaction surface for the stamp readout.
	draw_rect(plate, Palette.PAPER_DEEP, true)
	draw_rect(plate.grow(-1.0), Palette.PAPER_BONE, true)
	draw_rect(plate, Palette.INK_SOFT, false, 1.5)
	ArtKit.draw_ledger_grid(self, plate.grow(-4.0), 12)

	var inner := Rect2(pad, pad, maxf(8.0, size.x - pad * 2.0), maxf(8.0, size.y - pad * 2.0))
	var cell: float = minf(inner.size.x / float(w), inner.size.y / float(h))
	var origin := Vector2(
		inner.position.x + (inner.size.x - cell * float(w)) * 0.5,
		inner.position.y + (inner.size.y - cell * float(h)) * 0.5
	)
	var ink := Palette.RUST_FOSSIL
	ink.a = 0.92
	var chalk := Palette.CHALK_WHITE
	chalk.a = 0.35
	for y in range(mini(h, rows.size())):
		var line: String = str(rows[y])
		for x in range(mini(w, line.length())):
			var r := Rect2(origin + Vector2(x, y) * cell, Vector2(cell, cell))
			if line.substr(x, 1) == "#":
				draw_rect(r.grow(-0.4), ink, true)
			else:
				draw_rect(r.grow(-cell * 0.35), chalk, true)
