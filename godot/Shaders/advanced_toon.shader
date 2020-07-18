shader_type spatial;
render_mode unshaded;

const float ANISOTROPY_HOTSPOT_MIN = 0.083;
const float ANISOTROPY_HOTSPOT_MAX = 0.637;
const float ANISOTROPY_BAND_MIN = 0.42;
const float ANISOTROPY_BAND_MIDDLE = 0.5;
const float ANISOTROPY_BAND_MAX = 0.58;
const float ANISOTROPY_SHARPNESS= 0.350;
const float ANISOTROPY_SOFTNESS_MIN = 0.06;
const float ANISOTROPY_SOFTNESS_MAX = 0.364;
const float OUTLINE_MIN = 0.47;
const float OUTLINE_MAX = 0.53;
const float SPECULAR_SOFT_MIN = 0.0;
const float SPECULAR_SOFT_MAX = 0.637;
const float SPECULAR_HARD_MIN = 0.167;
const float SPECULAR_HARD_MAX = 0.179;
const float AO_SHARP_MIN = 0.48;
const float AO_SHARP_MAX = 0.52;
const float RIM_SHARPNESS = 0.4;
const float RIM_SOFTNESS_MIN = 0.2;
const float RIM_SOFTNESS_MAX = 0.7;

uniform sampler2D light_data : hint_black;
uniform sampler2D specular_data : hint_black;
uniform sampler2D rim_data : hint_black;
uniform sampler2D metalness_texture : hint_black_albedo;

uniform vec4 base_color : hint_color = vec4(1.0);

uniform vec4 paint_color1 : hint_color = vec4(1.0);
uniform sampler2D paint_mask1 : hint_black;

uniform vec4 paint_color2 : hint_color = vec4(1.0);
uniform sampler2D paint_mask2 : hint_black;

uniform vec4 paint_color3 : hint_color = vec4(1.0);
uniform sampler2D paint_mask3 : hint_black;

uniform sampler2D key_light_ramp : hint_black;
uniform sampler2D fill_light_ramp : hint_black;
uniform sampler2D kick_light_ramp : hint_black;

uniform float specular_softness : hint_range(0, 1) = 0.5;
uniform float specular_size : hint_range(0, 4) = 0.5;
uniform vec4 specular_color : hint_color = vec4(1);

uniform vec4 outline_color : hint_color = vec4(0, 0, 0, 1.0);
uniform float outline_size : hint_range(0, 1) = 0.175;

uniform vec4 key_light_color : hint_color = vec4(1.0);
uniform vec4 fill_light_color : hint_color = vec4(1.0);
uniform vec4 kick_light_color : hint_color = vec4(1.0);

uniform vec4 shadow_color : hint_color = vec4(0, 0, 0, 1);
uniform sampler2D shadow_paint : hint_black_albedo;

uniform sampler2D ambient_occlusion : hint_black_albedo;
uniform float ambient_occlusion_softness : hint_range(0, 1) = 0.5;
uniform float ambient_occlusion_opacity : hint_range(0, 1) = 0.0;
uniform float ambient_occlusion_shadow_limit : hint_range(0, 1) = 1.0;
uniform vec4 ambient_occlusion_color : hint_color = vec4(0, 0, 0, 1);

uniform vec4 dark_metalness_color : hint_color = vec4(0, 0, 0, 1);
uniform vec4 light_metalness_color : hint_color = vec4(1, 1, 1, 1);
uniform float metalness_contrast_factor : hint_range(0, 5) = 1.0;
uniform float metalness : hint_range(0, 1) = 0.0;

uniform sampler2D high_frequency_anisotropy_noise : hint_black;
uniform sampler2D low_frequency_anisotropy_noise : hint_black;
uniform sampler2D spottiness_anisotropy_noise : hint_black;
uniform vec4 anisotropy_specular_color : hint_color = vec4(1);
uniform float anisotropy_specular_width = 10.0;
uniform float anisotropy_specular_strength : hint_range(0, 1) = 0.0;
uniform float anisotropy_specular_contrast : hint_range(0, 12) = 5.0;
uniform float anisotropy_specular_brightness : hint_range(0, 2) = 0.85;
uniform float anisotropy_specular_softness : hint_range(0, 1) = 0.5;
uniform float anisotropy_in_shadow_strength : hint_range(0, 1) = 0.1;

uniform float rim_light_softness : hint_range(0, 1) = 0.5;
uniform vec4 rim_light_color : hint_color = vec4(0, 0, 0, 1);

varying vec3 down_camera_angle;

void vertex()
{
	down_camera_angle = (vec4(0, -1, 0, 1) * CAMERA_MATRIX).xyz;
}

void fragment()
{
	// Deferred light data
	vec3 diffuse = texture(light_data, SCREEN_UV).rgb;

	// Light data extracted from color channels (red for key light, green for
	// fill, blue for kick)
	float key_light_value = texture(key_light_ramp, vec2(diffuse.r, 0)).r;
	
	key_light_value = mix(key_light_value, 0, texture(shadow_paint, UV).r);

	// Lighten mix shadow color and out color
	vec3 out_color = key_light_value * key_light_color.rgb;

	out_color = max(out_color, shadow_color.rgb);

	// Multiply mix base color with key light
	vec3 flat_color = mix(base_color.rgb, paint_color1.rgb, texture(paint_mask1, UV).r);
	flat_color = mix(flat_color, paint_color2.rgb, texture(paint_mask2, UV).r);
	flat_color = mix(flat_color, paint_color3.rgb, texture(paint_mask3, UV).r);

	out_color = flat_color * out_color;

	// Additive mix fill light
	float fill_light_value = texture(fill_light_ramp, vec2(diffuse.g, 0)).r;
	out_color += fill_light_value * fill_light_color.rgb;

	// Metalness
	if (metalness > 0.0) {
		vec2 metalness_uv = (NORMAL.xy * vec2(0.5, -0.5) + vec2(0.5, 0.5));
		vec3 metalness_value = texture(metalness_texture, metalness_uv).rgb;

		metalness_value = clamp(pow(metalness_value, vec3(metalness_contrast_factor)), 0, 1);
		metalness_value = clamp(metalness_value, dark_metalness_color.rgb, light_metalness_color.rgb);

		out_color = mix(out_color, metalness_value, metalness);
	}

	// specular
	float specular = texture(specular_data, SCREEN_UV).r;
	if (specular_size > 0.0) {
		vec3 soft_specular
			= vec3(smoothstep(SPECULAR_SOFT_MIN, SPECULAR_HARD_MAX, specular * specular_size));
		vec3 hard_specular
			= vec3(smoothstep(SPECULAR_HARD_MIN, SPECULAR_HARD_MAX, specular * specular_size));

		vec3 specular_out
			= mix(hard_specular, soft_specular, specular_softness) * specular_color.rgb;

		out_color += specular_out;
	}

	// Anisotropic specular
	if (anisotropy_specular_strength > 0.0) {
		float anisotropy_angle = down_camera_angle.z * 0.33;

		float high_anisotropy_noise_value
			= (texture(high_frequency_anisotropy_noise, vec2(UV.x, 0)).r - 0.5) * 0.2;
		float low_anisotropy_noise_value
			= (texture(low_frequency_anisotropy_noise, vec2(UV.x, 0)).r - 0.5) * 0.2;

		float anisotropy_specular_hotspot = smoothstep(
			ANISOTROPY_HOTSPOT_MIN, ANISOTROPY_HOTSPOT_MAX, specular * anisotropy_specular_width);

		float spottiness_anisotropy_noise_value
			= (texture(spottiness_anisotropy_noise, vec2(UV.x, 0)).r - 0.5)
				* anisotropy_specular_contrast
			+ anisotropy_specular_brightness;

		float anisotropy_uv
			= UV.y + high_anisotropy_noise_value + low_anisotropy_noise_value - anisotropy_angle;

		float lower_sample = smoothstep(ANISOTROPY_BAND_MIN, ANISOTROPY_BAND_MIDDLE, anisotropy_uv);
		float higher_sample
			= 1.0 - smoothstep(ANISOTROPY_BAND_MIDDLE, ANISOTROPY_BAND_MAX, anisotropy_uv);
		float anisotropy_sample = lower_sample * higher_sample * spottiness_anisotropy_noise_value
			* max(anisotropy_specular_hotspot, anisotropy_in_shadow_strength);

		float sharp_anisotropy_value
			= step(ANISOTROPY_SHARPNESS, anisotropy_sample);
		float soft_anisotropy_value
			= smoothstep(ANISOTROPY_SOFTNESS_MIN, ANISOTROPY_SOFTNESS_MAX, anisotropy_sample);

		float anisotropy_value = mix(sharp_anisotropy_value, soft_anisotropy_value, 0.5);
		vec3 anisotropy_color = anisotropy_specular_color.rgb * anisotropy_value;

		out_color = out_color + (anisotropy_color * anisotropy_specular_strength);
	}

	// Additive mix kick light
	float kick_light_value = texture(kick_light_ramp, vec2(diffuse.b, 0)).r;
	
	if(length(rim_light_color.rgb) > 0.0) {
		float rim_value = texture(rim_data, SCREEN_UV).r;
		float hard_rim = step(RIM_SHARPNESS, rim_value);
		float soft_rim = smoothstep(RIM_SOFTNESS_MIN, RIM_SOFTNESS_MAX, rim_value);
		
		vec3 out_rim_light = vec3(mix(hard_rim, soft_rim, rim_light_softness)) * rim_light_color.rgb;
		
		out_color += out_rim_light * kick_light_value;
	}
	
	out_color += kick_light_value * kick_light_color.rgb;

	// Outline
	if (outline_size > 0.0) {
		float fresnel_factor = (outline_size)-dot(normalize(VIEW), NORMAL);
		float outline_factor = pow(fresnel_factor, diffuse.r * pow(2.0, 8.0));

		float outline_amount = 1.0 - smoothstep(OUTLINE_MIN, OUTLINE_MAX, outline_factor);

		out_color = mix(outline_color.rgb, out_color, outline_amount);
	}

	// AO
	if(ambient_occlusion_opacity > 0.0) {
		float ambient = texture(ambient_occlusion, UV).r;
		float sharp_ambient = smoothstep(AO_SHARP_MIN, AO_SHARP_MAX, ambient);
		float soft_ambient = ambient;
		float ambient_out = mix(sharp_ambient, soft_ambient, ambient_occlusion_softness);
		
		ambient_out = mix(1, ambient_out, ambient_occlusion_opacity);
		ambient_out = mix(ambient_out, 1, mix(key_light_value, 0, 1.0 - ambient_occlusion_shadow_limit));
		
		out_color = mix(ambient_occlusion_color.rgb, out_color, ambient_out);
	}

	ALBEDO = vec3(out_color);
}
