shader_type spatial;

uniform sampler2D main_noise;
uniform vec2 main_noise_scale = vec2(1.0);
uniform sampler2D detail_noise;
uniform vec2 detail_noise_scale = vec2(1.0);
uniform float water_speed = 0.3;
uniform float displacement = 0.1;
uniform vec4 foam_color: hint_color = vec4(1.0);
uniform float foam_threshold = 0.3;
uniform float foam_detail_threshold = 0.7;
uniform float foam_detail_speed = 0.1;
uniform float foam_smoothness = 0.0;
uniform float max_depth = 0.3;
uniform sampler2D depth_color_curve;
uniform float depth_foam_offset= 0.1;

// debug uniforms!
// we can use these uniform to peek behind the scenes
// most of the heavy lifting in this effect is done by
// clever UV unwrapping and vertex colors.
uniform bool debug_vertex_color = false;
uniform bool debug_uv = false;
uniform sampler2D debug_uv_color_grid: hint_albedo;

// Screen mix makes everything better.
float screen_mix(float a, float b){
	return mix(
		a * b * 2.0,
		1.0 - 2.0 * (1.0 - a) * (1.0 - b),
		step(0.5, a)
	);
}

void vertex(){
	if (!(debug_vertex_color || debug_uv)){
		float main_noise_value = textureLod(main_noise, vec2(UV.x, UV.y + TIME * water_speed) * main_noise_scale, 3.0).r;
		float foam_factor = smoothstep(0.0, (1.0 - foam_threshold), main_noise_value - foam_threshold + COLOR.r * 0.2);
		foam_factor = screen_mix(foam_factor, COLOR.r);
		VERTEX += NORMAL * foam_factor * displacement;
	}
}


void fragment(){
	if(debug_vertex_color || debug_uv){
		if (debug_vertex_color){
			ALBEDO = COLOR.rgb;
		} else {
			ALBEDO = texture(debug_uv_color_grid, UV).rgb;
		}
	}
	else{
		// we calculate the depth in the scene so that we can change opacity and color based on it
		// taken from official godot doc: https://docs.godotengine.org/en/stable/tutorials/shading/advanced_postprocessing.html
		float depth_value = texture(DEPTH_TEXTURE, SCREEN_UV).r;
		vec3 ndc = vec3(SCREEN_UV, depth_value) * 2.0 - vec3(1.0);
		vec4 view_depth = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
		view_depth.xyz /= view_depth.w;
		float linear_depth = -view_depth.z;
		float depth_delta = (linear_depth + VERTEX.z);
		float depth_normalized = smoothstep(depth_delta, 0.0, max_depth);
		
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
		// turn on debug uv to see how a grid texture stretches along the mesh.
		vec2 main_noise_uv = vec2(UV.x, UV.y + TIME * water_speed) * main_noise_scale;
		vec2 detail_noise_uv = vec2(vec2(UV.x, UV.y + TIME * foam_detail_speed) * detail_noise_scale);
		
		// We overlay two different noises here
		float main_noise_value = texture(main_noise, main_noise_uv).r;
		
		// we sample the detail noise, and offset it by the reverse depth factor. This means that
		// the secondary noise will appear also when the water is more shallow
		float detail_noise_value = texture(detail_noise, detail_noise_uv).r + (1.0 - depth_normalized) * depth_foam_offset;
		float total_noise = (main_noise_value + detail_noise_value) * 0.5;
		float foam_factor = smoothstep(0.0, foam_smoothness * (1.0 - foam_threshold), ((total_noise - foam_threshold) + main_foam_intensity * 0.1) * main_foam_intensity) ;
		foam_factor = screen_mix(foam_factor, main_foam_intensity);
		foam_factor += smoothstep(0.0, foam_smoothness * (1.0 - foam_threshold), ((detail_noise_value - foam_detail_threshold) + main_foam_intensity * 0.1)) ;
		foam_factor = clamp(foam_factor, 0.0, 1.0);

		vec4 water_color = texture(depth_color_curve, vec2(depth_normalized));
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
	}
}