shader_type canvas_item;

uniform vec2 direction;
uniform float speed;
uniform sampler2D Texture: source_color, repeat_enable, filter_nearest;
uniform sampler2D glintTexture: source_color, repeat_enable, filter_nearest;
uniform vec2 tiling = vec2(1.0, 1.0);
uniform vec4 glintColor: source_color = vec4(1.0, 1.0, 1.0, 0.0);
varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {
	vec2 move = direction * speed * TIME;
	vec4 tex_color = texture(TEXTURE, UV);
	vec4 GLINT = texture(Texture, fract((UV * tiling) + move)) * modulate;
	vec4 glint_tex_color = texture(glintTexture, fract((UV * tiling) + move)) * glintColor;
	vec4 card = tex_color + (glint_tex_color * glint_tex_color.a);
	COLOR.rgb = mix(card.rgb, GLINT.rgb, GLINT.a);
}
