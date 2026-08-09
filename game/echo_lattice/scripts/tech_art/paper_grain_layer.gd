extends ColorRect
class_name PaperGrainLayer
##
## Fullscreen / page paper-grain host for TECH ART v3.
## One textured ColorRect — never N×1×1 rects. Static; no per-frame RNG.
##

const SHADER_PATH := "res://shaders/paper_grain.gdshader"
const GRAIN_PNG := "res://art/noise/paper_grain_512.png"

@export var grain_seed: int = 42
@export var grain_opacity: float = 0.07
@export var scroll_px: Vector2 = Vector2.ZERO
@export var prefer_menu_material: bool = false

var _mat: ShaderMaterial = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	color = Color(1, 1, 1, 1)
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	_ensure_material()
	_sync_uniforms()
	set_process(false)
	# Refresh battery LOD if DeckProfile / a11y changes while mounted.
	var store := get_node_or_null("/root/SettingsStore")
	if store != null and store.has_signal("settings_changed"):
		if not store.settings_changed.is_connected(_on_settings_changed):
			store.settings_changed.connect(_on_settings_changed)


func configure(seed_id: int, opacity: float, scroll: Vector2 = Vector2.ZERO) -> void:
	grain_seed = seed_id
	grain_opacity = TechArt.clamp_grain_opacity(opacity)
	scroll_px = scroll
	_ensure_material()
	_sync_uniforms()


func _on_settings_changed(section: String, key: String, _value: Variant) -> void:
	if section == "graphics" or (section == "accessibility" and key == "reduce_motion"):
		_sync_uniforms()


func _ensure_material() -> void:
	if _mat != null:
		material = _mat
		return
	var template_path: String = (
		TechArt.PAPER_GRAIN_MENU_MAT if prefer_menu_material else TechArt.PAPER_GRAIN_PAGE_MAT
	)
	var template: Resource = load(template_path)
	if template is ShaderMaterial:
		# Instance so opacity/seed can differ per host without editing .tres on disk.
		_mat = (template as ShaderMaterial).duplicate() as ShaderMaterial
	else:
		_mat = ShaderMaterial.new()
		var sh: Shader = load(SHADER_PATH) as Shader
		_mat.shader = sh
	material = _mat


func _sync_uniforms() -> void:
	if _mat == null:
		return
	var opacity: float = TechArt.clamp_grain_opacity(grain_opacity)
	var tex: Texture2D = _grain_texture()
	var tile: float = 512.0
	if tex != null:
		tile = float(maxi(tex.get_width(), 1))
	_mat.set_shader_parameter("grain_tex", tex)
	_mat.set_shader_parameter("ink_soft", Palette.INK_SOFT)
	_mat.set_shader_parameter("opacity", opacity)
	_mat.set_shader_parameter("tile_px", tile)
	_mat.set_shader_parameter("scroll_px", scroll_px)
	_mat.set_shader_parameter("battery_scale", TechArt.battery_grain_scale())


func _grain_texture() -> Texture2D:
	## Prefer offline PNG; fall back to ArtKit bake so headless CI never depends on .import.
	if ResourceLoader.exists(GRAIN_PNG):
		var loaded: Resource = load(GRAIN_PNG)
		if loaded is Texture2D:
			return loaded as Texture2D
	if has_node("/root/ArtKit") and ArtKit.has_method("grain_texture"):
		return ArtKit.grain_texture(grain_seed)
	return null


static func attach_to(parent: Control, seed_id: int, opacity: float, scroll: Vector2 = Vector2.ZERO, menu: bool = false) -> PaperGrainLayer:
	## Idempotent host mount — reuses an existing layer named PaperGrainLayer.
	var existing: Node = parent.get_node_or_null("PaperGrainLayer")
	var layer: PaperGrainLayer
	if existing is PaperGrainLayer:
		layer = existing as PaperGrainLayer
	else:
		if existing != null:
			existing.free()
		layer = PaperGrainLayer.new()
		layer.name = "PaperGrainLayer"
		parent.add_child(layer)
		# Sit above the canvas wash / chamber draw, under HUD chrome when parent is scene root.
		parent.move_child(layer, mini(parent.get_child_count() - 1, _preferred_index(parent)))
	layer.prefer_menu_material = menu
	layer.configure(seed_id, opacity, scroll)
	layer.visible = TechArt.v3_enabled()
	return layer


static func _preferred_index(parent: Control) -> int:
	## Place after Background / Chamber-like bodies, before TopBar / BottomBar when present.
	for i in range(parent.get_child_count()):
		var n: Node = parent.get_child(i)
		var nm: String = str(n.name)
		if nm == "TopBar" or nm == "BottomBar" or nm.begins_with("Top") or nm.find("Button") >= 0:
			return i
	return parent.get_child_count() - 1


static func set_visible_for(parent: Control, enabled: bool) -> void:
	var existing: Node = parent.get_node_or_null("PaperGrainLayer")
	if existing is PaperGrainLayer:
		(existing as PaperGrainLayer).visible = enabled
		if enabled:
			(existing as PaperGrainLayer)._sync_uniforms()
