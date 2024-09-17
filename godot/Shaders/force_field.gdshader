shader_type spatial;
render_mode depth_draw_opaque, cull_disabled, ambient_light_disabled, blend_add, shadows_disabled;

group_uniforms ColorAndPattern;
/** Base color. */
uniform vec4 color : source_color;
/** The speed that the pattern scrolls. */
uniform float pattern_scroll_speed = 0.025;
/** The scale of the pattern. Bigger values make the hexagons smaller. */
uniform vec2 pattern_uv_scale = vec2(6.0, 3.0);
/** The texture of the pattern. */
uniform sampler2D pattern_texture : source_color;
group_uniforms;

group_uniforms Intensity;
/** The thickness of the edges. Higher values mean thinner edges. */
uniform float fresnel_power: hint_range(0.5, 8.0) = 4.0;
/** The intensity of the edges. Values over [code]1.0[/code] will glow, if you have Glow enabled on your environment.
*/
uniform float edge_intensity: hint_range(0.0, 2.0) = 1.5;
/** The intensity of the center. */
uniform float center_intensity : hint_range(0.0, 1.0) = 0.1;
group_uniforms;

group_uniforms Pulsing;
/** Magnitude of the pulsing effect.
* This is the amplitude of the sine wave used to move the vertices. The pulsing is additive and done in model space, so if you scale the mesh or the mesh instance, you'll need to adjust this value.
*/
uniform float pulsing_strength = 0.25;
/** Speed of the pulsing effect. Higher values are faster.
* The frequency of the sine wave used to move the vertices.
*/
uniform float pulsing_speed = 1.0;
group_uniforms;

group_uniforms Scanlines;
/** The frequency of the scanline effect. Higher values mean the scanlines repeat more often.
*/
uniform float scanline_frequency = 0.5;
/** The width of the scanlines. */
uniform float scanline_width : hint_range(0, 0.5) = 0.1;
/** The intensity (brightness) of the scanlines. */
uniform float scanline_intensity = 0.35;
group_uniforms;

uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear_mipmap;

void vertex() {
	float pulse_distance = sin(TIME * pulsing_speed) * 0.1 * pulsing_strength;
	VERTEX += NORMAL * pulse_distance;
}

float get_linear_depth(sampler2D depth_texture, vec2 screen_uv, mat4 inv_projection_matrix, bool use_opengl_ndc) {
	float depth_raw = texture(depth_texture, screen_uv).x;
	vec3 ndc;
	if (use_opengl_ndc){
		// Compatibility. Uses OpenGL NDC space: range of [-1,1] for NDC.xy, range of [-1,1] for NDC.z
		ndc = vec3(screen_uv, depth_raw) * 2.0 - 1.0;
	} else {
		// Forward+ or Mobile. Uses Vulkan NDC space: range of [-1,1] for NDC.xy, range of [0,1] for NDC.z
		ndc = vec3(screen_uv * 2.0 - 1.0, depth_raw);
	}
	vec4 position_view = inv_projection_matrix * vec4(ndc, 1.0);
	position_view.xyz /= position_view.w;
	return -position_view.z;
}

void fragment() {
	// Create a fresnel effect from the NORMAL and VIEW vectors.
	float fresnel = pow(1.0 - dot(NORMAL, VIEW), fresnel_power) * edge_intensity;

	// Add back transparency in the middle
	fresnel = fresnel + center_intensity;

	// Get the linear depth.
	float depth = get_linear_depth(DEPTH_TEXTURE, SCREEN_UV, INV_PROJECTION_MATRIX, OUTPUT_IS_SRGB);

	// Get the difference between the linear depth and the fragment's linear depth.
	// VERTEX is the interpolated position of each fragment, in view space.
	// VERTEX.z is the linear depth of each fragment.
	depth = depth + VERTEX.z;

	// Intensity intersection effect
	depth = pow(1.0 - clamp(depth, 0, 1), fresnel_power) * edge_intensity;

	// Calculate final alpha using fresnel and depth joined together.
	fresnel = fresnel + depth;

	// Calculate UV scrolling pattern.
	float scrolling_time = TIME * pattern_scroll_speed;
	vec4 pattern = texture(pattern_texture, (UV * pattern_uv_scale) + vec2(scrolling_time));

	// Use pattern to cut holes in alpha.
	fresnel *= pattern.r;

	float uv_offset = mod(-TIME * scanline_frequency, 2.0) - 1.0;
	float scanline = smoothstep(0.5 - scanline_width, 0.5, UV.y + uv_offset)
			* (1.0 - smoothstep(0.5, 0.5 + scanline_width, UV.y + uv_offset)) * pattern.r;

	// Apply final color.
	ALBEDO = vec3(0);
	EMISSION = color.rgb;
	ALPHA = smoothstep(0.0, 1.0, fresnel + scanline * scanline_intensity);
}
