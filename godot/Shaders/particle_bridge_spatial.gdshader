// ANCHOR: setup
shader_type spatial;

uniform float oscillation_size = 0.2;

// Share CUSTOM data between the vertex() and fragment() functions. 
varying float normalized_distance;
varying float ascend_factor;
// END: setup
// Four curves for controlling scale and position animation on ascent and descent
uniform sampler2D y_curve_ascend;
uniform sampler2D y_curve_descend;
uniform sampler2D xz_curve_ascend;
uniform sampler2D xz_curve_descend;

uniform vec4 emission_color: source_color;
uniform vec4 albedo_color: source_color;

// ANCHOR: rand
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
// END: rand
// ANCHOR: instance
void vertex() {
	// In INSTANCE_CUSTOM we stored the following data:
	// x: desired height of the particle (0 -> 1)
	float distance_factor = INSTANCE_CUSTOM.x;
	// y: normalized distance to the character (0 -> 1)
	normalized_distance = INSTANCE_CUSTOM.y;
	// z: is the particle ascending or descending (ascending 1 or descending 0)
	ascend_factor = INSTANCE_CUSTOM.z;
// END: instance
// ANCHOR: oscillation
	// We add a small oscillation to the particles, randomized by the instance ID of the particle
	// note that because we place particles in a grid, we could observe repeating patterns.
	// Try to change the 133.0 below with different numbers and observe what happens!
	// pow is used to create a steeper curve of influence for the oscillation
	VERTEX.y += sin(TIME + float(rand_from_seed(INSTANCE_ID) * 133.0)) 
			* pow(normalized_distance, 3.0) * oscillation_size;
// END: oscillation
// ANCHOR: y_offset
	// Sample y-offset curve for when we are ascending and descending
	float y_ascend = texture(y_curve_ascend, vec2(distance_factor)).r;
	float y_descend = texture(y_curve_descend, vec2(distance_factor)).r;
	// Mix based on the descend_factor property. Note it's either 0.0 or 1.0.
	VERTEX.y += mix(y_descend, y_ascend, ascend_factor);
// END: y_offset
// ANCHOR: scale
	// We want also to control the scale of the particles in the bridge for ascent and descent
	float xz_scale_ascend = texture(xz_curve_ascend, vec2(distance_factor)).r;
	float xz_scale_descend = texture(xz_curve_descend, vec2(distance_factor)).r;
	VERTEX.xz *= mix(xz_scale_descend, xz_scale_ascend, ascend_factor);
// END: scale
}

// ANCHOR: fragment
void fragment() {
	ALBEDO = albedo_color.rgb;
	// Smoothstep and raise to a power to make space around the character without glow
	float emission_ascend = pow(smoothstep(0.0, 0.7, normalized_distance), 4.0);
// END: fragment
// ANCHOR: emission
	// The descend_factor removes the glow where particles drop during descent
	EMISSION = emission_color.rgb * emission_ascend * ascend_factor * 3.0;
// END: emission
}