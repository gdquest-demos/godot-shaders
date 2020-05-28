shader_type canvas_item;

const float SQUARE_SIZE_MAX = 8.0;
const float PI = 3.14159;
const float R_LUMINANCE = 0.298912;
const float G_LUMINANCE = 0.586611;
const float B_LUMINANCE = 0.114478;

float greysize(in vec3 in_color) {
	return dot(in_color, vec3(R_LUMINANCE, G_LUMINANCE, B_LUMINANCE));
}

//sin()-less 1 out, 2 in hash by Dave Hoskins
float hash(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
	vec3 color = texture(TEXTURE, UV).rgb;
	float grey = greysize(color);
	float value = pow(clamp(grey, 0.0, 1.0), 0.4545);
	
	float point = 0.0;
	float size = 0.0;
	
	if(0.0 < value) {
		size = value < 1.0 ? (1.0-value)*SQUARE_SIZE_MAX : 1.0;
		
		vec2 xy = FRAGCOORD.xy;
		
		vec2 inverse_resolution = 1.0 / SCREEN_PIXEL_SIZE.xy;
		vec2 id = SCREEN_PIXEL_SIZE.xy * (UV * inverse_resolution)/inverse_resolution;
		xy += (size * hash(id));
		
		point = step(mod(xy.x, size), 1.0) * step(mod(xy.y, size), 1.0);
	}
	
	COLOR = vec4(vec3(1.0), point);
}