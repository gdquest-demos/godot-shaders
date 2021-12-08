shader_type canvas_item;

uniform vec2 scale = vec2(10.0);
uniform bool seamless = false;

vec2 rand2(vec2 coord) {
	return fract(sin(vec2(dot(coord, vec2(127.1, 311.7)), dot(coord, vec2(269.5, 183.3)))) 
			* 43758.5453);
}

float voronoi_noise(vec2 coord) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	float min_dist = 999999.0;
	for (float x = -1.0; x <= 1.0; ++x) {
		for (float y = -1.0; y <= 1.0; ++y) {
			vec2 node = rand2(i + vec2(x, y)) + vec2(x, y);
			
			float dist = sqrt(pow((f - node).x, 2) + pow((f - node).y, 2));
			min_dist = min(min_dist, dist);
		}
	}
	
	return min_dist;
}

void fragment() {
	vec2 coord = UV * scale;
	
	float value = voronoi_noise(coord);
	
	COLOR = vec4(vec3(value), 1.0);
}