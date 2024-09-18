// This shader is based on Kenney's UnlitDirectionalTint shader https://gist.github.com/KenneyNL/802d7107fbe9bf42b16ec05b43b58079
shader_type spatial;
render_mode unshaded;

/** Albedo texture. Base color. */
uniform sampler2D albedo_texture: source_color;

/** The tint for the sides of the mesh along the global x-axis. */
uniform vec4 tint_x : source_color = vec4(.4, 0.6, 0.8, 1.0);
/** The tint for the top of the mesh along the global y-axis. */
uniform vec4 tint_y : source_color =  vec4(0.9, 0.9, 0.9, 1.0);
/** The tint for the sides of the mesh along the global z-axis. */
uniform vec4 tint_z : source_color =  vec4(0.6, 0.8, 0.7, 1.0);
/** Use this color to control the overall tint of the mesh after tinting per-axis. */
uniform vec4 overall_tint : source_color = vec4(1.0);

varying vec4 tint;

void vertex() {
	// In this shader, we use the world normal to mix the tints of the object.

	// Transform the normal from model space to world space.
	vec3 world_normal = (MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz;
	world_normal = normalize(world_normal);

	// Because we will use each component in a mix() function, we want to ensure
	// that they will be positive. We could use abs(), but using a power gives us
	// us a nice, non-linear curve.
	// We raise the normal to the power of two.
	world_normal = world_normal * world_normal;

	// Start with a neutral white, then mix in each world axis color.
	tint = mix(vec4(1.0), tint_y, world_normal.y);
	tint = mix(tint, tint_x, world_normal.x);
	tint = mix(tint, tint_z, world_normal.z);
	// Then, modulate by an overall tint.
	// This will be passed along to the fragment shader.
	tint = overall_tint * tint;
}

void fragment() {
	ALBEDO = tint.rgb * texture(albedo_texture, UV).rgb;
}
