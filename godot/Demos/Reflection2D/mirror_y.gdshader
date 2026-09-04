shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float scale_y = 1.0f;
uniform float zoom_y = 1.0f;

void fragment() {
	float px_size_ratio = SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y;
	vec2 uv_reflected = vec2(SCREEN_UV.x, SCREEN_UV.y + px_size_ratio * UV.y * 2.0 * scale_y * zoom_y);
	
	COLOR = texture(SCREEN_TEXTURE, uv_reflected);
}