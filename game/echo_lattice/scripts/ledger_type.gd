extends Node
##
## LedgerType — Field Ledger latin font stack (IBM Plex OFL).
## Autoload; loads display / body / mono for draw_string + ThemeDB fallback.
## Falls back to ThemeDB.fallback_font when vendor files are missing.
##

const DISPLAY_CANDIDATES := [
	"res://fonts/latin/IBMPlexSansCondensed-SemiBold.ttf",
	"res://fonts/latin/IBMPlexSansCondensed-Regular.ttf",
]
const BODY_CANDIDATES := [
	"res://fonts/latin/IBMPlexSerif-Regular.ttf",
]
const MONO_CANDIDATES := [
	"res://fonts/latin/IBMPlexMono-Regular.ttf",
]

var display: Font = null
var body: Font = null
var mono: Font = null
var _engine_fallback: Font = null
var _latin_ready: bool = false


func _ready() -> void:
	_engine_fallback = ThemeDB.fallback_font
	_load_stack()
	# Prefer ledger display as the project-wide Latin fallback until CJK swaps it.
	if display != null:
		ThemeDB.fallback_font = display


func is_latin_ready() -> bool:
	return _latin_ready


func font_or_fallback(role: String = "display") -> Font:
	var f: Font = null
	match role:
		"body":
			f = body
		"mono":
			f = mono
		_:
			f = display
	if f != null:
		return f
	if ThemeDB.fallback_font != null:
		return ThemeDB.fallback_font
	return _engine_fallback


func apply_to_control(control: Control, role: String = "body", size: int = 16) -> void:
	if control == null:
		return
	var f: Font = font_or_fallback(role)
	if f != null:
		control.add_theme_font_override("font", f)
	if size > 0:
		control.add_theme_font_size_override("font_size", size)


func stars_ink(n: int, max_n: int = 3) -> String:
	## Ink-stamp star glyphs — never ASCII *** / ---.
	var filled: int = clampi(n, 0, max_n)
	var out := ""
	for i in range(max_n):
		out += "★" if i < filled else "☆"
	return out


func _load_stack() -> void:
	display = _load_first(DISPLAY_CANDIDATES)
	body = _load_first(BODY_CANDIDATES)
	mono = _load_first(MONO_CANDIDATES)
	_latin_ready = display != null and mono != null
	if not _latin_ready:
		push_warning(
			"LedgerType: latin faces missing under res://fonts/latin/. "
			+ "Run tools/fonts/fetch_ibm_plex_latin.py"
		)


func _load_first(candidates: Array) -> Font:
	for path in candidates:
		if not FileAccess.file_exists(path):
			continue
		var font := FontFile.new()
		var err := font.load_dynamic_font(path)
		if err == OK:
			return font
		push_warning("LedgerType: failed to load %s (%s)" % [path, error_string(err)])
	return null
