extends Control

func _on_exit_pressed():
	get_parent().buttonsDisabled = false
	queue_free()
