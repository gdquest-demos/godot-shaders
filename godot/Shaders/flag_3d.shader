shader_type spatial;

uniform float wave_size = 1.0;
uniform float face_distortion = 0.5;
uniform vec2 time_scale = vec2(0.3, 0.0);
uniform vec2 uv_offset_scale = vec2(-0.2, -0.1);

uniform sampler2D uv_offset_texture : hint_black; 


void vertex(){
	// Sample Noise
	vec2 base_uv_offset = UV * uv_offset_scale;
	base_uv_offset += TIME * time_scale;
	float noise = texture(uv_offset_texture, base_uv_offset).r;
	
	// Calculate offset
	float texture_based_offset = noise * 2.0 - 1.0; // Convert from 0.0 <=> 1.0 to -1.0 <=> 1.0
	texture_based_offset *= wave_size; // Apply amplitude
	
	texture_based_offset *= UV.x; // Apply dampening
	
	VERTEX.y += texture_based_offset;
	
	VERTEX.z += texture_based_offset * face_distortion; // Distort the face to give impression of conserving shape
	VERTEX.x += texture_based_offset * -face_distortion;
}


void fragment(){
	// Sample noise
	vec2 base_uv_offset = UV * uv_offset_scale;
	base_uv_offset += TIME * time_scale;
	float noise = texture(uv_offset_texture, base_uv_offset).r;
	
	ALBEDO = vec3(0.0, noise, 1.0 - noise); //Display noise. Blue for valleys, green for peaks
	//ALBEDO = vec3(1.0 - UV.x, 0.0, UV.x); //Display dampening. Red is full dampening, blue is none
}