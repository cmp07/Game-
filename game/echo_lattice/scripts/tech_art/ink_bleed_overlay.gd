extends Node2D
class_name InkBleedOverlay
##
## Optional tech_art_v3 ink-bleed quads for rewrite slam (TECH_ART_V3 §3).
## Uses ONE shared ShaderMaterial; Sprite2D hosts only — never material.duplicate().
## When disabled, chamber keeps the RC1 CPU rust blit path.
##

const MAX_QUADS: int = 24

var _quads: Array = []  ## Array[Sprite2D]
var _active: int = 0


func _ready() -> void:
	z_index = 8
	_ensure_pool()


func _ensure_pool() -> void:
	while _quads.size() < MAX_QUADS:
		var s := Sprite2D.new()
		s.centered = false
		s.visible = false
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(s)
		_quads.append(s)


func clear() -> void:
	_active = 0
	for s in _quads:
		(s as Sprite2D).visible = false


func sync_slam(
	pending: Array,
	offset: Vector2,
	cell_size: float,
	t_norm: float,
	wall_tex: Texture2D,
	rust_textures: Array
) -> void:
	## Show edge-bleed quads for cells in the rust phase. Shared material uniforms
	## use the max bleed among visible cells (cascade reads as one soak pulse).
	if not TechArt.v3_enabled():
		clear()
		return
	_ensure_pool()
	var n: int = mini(pending.size(), MAX_QUADS)
	var max_bleed: float = 0.0
	var shown: int = 0
	var first_rust: Texture2D = null
	for i in range(n):
		var p: Vector2i = pending[i]
		var stagger: float = float(i) / float(maxi(n, 1)) * 0.18
		var local_t: float = clampf((t_norm - stagger) / maxf(0.001, 1.0 - stagger), 0.0, 1.0)
		var bleed: float = SlamShaderDriver.bleed_for_local_t(local_t)
		if bleed <= 0.001:
			continue
		max_bleed = maxf(max_bleed, bleed)
		var spr: Sprite2D = _quads[shown] as Sprite2D
		spr.position = offset + Vector2(p) * cell_size
		var tw: float = 32.0
		if wall_tex != null:
			spr.texture = wall_tex
			tw = float(maxi(wall_tex.get_width(), 1))
		spr.scale = Vector2(cell_size / tw, cell_size / tw)
		var rust_i: int = SlamShaderDriver.rust_variant_index(p, rust_textures.size())
		if rust_textures.size() > 0 and rust_textures[rust_i] != null and first_rust == null:
			first_rust = rust_textures[rust_i]
		spr.visible = true
		shown += 1
	_active = shown
	for j in range(shown, _quads.size()):
		(_quads[j] as Sprite2D).visible = false
	if shown == 0:
		return
	var mat: ShaderMaterial = SlamShaderDriver.apply_bleed_uniforms(
		max_bleed,
		1.0,
		wall_tex,
		first_rust
	)
	for i in range(shown):
		(_quads[i] as Sprite2D).material = mat
