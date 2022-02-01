shader_type particles;
// Keep data is ESSENTIAL, otherwise the CUSTOM data resets when the particle dies.
// Also - ensure explosiveness on the particles is set to 1.0
render_mode keep_data;

// input character position
uniform vec3 character_position;

uniform float radius = 5.0;
uniform float animation_speed = 10.0;

// width and spacing of the bridge
uniform int bridge_width_particles = 12;
uniform float spacing = 0.3;


void vertex() {
	// Place the particles of the bridge in a grid
	TRANSFORM[3].x = float(INDEX % bridge_width_particles) * spacing;
	TRANSFORM[3].z = float(INDEX / bridge_width_particles) * spacing;
	// Find the distance from the character, normalized between zero and one.
	float distance_from_character = length(TRANSFORM[3].xz - character_position.xz);
	float distance_from_character_normalized = smoothstep(0.0, radius, distance_from_character);
	// We make the bridge appear faster than disappear
	float bridge_delta = 2.0 - 3.0 * distance_from_character_normalized;
	bridge_delta *=  DELTA * animation_speed;
	// Write all the data to CUSTOM to share it
	CUSTOM.x = clamp(CUSTOM.x + bridge_delta, 0.0, 1.0);
	CUSTOM.y = distance_from_character_normalized;
	CUSTOM.z = step(0.0, bridge_delta);
}