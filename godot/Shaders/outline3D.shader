shader_type spatial;
render_mode unshaded, cull_front, depth_draw_always;

uniform float thickness = 0.1;
uniform vec4 outline_color : hint_color = vec4(1.0);

void vertex() {
	VERTEX += (NORMAL * thickness);
}

void fragment() {
	ALBEDO = outline_color.rgb;
	ALPHA = outline_color.a;
}