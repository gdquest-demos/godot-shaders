shader_type canvas_item;

uniform sampler2D mask_texture;
uniform float displacement_amount;

void fragment() {
	float mask = texture(mask_texture, UV).r;
	
	// Displace by the torus mask
	vec2 displacement_uv = UV + mask * displacement_amount;

	COLOR = texture(TEXTURE, displacement_uv);
}