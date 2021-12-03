shader_type canvas_item;
render_mode unshaded, blend_disabled;

uniform sampler2D palette;
uniform float palette_count = 1.0;
uniform float palette_index = 0.0;

const float STEP_UNIT = 0.00392;

void fragment() {
    
	float increment = 1.0 / palette_count;
	float y = increment * palette_index + increment * 0.5;
	vec4 color = texture(TEXTURE, UV);
	vec4 new_color = texture(palette, vec2(color.r, y));
	new_color.a *= step(STEP_UNIT, color.a);
    
	COLOR = new_color;
}