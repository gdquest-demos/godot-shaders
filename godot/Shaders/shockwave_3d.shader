shader_type spatial;
render_mode world_vertex_coords, cull_disabled;

uniform vec3 shockwave_origin;
uniform float shockwave_radius = 1.0;
uniform float shockwave_percentage : hint_range(0, 1);
uniform float shockwave_width = 1.0;
uniform float shockwave_strength = 0.25;
uniform sampler2D color_texture: hint_albedo;

void vertex() {
	vec3 to_origin = (VERTEX.xyz - shockwave_origin);
	
	float max_effective_distance = shockwave_percentage * shockwave_radius;
	float min_effective_distance = max(0, max_effective_distance - shockwave_width);
	
	float distance_to_origin = length(to_origin);
	float effective_distance = smoothstep(min_effective_distance, max_effective_distance-shockwave_width/2.0, distance_to_origin) * (1.0 - smoothstep(max_effective_distance, max_effective_distance+shockwave_width/2.0, distance_to_origin));
	
	VERTEX += normalize(to_origin) * effective_distance * shockwave_strength;
}

void fragment() {
	ALBEDO = texture(color_texture, UV).rgb;
}