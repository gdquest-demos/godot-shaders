shader_type spatial;
render_mode depth_draw_opaque, cull_disabled, ambient_light_disabled, blend_add, shadows_disabled;

uniform vec4 color : hint_color;
uniform float fresnel_power = 1.0;
uniform float edge_intensity = 2.0;
uniform float fill_amount : hint_range(0, 1) = 0.1;

uniform float pulsing_strength = 0.25;
uniform float pulsing_speed = 1.0;

uniform float scanline_period = 0.5;
uniform float scanline_width : hint_range(0, 0.49) = 0.1;
uniform float scanline_intensity = 0.35;

uniform float pattern_scroll_speed = 0.025;
uniform vec2 pattern_uv_offset = vec2(6.0, 3.0);

uniform sampler2D pattern_texture : hint_albedo;

void vertex() {
	float pulse_distance = ((sin(TIME * pulsing_speed) * 0.1)) * pulsing_strength;
	VERTEX += NORMAL * pulse_distance;
}

void fragment() {
	//Create a fresnel effect from the NORMAL and VIEW vectors.
	float fresnel = pow(1.0 - dot(NORMAL, VIEW), fresnel_power) * edge_intensity;
	
	//Add back transparency in the middle
	fresnel = fresnel + fill_amount;
	
	//Get the raw linear depth from the depth texture into a  [-1, 1] range
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r * 2.0 - 1.0;
	//Recreate linear depth of the intersecting geometry using projection matrix, and subtract the vertex of the sphere
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]) + VERTEX.z;
	//Intensity intersection effect
	depth = pow(1.0 - clamp(depth, 0, 1), fresnel_power) * edge_intensity;
	
	//Calculate final alpha using fresnel and depth joined together
	fresnel = fresnel + depth;
	
	//Calculate UV scrolling pattern
	float scrolling_time = TIME * pattern_scroll_speed;
	vec4 pattern = texture(pattern_texture, (UV * pattern_uv_offset) + vec2(scrolling_time));
	
	//Use pattern to cut holes in alpha
	fresnel *= pattern.r;
	
	float uv_offset = mod(-TIME * scanline_period, 2.0) - 1.0;
	float scanline = smoothstep(0.5 - scanline_width, 0.5, UV.y + uv_offset) * (1.0 - smoothstep(0.5, 0.5 + scanline_width, UV.y + uv_offset)) * pattern.r;
	
	//Apply final color
	ALBEDO = vec3(0);
	EMISSION = color.rgb;
	ALPHA = smoothstep(0.0, 1.0, fresnel + scanline * scanline_intensity);
}