extends CanvasLayer

var PlayerNode: Player

func _ready():
	PlayerNode = get_parent().get_node("Player")
	$Control/Ability.visible = false

func _process(_delta):
	if PlayerNode:
		if PlayerNode.ABILITY != "none":
			$Control/Ability.visible = true
			if PlayerNode.ABILITYCOOLDOWN > 0: $Control/Ability.modulate = Color(0.5, 0.5, 0.5, 1.0)
			else: $Control/Ability.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			$Control/Ability.visible = false
		if ControlsGlobal.mobileControls.get("movement_style") == 0:
			$Control/Move/Joystick.visible = true
			$Control/Move/DPad.visible = false
		else:
			$Control/Move/Joystick.visible = false
			$Control/Move/DPad.visible = true

func _shoot_pressed():
	Input.action_press("shoot")

func _shoot_released(_input_vector):
	Input.action_release("shoot")
