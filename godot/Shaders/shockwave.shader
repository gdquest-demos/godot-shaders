shader_type canvas_item;

uniform float torus_thickness : hint_range(0.001, 1.0) = 0.5;
uniform float torus_hardness = 1.0;
uniform float torus_radius = 1.0;
uniform float torus_invert : hint_range(-1.0, 1.0) = 0.0;
uniform vec2 torus_center = vec2(0.5, 0.5);
uniform vec2 torus_size = vec2(1.0, 1.0);

uniform float displacement_amount;

void fragment() {
	// Mask
	float torus_distance = length((UV - torus_center) * torus_size);
	float radius_distance = torus_thickness / 2.0;
	float inner_radius = torus_radius - radius_distance;
	
	float circle_value = clamp(abs(torus_distance - inner_radius) / torus_thickness, 0.0, 1.0);
	float circle_alpha = pow(circle_value, pow(torus_hardness, 2.0));
	
	float mask = abs(clamp(abs(sign(torus_invert)) - sign(torus_invert), 0.0, 1.0) - circle_alpha) 
			* abs(torus_invert);
	
	// Displace
	vec2 displacement_uv = UV + mask * displacement_amount;
	
	vec4 distorted_color = texture(TEXTURE, displacement_uv);
	
	COLOR = distorted_color;
}