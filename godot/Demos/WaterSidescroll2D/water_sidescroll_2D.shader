shader_type canvas_item;

uniform sampler2D diffuse_texture :hint_black;
uniform sampler2D transition_gradient :hint_black;
uniform float reflection_intensity = 0.5;

uniform vec4 water_tint :hint_color;

// Updated from GDScript
uniform float scale_y = 1.0f;
uniform float zoom_y = 1.0f;

uniform float tile_factor = 2.0;
uniform float aspect_ratio = 0.5;

uniform sampler2D texture_offset_uv : hint_black;
uniform vec2 texture_offset_scale = vec2(0.5, 0.5);
uniform float texture_offset_height = 0.1;

uniform float texture_offset_time_scale = 0.05;

// TODO: 
// - Perspective
// - Lighting
// - Parallax?
void fragment() {
	float uv_size_ratio_v = SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y;
	vec2 uv_reflected = vec2(SCREEN_UV.x, SCREEN_UV.y + uv_size_ratio_v * UV.y * 2.0 * scale_y * zoom_y);

	vec2 base_uv_offset = UV * texture_offset_scale;
	base_uv_offset += TIME * texture_offset_time_scale;

	vec2 adjusted_uv = UV * tile_factor;
	adjusted_uv.y *= aspect_ratio;
	
	vec2 texture_based_offset = texture(texture_offset_uv, base_uv_offset).rg * 2.0 - 1.0;
	vec2 final_waves_uvs = adjusted_uv + texture_based_offset * texture_offset_height;

	vec2 reflection_uvs = uv_reflected + texture_based_offset * texture_offset_height / tile_factor;
	vec4 reflection_color = texture(SCREEN_TEXTURE, reflection_uvs);
	vec4 water_color = texture(diffuse_texture, UV * scale_y + final_waves_uvs) * water_tint;
	float transition = texture(transition_gradient, vec2(1.0 - UV.y, 1.0)).r;
	COLOR = mix(water_color, reflection_color, transition * reflection_intensity);
}
