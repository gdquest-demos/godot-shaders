shader_type spatial;
render_mode unshaded;

uniform vec4 albedo : source_color;

void fragment() {
	ALBEDO = albedo.rgb;
}
