shader_type canvas_item;

void fragment() {
	float scan = step(0.55, fract(SCREEN_UV.y * 280.0));
	float vig = smoothstep(0.95, 0.35, length(SCREEN_UV - vec2(0.5)));
	COLOR = vec4(0.0, 0.04, 0.0, scan * 0.22 + (1.0 - vig) * 0.18);
}
