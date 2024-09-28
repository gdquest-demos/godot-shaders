shader_type canvas_item;

uniform vec2 scale = vec2(10.0);
uniform int seed = 1;

// Generate a random value based on a 2D point and seed
float rand(vec2 point) {
    vec3 p3 = fract(vec3(point.xyx) * float(seed) * 1.031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// Generate value noise for a given coordinate
float noise(vec2 coord) {
    vec2 integer_coord = floor(coord);

    // Calculate random values for the four corners of a tile
    float bottom_left = rand(integer_coord);
    float bottom_right = rand(integer_coord + vec2(1.0, 0.0));
    float top_left = rand(integer_coord + vec2(0.0, 1.0));
    float top_right = rand(integer_coord + vec2(1.0, 1.0));

    // Use Cubic Hermite Curve for smooth interpolation (equivalent to smoothstep)
    vec2 fractional_coord = fract(coord);
    vec2 smooth_coord = fractional_coord * fractional_coord * (3.0 - 2.0 * fractional_coord);

    // Interpolate between the four corners
    float bottom_mix = mix(bottom_left, bottom_right, smooth_coord.x);
    float top_mix = mix(top_left, top_right, smooth_coord.x);

    return mix(bottom_mix, top_mix, smooth_coord.y);
}

void fragment() {
    vec2 scaled_uv = UV * scale;
    float noise_value = noise(scaled_uv);
    COLOR = vec4(vec3(noise_value), 1.0);
}
