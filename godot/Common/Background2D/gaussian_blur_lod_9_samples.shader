shader_type canvas_item;

uniform float blur_size = 1.0;
uniform float texture_lod = 1.0;

void fragment() {
	const int SAMPLES = 9;
	const float TOTAL_WEIGHT = 1.627038;
	const float WEIGHTS[8] = {
		0.05467,
		0.080657,
		0.106483,
		0.125794,
		0.132981,
		0.125794,
		0.106483,
		0.080657
	};

	vec2 scale = TEXTURE_PIXEL_SIZE * blur_size;
	
	COLOR = vec4(0.0);

	vec2 blur_direction_1 = TEXTURE_PIXEL_SIZE * vec2(blur_size);
	vec2 blur_direction_2 = TEXTURE_PIXEL_SIZE * vec2(blur_size, -blur_size);

	for(int i=-SAMPLES/2; i < SAMPLES/2; ++i) {
		int w = i + SAMPLES/2;
		COLOR += textureLod(TEXTURE, UV + blur_direction_1 * float(i), texture_lod) * WEIGHTS[w];
	}
	for(int i=-SAMPLES/2; i < SAMPLES/2; ++i) {
		int w = i + SAMPLES/2;
		COLOR += textureLod(TEXTURE, UV + blur_direction_2 * float(i), texture_lod) * WEIGHTS[w];
	}

	COLOR /= TOTAL_WEIGHT;
}