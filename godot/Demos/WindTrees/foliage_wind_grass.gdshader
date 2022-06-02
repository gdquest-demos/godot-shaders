shader_type spatial;
render_mode cull_disabled;

uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float alpha_scissor_threshold;
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_normal : hint_normal;
uniform float normal_scale : hint_range(-16,16);
uniform vec4 transmission : hint_color;

uniform sampler2D texture_wind_noise : hint_black;
uniform float wind_angle : hint_range(0, 360);
uniform float wind_strength : hint_range(0.0, 2.0) = 1.0;
uniform float wind_frequency : hint_range(0.0, 2.0) = .05;
uniform float wind_speed : hint_range(0.0, 2.0) = .25;
uniform float stretch_correction : hint_range(0.0, 2.0) = 0.5;

float rand(vec3 p) {
	return fract(sin(dot(p,vec3(127.1,311.7, 74.7)))*43758.5453123);
}

vec3 rotate (vec3 v, vec3 n, float a) { 
	return v * cos(a) + cross(n, v) * sin(a) + n * dot(n, v) * (1. - cos(a)); 
}

void vertex() {
	vec3 obj_pos = (WORLD_MATRIX * vec4(0, 0, 0, 1)).xyz;
	float seed = rand(obj_pos);
	vec3 wind_vector_world = vec3(1.0, 0.0, 0.0);
	wind_vector_world = rotate(wind_vector_world, vec3(0.0, 1.0, 0.0), wind_angle * 0.01745329251);
	
	float noise1 = texture(texture_wind_noise, 0.1 / wind_frequency * (WORLD_MATRIX * vec4(VERTEX, 1.0) + COLOR.g).xz - wind_vector_world.xz * TIME * wind_speed ).r;
	float noise2 = texture(texture_wind_noise, 0.1 / wind_frequency * 2.0 * (WORLD_MATRIX * vec4(VERTEX, 1.0) + COLOR.g).xz - (wind_vector_world).xz * TIME * wind_speed * 2.0 ).r * .5;
	
	vec3 wind_vector = (vec4(wind_vector_world, 0.0) * WORLD_MATRIX).xyz;
	wind_vector = rotate(wind_vector, vec3(0.0, 1.0, 0.0), sin(TIME * 4.0 * wind_speed + COLOR.g * 6.28) * 0.2);
	
	float lean_mask = pow(COLOR.r, 1.5);
	float lean = (noise1 + noise2) * pow(wind_strength, 0.5) * lean_mask;
	
	VERTEX += wind_vector * lean * 0.4;
	VERTEX.y *= 1.0 - lean * stretch_correction;
	
}

void fragment() {
	NORMAL = FRONT_FACING ? NORMAL : -NORMAL;
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ROUGHNESS = roughness;
	NORMALMAP = texture(texture_normal, UV).rgb;
	NORMALMAP_DEPTH = normal_scale;
	ALPHA = albedo.a * albedo_tex.a;
	TRANSMISSION = transmission.rgb;
	ALPHA_SCISSOR = alpha_scissor_threshold;
}