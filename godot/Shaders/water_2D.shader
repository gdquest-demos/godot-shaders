shader_type canvas_item;

uniform vec4 shadow_color : hint_color;

uniform float tile_factor = 10.0;
uniform float aspect_ratio = 0.5;

uniform sampler2D texture_offset_uv : hint_black;
uniform vec2 texture_offset_scale = vec2(0.2, 0.2);
uniform float texture_offset_height = 0.1;

uniform float texture_offset_time_scale = 0.05;

uniform float sine_time_scale = 0.03;
uniform vec2 sine_offset_scale = vec2(0.4, 0.4);
uniform float sine_wave_size = 0.4;

vec2 calculate_sine_wave(float time, float multiplier, vec2 uv, vec2 offset_scale) {
	float time_multiplied = time * multiplier;
	float unique_offset = uv.x + uv.y;
	return vec2(
		sin(time_multiplied + unique_offset * offset_scale.x),
		cos(time_multiplied + unique_offset * offset_scale.y));
}

void fragment() {
	vec2 base_uv_offset = UV * texture_offset_scale;
	base_uv_offset += TIME * texture_offset_time_scale;

	vec2 adjusted_uv = UV * tile_factor;
	adjusted_uv.y *= aspect_ratio;
	
	vec2 texture_based_offset = texture(texture_offset_uv, base_uv_offset).rg * 2.0 - 1.0;
	vec2 sine_offset = calculate_sine_wave(TIME, sine_time_scale, adjusted_uv, sine_offset_scale);

	vec2 sine_uv_offset = sine_offset * sine_wave_size;
	vec2 final_waves_uvs = adjusted_uv + texture_based_offset 
			* texture_offset_height + sine_uv_offset;
	
	float water_height = (sine_offset.y + texture_based_offset.y) * 0.5;

	vec4 diffuse_color = texture(TEXTURE, final_waves_uvs);
	COLOR = mix(diffuse_color, shadow_color, water_height * NORMALMAP.b * 0.4);
	NORMALMAP = texture(NORMAL_TEXTURE, (adjusted_uv + sine_uv_offset) / 5.0).rgb;
	NORMALMAP.z *= 1.0 - water_height;
}
