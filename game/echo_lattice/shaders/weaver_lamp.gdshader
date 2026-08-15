shader_type canvas_item;
render_mode unshaded, blend_mix;

// One practical shed lamp — hard-ish falloff + ordered dither, no bloom.
uniform vec2 lamp_uv = vec2(0.28, 0.22);
uniform vec4 lamp_color : source_color = vec4(0.769, 0.643, 0.416, 1.0);
uniform float inner = 0.12;
uniform float mid = 0.28;
uniform float outer = 0.48;
uniform float strength : hint_range(0.0, 0.45) = 0.22;

float bayer4(vec2 p) {
	int x = int(mod(p.x, 4.0));
	int y = int(mod(p.y, 4.0));
	int i = x + y * 4;
	float m = 0.0;
	if (i == 0) m = 0.0;
	else if (i == 1) m = 8.0;
	else if (i == 2) m = 2.0;
	else if (i == 3) m = 10.0;
	else if (i == 4) m = 12.0;
	else if (i == 5) m = 4.0;
	else if (i == 6) m = 14.0;
	else if (i == 7) m = 6.0;
	else if (i == 8) m = 3.0;
	else if (i == 9) m = 11.0;
	else if (i == 10) m = 1.0;
	else if (i == 11) m = 9.0;
	else if (i == 12) m = 15.0;
	else if (i == 13) m = 7.0;
	else if (i == 14) m = 13.0;
	else m = 5.0;
	return m / 16.0;
}

void fragment() {
	float d = distance(SCREEN_UV, lamp_uv);
	float inten = 0.0;
	if (d <= inner) {
		inten = 1.0;
	} else if (d <= mid) {
		inten = mix(1.0, 0.35, (d - inner) / max(mid - inner, 0.0001));
	} else if (d <= outer) {
		inten = mix(0.35, 0.0, (d - mid) / max(outer - mid, 0.0001));
	}
	float dither = step(bayer4(FRAGCOORD.xy), clamp(inten + 0.08, 0.0, 1.0));
	float a = mix(inten, inten * dither, 0.42) * strength;
	COLOR = vec4(lamp_color.rgb, a);
}
