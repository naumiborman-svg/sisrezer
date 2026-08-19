shader_type canvas_item;

uniform vec4 tint: source_color = vec4(0.05, 0.2, 0.05, 0.12);

void fragment() {
	float scan = sin(UV.y * 900.0) * 0.5 + 0.5;
	float vig = smoothstep(0.0, 0.35, UV.x) * smoothstep(1.0, 0.65, UV.x)
		* smoothstep(0.0, 0.25, UV.y) * smoothstep(1.0, 0.75, UV.y);
	float a = tint.a + scan * 0.07;
	COLOR = vec4(tint.rgb, a * (0.55 + 0.45 * vig));
}
