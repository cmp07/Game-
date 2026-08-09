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
##   wishlist CTA on wing clear, no late-act chamber spoilers.
##

const FEATURE_TAG := "demo"
const ACT_ID := "induction"
## First transform lesson — the marketing hook beat.
const MIRROR_BIRTH_ID := "02_mirror_birth"
## Placeholder until Steamworks assigns a real AppID (see 08_STEAM_CHECKLIST).
const WISHLIST_URL := "https://store.steampowered.com/app/YOUR_APP_ID/"
const PRODUCT_NAME := "Echo Lattice Demo"


static func is_demo() -> bool:
	if OS.has_feature(FEATURE_TAG):
		return true
	var args: PackedStringArray = OS.get_cmdline_user_args()
	for a in OS.get_cmdline_args():
		args.append(a)
	return args.has("--demo")


static func wishlist_url() -> String:
	return WISHLIST_URL


static func open_wishlist() -> void:
	var url := wishlist_url()
	if url.find("YOUR_APP_ID") >= 0:
		push_warning("DemoBuild: wishlist URL still uses YOUR_APP_ID placeholder")
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
