shader_type canvas_item;

uniform sampler2D alternate_viewport;
uniform sampler2D mask_viewport;
uniform float dim_main_view : hint_range(0, 1) = 0.2;

void fragment() {
	vec4 background_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 main_color = texture(TEXTURE, UV);
	float mask_color = texture(mask_viewport, UV).r;
	vec4 alternate_color = texture(alternate_viewport, UV);
	
	vec4 out_color = main_color * (1.0 - alternate_color.a * mask_color);
	out_color += alternate_color * mask_color;
	vec4 dim_color = vec4(vec3(dim_main_view), 0.0) * (1.0 - mask_color);

	COLOR = clamp(out_color - dim_color + background_color * (1.0 - main_color.a), 0, 1);
}