extends Node
##
## LocaleManager — loads CSV catalogs into TranslationServer, picks locale,
## and swaps ThemeDB fallback fonts when CJK coverage is required.
## Autoload; runs before UI scenes so tr() / auto-translate see messages.
##

signal locale_changed(locale: String)

const CATALOG_PATH := "res://locale/echo_lattice.csv"
const SETTINGS_PATH := "user://locale.cfg"

## Locales we ship catalogs for. `en` is the source language.
const SUPPORTED := ["en", "zh_Hans"]

## OS / Steam locale tags that map onto our shipping catalogs.
const LOCALE_ALIASES := {
	"zh": "zh_Hans",
	"zh_CN": "zh_Hans",
	"zh_SG": "zh_Hans",
	"zh-Hans": "zh_Hans",
	"zh-CN": "zh_Hans",
	"zh_Hans_CN": "zh_Hans",
}

## Fonts that cover Han ideographs. First existing path wins.
## Vendor files under res://fonts/cjk/ before shipping zh-Hans (see fonts/README.md).
const CJK_FONT_CANDIDATES := [
	"res://fonts/cjk/NotoSansSC-Regular.otf",
	"res://fonts/cjk/NotoSansSC-Regular.ttf",
	"res://fonts/cjk/SourceHanSansSC-Regular.otf",
	"res://fonts/cjk/SourceHanSansSC-Regular.ttf",
]

var current_locale: String = "en"
var _cjk_font: Font = null
var _default_fallback_font: Font = null


func _ready() -> void:
	_default_fallback_font = ThemeDB.fallback_font
	_load_catalog(CATALOG_PATH)
	var chosen := _resolve_startup_locale()
	apply_locale(chosen)


func supported_locales() -> PackedStringArray:
	return PackedStringArray(SUPPORTED)


func apply_locale(locale: String) -> void:
	var normalized := normalize_locale(locale)
	if normalized not in SUPPORTED:
		normalized = "en"
	current_locale = normalized
	TranslationServer.set_locale(normalized)
	_apply_font_for_locale(normalized)
	_persist(normalized)
	emit_signal("locale_changed", normalized)


func normalize_locale(locale: String) -> String:
	var raw := locale.strip_edges()
	if raw == "" or raw == "system" or raw == "auto":
		return _from_system()
	if LOCALE_ALIASES.has(raw):
		return str(LOCALE_ALIASES[raw])
	# Accept BCP-47 with hyphens.
	var underscored := raw.replace("-", "_")
	if LOCALE_ALIASES.has(underscored):
		return str(LOCALE_ALIASES[underscored])
	if underscored in SUPPORTED:
		return underscored
	# Language-only fallback (e.g. "en_US" → "en").
	var lang := underscored.split("_")[0]
	if lang in SUPPORTED:
		return lang
	if LOCALE_ALIASES.has(lang):
		return str(LOCALE_ALIASES[lang])
	return "en"


func translate_chamber_title(content_id: String, fallback: String = "") -> String:
	var key := "chamber.%s.title" % content_id
	var translated := tr(key)
	if translated == key:
		return fallback if fallback != "" else content_id
	return translated


func translate_chamber_caption(content_id: String, fallback: String = "") -> String:
	var key := "chamber.%s.caption" % content_id
	var translated := tr(key)
	if translated == key:
		return fallback
	return translated


func habit_label(dir_key: String) -> String:
	match dir_key:
		"up":
			return tr("habit.up")
		"down":
			return tr("habit.down")
		"left":
			return tr("habit.left")
		"right":
			return tr("habit.right")
		_:
			return dir_key


func _resolve_startup_locale() -> String:
	var saved := _read_saved()
	if saved != "":
		return normalize_locale(saved)
	return _from_system()


func _from_system() -> String:
	return normalize_locale(OS.get_locale())


func _persist(locale: String) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("locale", "code", locale)
	cfg.save(SETTINGS_PATH)


func _read_saved() -> String:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return ""
	return str(cfg.get_value("locale", "code", ""))


func _load_catalog(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("LocaleManager: missing catalog %s" % path)
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("LocaleManager: cannot open %s" % path)
		return
	var header: PackedStringArray = file.get_csv_line()
	if header.size() < 2 or header[0] != "keys":
		push_error("LocaleManager: bad CSV header in %s" % path)
		return
	var translations: Dictionary = {}
	for i in range(1, header.size()):
		var locale_code := str(header[i])
		var t := Translation.new()
		t.locale = locale_code
		translations[locale_code] = t
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.is_empty() or row[0] == "":
			continue
		var key := str(row[0])
		for i in range(1, mini(row.size(), header.size())):
			var locale_code2 := str(header[i])
			var msg := str(row[i])
			(translations[locale_code2] as Translation).add_message(key, msg)
	for locale_code3 in translations.keys():
		TranslationServer.add_translation(translations[locale_code3])


func _apply_font_for_locale(locale: String) -> void:
	var needs_cjk := locale.begins_with("zh") or locale in ["ja", "ko"]
	if not needs_cjk:
		if _default_fallback_font != null:
			ThemeDB.fallback_font = _default_fallback_font
		return
	if _cjk_font == null:
		_cjk_font = _load_first_cjk_font()
	if _cjk_font != null:
		ThemeDB.fallback_font = _cjk_font
	else:
		# Missing vendor file: keep Latin fallback; glyphs for Han will tofu.
		# Documented in docs/RELEASE/LOCALIZATION.md + fonts/README.md.
		push_warning(
			"LocaleManager: zh_Hans active but no CJK font under res://fonts/cjk/. "
			+ "UI Labels may show missing glyphs until Noto Sans SC is vendored."
		)


func _load_first_cjk_font() -> Font:
	for path in CJK_FONT_CANDIDATES:
		if FileAccess.file_exists(path):
			var font := FontFile.new()
			var err := font.load_dynamic_font(path)
			if err == OK:
				return font
			push_warning("LocaleManager: failed to load %s (%s)" % [path, error_string(err)])
	return null
