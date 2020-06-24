shader_type spatial;
render_mode unshaded, world_vertex_coords;

uniform sampler2D light_data;
uniform sampler2D specular_data;
uniform sampler2D metalness_texture;

uniform sampler2D key_light_ramp;
uniform sampler2D fill_light_ramp;
uniform sampler2D kick_light_ramp;
uniform sampler2D outline_ramp;
uniform sampler2D soft_specular_ramp;
uniform sampler2D hard_specular_ramp;

uniform float specular_softness : hint_range(0, 1) = 0.5;
uniform float specular_size : hint_range(0, 4) = 0.5;
uniform vec4 specular_color : hint_color = vec4(1);

uniform vec4 base_color : hint_color = vec4(1.0);
uniform sampler2D base_color_texture;

uniform vec4 outline_color : hint_color = vec4(0, 0, 0, 1.0);
uniform float outline_size : hint_range(0, 1) = 0.175;

uniform vec4 key_light_color : hint_color = vec4(1.0);
uniform vec4 fill_light_color : hint_color = vec4(1.0);
uniform vec4 kick_light_color : hint_color = vec4(1.0);

uniform vec4 shadow_color : hint_color = vec4(0, 0, 0, 1);

uniform vec4 dark_metalness_color : hint_color = vec4(0, 0, 0, 1);
uniform vec4 light_metalness_color : hint_color = vec4(1, 1, 1, 1);
uniform float metalness_contrast_factor : hint_range(0, 5) = 1.0;
uniform float metalness : hint_range(0, 1) = 0.0;

uniform vec3 world_camera_position;

varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = VERTEX;
	world_normal = NORMAL;
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
	
	//Metalness
	vec2 metalness_uv = (NORMAL.xy * vec2(0.5, -0.5) + vec2(0.5, 0.5));
	vec3 metalness_value = texture(metalness_texture, metalness_uv).rgb;
	
	metalness_value = pow(metalness_value, vec3(metalness_contrast_factor));
	metalness_value = 1.0 - (1.0 - metalness_value) * (1.0 - dark_metalness_color.rgb);
	metalness_value = metalness_value + light_metalness_color.rgb - 1.0;
	
	out_color = mix(out_color, metalness_value, metalness);
	
	//specular
	float specular = texture(specular_data, SCREEN_UV).r;
	vec3 soft_specular = texture(soft_specular_ramp, vec2(specular * specular_size, 0)).rgb;
	vec3 hard_specular = texture(hard_specular_ramp, vec2(specular * specular_size/2.0, 0)).rgb;
	
	vec3 specular_out = mix(hard_specular, soft_specular, specular_softness) * specular_color.rgb;
	
	out_color += specular_out;
	
	//Additive mix kick light
	out_color += kick_light_value * kick_light_color.rgb;
	
	//Outline
	float fresnel_factor = (outline_size) - dot(normalize(VIEW), NORMAL);
	float outline_factor = pow(fresnel_factor, diffuse.r * pow(2.0, 8.0));
	float outline_amount = texture(outline_ramp, normalize(vec2(outline_factor, 0))).r;
	
	out_color = mix(outline_color.rgb, out_color, outline_amount);
	
	ALBEDO = out_color;
}