shader_type spatial;

uniform sampler2D matcap_texture : hint_black_albedo;
uniform vec4 dark_tint : hint_color = vec4(0, 0, 0, 1);
uniform vec4 light_tint : hint_color = vec4(1);
uniform float contrast_factor = 1.0;

void fragment() {
	vec2 matcap_uv = (NORMAL.xy * vec2(0.5, -0.5) + vec2(0.5, 0.5));
	vec3 matcap_value = texture(matcap_texture, matcap_uv).rgb;

	matcap_value = clamp(pow(matcap_value, vec3(contrast_factor)), 0, 1);
	matcap_value = clamp(matcap_value, dark_tint.rgb, light_tint.rgb);

	ALBEDO = matcap_value;
}