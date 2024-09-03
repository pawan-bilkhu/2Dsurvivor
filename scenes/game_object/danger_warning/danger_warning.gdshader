shader_type canvas_item;
uniform float lerp_percent : hint_range(0.0, 1.0, 0.1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 texture_color = texture(TEXTURE, UV);
	vec4 final_color = mix(texture_color, vec4(1.0, 1.0, 1.0, 0.0), lerp_percent);
	
	COLOR = final_color;
}
