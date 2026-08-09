extends Node
##
## TypeKit — Field Ledger latin type stack (ART_DIRECTION_V3 §3).
## Loads IBM Plex under res://fonts/latin/, installs a project Theme, and
## exposes role helpers so draw_string / Labels stop depending on Godot's
## default Inter-like ThemeDB.fallback_font for brand identity.
##
## Roles:
##   display — IBM Plex Sans Condensed (brand, titles, index actions)
##   body    — IBM Plex Serif (blurbs, settings, habit copy)
##   mono    — IBM Plex Mono (seeds, punch-card labels, meta)
##
## CJK: when LocaleManager swaps ThemeDB.fallback_font to Noto Sans SC,
## display/body resolve to that face so Han never tofu. Mono stays Latin
## for seed hex / buffer digits (art bible).
##

enum Role { DISPLAY, BODY, MONO }

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

const UI_CANDIDATES := [
	"res://fonts/latin/IBMPlexSansCondensed-Regular.ttf",
	"res://fonts/latin/IBMPlexSansCondensed-SemiBold.ttf",
]

var display: Font = null
var body: Font = null
var mono: Font = null
var ui: Font = null
var _project_theme: Theme = null
var _loaded: bool = false


func _ready() -> void:
	reload()
	if has_node("/root/LocaleManager") and LocaleManager.has_signal("locale_changed"):
		if not LocaleManager.locale_changed.is_connected(_on_locale_changed):
			LocaleManager.locale_changed.connect(_on_locale_changed)


func reload() -> void:
	display = _load_first(DISPLAY_CANDIDATES)
	body = _load_first(BODY_CANDIDATES)
	mono = _load_first(MONO_CANDIDATES)
	ui = _load_first(UI_CANDIDATES)
	if ui == null:
		ui = display
	_loaded = display != null or body != null or mono != null
	_install_theme()
	# Prefer serif/body as the global fallback so Labels are not Inter-default.
	# LocaleManager captures this on its own _ready when TypeKit boots first.
	var fallback: Font = body if body != null else (ui if ui != null else display)
	if fallback != null:
		ThemeDB.fallback_font = fallback
	if not _loaded:
		push_warning(
			"TypeKit: no latin faces under res://fonts/latin/. "
			+ "Run tools/fonts/fetch_ibm_plex_latin.py (see fonts/README.md)."
		)


func is_ready() -> bool:
	return _loaded and display != null and mono != null


func font(role: int = Role.BODY) -> Font:
	## Role-aware face. Falls back through the stack, then ThemeDB.
	if _needs_cjk() and role != Role.MONO:
		var cjk: Font = _cjk_font()
		if cjk != null:
			return cjk
	match role:
		Role.DISPLAY:
			if display != null:
				return display
			if ui != null:
				return ui
		Role.MONO:
			if mono != null:
				return mono
		_:
			if body != null:
				return body
			if ui != null:
				return ui
	return ThemeDB.fallback_font


func display_font() -> Font:
	return font(Role.DISPLAY)


func body_font() -> Font:
	return font(Role.BODY)


func mono_font() -> Font:
	return font(Role.MONO)


func apply_to_control(ctrl: Control, role: int = Role.BODY) -> void:
	if ctrl == null:
		return
	var f: Font = font(role)
	if f == null:
		return
	if ctrl is Label or ctrl is RichTextLabel or ctrl is Button or ctrl is LineEdit:
		ctrl.add_theme_font_override("font", f)
	elif ctrl is TextEdit:
		ctrl.add_theme_font_override("font", f)


func apply_tree(root: Node, role: int = Role.BODY) -> void:
	if root is Control:
		apply_to_control(root as Control, role)
	for child in root.get_children():
		apply_tree(child, role)


func _install_theme() -> void:
	_project_theme = Theme.new()
	var default_f: Font = body if body != null else ui
	if default_f != null:
		_project_theme.default_font = default_f
	if ui != null:
		_project_theme.set_font("font", "Button", ui)
		_project_theme.set_font("font", "OptionButton", ui)
		_project_theme.set_font("font", "CheckBox", ui)
		_project_theme.set_font("font", "CheckButton", ui)
	if body != null:
		_project_theme.set_font("font", "Label", body)
		_project_theme.set_font("normal_font", "RichTextLabel", body)
	if mono != null:
		_project_theme.set_font("font", "LineEdit", mono)
		_project_theme.set_font("font", "TextEdit", mono)
	# Attach on the scene tree root when available (boot / headless both OK).
	var tree := get_tree()
	if tree != null and tree.root != null:
		tree.root.theme = _project_theme


func _on_locale_changed(_locale: String) -> void:
	# Theme stays latin; role helpers re-route display/body to CJK when needed.
	pass


func _needs_cjk() -> bool:
	if not has_node("/root/LocaleManager"):
		return false
	var loc: String = str(LocaleManager.current_locale)
	return loc.begins_with("zh") or loc in ["ja", "ko"]


func _cjk_font() -> Font:
	if not has_node("/root/LocaleManager"):
		return null
	# LocaleManager owns the loaded CJK FontFile on ThemeDB when active.
	if _needs_cjk() and ThemeDB.fallback_font != null:
		# Prefer ThemeDB only when it is not one of our latin faces.
		var fb: Font = ThemeDB.fallback_font
		if fb != display and fb != body and fb != mono and fb != ui:
			return fb
	return null


func _load_first(candidates: Array) -> Font:
	for path in candidates:
		var p: String = str(path)
		if not FileAccess.file_exists(p):
			continue
		var font := FontFile.new()
		var err := font.load_dynamic_font(p)
		if err == OK:
			return font
		push_warning("TypeKit: failed to load %s (%s)" % [p, error_string(err)])
	return null
