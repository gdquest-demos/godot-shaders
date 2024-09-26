shader_type canvas_item;

uniform vec2 scale = vec2(10.0);
uniform int seed = 1;

float rand(vec2 p) {
    vec3 p3  = fract(vec3(p.xyx) * float(seed) * 1.031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float noise(vec2 coord) {
    vec2 i = floor(coord);
    vec2 f = fract(coord);

    // Four corners in 2D of a tile
    float b_l = rand(i);
    float b_r = rand(i + vec2(1.0, 0.0));
    float t_l = rand(i + vec2(0.0, 1.0));
    float t_r = rand(i + vec2(1.0, 1.0));

    // We use smooth interpolation technique called Cubic Hermine Curve.
    // Same as smoothstep()
    vec2 cubic = f * f * (3.0 - 2.0 * f);
    // cubic = smoothstep(0.,1.,f);

    float b_mix = mix(b_l, b_r, cubic.x);
    float t_mix = mix(t_l, t_r, cubic.x);

    return mix(b_mix, t_mix, cubic.y);
}

void fragment() {
    vec2 coord = UV * scale;

    float value = noise(coord);

    COLOR = vec4(vec3(value), 1.0);
}