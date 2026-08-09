extends Object
class_name TechArt
##
## TECH ART v3 feature gate (docs/VISION/TECH_ART_V3.md).
## Default OFF in CI / stock settings — enable for Deck QA once green.
##

const SETTINGS_SECTION := "graphics"
const SETTINGS_KEY := "tech_art_v3"
const MAX_GRAIN_OPACITY := 0.08

const PAPER_GRAIN_SHADER := "res://shaders/paper_grain.gdshader"
const INK_BLEED_SHADER := "res://shaders/ink_bleed.gdshader"
const PAPER_GRAIN_PAGE_MAT := "res://materials/paper_grain_page.tres"
const PAPER_GRAIN_MENU_MAT := "res://materials/paper_grain_menu.tres"
const INK_BLEED_SLAM_MAT := "res://materials/ink_bleed_slam.tres"
const GRAIN_TEX_PATH := "res://art/noise/paper_grain_512.png"
const BLEED_LUT_PATH := "res://art/noise/bleed_edge_lut.png"


static func v3_enabled() -> bool:
	var store := _settings_store()
	if store != null and store.has_method("get_value"):
		return bool(store.call("get_value", SETTINGS_SECTION, SETTINGS_KEY, false))
	return false


static func set_v3_enabled(enabled: bool, save_now: bool = true) -> void:
	var store := _settings_store()
	if store != null and store.has_method("set_value"):
		store.call("set_value", SETTINGS_SECTION, SETTINGS_KEY, enabled, save_now)


static func battery_grain_scale() -> float:
	## Deck 4 W / battery → half grain opacity (TECH_ART_V3 §2.3 / §6.1).
	if _reduce_fx():
		return 0.5
	var deck := _deck_profile()
	if deck != null and bool(deck.get("battery_mode")):
		return 0.5
	return 1.0


static func clamp_grain_opacity(opacity: float) -> float:
	return clampf(opacity, 0.0, MAX_GRAIN_OPACITY)


static func _settings_store() -> Node:
	var tree := Engine.get_main_loop()
	if tree is SceneTree:
		return (tree as SceneTree).root.get_node_or_null("SettingsStore")
	return null


static func _deck_profile() -> Node:
	var tree := Engine.get_main_loop()
	if tree is SceneTree:
		return (tree as SceneTree).root.get_node_or_null("DeckProfile")
	return null


static func _reduce_fx() -> bool:
	## reduce_fx not yet a first-class a11y key — treat reduce_motion as the LOD gate.
	var tree := Engine.get_main_loop()
	if tree is SceneTree:
		var a11y: Node = (tree as SceneTree).root.get_node_or_null("AccessibilityService")
		if a11y != null and a11y.has_method("reduce_motion"):
			return bool(a11y.call("reduce_motion"))
	return false
