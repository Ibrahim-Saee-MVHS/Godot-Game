shader_type canvas_item;

uniform vec2 direction;
uniform float speed;
uniform sampler2D Texture: source_color, repeat_enable, filter_nearest;
uniform vec2 tiling = vec2(1.0, 1.0);
varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {
	vec2 move = direction * speed * TIME;
	vec4 tex_color = texture(TEXTURE, UV);
	vec4 GLINT = texture(Texture, fract((UV * tiling) + move)) * modulate;
	COLOR.rgb = mix(tex_color.rgb, GLINT.rgb, GLINT.a);
}
