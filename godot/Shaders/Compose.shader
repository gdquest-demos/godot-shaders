shader_type canvas_item;

void fragment() {
	vec4 output_color = texture(TEXTURE, UV);
	if(output_color.r == 0.0 && output_color.g == 0.0 && output_color.b == 0.0) {
		discard;
	}
	COLOR = vec4(output_color.rgb, step(0.01, min(1.0, output_color.r + output_color.g + output_color.b)));
}