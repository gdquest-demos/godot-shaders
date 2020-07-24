shader_type canvas_item;

uniform float blur_size = 1.0;
uniform float texture_lod = 1.0;

void fragment() {
	const float TOTAL_WEIGHT = 1.85547;
	const int SAMPLES = 15;
	const float WEIGHTS[14] = {
		0.020115,
		0.031025,
		0.044766,
		0.060428,
		0.076309,
		0.090149,
		0.09963,
		0.103006,
		0.09963,
		0.090149,
		0.076309,
		0.060428,
		0.044766,
		0.031025
	};

	vec2 scale = TEXTURE_PIXEL_SIZE * blur_size;
	
	COLOR = vec4(0.0);

	vec2 blur_direction_1 = TEXTURE_PIXEL_SIZE * vec2(blur_size);
	vec2 blur_direction_2 = TEXTURE_PIXEL_SIZE * vec2(blur_size, -blur_size);

	for(int index = -SAMPLES / 2; index < SAMPLES / 2; ++index) {
		int weight_index = index + SAMPLES / 2;
		COLOR += textureLod(TEXTURE, UV + blur_direction_1 * float(index), texture_lod) * WEIGHTS[weight_index];
	}
	for(int index = -SAMPLES / 2; index < SAMPLES / 2; ++index) {
		int weight_index = index + SAMPLES / 2;
		COLOR += textureLod(TEXTURE, UV + blur_direction_2 * float(index), texture_lod) * WEIGHTS[weight_index];
	}

	COLOR.rgb /= TOTAL_WEIGHT;
}