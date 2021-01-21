// This shader is based on Minionsart's stylized fire
// https://twitter.com/minionsart/status/1132593681452683264?s=20

shader_type spatial;
render_mode blend_mix;

// This texture must be seamless!
// Experiment with the different noises provided in the res://Demos/StylizedFire/ folder
uniform sampler2D noise_texture;

uniform sampler2D texture_mask;
uniform float emission_intensity = 2.0;
uniform float time_scale = 3.0;
uniform vec2 texture_scale = vec2(1.0);
uniform float edge_softness = 0.1;

varying vec3 world_coord;
varying float world_x_dot;


void vertex() {
	// Billboard code, taken directly from a spatial material
	// create a spatial material, enable billboard with billboard keep scale, and then convert
	// to shader material, and it will create a shader with this code.
	mat4 mat_world = mat4(normalize(CAMERA_MATRIX[0])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[1])*length(WORLD_MATRIX[0]),normalize(CAMERA_MATRIX[2])*length(WORLD_MATRIX[2]),WORLD_MATRIX[3]);
	mat_world = mat_world * mat4( vec4(cos(INSTANCE_CUSTOM.x),-sin(INSTANCE_CUSTOM.x), 0.0, 0.0), vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0),vec4(0.0, 0.0, 1.0, 0.0),vec4(0.0, 0.0, 0.0, 1.0));
	MODELVIEW_MATRIX = INV_CAMERA_MATRIX * mat_world;
	
	// We map the coordinates on the vertical planes xy and zy
	// we also calculate how to blend between the two based on where the world space normal
	// is pointing.
	world_coord = (mat_world * vec4(VERTEX, 1.0)).rgb;
	vec4 world_normal = (mat_world * vec4(NORMAL, 0.0));
	world_x_dot =  abs(dot(normalize(world_normal.rgb), vec3(1.0,0.0,0.0)));
}


void fragment() {
	
	// We sample the mask texture based on regular UV
	// We don't want the particles to show their square shape
	// so we use a round, black and white, mask texture
	float mask = texture(texture_mask, UV).r;
	
	// We sample the noise both from the xy plane and from the zy plane, adding a time-based
	// panning. If we didn't do this, we would see the holes of the noise will always be in the
	// same space in global coordinates. Set the time_scale to zero to see how it would look like.
	// To add more variation, we could sample from another noise that has a different scale and panning speed.
	// The additional offset on the zy noise is to avoid mirroring effects when
	// the view vector is between same-sign x and z axes
	vec2 time_based_pan = vec2(0.2, 1.0) * (- TIME * time_scale);
	float noise_xy = texture(noise_texture, world_coord.xy * texture_scale + time_based_pan).r;
	float noise_zy = texture(noise_texture, world_coord.zy * texture_scale + time_based_pan + vec2(0.7, 0.3)).r;
	
	// We blend the noise based on world_x_dot, which is the dot product between
	// the normal of the billboard plane, and the global x axis. If we face the global
	// x axis, then we sample from the xy plane, otherwise, we sample from the zy plane
	float noise = mix(noise_xy, noise_zy, clamp(world_x_dot, 0.0, 1.0));
	
	// The particle color is assigned to the vertex color, which is called COLOR
	ALBEDO = COLOR.rgb;
	// Assign the same color for emission, multiplied by the emission intensity
	EMISSION = ALBEDO * emission_intensity;
	
	// Instead of blending out the particle, we apply a technique called alpha erosion, where we
	// subtract an erosion amount from the alpha.
	float erosion_amount = (1.0 - COLOR.a);
	float alpha = (noise * mask) - erosion_amount;
	
	// Because we perform a subtraction, we ensure that the alpha is always between 0 and 1.
	// If the alpha goes negative or above 1, a number of visual artifacts appear.
	alpha = clamp(alpha, 0.0, 1.0);
	
	// In order to give this fire a stylized vibe, we use smoothstep to remap the alpha value
	// We could use step(0.1, alpha), but then there would be an abrupt cut between transparent and
	// non transparent (exactly as if we discarded the fragment with discard)
	// smoothstep gives a nice blend on the edges instead
	ALPHA = smoothstep(0.0, edge_softness, alpha);
}
