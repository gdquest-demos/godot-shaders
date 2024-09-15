shader_type canvas_item;

void fragment() {
	COLOR = vec4(vec3(1.0) - texture(TEXTURE, UV).rgb, 1.0);
}