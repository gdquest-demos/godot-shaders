shader_type canvas_item;

uniform sampler2D transition_gradient :hint_default_black;
uniform sampler2D distortion_map : hint_default_black;

uniform vec4 water_tint :source_color;

uniform vec2 distortion_scale = vec2(0.5, 0.5);
uniform float distortion_amplitude :hint_range(0.005, 0.4) = 0.1;
uniform float distortion_time_scale :hint_range(0.01, 0.15) = 0.05;

uniform float water_time_scale :hint_range(0.01, 2.0) = 0.1;
uniform float scale_y_factor :hint_range(0.1, 4.0) = 2.0;
uniform float tile_factor :hint_range(0.1, 3.0) = 1.4;

uniform float reflection_intensity :hint_range(0.01, 1.0) = 0.5;

// Updated from GDScript
uniform vec2 scale;
uniform float zoom_y;
uniform float aspect_ratio;


vec2 calculate_distortion(vec2 uv, float time) {
	vec2 base_uv_offset = uv * distortion_scale + time * distortion_time_scale;
	return texture(distortion_map, base_uv_offset).rg * 2.0 - 1.0;
}

void fragment() {
	vec2 uv_size_ratio = SCREEN_PIXEL_SIZE / TEXTURE_PIXEL_SIZE;
	vec2 distortion = calculate_distortion(UV, TIME);
	
	vec2 adjusted_uv = UV * scale * tile_factor;
	adjusted_uv.y *= aspect_ratio * scale_y_factor;
	vec2 waves_uvs = adjusted_uv + distortion * distortion_amplitude + vec2(water_time_scale, 0.0) * TIME;

	vec2 uv_reflected = vec2(SCREEN_UV.x, SCREEN_UV.y + uv_size_ratio.y * UV.y * 2.0 * scale.y * zoom_y);
	vec2 reflection_uvs = uv_reflected + uv_size_ratio * distortion * distortion_amplitude;
	
	vec4 reflection_color = texture(SCREEN_TEXTURE, reflection_uvs);
	vec4 water_color = texture(TEXTURE, waves_uvs) * water_tint;
	float transition = texture(transition_gradient, vec2(1.0 - UV.y, 1.0)).r;
	COLOR = mix(water_color, reflection_color, transition * reflection_intensity);
}
