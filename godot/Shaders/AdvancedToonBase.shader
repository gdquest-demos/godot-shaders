shader_type spatial;
render_mode unshaded, world_vertex_coords;

uniform sampler2D light_data;

uniform sampler2D key_light_ramp;
uniform sampler2D fill_light_ramp;
uniform sampler2D kick_light_ramp;
uniform sampler2D outline_ramp;

uniform vec4 base_color : hint_color = vec4(1.0);
uniform sampler2D base_color_texture;

uniform vec4 key_light_color : hint_color = vec4(1.0);
uniform vec4 fill_light_color : hint_color = vec4(1.0);
uniform vec4 kick_light_color : hint_color = vec4(1.0);

uniform vec4 shadow_color : hint_color = vec4(0, 0, 0, 1);

uniform vec3 world_camera_position;

uniform float lit_outline_factor = 1.0;

varying vec3 world_pos;

void vertex() {
	world_pos = VERTEX;
}

void fragment() {
	//Deferred light data
	vec3 diffuse = texture(light_data, SCREEN_UV).rgb;
	
	//Light data extracted from color channels (red for key light, green for fill, blue for kick)
	float key_light_value = texture(key_light_ramp, vec2(diffuse.r, 0)).r;
	float fill_light_value = texture(fill_light_ramp, vec2(diffuse.g, 0)).r;
	float kick_light_value = texture(kick_light_ramp, vec2(diffuse.b, 0)).r;
	
	//Base color and texture
	vec3 base_out_color = base_color.rgb * texture(base_color_texture, UV).rgb;
	
	//Multiply mix base color with key light
	vec3 out_color = base_out_color * key_light_value * key_light_color.rgb;
	
	//Lighten mix shadow color and out color
	out_color = 1.0 - (1.0 - shadow_color.rgb) * (1.0 - out_color.rgb);
	
	//Additive mix fill light
	out_color += fill_light_value * fill_light_color.rgb;
	
	//Additive mix kick light
	out_color += kick_light_value * kick_light_color.rgb;
	
	//Outline
	vec3 eye_normal = normalize(world_pos - world_camera_position);
	float fresnel_term = 0.0 + 0.5 * pow(1.0 + dot(eye_normal, NORMAL), 32.0);
	float fresnel_factor = pow(fresnel_term, diffuse.r * 12.0);
	float outline_amount = texture(outline_ramp, normalize(vec2(fresnel_factor, 0))).r;
	
	out_color = mix(vec3(0.0), out_color, outline_amount);
	
	ALBEDO = out_color;
}