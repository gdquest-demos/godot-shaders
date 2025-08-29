shader_type spatial;

group_uniforms Snow;
/** Mask texture for the snow and dirt mix. This is the texture to which the game writes the ball trail. */
uniform sampler2D mask_texture: hint_default_white, repeat_disable, filter_linear_mipmap;
/** In-world area covered by the mask texture, in meters. */
uniform vec2 mask_texture_world_size = vec2(16.0);
/** Height of the snow layer. */
uniform float snow_height = 0.3;
/** Controls the sharpness of the snow transition. Higher values make the transition from snow to dirt shorter. */
uniform float snow_sharpness: hint_range(0.3, 20.0, 0.1) = 3.0;
/** Tiling factor for the snow and dirt textures */
uniform vec2 textures_tiling = vec2(4.0);
group_uniforms;

group_uniforms PBRTextures;
/** Color texture for the snow */
uniform sampler2D snow_texture: source_color, filter_linear_mipmap;
/** Normal map texture for the snow */
uniform sampler2D snow_texture_normal: hint_normal, filter_linear_mipmap;
/** Roughness texture for the snow */
uniform sampler2D snow_texture_roughness: filter_linear_mipmap;
/** Color texture for the dirt */
uniform sampler2D dirt_texture: source_color, filter_linear_mipmap;
/** Normal map texture for the dirt */
uniform sampler2D dirt_texture_normal: hint_normal, filter_linear_mipmap;
/** Roughness texture for the dirt */
uniform sampler2D dirt_texture_roughness: filter_linear_mipmap;
/** Texture used for blending between snow and dirt */
uniform sampler2D blend_texture;
group_uniforms;

varying vec2 world_uv;

void vertex() {
	float height = 1.0 - texture(mask_texture, UV).a;
	VERTEX.y += snow_height * height;

	vec2 texture_increment = 1.0 / vec2(textureSize(mask_texture, 0));

	// Neighbor sample
	// Approximate derivative along the z axis
	float height_up = 1.0 - texture(mask_texture, UV + vec2(0.0, texture_increment.y)).a;
	float height_down = 1.0 - texture(mask_texture, UV + vec2(0.0, -texture_increment.y)).a;
	// Approximate derivative along the x axis
	float height_left = 1.0 - texture(mask_texture, UV + vec2(-texture_increment.x, 0.0)).a;
	float height_right = 1.0 - texture(mask_texture, UV + vec2(texture_increment.x, 0.0)).a;

	// Lighting
	BINORMAL = normalize(vec3(1.0, height_right - height_left, 0.0));
	TANGENT = normalize(vec3(0.0, height_up - height_down, 1.0));
	NORMAL = normalize(cross(TANGENT, BINORMAL));
}

void fragment() {
	// Sample textures.
	vec2 world_uv_tiled = UV * textures_tiling;
	float mask_snow_to_dirt = 1.0 - texture(mask_texture, UV).a;

	vec4 snow_color = texture(snow_texture, world_uv_tiled);
	vec4 dirt_color = texture(dirt_texture, world_uv_tiled);
	vec3 snow_normal = texture(snow_texture_normal, world_uv_tiled).rgb;
	vec3 dirt_normal = texture(dirt_texture_normal, world_uv_tiled).rgb;
	float snow_rougness = texture(snow_texture_roughness, world_uv_tiled).r;
	float dirt_roughness = texture(dirt_texture_roughness, world_uv_tiled).r;
	float noise_interp = texture(blend_texture, world_uv_tiled * 0.7).r;

	// Overlay blend
	float snow_interpolation = mix(
		mask_snow_to_dirt * noise_interp * 2.0,
		1.0 - 2.0 * (1.0 - mask_snow_to_dirt) * (1.0 - noise_interp),
		step(0.5, mask_snow_to_dirt));

	// Sanitize
	snow_interpolation = 1.0 - pow(1.0 - snow_interpolation, snow_sharpness);
	snow_interpolation = clamp(snow_interpolation, 0.0, 1.0);

	// Mix
	ALBEDO = mix(dirt_color.rgb, snow_color.rgb, snow_interpolation);
	NORMAL_MAP = mix(dirt_normal, snow_normal, snow_interpolation);
	ROUGHNESS = mix(dirt_roughness, snow_rougness, snow_interpolation);
}
