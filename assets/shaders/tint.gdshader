shader_type canvas_item;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec3 TINT = vec3(1.0, 1.0, 1.0);
	vec3 FINAL = mix(tex_color.rgb, TINT, 0.5);
	COLOR = vec4(FINAL, tex_color.a);
}
