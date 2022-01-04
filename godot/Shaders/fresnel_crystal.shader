// ANCHOR: all
// ANCHOR: setup
shader_type spatial;

uniform float metallic;
uniform float roughness : hint_range(0,1);

uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D texture_normal : hint_normal;
// END: setup
// ANCHOR: emission_setup
uniform sampler2D texture_emission : hint_black_albedo;
uniform vec4 emission : hint_color;

uniform float emission_energy;
// END: emission_setup
uniform float fresnel_power = 3.0;
// ANCHOR: fresnel_setup
uniform float fresnel_color_intensity = 1.0;
uniform vec4 fresnel_color : hint_color;

uniform float fresnel_pulse_speed = 1.0;
// END: fresnel_setup
// ANCHOR: speed
uniform float emission_pulse_speed = 1.0;
// END: speed
// ANCHOR: setup_fragment
void fragment() {
	ALBEDO = texture(texture_albedo, UV).rgb;
	
	METALLIC = metallic;
	ROUGHNESS = roughness;
	
	NORMALMAP = texture(texture_normal, UV).rgb;
// END: setup_fragment
	// ANCHOR: emission_tex
	vec3 emission_tex = texture(texture_emission, UV).rgb;
	// END: emission_tex
	// ANCHOR: fresnel
	float fresnel = 1.0 - dot(NORMAL, VIEW);
	// END: fresnel
	// ANCHOR: fresnel_power
	fresnel = pow(fresnel, fresnel_power);
	// END: fresnel_power
	// ANCHOR: fresnel_time
	float fresnel_time_factor = clamp(sin(TIME * fresnel_pulse_speed), 0.15, 1);
	// END: fresnel_time
	// ANCHOR: time_factor
	float emission_time_factor = clamp(sin(TIME * emission_pulse_speed) + 0.33, 0.33, 1);
	// END: time_factor
	// ANCHOR: emission_time
	EMISSION = ((emission.rgb * emission_tex) * emission_energy * emission_time_factor);
	// END: emission_time
	// ANCHOR: emission_fresnel
	EMISSION += (fresnel * fresnel_color.rgb * fresnel_color_intensity * fresnel_time_factor);
	// END: emission_fresnel
}
// END: all