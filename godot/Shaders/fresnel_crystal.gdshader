shader_type spatial;

group_uniforms BasicPBRValues;
/** Metallic amount. Controls how metallic the material looks. */
uniform float metallic: hint_range(0.0,1.0) = 1.0;
/** Roughness amount. The lower the roughness, the shinier the material. As you increase the roughness, the specular highlights scatter.  */
uniform float roughness : hint_range(0.0,1.0) = 0.1;
/** Albedo texture. Base color. */
uniform sampler2D texture_albedo : source_color, repeat_enable, filter_linear_mipmap;
/** Normal texture. */
uniform sampler2D texture_normal : hint_normal, repeat_enable, filter_linear_mipmap;
group_uniforms;

group_uniforms Emission;
/** Color of light emission. This light is emitted from the core of the crystal. */
uniform vec4 emission : source_color = vec4(1.0, 0.6, 0.1, 1.0); // Light orange.
/** Energy of emission.
* Values over [code]1.0[/code] will glow, if you have Glow enabled in your environment resource.
*/
uniform float emission_energy: hint_range(0.0, 10.0) = 6.0;
/** Emission texture. Controls the strength of the effect across the mesh. */
uniform sampler2D texture_emission : hint_default_black, repeat_enable, filter_linear_mipmap;
/** Speed of the pulsing emission effect. Higher values mean pulsing more often.
* If this matches the fresnel pulse speed, the effects will sync.
*/
uniform float emission_pulse_speed: hint_range(0.0, 2.0) = .75;
group_uniforms;

group_uniforms Fresnel;
/** Color of fresnel effect. */
uniform vec4 fresnel_color : source_color = vec4(0.0, 0.9, 0.9, 1.0); // Near cyan.
/** Fresnel intensity.
* Values over [code]1.0[/code] will glow, if you have Glow enabled in your environment resource.
*/
uniform float fresnel_color_intensity: hint_range(0.0, 10.0) = 1.0;
/** The power of the fresnel effect.
* High values mean the effect only appears on the very edges, at glancing angles.
*/
uniform float fresnel_power: hint_range(0.5,8.0) = 6.0;
/** Speed of the pulsing fresnel effect. Higher values mean pulsing more often.
* If this matches the emission pulse speed, the effects will sync.
*/
uniform float fresnel_pulse_speed: hint_range(0.0,2.0) = 0.75;
group_uniforms;

void fragment() {
	// Set the PBR values from textures and sliders.
	ALBEDO = texture(texture_albedo, UV).rgb;
	NORMAL_MAP = texture(texture_normal, UV).rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;

	// Emission.
	vec3 emission_texture = texture(texture_emission, UV).rgb;
	float emission_time_factor = clamp(sin(TIME * emission_pulse_speed) + 0.33, 0.33, 1);
	EMISSION = ((emission.rgb * emission_texture) * emission_energy * emission_time_factor);

	float fresnel = 1.0 - dot(NORMAL, VIEW);
	// Raise the fresnel to a power to control the thickness of the edge effect.
	fresnel = pow(fresnel, fresnel_power);
	float fresnel_time_factor = clamp(sin(TIME * fresnel_pulse_speed), 0.15, 1);
	EMISSION += (fresnel * fresnel_color.rgb * fresnel_color_intensity * fresnel_time_factor);
}
