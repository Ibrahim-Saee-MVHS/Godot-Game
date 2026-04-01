extends CanvasLayer

var buttonPressed = "none"

func _retry() -> void:
	buttonPressed = "retry"
	$Control/AnimationPlayer.play("fade_out")

func menu() -> void:
	buttonPressed = "menu"
	$Control/AnimationPlayer.play("fade_out")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_out":
		if buttonPressed == "retry":
			get_tree().reload_current_scene()
		else:
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
