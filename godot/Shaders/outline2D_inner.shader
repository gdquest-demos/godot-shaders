shader_type canvas_item;

uniform vec4 line_color : hint_color = vec4(1.0);
uniform float line_thickness : hint_range(0, 10) = 1.0;

const vec2 OFFSETS[8] = {
	vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(0, -1), vec2(0, 1), 
	vec2(1, -1), vec2(1, 0), vec2(1, 1)
};

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
	float outline = 1.0;
	
	for (int i = 0; i < OFFSETS.length(); i++) {
		outline *= texture(TEXTURE, UV + size * OFFSETS[i]).a;
	}
	outline = 1.0 - outline;
	
	vec4 color = texture(TEXTURE, UV);
	vec4 outlined_result = mix(color, line_color, outline * color.a);
	COLOR = mix(color, outlined_result, outlined_result.a);
}
