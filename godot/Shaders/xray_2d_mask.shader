shader_type canvas_item;

uniform sampler2D alternate_viewport;
uniform sampler2D mask_viewport;
uniform float dim_factor : hint_range(0, 1) = 0.8;

void fragment() {
	vec4 main_color = texture(TEXTURE, UV);
	float mask_color = texture(mask_viewport, UV).r;
	vec4 alternate_color = texture(alternate_viewport, UV);
	
	// Dim the main viewport wherever the mask is black
	main_color.rgb *=  max(dim_factor, mask_color);
	// Use mix blending to reveal the X-ray view where the mask, and X-ray view overlap
	COLOR = mix(main_color, alternate_color, alternate_color.a * mask_color);
}