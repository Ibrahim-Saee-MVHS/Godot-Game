extends Control

func _ready() -> void:
	if not Global.isMobileDevice:
		if str(ControlsGlobal.currentControls) != str(ControlsGlobal.defaultControls):
			$Panel/Control/Desktop/WASD.visible = false
			$Panel/Control/Desktop/Mouse.visible = false
			$Panel/Control/Desktop/Text.visible = true
	else:
		$Panel/Control/Desktop.visible = false
		$Panel/Control/Mobile.visible = true

func _exit() -> void:
	get_parent().buttonsDisabled = false
	queue_free()
