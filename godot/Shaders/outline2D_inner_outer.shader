shader_type canvas_item;

uniform vec4 line_color : hint_color = vec4(1);
uniform float line_thickness : hint_range(0, 10) = 1.0;

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness / 2.0;
	
	float l = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
	float u = texture(TEXTURE, UV + vec2(0, size.y)).a;
	float r = texture(TEXTURE, UV + vec2(size.x, 0)).a;
	float d = texture(TEXTURE, UV + vec2(0, -size.y)).a;
	float lu = texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
	float ru = texture(TEXTURE, UV + vec2(size.x, size.y)).a;
	float ld = texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
	float rd = texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
	
	vec4 color = texture(TEXTURE, UV);
	float outline = max(max(max(l, r), max(u, d)), max(max(lu, ru), max(ld, rd))) - color.a;
	float inline = (1.0 - l * r * u * d * lu * ru * rd * ld) * color.a;
	
	COLOR = mix(color, line_color, outline + inline);
}
