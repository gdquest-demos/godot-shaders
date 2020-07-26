shader_type spatial;
render_mode depth_draw_alpha_prepass;

uniform vec4 albedo : hint_color;
uniform sampler2D stencil;
uniform vec4 stencil_color : hint_color;

void fragment() {
	vec4 stencil_test = texture(stencil, SCREEN_UV);
	vec4 color_test = stencil_color;
	
	float stencil_id = stencil_test.r * 10.0 + stencil_test.g + 100.0 * stencil_test.b + 1000.0;
	float mask_id = stencil_color.r * 10.0 + stencil_color.g + 100.0 * stencil_color.b + 1000.0;
	
	float mask_result = abs(stencil_id - mask_id);

	ALBEDO = albedo.rgb;
	ALPHA = step(mask_result, 0.0) * albedo.a;
}