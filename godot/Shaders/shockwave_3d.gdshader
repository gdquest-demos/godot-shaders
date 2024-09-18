shader_type spatial;
render_mode world_vertex_coords, cull_disabled;

/** The center of the shockwave, in world coordinates.
* Set automatically by script.
*/
uniform vec3 shockwave_origin;

uniform float shockwave_radius = 1.0;
/** Percent completion of the shockwave.
* Set automatically by script.
*/
uniform float shockwave_percentage : hint_range(0, 1);
/** Width of the shockwave. */
uniform float shockwave_width = 1.0;
/** Strength of the shockwave. Affects how far the vertices are offset. */
uniform float shockwave_strength: hint_range(0.0, 2.0) = 0.5;
/** Albedo texture. Base color.*/
uniform sampler2D albedo_texture : source_color;

void vertex() {
	vec3 to_origin = (VERTEX.xyz - shockwave_origin);

	float max_effective_distance = shockwave_percentage * shockwave_radius;
	float min_effective_distance = max(0, max_effective_distance - shockwave_width);

	float distance_to_origin = length(to_origin);
	float effective_distance = smoothstep(
			min_effective_distance,
			max_effective_distance - shockwave_width / 2.0,
			distance_to_origin);
	effective_distance *= (1.0 - smoothstep(
			max_effective_distance,
			max_effective_distance + shockwave_width / 2.0,
			distance_to_origin));

	VERTEX += normalize(to_origin) * effective_distance * shockwave_strength;
}

void fragment() {
	ALBEDO = texture(albedo_texture, UV).rgb;
}