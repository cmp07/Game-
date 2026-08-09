extends Node
##
## LedgerType — Field Ledger latin font stack (IBM Plex OFL) + title-menu roles.
## Autoload; loads Bold / Medium / Serif / Mono for draw_string + Control themes.
## Role contract: docs/VISION/MENU_TYPE_SYSTEM.md (coordinates with menu-premium-v1).
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

## Canonical title-menu roles (MENU_TYPE_SYSTEM.md §1).
const ROLE_BRAND := "brand"
const ROLE_TAGLINE := "tagline"
const ROLE_DECK := "deck"
const ROLE_ACTION := "action"
const ROLE_ACTION_DISABLED := "action_disabled"
const ROLE_META := "meta"
const ROLE_MICRO := "micro"

## Published sizes @ 1080p (px).
const SIZE_BRAND_1080 := 92
const SIZE_TAGLINE_1080 := 24
const SIZE_DECK_1080 := 17
const SIZE_ACTION_1080 := 20
const SIZE_ACTION_PRIMARY_1080 := 24
const SIZE_META_1080 := 13
const SIZE_MICRO_1080 := 12

## Tracking @ 1080p (Godot letter_spacing / spacing_glyph px).
const TRACK_BRAND_1080 := -3.0
const TRACK_TAGLINE_1080 := 1.5
const TRACK_DECK_1080 := 0.0
const TRACK_ACTION_1080 := 0.0
const TRACK_META_1080 := 0.0
const TRACK_MICRO_1080 := 0.5

## Line-height multipliers (constant across scales).
const LH_BRAND := 1.00
const LH_TAGLINE := 1.15
const LH_DECK := 1.35
const LH_ACTION := 1.20
const LH_META := 1.25
const LH_MICRO := 1.20

## Meta may use mono only at or below this size (1080p gate, absolute px).
const META_MONO_MAX_PX := 13

## Cap px so nothing reads as engine-default mega-type.
const SIZE_CAP_BRAND := 96
const SIZE_CAP_ACTION := 28
const SIZE_CAP_BODY := 22
const SIZE_CAP_MONO := 16

var display: Font = null
var action: Font = null
var body: Font = null
var mono: Font = null
var _engine_fallback: Font = null
var _latin_ready: bool = false
## role -> FontVariation with tracking baked for draw_string callers.
var _tracked: Dictionary = {}


func _ready() -> void:
	_engine_fallback = ThemeDB.fallback_font
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
	if mono != null:
		return mono
	if ThemeDB.fallback_font != null:
		return ThemeDB.fallback_font
	return _engine_fallback


func scale_factor(page_h: float = 1080.0) -> float:
	## MENU_TYPE_SYSTEM.md §3 — Deck compact / 1080p / soft 1440p lift.
	if page_h < 700.0:
		return 0.62
	if page_h >= 1200.0:
		return clampf(page_h / 1080.0, 1.0, 1.15)
	return 1.0


func role_face(role: String, size_px: int = -1) -> String:
	## Face stack for a role. Actions → Medium ("action"). Meta → mono only when size ≤ META_MONO_MAX_PX.
	match role:
		ROLE_BRAND, ROLE_TAGLINE:
			return "display"
		ROLE_ACTION, ROLE_ACTION_DISABLED:
			# Premium type: Condensed Medium — never mono.
			return "action"
		ROLE_DECK:
			return "body"
		ROLE_META:
			var px: int = size_px if size_px > 0 else SIZE_META_1080
			return "mono" if px <= META_MONO_MAX_PX else "body"
		ROLE_MICRO:
			return "mono"
		"display", "body", "mono", "action":
			return role
		_:
			return "display"


func role_size(role: String, page_h: float = 1080.0, primary: bool = false) -> int:
	var base: int = SIZE_ACTION_1080
	match role:
		ROLE_BRAND:
			base = SIZE_BRAND_1080
		ROLE_TAGLINE:
			base = SIZE_TAGLINE_1080
		ROLE_DECK:
			base = SIZE_DECK_1080
		ROLE_ACTION, ROLE_ACTION_DISABLED:
			base = SIZE_ACTION_PRIMARY_1080 if primary else SIZE_ACTION_1080
		ROLE_META:
			base = SIZE_META_1080
		ROLE_MICRO:
			base = SIZE_MICRO_1080
		_:
			base = SIZE_ACTION_1080
	return maxi(8, int(round(float(base) * scale_factor(page_h))))


func role_tracking(role: String, page_h: float = 1080.0) -> float:
	var base: float = 0.0
	match role:
		ROLE_BRAND:
			base = TRACK_BRAND_1080
		ROLE_TAGLINE:
			base = TRACK_TAGLINE_1080
		ROLE_DECK:
			base = TRACK_DECK_1080
		ROLE_ACTION, ROLE_ACTION_DISABLED:
			base = TRACK_ACTION_1080
		ROLE_META:
			base = TRACK_META_1080
		ROLE_MICRO:
			base = TRACK_MICRO_1080
		_:
			base = 0.0
	return base * scale_factor(page_h)


func role_line_height(role: String) -> float:
	match role:
		ROLE_BRAND:
			return LH_BRAND
		ROLE_TAGLINE:
			return LH_TAGLINE
		ROLE_DECK:
			return LH_DECK
		ROLE_ACTION, ROLE_ACTION_DISABLED:
			return LH_ACTION
		ROLE_META:
			return LH_META
		ROLE_MICRO:
			return LH_MICRO
		_:
			return 1.2


func font_for_role(role: String, size_px: int = -1) -> Font:
	return font_or_fallback(role_face(role, size_px))


func tracked_font_for_role(role: String, page_h: float = 1080.0, size_px: int = -1) -> Font:
	## FontVariation with role tracking for draw_string (Actions never mono).
	var px: int = size_px if size_px > 0 else role_size(role, page_h)
	var face_role: String = role_face(role, px)
	var track: float = role_tracking(role, page_h)
	if absf(track) < 0.01:
		return font_or_fallback(face_role)
	var key := "%s:%.2f" % [face_role, track]
	if _tracked.has(key):
		return _tracked[key] as Font
	var base: Font = font_or_fallback(face_role)
	if base == null:
		return null
	var fv := FontVariation.new()
	fv.base_font = base
	fv.spacing_glyph = int(round(track))
	_tracked[key] = fv
	return fv


func title_role_scale(page_h: float = 1080.0) -> Dictionary:
	## Token map for menu draw + LedgerChrome (includes legacy aliases + premium metrics).
	var f: float = scale_factor(page_h)
	var brand: int = role_size(ROLE_BRAND, page_h)
	var tagline: int = role_size(ROLE_TAGLINE, page_h)
	var deck: int = role_size(ROLE_DECK, page_h)
	var action_px: int = role_size(ROLE_ACTION, page_h, false)
	var action_primary: int = role_size(ROLE_ACTION, page_h, true)
	var meta: int = role_size(ROLE_META, page_h)
	var micro: int = role_size(ROLE_MICRO, page_h)
	var compact: bool = f < 0.9
	return {
		"brand": brand,
		"tagline": tagline,
		"deck": deck,
		"blurb": deck,
		"action": action_px,
		"action_primary": action_primary,
		"action_disabled": action_px,
		"index": action_px,
		"index_primary": action_primary,
		"meta": meta,
		"micro": micro,
		"folio": micro,
		"seed": meta,
		"card_header": maxi(micro, int(round(14.0 * f))),
		"rule_w": 2.8 if compact else 4.0,
		"rule_len": 280.0 if compact else 560.0,
		"seal_r": 58.0 if compact else 118.0,
		"row_h": 26.0 if compact else 38.0,
		"primary_h": 32.0 if compact else 42.0,
		"row_sep": 4 if compact else 4,
		"track_brand": role_tracking(ROLE_BRAND, page_h),
		"track_tagline": role_tracking(ROLE_TAGLINE, page_h),
		"track_deck": role_tracking(ROLE_DECK, page_h),
		"track_action": role_tracking(ROLE_ACTION, page_h),
		"track_meta": role_tracking(ROLE_META, page_h),
		"track_micro": role_tracking(ROLE_MICRO, page_h),
		"lh_brand": LH_BRAND,
		"lh_tagline": LH_TAGLINE,
		"lh_deck": LH_DECK,
		"lh_action": LH_ACTION,
		"lh_meta": LH_META,
		"lh_micro": LH_MICRO,
		"scale": f,
	}


func apply_to_control(control: Control, role: String = "body", size: int = 16) -> void:
	if control == null:
		return
	var f: Font = font_or_fallback(role)
	if f != null:
		control.add_theme_font_override("font", f)
	if size > 0:
		control.add_theme_font_size_override("font_size", _cap_size(role, size))


func apply_role(
	control: Control,
	role: String,
	page_h: float = 1080.0,
	primary: bool = false
) -> void:
	## Apply face + size + tracking for a MENU_TYPE_SYSTEM role.
	if control == null:
		return
	var px: int = role_size(role, page_h, primary)
	var face: String = role_face(role, px)
	## Actions must never resolve to mono — belt + suspenders (Medium/"action").
	if role == ROLE_ACTION or role == ROLE_ACTION_DISABLED:
		face = "action"
	var f: Font = font_or_fallback(face)
	if f != null:
		control.add_theme_font_override("font", f)
	control.add_theme_font_size_override("font_size", _cap_size(face, px))
	var track: float = role_tracking(role, page_h)
	## Label supports letter_spacing; Buttons ignore unknown constants safely.
	control.add_theme_constant_override("letter_spacing", int(round(track)))
	if control is Label:
		var lh: float = role_line_height(role)
		(control as Label).add_theme_constant_override(
			"line_spacing",
			maxi(0, int(round(float(px) * (lh - 1.0))))
		)


func stars_ink(n: int, max_n: int = 3) -> String:
	## Ink-stamp star glyphs — never ASCII *** / ---.
	var filled: int = clampi(n, 0, max_n)
	var out := ""
	for i in range(max_n):
		out += "★" if i < filled else "☆"
	return out


func _cap_size(role: String, size: int) -> int:
	match role:
		"display", "brand", "tagline":
			return mini(size, SIZE_CAP_BRAND)
		"action", "ui", "index", "action_disabled":
			return mini(size, SIZE_CAP_ACTION)
		"mono", "micro", "meta":
			return mini(size, SIZE_CAP_MONO)
		_:
			return mini(size, SIZE_CAP_BODY)


func _load_stack() -> void:
	display = _load_first(DISPLAY_CANDIDATES)
	action = _load_first(ACTION_CANDIDATES)
	body = _load_first(BODY_CANDIDATES)
	mono = _load_first(MONO_CANDIDATES)
	_latin_ready = display != null and action != null and body != null and mono != null
	_tracked.clear()
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
