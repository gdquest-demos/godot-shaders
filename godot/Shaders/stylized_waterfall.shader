shader_type spatial;

// ANCHOR: main_noise
uniform sampler2D main_noise;
uniform vec2 main_noise_scale = vec2(5.7, 1.0);
// END: main_noise
// ANCHOR: detail_noise
uniform sampler2D detail_noise;
uniform vec2 detail_noise_scale = vec2(2.5);
// END: detail_noise
// ANCHOR: water_speed
uniform float water_speed = 0.2;
// END: water_speed
// ANCHOR: displacement
uniform float displacement = 0.444;
// END: displacement
// ANCHOR: foam_color
uniform vec4 foam_color: hint_color = vec4(1.0);
// END: foam_color
// ANCHOR: foam_threshold
uniform float foam_threshold = 0.5;
// END: foam_threshold
// ANCHOR: foam_detail_threshold
uniform float foam_detail_threshold = 0.7;
// END: foam_detail_threshold
// ANCHOR: smoothness
uniform float foam_smoothness = 0.063;
// END: smoothness
// ANCHOR: max_depth
uniform float max_depth = 1.0;
// END: max_depth
// ANCHOR: depth_color
uniform sampler2D depth_color_curve;
// END: depth_color
// ANCHOR: depth_foam_offset
uniform float depth_foam_offset= 0.25;
// END: depth_foam_offset
// debug uniforms!
// we can use these uniform to peek behind the scenes
// most of the heavy lifting in this effect is done by
// clever UV unwrapping and vertex colors.
uniform bool debug_vertex_color = false;
uniform bool debug_uv = false;
uniform sampler2D debug_uv_color_grid: hint_albedo;

// ANCHOR: overlay_blend
// Overlay blend makes everything better.
float overlay_blend(float a, float b) {
	return mix(
			a * b * 2.0,
			1.0 - 2.0 * (1.0 - a) * (1.0 - b),
			step(0.5, a));
}
// END: overlay_blend

void vertex() {
	if (!(debug_vertex_color || debug_uv)) {
		// ANCHOR: noise_uv_offset
		vec2 noise_uv_offset = vec2(UV.x, UV.y + TIME * water_speed) * main_noise_scale;
		// END: noise_uv_offset
		// ANCHOR: sample_main_noise
		float main_noise_value = textureLod(
				main_noise, 
				noise_uv_offset, 
				3.0).r;
		// END: sample_main_noise
		// ANCHOR: foam_smoothstep
		float foam_factor = smoothstep(
				0.0, 
				(1.0 - foam_threshold), 
				main_noise_value - foam_threshold + COLOR.r * 0.2);
		// END: foam_smoothstep
		// ANCHOR: vertex_overlay
		foam_factor = overlay_blend(foam_factor, COLOR.r);
		// END: vertex_overlay
		// ANCHOR: vertex_displacement
		VERTEX += NORMAL * foam_factor * displacement;
		// END: vertex_displacement
	}
}

void fragment() {
	if (debug_vertex_color) {
		ALBEDO = COLOR.rgb;
	} else if (debug_uv) {
		// turn on debug uv to see how a grid texture stretches along the mesh.
		ALBEDO = texture(debug_uv_color_grid, UV).rgb;
	}
	else {
		// ANCHOR: depth_texture
		// we calculate the depth in the scene so that we can change opacity and color based on it
		// taken from official godot doc: https://docs.godotengine.org/en/stable/tutorials/shading/advanced_postprocessing.html
		float depth_value = texture(DEPTH_TEXTURE, SCREEN_UV).r;
		// END: depth_texture
		// ANCHOR: ndc
		vec3 ndc = vec3(SCREEN_UV, depth_value) * 2.0 - vec3(1.0);
		vec4 view_depth = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
		view_depth.xyz /= view_depth.w;
		// END: ndc
		// ANCHOR: linear_depth
		float depth_delta = VERTEX.z - view_depth.z;
		// END: linear_depth
		// ANCHOR: depth_noramlized
		float depth_normalized = smoothstep(0.0, max_depth, depth_delta);
		// END: depth_normalized
		// ANCHOR: water_color
		vec4 water_color = texture(depth_color_curve, vec2(depth_normalized));
		// END: water_color
		// ANCHOR: main_uv_setup
		// COLOR in the fragment shader indicates the vertex color that is
		// assigned to a vertex and then interpolated between the adjacet vertices.
		// it can be assigned inside of blender by using vertex paint
		// right now we are exporting in dae because blender's 2.9 gltf uses a
		// different color format that Godot 3.2.3 cannot read.
		// In the red channel, we have encoded how foamy we want the water to be
		float main_foam_intensity = COLOR.r;
		
		// Instead of using some complex mapping with world coordinates, or even flow maps,
		// we can directly pan on UV.y.
		// This is possible because the mesh is unwrapped in a way where the y direction is the same direction as we
		// would use to make the water flow. Check out the UVs in editor!
		// we also use different stretching of the UV to make it look like the water flows faster
		// in the vertical part.
		vec2 main_noise_uv = vec2(UV.x, UV.y + TIME * water_speed) * main_noise_scale;
		float main_noise_value = texture(main_noise, main_noise_uv).r;
		// END: main_uv_setup
		// ANCHOR: detail_uv
		// We overlay two different noises here
		vec2 detail_noise_uv = vec2(UV.x, UV.y + TIME * water_speed) * detail_noise_scale;
		// END: detail_uv
		// ANCHOR: detail_noise
		// we sample the detail noise, and offset it by the reverse depth factor. This means that
		// the secondary noise will appear also when the water is more shallow
		float detail_noise_value = texture(detail_noise, detail_noise_uv).r 
				+ (1.0 - depth_normalized) * depth_foam_offset;
		// END: detail_noise
		// ANCHOR: total_noise
		float total_noise = mix(main_noise_value, detail_noise_value, 0.5);
		// END: total_noise
		// ANCHOR: smoothstep_main_noise
		float foam_upper_bound = foam_smoothness * (1.0 - foam_threshold);
		float foam_factor = smoothstep(0.0, 
				foam_upper_bound, 
				(total_noise - foam_threshold + main_foam_intensity * 0.1) * main_foam_intensity);
		foam_factor = overlay_blend(foam_factor, main_foam_intensity);
		// END: smoothstep_main_noise
		// ANCHOR: smoothstep_detail_noise
		foam_factor += smoothstep(0.0, 
				foam_upper_bound, 
				(detail_noise_value - foam_detail_threshold + main_foam_intensity * 0.1));
		
		foam_factor = clamp(foam_factor, 0.0, 1.0);
		// END: smoothstep_detail_noise
		// ANCHOR: albedo
		ALBEDO = mix(water_color, foam_color, foam_factor).rgb;
		ROUGHNESS = 0.0;
		// In this shader we take the approach of assigning alpha instead of using a screen texture.
		// You might have noticed, by looking with different angles, that sometimes the pond below
		// will render in front of the waterfall.
		// Sorting of transparent elements is done by sorting them based on their distance from the camera, and
		// then they are layered one on top of the other. In order to make the pond drawn almost always
		// before the waterfall, its origin has been placed in a way that makes it be sorted first
		// for the most common view angles that we expect (in this case, from the front of the waterfall)
		// There are many different approaches to alpha and reflection/refraction, and in the end
		// there is always a trade-off somewhere
		ALPHA = mix(water_color, foam_color, foam_factor).a;
		// END: albedo
	}
}