shader_type canvas_item;

uniform vec2 scale = vec2(10.0);

float rand(vec2 coord) {
	return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 coord = UV * scale;
	
	float value = rand(coord);
	
	COLOR = vec4(vec3(value), 1.0);
}