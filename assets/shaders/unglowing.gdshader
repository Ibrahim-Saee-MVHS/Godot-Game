shader_type canvas_item;


void fragment() {
	vec4 newColor = texture(TEXTURE, UV);
	COLOR = clamp(newColor, vec4(0, 0, 0, 0), vec4(1, 1, 1, 1));
}
