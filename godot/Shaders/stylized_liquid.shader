shader_type spatial;
render_mode cull_disabled,shadows_disabled;

uniform float liquid_height = 0.5;
uniform vec4 liquid_surface_color: hint_color = vec4(0.7,0.5,1.0,1.0);
uniform sampler2D liquid_rim_gradient;
uniform float rim_emission_intensity: hint_range(0.0, 2.0) = 0.2;
uniform float rim_exponent: hint_range(1.0, 10.0) = 3.0;
uniform float emission_intensity:hint_range(0.0, 3.0) = 0.1;
uniform float liquid_surface_gradient_size: hint_range(0.0, 3.0) = 0.1;
uniform vec2 wobble = vec2(0.0,0.0); 

varying float y_coordinate;

mat4 rotate_x( in float angle ) {
	return mat4(
				vec4(1.0,0.0,0.0,0.0),
				vec4(0.0,cos(angle),-sin(angle),0.0),
				vec4(0.0,sin(angle),cos(angle),0.0),
				vec4(0.0,0.0,0.0,1.0)
				);
}

mat4 rotate_z( in float angle ) {
	return mat4(
				vec4(cos(angle),-sin(angle), 0.0, 0.0),
				vec4(sin(angle),cos(angle), 0.0, 0.0),
				vec4(0.0,0.0,1.0,0.0),
				vec4(0.0,0.0,0.0,1.0)
				);
}

void vertex(){
	// Here is the part where most of the magic happens
	// we rotate the model on X and Z axis, and add an offset to the Y based on
	// as a result of a sum of all these vertex positions
	// Note that because wobble x and y are respectively the sine and the cosine of
	// the same number, when one is 1, the other will be zero.
	// see the file LiquidWobble.gd for more details
	vec3 rotated_vert_z = (rotate_z(1.6) * vec4(VERTEX, 1.0)).xyz;
	vec3 rotated_vert_x = (rotate_x(-1.6) * vec4(VERTEX, 1.0)).xyz;
	vec3 vert = (rotated_vert_z * wobble.x + rotated_vert_x * wobble.y) + VERTEX;
	y_coordinate = (WORLD_MATRIX * (vec4(vert, 1.0))).y - WORLD_MATRIX[3].y;
}

void fragment(){
	
	float fresnel = dot(normalize(NORMAL), normalize(VERTEX));
	fresnel = abs(fresnel);
	fresnel = 1.0 - fresnel;
	float pow_fresnel = pow(fresnel, rim_exponent);
	
	if(y_coordinate > liquid_height){
		discard;
	}
	
	if(!FRONT_FACING){
		// This is an approximation of the normal.
		// the normal of the backface will always point up
		NORMAL = (INV_CAMERA_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
		ALBEDO = liquid_surface_color.rgb;
		// this is needed because we want the backfaces to look solid
		// if we let it be affected by AO, it will reveal the trick
		AO_LIGHT_AFFECT = 0.0;
	} else {
		vec4 liquid_color = texture(liquid_rim_gradient, vec2(pow_fresnel));
		float surface_component = smoothstep(
			liquid_height - liquid_surface_gradient_size,
			liquid_height,
			y_coordinate);
		ALBEDO = mix(liquid_color.rgb, liquid_surface_color.rgb, surface_component);
	}
	// Magical liquid!
	EMISSION = ALBEDO * (pow_fresnel * rim_emission_intensity + emission_intensity);
}