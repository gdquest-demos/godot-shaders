// ANCHOR: all
// ANCHOR: setup
shader_type spatial;
render_mode cull_disabled, ambient_light_disabled;

uniform vec3 mask_center = vec3(0.0);
uniform float mask_radius = 5.0;
// END: setup
uniform vec4 object_color: source_color = vec4(1.0);
uniform vec4 mask_color: source_color = vec4(1.0);


uniform float mask_border_radius = 0.1;
uniform float emission_energy = 3.0;

uniform sampler2D ghost_noise;

// ANCHOR: overlay
float mix_overlay(float a, float b) {
	return mix(
			a * b * 2.0,
			1.0 - 2.0 * (1.0 - a) * (1.0 - b),
			step(0.5, a));
}
// END: overlay
// ANCHOR: vert
void fragment() {
	// Calculate the world space coordinates of the vertex
	vec3 world_space_vert = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
// END: vert
// ANCHOR: discard
	float view_space_distance = length(mask_center - world_space_vert);
	
	// Here's the magic! Don't draw anything outside of the sphere of influence of our mask
	if (view_space_distance >= mask_radius) {
		discard;
	}
// END: discard
// ANCHOR: scroll
	world_space_vert.x += TIME;
	float noise_value = texture(ghost_noise, world_space_vert.xz).r;
// END: scroll
// ANCHOR: smoothstep
	// Find the area bordering the spherical mask with the mask_border_radius
	float border_value = smoothstep(
			0.0, 
			mask_border_radius,
			mask_border_radius + view_space_distance - mask_radius);
// END: smoothstep
// ANCHOR: mix_overlay
	// Overlay blend increases values where the noise and border overlap
	float mask_value = mix_overlay(border_value, noise_value);
// END: mix_overlay
// ANCHOR: step
	// Wherever the mask_value exceeds 0.7 return 1.0, otherwise return 0.0
	mask_value = step(0.7, mask_value);
// END: step
// ANCHOR: front_facing
	// Magic part two! To make things look "solid" include the backfaces in the mask
	if (!FRONT_FACING) {
		mask_value = 1.0;
	}
// END: front_facing
	
	// Use this mask_value to control the color and emission of the fragment
	// Emission is added on top of albedo, so set albedo to the same color
// ANCHOR: albedo
	ALBEDO = mix(object_color.rgb, mask_color.rgb, mask_value);
// END: albedo
// ANCHOR: emission
	EMISSION = emission_energy * mask_color.rgb * mask_value;
// END: emission
}
// END: all