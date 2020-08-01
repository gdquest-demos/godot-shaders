shader_type canvas_item;

uniform vec2 scale = vec2(10.0);

float rand(vec2 coord) {
	return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453);
}

float value_noise(vec2 coord) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	float t_l = rand(i);
	float t_r = rand(i + vec2(1, 0));
	float b_l = rand(i + vec2(0, 1));
	float b_r = rand(i + vec2(1));
	
	vec2 cubic = f * f * (3.0 - 2.0 * f);
	
	float top_mix = mix(t_l, t_r, cubic.x);
	float bot_mix = mix(b_l, b_r, cubic.x);
	float whole_mix = mix(top_mix, bot_mix, cubic.y);
	
	return whole_mix;
}

void fragment() {
	vec2 coord = UV * scale;
	
	float value = value_noise(coord);
	
	COLOR = vec4(vec3(value), 1.0);
}