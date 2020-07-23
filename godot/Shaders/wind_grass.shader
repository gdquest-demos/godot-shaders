shader_type spatial;
render_mode cull_disabled, unshaded;

uniform float wind_speed = 0.2;
uniform float wind_strength = 2.0;
uniform float wind_randomness = 0.5;

uniform sampler2D color_ramp : hint_black_albedo;

uniform sampler2D wind_noise : hint_black;

void vertex() {
	vec2 uv = (INSTANCE_CUSTOM.xz * wind_randomness) + (TIME * wind_speed);
	
	vec2 bump_wind = (textureLod(wind_noise, uv, 0.0).rg - 0.5) * wind_strength;
	
	VERTEX += vec3(bump_wind.x, 0.0, bump_wind.y) * (1.0 - UV.y);
}

void fragment() {
	ALBEDO = texture(color_ramp, vec2(1.0 - UV.y, 0)).rgb;
}