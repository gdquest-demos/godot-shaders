shader_type spatial;
// Disable culling so the flag is visible from both sides.
render_mode cull_disabled;

uniform bool display_dampening = false;
uniform bool display_deformation = false;

uniform vec4 flag_color: source_color = vec4(1.0);
uniform float wave_size: hint_range(0.0, 2.0) = 0.5;
uniform float face_distortion: hint_range(0.0, 1.0) = 0.5;
uniform float time_scale: hint_range(0.0, 1.0) = 0.3;
uniform vec2 uv_offset_scale = vec2(-0.2, -0.1);

uniform sampler2D uv_offset_texture : hint_default_black;

void vertex() {
	// Sample Noise
	vec2 base_uv_offset = UV * uv_offset_scale;
	base_uv_offset += TIME * time_scale * vec2(1.0, 0.0);
	float noise = texture(uv_offset_texture, base_uv_offset).r;

	// Calculate offset and convert from 0.0 <=> 1.0 to -1.0 <=> 1.0
	float texture_based_offset = noise * 2.0 - 1.0;
	// Apply amplitude and dampening
	texture_based_offset *= wave_size;
	texture_based_offset *= UV.x;

	VERTEX.y += texture_based_offset;
	// Distort the face to give impression of conserving shape
	VERTEX.z += texture_based_offset * face_distortion;
	VERTEX.x += texture_based_offset * -face_distortion;
}

void fragment() {
	vec2 base_uv_offset = UV * uv_offset_scale;
	base_uv_offset += TIME * time_scale * vec2(1.0, 0.0);
	float noise = texture(uv_offset_texture, base_uv_offset).r;

	if (display_deformation == true) {
		// Display noise. Blue for valleys, green for peaks
		ALBEDO = vec3(0.0, noise, 1.0 - noise);
	}
	else if (display_dampening == true) {
		// Display dampening. Red is full dampening, blue is none
		ALBEDO = vec3(1.0 - UV.x, 0.0, UV.x);
	}
	else {
		ALBEDO = flag_color.rgb;
	}
}