shader_type canvas_item;

uniform sampler2D dissolve_texture;
uniform float burn_size : hint_range(0, 2);
uniform float dissolve_amount : hint_range(0, 1);

void fragment() {
	vec4 out_color = texture(TEXTURE, UV);
	vec3 emission = vec3(0);
	float sample = texture(dissolve_texture, UV).r;
	float emission_value = 1.0 - smoothstep(dissolve_amount, dissolve_amount + burn_size, sample);
	
	emission = vec3(1.0) * emission_value;
	
	COLOR = vec4(max(vec3(0.0), emission), smoothstep(dissolve_amount - burn_size, dissolve_amount, sample) * out_color.a);
}