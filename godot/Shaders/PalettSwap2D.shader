shader_type canvas_item;
render_mode unshaded, blend_disabled;

uniform sampler2D palette;
uniform float palette_count = 1.0;
uniform float palette_index = 0.0;

void fragment(){
    
	float increment = 1.0/palette_count;
	float y = increment*palette_index + increment * 0.5;
	vec4 color = texture(TEXTURE, UV);
	vec4 new_color = texture(palette, vec2(color.r, y));
	float a = step(0.00392, color.a);
	new_color.a *= a;
    
	COLOR = new_color;
}