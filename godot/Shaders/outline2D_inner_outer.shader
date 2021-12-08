shader_type canvas_item;

uniform vec4 line_color : hint_color = vec4(1);
uniform float line_thickness : hint_range(0, 10) = 1.0;

const vec2 OFFSETS[8] = {
	vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(0, -1), vec2(0, 1), 
	vec2(1, -1), vec2(1, 0), vec2(1, 1)
};

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness / 2.0;
	vec4 color = texture(TEXTURE, UV);
	
	float inline = 1.0;
	float outline = 0.0;
	for (int i = 0; i < OFFSETS.length(); i++) {
		outline += texture(TEXTURE, UV + size * OFFSETS[i]).a;
		inline *= texture(TEXTURE, UV + size * OFFSETS[i]).a;
	}
	outline = min(1.0, outline) - color.a;
	inline = (1.0 - inline) * color.a;
	
	vec4 outlined_result = mix(color, line_color, outline + inline);
	COLOR = mix(color, outlined_result, outlined_result.a);
}
