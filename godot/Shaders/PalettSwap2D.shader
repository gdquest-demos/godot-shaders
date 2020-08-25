shader_type canvas_item;
render_mode unshaded, blend_disabled;

uniform sampler2D palette;									//Use palletes in collum and color set horizontaly
uniform float palette_count = 1.0;							//Used for highlighting hovered color
uniform float palette_index = 0.0;							//Set for chosing differen palettes (0 is first)

void fragment(){
    
	float increment = 1.0/palette_count;					//value for getting palette index
	float y = increment*palette_index + increment * 0.5;	// + safety measure for floating point imprecision
	vec4 color = texture(TEXTURE, UV);						//Original grayscale color used as collumn index
	vec4 new_color = texture(palette, vec2(color.r, y));	//get color from palette texture
	float a = step(0.00392, color.a);						//check if transparent color is less than 1/255 for backgrounds
	new_color.a *= a;										//if BG is transparent alpha is multiplied by 0
    
	COLOR = new_color;										//set new color from palette
}