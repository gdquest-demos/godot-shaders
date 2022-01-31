shader_type particles;
// keep data is very important here, because otherwise the CUSTOM vector
// will reset when the particle dies, and it will be very obvious.
render_mode keep_data;

// input character position
uniform vec3 character_position;
// radius of the bridge
uniform float radius = 5.0;
// width of the bridge, in particles
uniform int bridge_width_particles = 12;
// bridge appearing speed
uniform float bridge_speed = 10.0;
// spacing between the particles
uniform float spacing = 0.3;


void vertex() {
	// Place the particles of the bridge in a grid
	TRANSFORM[3] = vec4(float(INDEX % bridge_width_particles) * spacing, 
			0.0, float(INDEX / bridge_width_particles) * spacing, 1.0);

	// In CUSTOM.x we accumulate the distance from the character, normalized between zero and one.
	// if the character is within the radius, we will increase
	float distance_from_character = length(TRANSFORM[3].xz - character_position.xz);
	float distance_from_character_normalized = smoothstep(0.0, radius, distance_from_character);
	// we make the bridge appear twice as fast as disappear
	float bridge_delta = 2.0 - 3.0 * distance_from_character_normalized;
	bridge_delta *=  DELTA * bridge_speed;
	
	// Write all the data to CUSTOM
	CUSTOM.x += bridge_delta;
	CUSTOM.x = clamp(CUSTOM.x, 0.0, 1.0);
	CUSTOM.y = distance_from_character_normalized;
	CUSTOM.z = sign(bridge_delta);
}