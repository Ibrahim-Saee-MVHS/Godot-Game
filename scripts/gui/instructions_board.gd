extends Control

func _exit() -> void:
	get_parent().buttonsDisabled = false
	queue_free()
