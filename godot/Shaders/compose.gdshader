shader_type canvas_item;

uniform sampler2D prepass_texture;
uniform sampler2D blur_texture;
uniform float glow_intensity;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 prepass = texture(prepass_texture, UV);
	vec4 blurred = texture(blur_texture, UV);
	vec3 glow = max(vec3(0.0), blurred.rgb - prepass.rgb);
	
	vec3 out_color = color.rgb + glow.rgb * glow_intensity;
	
	COLOR = vec4(out_color, clamp(out_color.r + out_color.g + out_color.b, 0, 1));
}