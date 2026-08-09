shader_type canvas_item;
render_mode unshaded, blend_mix;

// Rust / ink seep from fossil joins — geology, not emission (TECH_ART_V3 §3).
// Optional behind settings.graphics.tech_art_v3; shared material only (no hot-path duplicate).

uniform sampler2D base_tex : source_color, filter_nearest;
uniform sampler2D rust_decal : source_color, filter_nearest;
uniform sampler2D edge_lut : source_color, filter_linear, repeat_disable;
uniform vec4 rust_fossil : source_color = vec4(0.545, 0.227, 0.122, 1.0); // #8B3A1F
uniform vec4 rust_deep : source_color = vec4(0.369, 0.141, 0.071, 1.0); // #5E2412
uniform float bleed : hint_range(0.0, 1.0) = 0.0; // slam local_t mapped
uniform float join_mask = 1.0; // 1 at edges, 0 at tile center
uniform float max_uv_warp : hint_range(0.0, 0.04) = 0.02; // paper soak, not psychedelia

void fragment() {
	// Soft UV pull toward tile center as ink soaks — tiny, readability-safe.
	vec2 to_c = vec2(0.5) - UV;
	vec2 uv = UV + to_c * (bleed * max_uv_warp * join_mask);
	vec4 base = texture(base_tex, uv);
	float edge = texture(edge_lut, vec2(clamp(join_mask, 0.0, 1.0), clamp(bleed, 0.0, 1.0))).r;
	vec4 rust = texture(rust_decal, UV);
	vec3 ink = mix(rust_deep.rgb, rust_fossil.rgb, rust.r);
	float a = rust.a * edge * bleed;
	COLOR = vec4(mix(base.rgb, ink, a), clamp(base.a + a, 0.0, 1.0));
}
