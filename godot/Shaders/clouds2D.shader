// Blends two noise textures to create a layer of animated shadows over the game world.
// Expects the first noise to be assigned to the node's Texture property,
// and the second noise texture is the noise_texture2 uniform.
shader_type canvas_item;
render_mode blend_mul;

uniform vec4 tint : hint_color = vec4(0.0);
uniform sampler2D noise_texture_2 : hint_black;
uniform sampler2D gradient_texture : hint_black;

uniform vec2 scroll_direction_1 = vec2(0.7, -0.7);
uniform float time_scale_1 : hint_range(0.001, 0.25) = 0.012;
uniform float tile_factor_1 : hint_range(0.1, 3.0) = 0.6;

uniform vec2 scroll_direction_2 = vec2(0.75, 0.25);
uniform float time_scale_2 : hint_range(0.001, 0.25) = 0.005;
uniform float tile_factor_2 : hint_range(0.1, 3.0) = 0.3;

void fragment() {
	vec2 noise_2_uv = UV * tile_factor_2 + scroll_direction_2 * TIME * time_scale_2;
	float noise_2 = texture(noise_texture_2, noise_2_uv).r;
	
	vec2 noise_1_uv = UV * tile_factor_1 + scroll_direction_1 * TIME * time_scale_1;
	float noise_1 = texture(TEXTURE, noise_1_uv + noise_2 * 0.02).r;
	
	float clouds = texture(gradient_texture, vec2(noise_1, 0.0)).r;
	COLOR.rgb = mix(vec3(1.0), tint.rgb, clouds * tint.a);
}