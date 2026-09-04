shader_type spatial;
render_mode unshaded;

uniform vec4 deep_color : source_color;
uniform vec4 shallow_color : source_color = vec4(1);

uniform float refraction_speed = 0.25;
uniform float refraction_strength = 1.0;

uniform float foam_amount = 1.0;
uniform float foam_cutoff = 1.0;
uniform vec4 foam_color : source_color = vec4(1);

uniform float displacement_strength = 0.25;

uniform float depth_distance = 1.0;

uniform vec2 movement_direction = vec2(1,0);

uniform sampler2D refraction_noise : hint_normal;
uniform sampler2D foam_noise : hint_default_black;
uniform sampler2D displacement_noise : hint_default_black;

// In Godot 4 the screen and depth buffers are reached through uniforms with
// these hints instead of the built-ins SCREEN_TEXTURE / DEPTH_TEXTURE.
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

// Returns the positive view-space distance from the camera to the geometry
// already drawn behind this fragment.
// Godot 4 stores depth in the [0, 1] range (reverse-Z), so unlike in Godot 3 we
// only remap the screen UV to NDC and leave the depth value untouched.
float get_scene_distance(vec2 uv, mat4 inv_projection_matrix) {
	float depth_raw = texture(DEPTH_TEXTURE, uv).r;
	vec3 ndc = vec3(uv * 2.0 - 1.0, depth_raw);
	vec4 position_view = inv_projection_matrix * vec4(ndc, 1.0);
	position_view.xyz /= position_view.w;
	return -position_view.z;
}

void vertex() {
	float displacement = textureLod(
			displacement_noise, 
			UV + (TIME * movement_direction) * refraction_speed, 
			0.0).r * 2.0 - 1.0;
	
	VERTEX.y += displacement * displacement_strength;
}

void fragment() {
	vec2 uv = SCREEN_UV + refraction_strength 
			* (texture(refraction_noise, UV + (TIME * movement_direction) * refraction_speed).rg 
			* 2.0 - 1.0);
	
	// Unrefracted depth, so the water never samples geometry in front of it.
	float real_depth = get_scene_distance(SCREEN_UV, INV_PROJECTION_MATRIX) + VERTEX.z;
	
	// Depth of the geometry seen through the refracted UV, relative to the water surface.
	float depth = get_scene_distance(uv, INV_PROJECTION_MATRIX) + VERTEX.z;
	
	depth = max(depth, real_depth);
	
	float intersection = clamp(depth / foam_amount, 0.0, 1.0) * foam_cutoff;
	
	vec4 out_color = mix(shallow_color, deep_color, clamp((depth / depth_distance), 0.0, 1.0));
	vec4 scene_color = texture(SCREEN_TEXTURE, uv);
	out_color = mix(scene_color, out_color, out_color.a);
	
	vec3 foam = step(intersection, 
			texture(foam_noise, UV + (TIME * movement_direction) * refraction_speed).rgb) 
			* foam_color.rgb;
	
	ALBEDO = out_color.rgb + foam;
}
