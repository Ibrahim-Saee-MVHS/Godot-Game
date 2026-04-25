extends Label

@export var TYPE: String
var DAMAGE: float
var velocity: float = 20

func _process(delta: float) -> void:
	if TYPE == "block":
		text = "BLOCK"
	else:
		text = str(snapped(DAMAGE, 0.01)) if DAMAGE < 0 else "+" + str(snapped(DAMAGE, 0.01))
	if DAMAGE > 0:
		set("theme_override_colors/font_color", Color("00ffd8ff"))
	if !$AnimationPlayer.is_playing():
		queue_free()
	else:
		position.y -= velocity * delta
		velocity += 16 * delta
