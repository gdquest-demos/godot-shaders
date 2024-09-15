shader_type  canvas_item;
render_mode blend_add;

uniform sampler2D stencil_view : hint_default_black;

void fragment() {
	float mask = texture(stencil_view, SCREEN_UV).r;
	
	COLOR.rgb = texture(TEXTURE, UV).rgb;
	COLOR.a = 1.0 - mask;
}