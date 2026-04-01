shader_type canvas_item;

uniform vec3 new_color = vec3(1.0, 0.0, 0.0);
uniform float deltaTime = 0.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec3 FINAL = mix(new_color, tex_color.rgb, smoothstep(1.0, 0.0, deltaTime));
	COLOR = vec4(FINAL, tex_color.a);
}
