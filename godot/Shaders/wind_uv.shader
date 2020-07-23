shader_type spatial;
render_mode world_vertex_coords, unshaded, cull_disabled;

uniform float wind_speed = 0.3;
uniform float wind_strength = 0.3;

uniform sampler2D gradient : hint_black_albedo;


void vertex() {
	float wind_offset = sin(wind_speed * TIME) * wind_strength;
	VERTEX = VERTEX + vec3(wind_offset, 0.0, 0.0) * UV.y;
}

void fragment() {
	vec4 color = texture(gradient, vec2(UV.y, 0));
	
	ALBEDO = color.rgb;
}