shader_type canvas_item;

uniform vec2 direction;
uniform float speed;
uniform float strength;
uniform sampler2D Texture;
varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {
	vec2 move = direction * speed  * TIME;
	vec4 GLINT = texture(Texture, fract(UV + move)) * modulate;
	COLOR.rgb = mix(COLOR.rgb, GLINT.rgb, strength);
}
