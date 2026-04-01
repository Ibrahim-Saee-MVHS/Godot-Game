shader_type canvas_item;

uniform float intensity = 2.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR.rgb = tex_color.rgb * vec3(intensity, intensity, intensity);
}
