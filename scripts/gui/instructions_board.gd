extends Control

func _ready() -> void:
	if str(ControlsGlobal.currentControls) != str(ControlsGlobal.defaultControls):
		$Panel/Control/WASD.visible = false
		$Panel/Control/Mouse.visible = false
		$Panel/Control/Text.visible = true

func _exit() -> void:
	get_parent().buttonsDisabled = false
	queue_free()
