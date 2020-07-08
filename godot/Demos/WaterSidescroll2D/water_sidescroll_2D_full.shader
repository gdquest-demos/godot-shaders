shader_type canvas_item;

uniform sampler2D diffuse_texture :hint_black;
uniform sampler2D transition_gradient :hint_black;
uniform sampler2D distortion_map : hint_black;

uniform vec4 water_tint :hint_color;

uniform vec2 distortion_scale = vec2(0.5, 0.5);
uniform float distortion_height = 0.1;
uniform float distortion_time_scale = 0.05;

uniform float water_time_scale = 0.1;

uniform float reflection_intensity = 0.5;

// Updated from GDScript
uniform float scale_y = 1.0f;
uniform float zoom_y = 1.0f;
uniform float aspect_ratio = 0.5;

uniform float tile_factor = 2.0;

const vec3 VIEW_DIRECTION = vec3(0.0, -0.707, 0.707);

vec2 calculate_distortion(vec2 uv, float time) {
	vec2 base_uv_offset = uv * distortion_scale + time * distortion_time_scale;
	return texture(distortion_map, base_uv_offset).rg * 2.0 - 1.0;
}

// TODO: Add parallax map?
vec2 parallax_mapping(vec2 uv_coordinates) { 
    float height =  texture(distortion_map, uv_coordinates * 0.1).r;    
    vec2 parallax = VIEW_DIRECTION.xy / VIEW_DIRECTION.z * (height * 1.0);
    return uv_coordinates - parallax;
}

void fragment() {
	vec2 distortion = calculate_distortion(UV, TIME);
	
	vec2 adjusted_uv = UV * tile_factor;
	adjusted_uv.y *= aspect_ratio;
	vec2 waves_uvs = adjusted_uv + distortion * distortion_height + vec2(water_time_scale, 0.0) * TIME;

	float uv_size_ratio_v = SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y;
	vec2 uv_reflected = vec2(SCREEN_UV.x, SCREEN_UV.y + uv_size_ratio_v * UV.y * 2.0 * scale_y * zoom_y);
	vec2 reflection_uvs = uv_reflected + distortion * distortion_height / tile_factor;
	
	vec4 reflection_color = texture(SCREEN_TEXTURE, reflection_uvs);
	vec4 water_color = texture(diffuse_texture, UV * scale_y + waves_uvs) * water_tint;
	float transition = texture(transition_gradient, vec2(1.0 - UV.y, 1.0)).r;
	COLOR = mix(water_color, reflection_color, transition * reflection_intensity);
}
