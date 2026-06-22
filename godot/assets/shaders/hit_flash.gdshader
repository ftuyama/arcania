shader_type canvas_item;

uniform float flash : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 color = COLOR;
	color.rgb = mix(color.rgb, vec3(1.0), flash);
	COLOR = color;
}
