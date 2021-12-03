// this shader is based on Kenney's shader https://gist.github.com/KenneyNL/802d7107fbe9bf42b16ec05b43b58079
shader_type spatial;
render_mode unshaded;

uniform sampler2D color_texture: hint_albedo;

uniform vec4 modulate_color : hint_color = vec4(1.0);
uniform vec4 colorA : hint_color = vec4(1.0);
uniform vec4 colorB : hint_color = vec4(1.0);
uniform vec4 colorC : hint_color = vec4(1.0);

varying vec3 color;

void vertex() {
	// In this shader, we use the world normal to mix the tints of the object.
	vec3 world_normal = (WORLD_MATRIX * vec4(NORMAL, 0.0)).xyz;
	world_normal = normalize(world_normal);
	// because we will use each component in a mix() function, we want to ensure
	// that they will be positive. We could do abs(), but using pow also gives us
	// a nice, non linear curve.
	world_normal = pow(world_normal, vec3(2.0));
	vec4 mod_x = modulate_color * colorA;
	COLOR = mix(mix(mix(mod_x, modulate_color * colorB, world_normal.x), mod_x, world_normal.y),
			modulate_color * colorC,
			world_normal.z);
	
	color = world_normal;
}

void fragment() {
	ALBEDO = COLOR.rgb * texture(color_texture, UV).rgb;
}