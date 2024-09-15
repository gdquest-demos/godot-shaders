shader_type canvas_item;

uniform sampler2D alternate_viewport;
uniform sampler2D mask_viewport;
uniform float dimness : hint_range(0, 1) = 0.2;

void fragment() {
	vec4 main_color = texture(TEXTURE, UV);
	float mask_color = texture(mask_viewport, UV).r;
	vec4 alternate_color = texture(alternate_viewport, UV);
	
	float brightness = 1.0 - dimness;
	// Dim the main viewport wherever the mask is black
	main_color.rgb *=  max(brightness, mask_color);
	// Use mix blending to reveal the X-ray view where the mask, and X-ray view overlap
	COLOR = mix(main_color, alternate_color, alternate_color.a * mask_color);
}