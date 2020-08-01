shader_type canvas_item;

uniform vec2 scale = vec2(10.0);
uniform bool seamless = false;

float rand(vec2 coord) {
	return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453);
}

float perlin_noise(vec2 coord) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	float t_l = rand(i) * 6.283;
	float t_r = rand(i + vec2(1, 0)) * 6.283;
	float b_l = rand(i + vec2(0, 1)) * 6.283;
	float b_r = rand(i + vec2(1)) * 6.283;
	
	vec2 t_l_vec = vec2(-sin(t_l), cos(t_l));
	vec2 t_r_vec = vec2(-sin(t_r), cos(t_r));
	vec2 b_l_vec = vec2(-sin(b_l), cos(b_l));
	vec2 b_r_vec = vec2(-sin(b_r), cos(b_r));
	
	float t_l_dot = dot(t_l_vec, f);
	float t_r_dot = dot(t_r_vec, f - vec2(1, 0));
	float b_l_dot = dot(b_l_vec, f - vec2(0, 1));
	float b_r_dot = dot(b_r_vec, f - vec2(1));
	
	vec2 cubic = f * f * (3.0 - 2.0 * f);
	
	float top_mix = mix(t_l_dot, t_r_dot, cubic.x);
	float bot_mix = mix(b_l_dot, b_r_dot, cubic.x);
	float whole_mix = mix(top_mix, bot_mix, cubic.y);
	
	return whole_mix + 0.5;
}

void fragment() {
	vec2 coord = UV * scale;
	
	float value = perlin_noise(coord);
	
	COLOR = vec4(vec3(value), 1.0);
}