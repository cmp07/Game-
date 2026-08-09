class_name DemoBuild
extends RefCounted
##
## Demo / Next Fest build gates for Echo Lattice.
##
## Detection:
##   - Export custom feature tag `demo` (Windows Demo preset)
##   - CLI `--demo` for local testing without a demo export
##
## Scope (see docs/RELEASE/DEMO_SPEC.md):
##   Act I Induction through Mirror Birth's act (chambers 00–08),
##   wishlist CTA on wing clear (Steam builds with a real store URL only),
##   no late-act chamber spoilers.
##
## Wishlist / store CTAs are feature-flagged via steam_features.json and are
## suppressed on itch / DRM-free exports and when the AppID / URL is still a
## placeholder (never open YOUR_APP_ID links).
##

const FEATURE_TAG := "demo"
const ACT_ID := "induction"
## First transform lesson — the marketing hook beat.
const MIRROR_BIRTH_ID := "02_mirror_birth"
const PRODUCT_NAME := "Echo Lattice Demo"
const FEATURES_PATH := "res://config/steam_features.json"
## Format string for derived Steam store URLs when store_wishlist_url is empty.
const STORE_WISHLIST_URL_TEMPLATE := "https://store.steampowered.com/app/%s/"
const _DRM_FREE_FEATURE_TAGS: PackedStringArray = PackedStringArray(["itch", "drm_free"])


static func is_demo() -> bool:
	if OS.has_feature(FEATURE_TAG):
		return true
	var args: PackedStringArray = OS.get_cmdline_user_args()
	for a in OS.get_cmdline_args():
		args.append(a)
	return args.has("--demo")


## itch / DRM-free storefront exports (custom_features includes itch or drm_free).
static func is_drm_free_storefront() -> bool:
	for tag in _DRM_FREE_FEATURE_TAGS:
		if OS.has_feature(tag):
			return true
	return false


## True when the Steam wishlist button may be shown (demo + Steam + real URL).
static func wishlist_cta_enabled() -> bool:
	if not is_demo():
		return false
	if is_drm_free_storefront():
		return false
	var feats: Dictionary = _load_store_features()
	if not bool(feats.get("wishlist_cta_enabled", true)):
		return false
	var url := _resolved_wishlist_url(feats)
	return not url.is_empty()


## Resolved Steam wishlist / store URL, or "" when gated off / placeholder.
static func wishlist_url() -> String:
	if is_drm_free_storefront():
		return ""
	var feats: Dictionary = _load_store_features()
	if not bool(feats.get("wishlist_cta_enabled", true)):
		return ""
	return _resolved_wishlist_url(feats)


static func open_wishlist() -> void:
	if not wishlist_cta_enabled():
		push_warning("DemoBuild: wishlist CTA disabled (itch/DRM-free, flag off, or missing AppID)")
		return
	var url := wishlist_url()
	if url.is_empty() or url.find("YOUR_APP_ID") >= 0:
		push_warning("DemoBuild: refusing to open placeholder / empty wishlist URL")
		return
	if not _is_allowed_store_url(url):
		push_warning("DemoBuild: wishlist URL failed store allowlist: %s" % url)
		return
	OS.shell_open(url)


## Campaign content ids allowed in the demo PCK / run queue.
static func allowed_campaign_ids() -> PackedStringArray:
	return PackedStringArray([
		"00_quiet_span",
		"01_echo_plate",
		"02_mirror_birth",
		"03_break_the_loop",
		"04_ceiling_first",
		"05_two_glances",
		"06_far_side",
		"07_first_thicken",
		"08_identity_induction",
	])


static func allows_content_id(content_id: String) -> bool:
	if not is_demo():
		return true
	return allowed_campaign_ids().has(content_id)


static func filter_campaign_ids(order: Array) -> Array:
	if not is_demo():
		return order
	var allow: PackedStringArray = allowed_campaign_ids()
	var out: Array = []
	for cid in order:
		if allow.has(str(cid)):
			out.append(cid)
	return out


static func _load_store_features() -> Dictionary:
	var defaults := {
		"wishlist_cta_enabled": true,
		"store_wishlist_url": "",
		"store_page_url": "",
		"app_id_placeholder": "YOUR_APP_ID",
	}
	if not FileAccess.file_exists(FEATURES_PATH):
		return defaults
	var f := FileAccess.open(FEATURES_PATH, FileAccess.READ)
	if f == null:
		return defaults
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return defaults
	for k in defaults.keys():
		if parsed.has(k):
			defaults[k] = parsed[k]
	return defaults


static func _resolved_wishlist_url(feats: Dictionary) -> String:
	var explicit := str(feats.get("store_wishlist_url", "")).strip_edges()
	if not explicit.is_empty():
		if explicit.find("YOUR_APP_ID") >= 0:
			return ""
		return explicit
	var page := str(feats.get("store_page_url", "")).strip_edges()
	if not page.is_empty():
		if page.find("YOUR_APP_ID") >= 0:
			return ""
		return page
	var app := str(feats.get("app_id_placeholder", "YOUR_APP_ID")).strip_edges()
	if app.is_empty() or app == "YOUR_APP_ID" or not app.is_valid_int():
		return ""
	var app_id := int(app)
	# Spacewar (480) is SDK bring-up only — never a public wishlist target.
	if app_id <= 0 or app_id == 480:
		return ""
	return STORE_WISHLIST_URL_TEMPLATE % str(app_id)


static func _is_allowed_store_url(url: String) -> bool:
	var lower := url.to_lower()
	if not (lower.begins_with("https://store.steampowered.com/") \
			or lower.begins_with("https://steampowered.com/")):
		return false
	if lower.find("your_app_id") >= 0:
		return false
	return true
