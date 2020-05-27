shader_type canvas_item;

uniform vec4 glow_color : hint_color = vec4(1.0);

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	COLOR = vec4(glow_color.rgb, color.a);
}