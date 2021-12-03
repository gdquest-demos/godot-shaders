shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform sampler2D tex_1_albedo: hint_albedo;
// Ambient occlusion, roughness, metalness
uniform sampler2D tex_1_ao: hint_black;
uniform sampler2D tex_1_normal : hint_normal;
uniform sampler2D tex_2_albedo: hint_albedo;
uniform sampler2D tex_2_normal : hint_normal;
uniform float blend_smoothness : hint_range(0.1, 1.0, 0.01) = 0.2;
uniform float threshold : hint_range(0.1, 1.0, 0.01) = 0.0;
uniform bool additive_mix = false;
uniform bool use_red_vertex_color = true;
uniform bool use_ao_occlusion = false;
uniform bool use_world_direction = false;
uniform vec3 world_direction = vec3(0.0, 1.0, 0.0);

void fragment() {
	// sample all the textures
	vec4 albedo_1 = texture(tex_1_albedo, UV);
	vec4 albedo_2 = texture(tex_2_albedo, UV);
	vec3 normal_1 = texture(tex_1_normal, UV).rgb;
	vec3 normal_2 = texture(tex_2_normal, UV).rgb;
	float ao = texture(tex_1_ao, UV).r;
	float mix_factor = 0.0;
	float addends = 0.0;
	if (use_red_vertex_color) {
		mix_factor += COLOR.r;
		addends += 1.0;
	}
	if (use_world_direction) {
		// textures are from 0 to 1, but we want the normals to be able to go negative.
		vec3 unpacked_normal = normal_1 * 2.0 - vec3(1.0);
		unpacked_normal.z = sqrt(max(0.0, 1.0 - dot(unpacked_normal.xy, unpacked_normal.xy)));
		// Binormal and tangent vectors are what allows us to transform the
		// 2D normalmaps into something that can interact with 3D space
		vec3 world_tangent = (CAMERA_MATRIX * vec4(TANGENT, 0.0)).xyz;
		vec3 world_binormal = (CAMERA_MATRIX * vec4(BINORMAL, 0.0)).xyz;
		vec3 world_normal = (CAMERA_MATRIX * vec4(NORMAL, 0.0)).xyz;
		// Normal mixing taken directly from Godot's spatial shader (drivers/gles3/shaders/spatial.glsl)
		vec3 normalmap_normal = normalize(unpacked_normal.y * world_tangent + unpacked_normal.x 
				* world_binormal + world_normal * unpacked_normal.z);
		
		// the more the world-space normal is aligned to the given vector,
		// the more we want to show the second texture.
		mix_factor += clamp(
				dot(normalmap_normal, world_direction)
				, 0.0, 1.0);
		
		addends += 1.0;
	}
	if (use_ao_occlusion) {
		mix_factor += 1.0 - ao;
		addends += 1.0;
	}
	
	// If we don't use additive mix, we do an average of the components.
	if (!additive_mix) {
		mix_factor /= addends;
	}

	// This part makes the mix factor more crisp than a bland mix between zero and one.
	// threshold allows us to cut away more of the second texture, while smoothness defines
	// the crispiness of the edges of the blending. The smoother the blending, the more diluted
	// and blended the textures will look like.
	// It would be interesting to use the displacement map of the second texture as a small
	// boost to the mix_factor, so that blending can follow the shapes in the second texture.
	// Here are the textures: https://cc0textures.com/view?id=Moss003
	// Have fun!
	mix_factor = smoothstep(0.0, blend_smoothness, mix_factor - threshold);

	NORMALMAP = mix(normal_1, normal_2, mix_factor);
	ALBEDO = clamp(mix(albedo_1, albedo_2, mix_factor).rgb, vec3(0.0), vec3(1.0));

}