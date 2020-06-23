shader_type spatial;
render_mode unshaded;

uniform sampler2D light_data;
uniform sampler2D key_light_ramp;
uniform sampler2D fill_light_ramp;
uniform sampler2D kick_light_ramp;
uniform vec4 base_color : hint_color = vec4(1.0);
uniform sampler2D base_color_texture;
uniform vec4 key_light_color : hint_color = vec4(1.0);
uniform vec4 fill_light_color : hint_color = vec4(1.0);
uniform vec4 kick_light_color : hint_color = vec4(1.0);
uniform vec4 shadow_color : hint_color = vec4(0, 0, 0, 1);

void fragment() {
	vec3 diffuse = texture(light_data, SCREEN_UV).rgb;
	
	float key_light_value = texture(key_light_ramp, vec2(diffuse.r, 0)).r;
	float fill_light_value = texture(fill_light_ramp, vec2(diffuse.g, 0)).r;
	float kick_light_value = texture(kick_light_ramp, vec2(diffuse.b, 0)).r;
	
	vec3 base_out_color = base_color.rgb * texture(base_color_texture, UV).rgb;
	
	vec3 out_color = base_out_color * key_light_value * key_light_color.rgb;
	out_color = 1.0 - (1.0 - shadow_color.rgb) * (1.0 - out_color.rgb);
	out_color += fill_light_value * fill_light_color.rgb;
	out_color += kick_light_value * kick_light_color.rgb;
	
	ALBEDO = out_color;
}