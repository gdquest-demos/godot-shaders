// Blends two noise textures to create a layer of animated shadows over the game world.
// Expects the first noise to be assigned to the node's Texture property,
// and the second noise texture is the noise_texture2 uniform.
shader_type canvas_item;
render_mode blend_mul;

uniform vec4 tint :hint_color = vec4(0.0);
uniform sampler2D noise_texture2 :hint_black;
uniform sampler2D gradient_texture :hint_black;

uniform vec2 scroll_direction1 = vec2(0.7, -0.7);
uniform float time_scale1 :hint_range(0.001, 0.25) = 0.012;
uniform float tile_factor1 :hint_range(0.1, 3.0) = 0.6;

uniform vec2 scroll_direction2 = vec2(0.75, 0.25);
uniform float time_scale2 :hint_range(0.001, 0.25) = 0.005;
uniform float tile_factor2 :hint_range(0.1, 3.0) = 0.3;

void fragment() {
	vec2 noise2_uv = UV * tile_factor2 + scroll_direction2 * TIME * time_scale2;
	float noise2 = texture(noise_texture2, noise2_uv).r;
	
	vec2 noise1_uv = UV * tile_factor1 + scroll_direction1 * TIME * time_scale1;
	float noise1 = texture(TEXTURE, noise1_uv + noise2 * 0.02).r;
	
	float clouds = texture(gradient_texture, vec2(noise1, 0.0)).r;
	COLOR.rgb = mix(vec3(1.0), tint.rgb, clouds * tint.a);
}