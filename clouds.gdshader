shader_type canvas_item;

uniform float speed;
uniform vec2 direction;

void fragment(){
	COLOR = texture(TEXTURE, UV + TIME * speed * direction);
}