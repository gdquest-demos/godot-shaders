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
uniform sampler2D anisotropic_ramp;
uniform sampler2D anisotropic_sharpness_ramp;
uniform sampler2D anisotropic_softness_ramp;

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

uniform sampler2D high_frequency_anisotropic_noise;
uniform sampler2D low_frequency_anisotropic_noise;
uniform sampler2D spottiness_anisotropic_noise;
uniform vec4 anisotropic_specular_color : hint_color = vec4(1);
uniform float anisotropic_specular_strength : hint_range(0, 1) = 0.0;

varying vec3 world_position;
varying vec3 world_normal;
varying vec3 down_camera_angle;

void vertex() {
	world_position = VERTEX;
	world_normal = NORMAL;
	down_camera_angle = (vec4(0, -1, 0, 1) * CAMERA_MATRIX).xyz;
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
	
	//Anisotropic specular
	float anisotropic_angle = down_camera_angle.z * 0.3;
	float high_anisotropic_noise_value = texture(high_frequency_anisotropic_noise, vec2(UV.x)).r;
	high_anisotropic_noise_value = (high_anisotropic_noise_value - 0.5) * 0.2;
	
	float low_anisotropic_noise_value = texture(low_frequency_anisotropic_noise, vec2(UV.x)).r;
	low_anisotropic_noise_value = (low_anisotropic_noise_value - 0.5) * 0.2;
	
	float anisotropic_specular_hotspot = texture(soft_specular_ramp, vec2(specular * 12.0, 0)).r;
	
	float spottiness_anisotropic_noise_value = texture(spottiness_anisotropic_noise, vec2(UV.x)).r;
	spottiness_anisotropic_noise_value = (spottiness_anisotropic_noise_value - 0.5) * 5.0 + 0.85;
	
	float anisotropic_uv = UV.y + high_anisotropic_noise_value + low_anisotropic_noise_value - anisotropic_angle;
	
	float anisotropic_value = (texture(anisotropic_ramp, vec2(anisotropic_uv, 0)).rgb * spottiness_anisotropic_noise_value * anisotropic_specular_hotspot).r;
	anisotropic_value = texture(anisotropic_sharpness_ramp, vec2(anisotropic_value, 0.0)).r;
	
	float soft_anisotropic_value = (texture(anisotropic_softness_ramp, vec2(anisotropic_uv, 0)).rgb * spottiness_anisotropic_noise_value * anisotropic_specular_hotspot).r;
	
	anisotropic_value = mix(anisotropic_value, soft_anisotropic_value, 0.04);
	vec3 anisotropic_color = mix(vec3(0), anisotropic_specular_color.rgb, anisotropic_value);
	
	out_color = out_color + (anisotropic_color *  anisotropic_specular_strength);
	
	//Outline
	float fresnel_factor = (outline_size) - dot(normalize(VIEW), NORMAL);
	float outline_factor = pow(fresnel_factor, diffuse.r * pow(2.0, 8.0));
	float outline_amount = texture(outline_ramp, normalize(vec2(outline_factor, 0))).r;
	
	out_color = mix(outline_color.rgb, out_color, outline_amount);
	
	ALBEDO = out_color;
}