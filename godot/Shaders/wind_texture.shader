shader_type spatial;

uniform sampler2D wind_mask;

void vertex() {
	float sample = textureLod(wind_mask, UV, 0.0).r;
}