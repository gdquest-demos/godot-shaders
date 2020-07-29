shader_type spatial;
render_mode blend_add, depth_draw_never, depth_test_disable;

uniform vec4 outline_color : hint_color;
uniform float color_intensity = 1.0;
uniform float outline_sharpness = 2.0;

uniform vec4 stencil_color : hint_color;
uniform sampler2D stencil : hint_black;

void fragment() {
	vec4 stencil_test = textureLod(stencil, SCREEN_UV, 0.0);
	vec4 color_test = stencil_color;
	
	float stencil_id = stencil_test.r * 10.0 + stencil_test.g + 100.0 * stencil_test.b + 1000.0;
	float mask_id = stencil_color.r * 10.0 + stencil_color.g + 100.0 * stencil_color.b + 1000.0;
	
	float mask_result = abs(stencil_id - mask_id);


	float fresnel_dot = 1.0 - dot(NORMAL, VIEW) * outline_sharpness;
	ALBEDO = vec3(0.0);
	EMISSION = smoothstep(0, 1, fresnel_dot) * outline_color.rgb * color_intensity;
	ALPHA = max(1.0 - step(mask_result, 0.0), 0.0);
}