shader_type spatial;
render_mode unshaded;

uniform vec4 deep_color : source_color;
uniform vec4 shallow_color : source_color = vec4(1);

uniform float refraction_speed = 0.25;
uniform float refraction_strength = 1.0;

uniform float foam_amount = 1.0;
uniform float foam_cutoff = 1.0;
uniform vec4 foam_color : source_color = vec4(1);

uniform float displacement_strength = 0.25;

uniform float depth_distance = 1.0;

uniform vec2 movement_direction = vec2(1,0);

uniform sampler2D refraction_noise : hint_normal;
uniform sampler2D foam_noise : hint_default_black;
uniform sampler2D displacement_noise : hint_default_black;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear_mipmap;

void vertex() {
	float displacement = textureLod(
			displacement_noise,
			UV + (TIME * movement_direction) * refraction_speed,
			0.0).r * 2.0 - 1.0;

	VERTEX.y += displacement * displacement_strength;
}

float depthToViewZ(mat4 projection_matrix, float depth, bool using_opengl) {
	if (projection_matrix[2][3] != -1.0) {
		return 0.0;
	}
	
	if (using_opengl) {
		// Normally, NDC.z has range [0, 1], but on the Compatibility renderer (based on OpenGL) it has range [-1, 1]
		depth = depth * 2.0 - 1.0;
	}

	// Apply the depth linearization formula
	return -projection_matrix[3][2] / (depth + projection_matrix[2][2]);
}

void fragment() {
	vec2 uv = SCREEN_UV + refraction_strength
			* (texture(refraction_noise, UV + (TIME * movement_direction) * refraction_speed).rg
			* 2.0 - 1.0);

	float real_depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;

	// Recreate linear depth of the intersecting geometry using projection matrix, and subtract the vertex of the sphere
	real_depth = VERTEX.z - depthToViewZ(PROJECTION_MATRIX, real_depth, OUTPUT_IS_SRGB);

	//if (OUTPUT_IS_SRGB) {
		//// Normally, NDC.z has range [0, 1], but on the Compatibility renderer (based on OpenGL) it has range [-1, 1]
		//real_depth = real_depth * 2.0 - 1.0;
	//}
	//
	//real_depth = PROJECTION_MATRIX[3][2] / (real_depth + PROJECTION_MATRIX[2][2]) + VERTEX.z;

	float depth = texture(DEPTH_TEXTURE, uv).r;
	
	
	// Recreate linear depth of the intersecting geometry using projection matrix, and subtract the vertex of the sphere
	depth = VERTEX.z - depthToViewZ(PROJECTION_MATRIX, depth, OUTPUT_IS_SRGB);

	//
	//if (OUTPUT_IS_SRGB) {
		//// Normally, NDC.z has range [0, 1], but on the Compatibility renderer (based on OpenGL) it has range [-1, 1]
		//depth = depth * 2.0 - 1.0;
	//}
	//
	//// Recreate linear depth of the intersecting geometry using projection matrix, and subtract the vertex of the sphere
	//depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]) + VERTEX.z;

	depth = max(depth, real_depth);

	float intersection = clamp(depth / foam_amount, 0, 1) * foam_cutoff;

	vec4 out_color = mix(shallow_color, deep_color, clamp((depth / depth_distance), 0, 1));
	vec4 scene_color = texture(SCREEN_TEXTURE, uv);
	out_color = mix(scene_color, out_color, out_color.a);

	vec3 foam = step(intersection,
			texture(foam_noise, UV + (TIME * movement_direction) * refraction_speed).rgb)
			* foam_color.rgb;

	ALBEDO = out_color.rgb + foam;
}