shader_type canvas_item;
render_mode unshaded, blend_mix;

// True void depth substrate — near-black wells, never purple, never cream page.
uniform vec4 void_far : source_color = vec4(0.015, 0.018, 0.028, 1.0);
uniform vec4 void_near : source_color = vec4(0.045, 0.055, 0.075, 1.0);
uniform float grain : hint_range(0.0, 0.12) = 0.04;

void fragment() {
	vec2 px = FRAGCOORD.xy;
	float n = fract(sin(dot(floor(px * 0.22), vec2(12.9898, 78.233))) * 43758.5453);
	float radial = length((SCREEN_UV - vec2(0.5, 0.48)) * vec2(1.15, 1.0));
	float depth = smoothstep(0.15, 0.95, radial);
	float mote = n * grain;
	vec3 c = mix(void_near.rgb, void_far.rgb, depth + mote);
	COLOR = vec4(c, 1.0);
}
