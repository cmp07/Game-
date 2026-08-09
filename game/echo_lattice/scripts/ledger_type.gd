extends Node
##
## LedgerType — Field Ledger latin font stack (IBM Plex OFL).
## Autoload; loads Bold / Medium / Serif / Mono for draw_string + Control themes.
## Brand = Bold Condensed. Actions = Medium Condensed. Never ThemeDB default for latin.
##

const DISPLAY_CANDIDATES := [
	"res://fonts/latin/IBMPlexSansCondensed-Bold.ttf",
	"res://fonts/latin/IBMPlexSansCondensed-SemiBold.ttf",
]
const ACTION_CANDIDATES := [
	"res://fonts/latin/IBMPlexSansCondensed-Medium.ttf",
	"res://fonts/latin/IBMPlexSansCondensed-Regular.ttf",
]
const BODY_CANDIDATES := [
	"res://fonts/latin/IBMPlexSerif-Regular.ttf",
]
const MONO_CANDIDATES := [
	"res://fonts/latin/IBMPlexMono-Regular.ttf",
]

## Cap px so nothing reads as engine-default mega-type.
const SIZE_CAP_BRAND := 96
const SIZE_CAP_ACTION := 28
const SIZE_CAP_BODY := 22
const SIZE_CAP_MONO := 16

var display: Font = null
var action: Font = null
var body: Font = null
var mono: Font = null
var _latin_ready: bool = false


func _ready() -> void:
	_load_stack()
	# Project-wide Latin Control default — menu/title still resolves faces via font_or_fallback
	# (Bold / Medium / Serif / Mono) and never reads ThemeDB.fallback_font for brand/actions.
	if display != null:
		ThemeDB.fallback_font = display


func is_latin_ready() -> bool:
	return _latin_ready


func font_or_fallback(role: String = "display") -> Font:
	## Prefer the authored Plex face for the role. Title chrome never asks ThemeDB.
	var f: Font = null
	match role:
		"body":
			f = body
		"mono":
			f = mono
		"action", "ui", "index":
			f = action if action != null else display
		_:
			f = display
	if f != null:
		return f
	# Last-resort chain within the ledger stack only.
	if display != null:
		return display
	if action != null:
		return action
	if body != null:
		return body
	return mono


func apply_to_control(control: Control, role: String = "body", size: int = 16) -> void:
	if control == null:
		return
	var f: Font = font_or_fallback(role)
	if f != null:
		control.add_theme_font_override("font", f)
	if size > 0:
		control.add_theme_font_size_override("font_size", _cap_size(role, size))


func stars_ink(n: int, max_n: int = 3) -> String:
	## Ink-stamp star glyphs — never ASCII *** / ---.
	var filled: int = clampi(n, 0, max_n)
	var out := ""
	for i in range(max_n):
		out += "★" if i < filled else "☆"
	return out


func _cap_size(role: String, size: int) -> int:
	match role:
		"display", "brand":
			return mini(size, SIZE_CAP_BRAND)
		"action", "ui", "index":
			return mini(size, SIZE_CAP_ACTION)
		"mono":
			return mini(size, SIZE_CAP_MONO)
		_:
			return mini(size, SIZE_CAP_BODY)


func _load_stack() -> void:
	display = _load_first(DISPLAY_CANDIDATES)
	action = _load_first(ACTION_CANDIDATES)
	body = _load_first(BODY_CANDIDATES)
	mono = _load_first(MONO_CANDIDATES)
	_latin_ready = display != null and action != null and body != null and mono != null
	if not _latin_ready:
		push_warning(
			"LedgerType: latin faces missing under res://fonts/latin/. "
			+ "Need Bold + Medium + Serif + Mono (see fonts/latin/README.md)."
		)


func _load_first(candidates: Array) -> Font:
	for path in candidates:
		if not FileAccess.file_exists(path):
			continue
		# Imported FontFile often ships with oversampling=0 (project default). In headless
		# / some DPI paths that default yields ~3× get_height and balloons Button mins.
		# Pin oversampling to 1.0 so index-row metrics match glyph size at every px.
		var res: Variant = ResourceLoader.load(path, "FontFile")
		if res is FontFile:
			var imported: FontFile = (res as FontFile).duplicate() as FontFile
			if imported != null:
				imported.oversampling = 1.0
				return imported
		if res is Font:
			return res as Font
		var font := FontFile.new()
		var err := font.load_dynamic_font(path)
		if err == OK:
			font.oversampling = 1.0
			return font
		push_warning("LedgerType: failed to load %s (%s)" % [path, error_string(err)])
	return null
