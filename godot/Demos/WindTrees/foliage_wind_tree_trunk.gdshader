shader_type spatial;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color;
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_normal : hint_normal;
uniform float normal_scale : hint_range(-16,16);

uniform float tree_height = 10.0;
uniform float wind_angle : hint_range(0, 360);

uniform float wind_strength : hint_range(0.0, 4.0) = 1.0;
uniform float wind_frequency : hint_range(0.0, 4.0) = 1.0;
uniform float wind_speed : hint_range(0.0, 4.0) = .25;
uniform float stretch_correction : hint_range(0.0, 0.1) = 0.01;

uniform sampler2D texture_wind_noise : hint_default_black;

float rand(vec3 p) {
	return fract(sin(dot(p,vec3(127.1,311.7, 74.7)))*43758.5453123);
}

vec3 rotate (vec3 v, vec3 n, float a) { 
	return v * cos(a) + cross(n, v) * sin(a) + n * dot(n, v) * (1. - cos(a)); 
}

void vertex() {
	vec3 obj_pos = (MODEL_MATRIX * vec4(0, 0, 0, 1)).xyz;
	float seed = rand(obj_pos);
	
	vec3 wind_vector_world = vec3(1.0, 0.0, 0.0);
	
	wind_vector_world = rotate(wind_vector_world, vec3(0.0, 0.0, 1.0), (cos(TIME * 4.0 + seed * 6.28) * 4.0) * 0.01745329251);
	wind_vector_world = rotate(wind_vector_world, vec3(0.0, 1.0, 0.0), (wind_angle + sin(TIME * 4.0 + seed * 6.28) * 4.0) * 0.01745329251);
	float height_mask = pow(VERTEX.y / tree_height, 2.0);
	
	float lean_noise = texture(texture_wind_noise, 0.2 / wind_frequency * normalize(vec2(1.0, 0.1)) * TIME * wind_speed + seed).r;
	float cluster_noise = texture(texture_wind_noise, 0.4 / wind_frequency * normalize(vec2(1.0, 0.1)) * TIME * wind_speed * 2.0 + seed + COLOR.g).r;

	float combined_lean = wind_strength * height_mask * 2.0 + lean_noise * 12.0 * height_mask * wind_strength;
	float combined_noise = cluster_noise * COLOR.b * wind_strength * 6.0;
	
	vec3 wind_vector = (vec4(wind_vector_world, 0.0) * MODEL_MATRIX).xyz;
	
	VERTEX += wind_vector * combined_lean;
	VERTEX += wind_vector * combined_noise;
	VERTEX *= 1.0 - (combined_lean + combined_noise) * stretch_correction;
}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ROUGHNESS = roughness;
	NORMAL_MAP = texture(texture_normal, UV).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
}