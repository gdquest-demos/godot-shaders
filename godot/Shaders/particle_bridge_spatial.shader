shader_type spatial;

uniform sampler2D y_curve_ascend;
uniform sampler2D y_curve_descend;
uniform sampler2D xz_curve_ascend;
uniform sampler2D xz_curve_descend;
uniform vec4 emission_color: hint_color;
uniform vec4 albedo_color: hint_color;
uniform float oscillation_size = 0.2;

varying float normalized_distance;
varying float descend_factor;
varying float descend_percent;
varying float y_coord;

// Randomization functions, taken directly from the built-in particle shader
float rand_from_seed(int seed) {
	int k;
	int s = int(seed);
	if (s == 0) {
		s = 305420679;
	}
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	if (s < 0) {
		s += 2147483647;
	}
	seed = s;
	return float(seed % 65536) / 65535.0;
}

uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

void vertex() {
	// In INSTANCE_CUSTOM we stored the following data:
	// x: desired height of the particle (0, 1)
	// y: normalized distance to the character (0, 1)
	// z: is the particle ascending or descending (descending -1, ascending 1, none 0)
	float distance_factor = INSTANCE_CUSTOM.x;
	float ascend = step(0.5, INSTANCE_CUSTOM.z * 0.5 + 0.5);
	// y offset curve for when we are ascending/descending
	float y_ascend = texture(y_curve_ascend, vec2(distance_factor)).r;
	float y_descend = texture(y_curve_descend, vec2(distance_factor)).r;
	// Mix y offset based on the ascend property. Note that "ascend" is
	// assigned either to 0 or 1 by using step at aline 43.
	VERTEX.y += mix(y_descend, y_ascend, ascend);
	// Similarly for the y offset, we want also to control the scale of the particles in the bridge
	// to give it a more snappy motion
	float xz_scale_ascend = texture(xz_curve_ascend, vec2(distance_factor)).r;
	float xz_scale_descend = texture(xz_curve_descend, vec2(distance_factor)).r;
	VERTEX.xz *= mix(xz_scale_descend, xz_scale_ascend, ascend);
	// We add a small oscillation to the particles, randomized by the instance ID of the particle
	// note that because we place particles in a grid, we could observe repeating patterns.
	// Try to change the 133.0 below with different numbers and observe what happens!
	// pow is used to create a steeper curve of influence for the oscillation
	VERTEX.y += sin(TIME + float(rand_from_seed(INSTANCE_ID) * 133.0)) 
			* pow(INSTANCE_CUSTOM.y, 3.0) * oscillation_size;
	
	normalized_distance = INSTANCE_CUSTOM.y * (step(INSTANCE_CUSTOM.y, 0.99));
	descend_factor = ascend;
	descend_percent = INSTANCE_CUSTOM.x;
}

void fragment() {
	ALBEDO = albedo_color.rgb;
	vec3 emission_ascend = emission_color.rgb * clamp(
			pow(smoothstep(0.0, 0.7,normalized_distance), 4.0), 0.0, 1.0);
	
	vec3 emission_descend = emission_color.rgb * descend_factor;
	EMISSION =  mix(emission_descend, emission_ascend, descend_factor) * 3.0;
}