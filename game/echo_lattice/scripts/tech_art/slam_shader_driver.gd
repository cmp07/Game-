extends RefCounted
class_name SlamShaderDriver
##
## Feeds ink-bleed (and future crease) uniforms from rewrite slam local_t.
## Optional path behind TechArt.v3_enabled() — Deck-safe: one shared ShaderMaterial.
##

const INK_BLEED_MAT := "res://materials/ink_bleed_slam.tres"
const BLEED_LUT := "res://art/noise/bleed_edge_lut.png"

## Shared material — never duplicate() in the hot path (TECH_ART_V3 §3.4).
static var _bleed_mat: ShaderMaterial = null


static func shared_bleed_material() -> ShaderMaterial:
	if _bleed_mat != null:
		return _bleed_mat
	var template: Resource = load(INK_BLEED_MAT)
	if template is ShaderMaterial:
		_bleed_mat = template as ShaderMaterial
	else:
		_bleed_mat = ShaderMaterial.new()
		_bleed_mat.shader = load(TechArt.INK_BLEED_SHADER) as Shader
	if ResourceLoader.exists(BLEED_LUT):
		var lut: Resource = load(BLEED_LUT)
		if lut is Texture2D:
			_bleed_mat.set_shader_parameter("edge_lut", lut)
	return _bleed_mat


static func bleed_for_local_t(local_t: float) -> float:
	## Map slam phases → bleed uniform (TECH_ART_V3 §3.3).
	## 0.00–0.50 crease/lift: 0
	## 0.50–0.78 slot: 0 → 0.15
	## 0.78–1.00 rust bleed: 0.15 → 1.0
	var t: float = clampf(local_t, 0.0, 1.0)
	if t < 0.50:
		return 0.0
	if t < 0.78:
		var slot: float = (t - 0.50) / 0.28
		return lerpf(0.0, 0.15, slot)
	var bleed_phase: float = (t - 0.78) / 0.22
	return lerpf(0.15, 1.0, clampf(bleed_phase, 0.0, 1.0))


static func join_mask_at_uv(uv: Vector2) -> float:
	## Edge-weighted mask: 1 at tile edges, 0 at center.
	var d: Vector2 = abs(uv - Vector2(0.5, 0.5)) * 2.0
	return clampf(maxf(d.x, d.y), 0.0, 1.0)


static func apply_bleed_uniforms(
	bleed: float,
	join_mask: float = 1.0,
	base_tex: Texture2D = null,
	rust_decal: Texture2D = null
) -> ShaderMaterial:
	var mat: ShaderMaterial = shared_bleed_material()
	mat.set_shader_parameter("bleed", clampf(bleed, 0.0, 1.0))
	mat.set_shader_parameter("join_mask", clampf(join_mask, 0.0, 1.0))
	mat.set_shader_parameter("max_uv_warp", 0.02)
	mat.set_shader_parameter("rust_fossil", Palette.RUST_FOSSIL)
	mat.set_shader_parameter("rust_deep", Palette.RUST_DEEP)
	if base_tex != null:
		mat.set_shader_parameter("base_tex", base_tex)
	if rust_decal != null:
		mat.set_shader_parameter("rust_decal", rust_decal)
	return mat


static func rust_variant_index(cell: Vector2i, rust_count: int) -> int:
	## Deterministic rust variant — same as RC1 chamber slam.
	if rust_count <= 0:
		return 0
	return (cell.x * 3 + cell.y * 7) % rust_count
