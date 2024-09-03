shader_type canvas_item;

uniform sampler2D NOISE_PATTERN: repeat_enable;
uniform vec2 noise_scale1 = vec2(1,1);
uniform vec2 noise_scale2 = vec2(1,1);
uniform vec2 scroll = vec2(0.5, 0.5);
uniform vec2 scroll2 = vec2(0.3, 0.3);
uniform sampler2D TONE_MAPPING;
uniform float blur: hint_range(0.0, 20.0) = 3.0;
uniform float base_intensity: hint_range(0.0, 0.5) = 0.1;
uniform float intensity_factor: hint_range(0.0, 5.0) = 1.5;

void fragment() {
	float texture_alpha = texture(TEXTURE, UV, blur).a;
	float pattern_intensity = texture(NOISE_PATTERN, UV * noise_scale1 + TIME * scroll).r;
	float pattern_intensity2 = texture(NOISE_PATTERN, UV * noise_scale2 + TIME * scroll2).r;
	float intensity = texture_alpha * intensity_factor *
		(pattern_intensity * pattern_intensity2 + base_intensity);
	COLOR = texture(TONE_MAPPING, vec2(intensity));
}