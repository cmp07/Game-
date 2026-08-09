shader_type canvas_item;
render_mode unshaded, blend_mix;

// Field Ledger print grain — screen-locked, opacity ≤ 8% (TECH_ART_V3 §2).
// Deck-safe: one textured quad, nearest repeat, no animated crawl.

uniform sampler2D grain_tex : source_color, filter_nearest, repeat_enable;
uniform vec4 ink_soft : source_color = vec4(0.227, 0.204, 0.173, 1.0); // #3A342C
uniform float opacity : hint_range(0.0, 0.08) = 0.07;
uniform float tile_px = 512.0;
uniform vec2 scroll_px = vec2(0.0); // normally 0 — screen-locked
uniform float battery_scale : hint_range(0.0, 1.0) = 1.0; // Deck 4 W → 0.5

void fragment() {
	vec2 px = FRAGCOORD.xy + scroll_px;
	vec2 uv = px / max(tile_px, 1.0);
	float g = texture(grain_tex, uv).a; // alpha = speck mask
	float a = g * opacity * battery_scale;
	COLOR = vec4(ink_soft.rgb, a);
}
