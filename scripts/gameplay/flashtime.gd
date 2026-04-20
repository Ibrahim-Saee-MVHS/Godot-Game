extends ColorRect

func _process(_delta):
	if Abilities.abilityTimer <= 0:
		$AnimationPlayer.play("fade_out")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_out":
		queue_free()
