extends Node
##
## WeaverPalette — shed-loom swatches for the W1 juice spike.
## Single source: content/palette.json. No purple void.
##

const PALETTE_PATH := "res://content/weaver/palette.json"

var cloth_bone: Color = Color("E8DFC8")
var cloth_deep: Color = Color("D4C7A8")
var ink_seat: Color = Color("2C2620")
var ink_soft: Color = Color("4A4238")
var chalk_dust: Color = Color("C4B8A0")
var chalk_bright: Color = Color("F0E8D4")
var timber: Color = Color("6B5344")
var kiln_copper: Color = Color("B8784A")
var kiln_rust: Color = Color("8B4A2A")
var gap_void: Color = Color("3A342C")
var shed_lamp: Color = Color("E8D2A8")

var _loaded: bool = false


func _ready() -> void:
	reload()


func reload() -> void:
	if not FileAccess.file_exists(PALETTE_PATH):
		push_warning("WeaverPalette: missing %s — using embedded defaults" % PALETTE_PATH)
		_loaded = false
		return
	var raw: String = FileAccess.get_file_as_string(PALETTE_PATH)
	var data: Variant = JSON.parse_string(raw)
	if typeof(data) != TYPE_DICTIONARY:
		push_warning("WeaverPalette: invalid JSON")
		_loaded = false
		return
	var swatches: Dictionary = data.get("swatches", {})
	cloth_bone = _hex(swatches, "cloth_bone", cloth_bone)
	cloth_deep = _hex(swatches, "cloth_deep", cloth_deep)
	ink_seat = _hex(swatches, "ink_seat", ink_seat)
	ink_soft = _hex(swatches, "ink_soft", ink_soft)
	chalk_dust = _hex(swatches, "chalk_dust", chalk_dust)
	chalk_bright = _hex(swatches, "chalk_bright", chalk_bright)
	timber = _hex(swatches, "timber", timber)
	kiln_copper = _hex(swatches, "kiln_copper", kiln_copper)
	kiln_rust = _hex(swatches, "kiln_rust", kiln_rust)
	gap_void = _hex(swatches, "gap_void", gap_void)
	shed_lamp = _hex(swatches, "shed_lamp", shed_lamp)
	_loaded = true


func is_loaded() -> bool:
	return _loaded


func _hex(swatches: Dictionary, key: String, fallback: Color) -> Color:
	var entry: Variant = swatches.get(key, null)
	if typeof(entry) != TYPE_DICTIONARY:
		return fallback
	var hex: String = str(entry.get("hex", "")).strip_edges()
	if hex.is_empty():
		return fallback
	if hex.begins_with("#"):
		hex = hex.substr(1)
	return Color(hex)
