shader_type spatial;
render_mode unshaded, world_vertex_coords;

uniform sampler2D matcap_texture : hint_black_albedo;
uniform bool use_world_normals = false;

varying vec3 world_normal;

void vertex() {
	world_normal = NORMAL;
}

void fragment() {
	vec2 matcap_uv = ((use_world_normals ? world_normal.xy : NORMAL.xy) 
			* vec2(0.5, -0.5) + vec2(0.5));
	vec3 matcap_value = texture(matcap_texture, matcap_uv).rgb;

	ALBEDO = matcap_value;
}