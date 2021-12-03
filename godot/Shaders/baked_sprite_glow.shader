/*
Baked Sprite Glow
Code inspiration: [jzayed](https://github.com/jzayed)
Adapted by: [Razoric](https://razori.ca)

The shader is intended to work with a sprite that has a glowing effect built
into the pixel data itself. It will draw the sprite twice, reducing or
intensifying the glow's alpha by the alpha_falloff for each layer.

The result is tinted and blended together. This makes it a high performance
shader, though the drawback is that it necessitates the sprite to be altered
with a glow effect.
*/
shader_type canvas_item;

// Amount of falloff to apply to the front of the sprite's glow.
uniform float alpha_falloff_front : hint_range(0.0, 3.0) = 1.0;

// Color to tin the front of the sprite's glow by.
uniform vec4 tint_front : hint_color = vec4(1.0, 1.0, 1.0, 1.0);

// Amount of falloff to apply to the back of the sprite's glow.
uniform float alpha_falloff_back : hint_range(0.0, 3.0) = 1.0;

// Color to tint the back of the sprite's glow by.
uniform vec4 tint_back : hint_color = vec4(1.0, 1.0, 1.0, 1.0);

// Linear proportion to blend between back and front layers of the sprite's glow.
uniform float blend_amount : hint_range(0.0, 1.0) = 1.0;

// Maximum alpha value before no longer being considered for falloff. Sprites
// that have fuzzy edges on top of the glow may need this adjusted to prevent
// cutting pixelization.
uniform float falloff_max_alpha : hint_range(0.0, 1.0) = 1.0;

const vec3 TINT_RGB_COMPARISON = vec3(0.222, 0.707, 0.071);

vec4 tint_rgba(vec4 tex, vec4 color) {
	float tint_amount = dot(tex.rgb, TINT_RGB_COMPARISON);
	vec3 tint = color.rgb * tint_amount;
	tex.rgb = mix(tex.rgb, tint.rgb, color.a);
	return tex;
}

vec4 alpha_intensity(vec4 tex, float fade) {
	if (tex.a < falloff_max_alpha) {
		tex.a = mix(0.0, tex.a, fade);
	}
	return tex;
}

vec4 blend(vec4 origin, vec4 overlay, float blend) {
	vec4 blended_output = origin;
	blended_output.a = overlay.a + origin.a * (1.0 - overlay.a);
	
	blended_output.rgb = (overlay.rgb * overlay.a + origin.rgb * origin.a * (1.0 - overlay.a)) 
			/ (blended_output.a + 0.0000001);
	
	blended_output.a = clamp(blended_output.a, 0.0, 1.0);
	blended_output = mix(origin, blended_output, blend);
	
	return blended_output;
}

void fragment() {
	vec4 main_texture = texture(TEXTURE, UV);
	vec4 intensity_front_tex = alpha_intensity(main_texture, alpha_falloff_front);
	vec4 tint_front_tex = tint_rgba(intensity_front_tex, tint_front);
	
	vec4 intensity_back_tex = alpha_intensity(main_texture, alpha_falloff_back);
	vec4 tint_back_tex = tint_rgba(intensity_back_tex, tint_back);
	
	vec4 blended_texture = blend(tint_back_tex, tint_front_tex, blend_amount);
	blended_texture *= main_texture;
	
	COLOR = blended_texture;
}