shader_type spatial;

uniform float wave_size = 1.0;
uniform float face_distortion = 0.5;
uniform vec2 time_scale = vec2(0.3, 0.0);
uniform vec2 uv_offset_scale = vec2(-0.2, -0.1);

uniform sampler2D uv_offset_texture : hint_black; 

void vertex() {
	// Sample Noise
	vec2 base_uv_offset = UV * uv_offset_scale;
	base_uv_offset += TIME * time_scale;
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
	base_uv_offset += TIME * time_scale;
	float noise = texture(uv_offset_texture, base_uv_offset).r;
	// Display noise. Blue for valleys, green for peaks
	ALBEDO = vec3(0.0, noise, 1.0 - noise);
	// Display dampening. Red is full dampening, blue is none
	//ALBEDO = vec3(1.0 - UV.x, 0.0, UV.x);
}