shader_type canvas_item;

uniform sampler2D transition_gradient :hint_black;
uniform sampler2D distortion_map : hint_black;

uniform vec4 water_tint :hint_color;
uniform vec4 shadow_color :hint_color;

uniform vec2 distortion_scale = vec2(0.5, 0.5);
uniform float distortion_amplitude = 0.1;
uniform float distortion_time_scale = 0.05;

uniform float water_time_scale = 0.1;

uniform float reflection_intensity = 0.5;

// Updated from GDScript
uniform vec2 scale;
uniform float zoom_y;
uniform float aspect_ratio;

uniform float tile_factor = 1.4;


uniform mat3 transform = mat3(vec3(1,0,0), vec3(0,1,0), vec3(0,0,1));

const vec3 VIEW_DIRECTION = vec3(0.0, -0.707, 0.707);



vec2 calculate_distortion(vec2 uv, float time) {
	vec2 base_uv_offset = uv * distortion_scale * scale * tile_factor + time * distortion_time_scale;
	return texture(distortion_map, base_uv_offset).rg * 2.0 - 1.0;
}

void fragment() {
	// Perspective projection
	vec3 projection_coords = vec3(UV, 1.0) * transform;
	vec2 uv = projection_coords.xy / projection_coords.z;

	vec2 distortion = calculate_distortion(uv, TIME);
		
	vec2 adjusted_uv = uv * tile_factor * scale;
	adjusted_uv.y *= aspect_ratio;
	vec2 waves_uvs = adjusted_uv + distortion * distortion_amplitude + vec2(water_time_scale, 0.0) * TIME;
	
    float height =  texture(distortion_map, waves_uvs * 0.05 + TIME * 0.004).r;
    vec2 parallax = VIEW_DIRECTION.xy / VIEW_DIRECTION.z * height * 0.5 + 0.2;
    waves_uvs -= parallax;

	float uv_size_ratio_v = SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y;
	vec2 uv_reflected = vec2(SCREEN_UV.x, SCREEN_UV.y + uv_size_ratio_v * uv.y * 2.0 * scale.y * zoom_y);
	vec2 reflection_uvs = uv_reflected + distortion * distortion_amplitude / tile_factor;
	
	vec4 reflection_color = texture(SCREEN_TEXTURE, reflection_uvs - parallax * vec2(0.0, uv_size_ratio_v));
	vec4 water_color = texture(TEXTURE, waves_uvs) * water_tint;
	float transition = texture(transition_gradient, vec2(1.0 - uv.y, 1.0)).r;
	water_color.rgb = mix(water_color.rgb, water_color.rgb * shadow_color.rgb, 1.0 - height - 0.5);
	COLOR = mix(water_color, reflection_color, transition * reflection_intensity);
//	COLOR = water_color;
//	COLOR.rgb = vec3(height);

	NORMAL = texture(NORMAL_TEXTURE, waves_uvs).rgb * normalize(vec3(height));
}
