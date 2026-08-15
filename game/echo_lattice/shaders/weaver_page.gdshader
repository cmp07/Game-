shader_type canvas_item;
render_mode unshaded, blend_mix;

// Screen-locked canvas fiber — page_bone / page_deep, never purple, never #000.
uniform vec4 page_bone : source_color = vec4(0.910, 0.875, 0.784, 1.0);
uniform vec4 page_deep : source_color = vec4(0.824, 0.769, 0.643, 1.0);
uniform float grain : hint_range(0.0, 0.12) = 0.08;

void fragment() {
	vec2 px = FRAGCOORD.xy;
	float weave_x = sin(px.x * 0.37) * 0.5 + 0.5;
	float weave_y = sin(px.y * 0.41) * 0.5 + 0.5;
	float n = fract(sin(dot(floor(px * 0.35), vec2(12.9898, 78.233))) * 43758.5453);
	float fiber = (weave_x * 0.45 + weave_y * 0.35 + n * 0.20) * grain;
	vec3 c = mix(page_bone.rgb, page_deep.rgb, fiber + 0.04);
	COLOR = vec4(c, 1.0);
}
