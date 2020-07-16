shader_type spatial;
render_mode specular_schlick_ggx, ambient_light_disabled;

uniform float normal_offset_x = 0.0;
uniform float normal_offset_y = 0.0;


void vertex() {
	NORMAL += vec3(normal_offset_x, normal_offset_y, 0);
}

void fragment() {
	ALBEDO = vec3(0);
	ROUGHNESS = 0.4;
	SPECULAR = 0.5;
}