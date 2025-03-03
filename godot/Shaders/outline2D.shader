shader_type canvas_item;

const int Inner = 1;
const int Outer = 2;

// TODO: Add support for struct uniforms in shaders: https://github.com/godotengine/godot/pull/93603
//struct Outline {
	//bool inner;
	//bool outer;
//};
//uniform Outline outline_type;

/**
	1 = Inner Outline
	2 = Outer Outline
	3 = Inner + Outer Outline
*/
uniform int outline_type: hint_range(1, 3) = 3;
uniform bool enabled = true;
uniform vec4 line_color : source_color = vec4(1);
uniform float line_thickness : hint_range(0, 10) = 1.0;

const vec2 OFFSETS[8] = {
	vec2(-1, -1), vec2(-1, 0), vec2(-1, 1), vec2(0, -1), vec2(0, 1), 
	vec2(1, -1), vec2(1, 0), vec2(1, 1)
};

vec4 apply_shader(sampler2D txtr, vec2 txtr_pixel_size, vec4 color, vec2 uv) {
	bool apply_inner = bool(outline_type & Inner);
	bool apply_outer = bool(outline_type & Outer);
	
	vec2 size = txtr_pixel_size * line_thickness / 2.0;
	
	float inline = 1.0;
	float outline = apply_inner && !apply_outer ? 1.0 : 0.0;
	for (int i = 0; i < OFFSETS.length(); i++) {
		float sample = texture(txtr, uv + size * OFFSETS[i]).a;
		
		// outer and inner_outer outline
		if (apply_outer) outline += sample;
		else if (apply_inner) outline *= sample;
		
		if (apply_inner && apply_outer) inline *= sample;
	}
	
	if (apply_inner && apply_outer) {
		outline = min(1.0, outline) - color.a;
		inline = (1.0 - inline) * color.a;
	}
	else if (apply_outer) outline = min(outline, 1.0);
	else if (apply_inner) outline = 1.0 - outline;
	
	float mix_value;
	if (apply_inner && apply_outer) mix_value = outline + inline;
	else if (apply_inner) mix_value = outline * color.a;
	else if (apply_outer) mix_value = outline - color.a;
	
	vec4 outlined_result = mix(color, line_color, mix_value);
	// inner and inner_outer outline
	if (apply_inner) {
		outlined_result = mix(color, outlined_result, outlined_result.a);
	}	
	return outlined_result;
}

void fragment() {
	if (enabled) COLOR = apply_shader(TEXTURE, TEXTURE_PIXEL_SIZE, COLOR, UV);
	else COLOR = COLOR;
}
