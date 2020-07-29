shader_type  canvas_item;
render_mode blend_add;

uniform sampler2D stencil_view : hint_black;

void fragment() {
	float mask = texture(stencil_view, SCREEN_UV).r;
	
	COLOR.rgb = texture(TEXTURE, UV).rgb;
	COLOR.a = max(0.0, 1.0 - mask);
}