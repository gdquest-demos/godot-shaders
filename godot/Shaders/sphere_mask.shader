shader_type spatial;
render_mode cull_disabled, ambient_light_disabled;

uniform vec3 mask_center = vec3(0.0);
uniform float mask_radius = 5.0;
uniform float mask_border_radius = 0.1;

uniform float emission_energy = 3.0;

uniform sampler2D ghost_noise;
uniform vec4 object_color: hint_color = vec4(1.0);
uniform vec4 mask_color: hint_color = vec4(1.0);

float mix_overlay(float a, float b) {
	return mix(
			a * b * 2.0,
			1.0 - 2.0 * (1.0 - a) * (1.0 - b),
			step(0.5, a));
}

void fragment() {
	// Calculate the camera center in view space for the discard
	vec3 camera_mask_center = (inverse(CAMERA_MATRIX) * vec4(mask_center, 1.0)).xyz;
	// Calculate the world space coordinates to be used as UVs of the noise
	vec3 world_space_vert = (CAMERA_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	// Here's the magic! We don't want to draw things outside of the
	// sphere of influence of our mask.
	if (length(VERTEX - camera_mask_center) >= mask_radius){
		discard;
	}
	
	// We want to add a magical effect at the border of the spherical mask, so we combine
	// noise with a fading ring (border_value) and then step it to decide where to place the
	// magical glow
	float noise_value = texture(ghost_noise, world_space_vert.xz + vec2(TIME, 0.0)).g;
	float border_value = smoothstep(
			0.0, 
			mask_border_radius,
			length(camera_mask_center - VERTEX) - mask_radius + mask_border_radius);
	
	noise_value = mix_overlay(border_value, noise_value);
	noise_value = step(0.7, noise_value);
	
	// Magic part two! In order to make things look "solid" we color the backfaces with the same emissive
	// material that we use for the border
	float front_facing = float(FRONT_FACING);
	float is_mask = front_facing * noise_value + (1.0 - front_facing);
	
	// because Godot adds emission on top of albedo, it looks strange if the
	// albedo is not the same color as emission.
	ALBEDO = mix(object_color.rgb, mask_color.rgb, is_mask);
	EMISSION = mix(vec3(0.0), emission_energy * mask_color.rgb, is_mask);
}