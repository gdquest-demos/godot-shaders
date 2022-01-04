// ANCHOR: all
shader_type spatial;

// mask texture for the snow/dirt mix
uniform sampler2D mask_texture: hint_white;
// in-world area covered by the mask texture
uniform vec2 mask_texture_world_size = vec2(16.0);
// ANCHOR: textures
uniform sampler2D snow_texture: hint_albedo;
uniform sampler2D snow_texture_normal: hint_normal;
uniform sampler2D snow_texture_roughness;
uniform sampler2D dirt_texture: hint_albedo;
uniform sampler2D dirt_texture_normal: hint_normal;
uniform sampler2D dirt_texture_roughness;
uniform sampler2D blend_texture;
// ANCHOR: textures
uniform float snow_height = 0.3;
uniform float snow_sharpness: hint_range(0.3, 20.0, 0.1) = 3.0;
uniform vec2 textures_tiling = vec2(4.0);

varying vec2 world_uv;

void vertex() {
	float height = 1.0 - texture(mask_texture, UV).a;
	VERTEX.y += snow_height * height;
	// ANCHOR: increment
	vec2 texture_increment = 1.0 / vec2(textureSize(mask_texture, 0));
	// END: increment
	// ANCHOR: neighbour_sample
	// Approximate derivative along the z axis
	float height_up = 1.0 - texture(mask_texture, UV + vec2(0.0, texture_increment.y)).a;
	float height_down = 1.0 - texture(mask_texture, UV + vec2(0.0, -texture_increment.y)).a;
	// Approximate derivative along the x axis
	float height_left = 1.0 - texture(mask_texture, UV + vec2(-texture_increment.x, 0.0)).a;
	float height_right = 1.0 - texture(mask_texture, UV + vec2(texture_increment.x, 0.0)).a;
	// END: neighbour_sample
	// ANCHOR: lighting
	BINORMAL = normalize(vec3(1.0, height_right - height_left, 0.0));
	TANGENT = normalize(vec3(0.0, height_up - height_down, 1.0));
	NORMAL = normalize(cross(TANGENT, BINORMAL));
	// END: lighting
}

void fragment() {
	// ANCHOR: sampling
	vec2 world_uv_tiled = UV * textures_tiling;
	float mask = 1.0 - texture(mask_texture, UV).a;
	vec4 snow_color = texture(snow_texture, world_uv_tiled);
	vec4 dirt_color = texture(dirt_texture, world_uv_tiled);
	vec3 snow_normal = texture(snow_texture_normal, world_uv_tiled).rgb;
	vec3 dirt_normal = texture(dirt_texture_normal, world_uv_tiled).rgb;
	float snow_rougness = texture(snow_texture_roughness, world_uv_tiled).r;
	float dirt_roughness = texture(dirt_texture_roughness, world_uv_tiled).r;
	float noise_interp = texture(blend_texture, world_uv_tiled * 0.7).r;
	// END: sampling 
	// ANCHOR: overlay
	// overlay overlay_blend_mode
	float snow_interp = mix(
		mask * noise_interp * 2.0,
		1.0 - 2.0 * (1.0 - mask) * (1.0 - noise_interp),
		step(0.5, mask));
	// END: overlay_blend_mode
	// ANCHOR: sanitize
	snow_interp = 1.0 - pow(1.0 - snow_interp, snow_sharpness);
	snow_interp = clamp(snow_interp, 0.0, 1.0);
	// END: sanitize
	// ANCHOR: mix
	ALBEDO = mix(dirt_color.rgb, snow_color.rgb, snow_interp);
	NORMALMAP = mix(dirt_normal, snow_normal, snow_interp);
	ROUGHNESS = mix(dirt_roughness, snow_rougness, snow_interp);
	// END: mix
}
// END: all