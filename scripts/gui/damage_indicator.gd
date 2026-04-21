extends Label

var DAMAGE: float
var velocity: float = 20

func _process(delta: float) -> void:
	text = str(snapped(DAMAGE, 0.01)) if DAMAGE < 0 else "+" + str(snapped(DAMAGE, 0.01))
	if true:
		pass
	else:
		pass
	if !$AnimationPlayer.is_playing():
		queue_free()
	else:
		position.y -= velocity * delta
		velocity += 16 * delta
