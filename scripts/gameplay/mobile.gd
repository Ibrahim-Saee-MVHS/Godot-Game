extends CanvasLayer

var PlayerNode: Player

func _ready():
	PlayerNode = get_parent().get_node("Player")
	$Control/Ability.visible = false

func _process(_delta):
	if PlayerNode:
		if PlayerNode.ABILITY != "none":
			$Control/Ability.visible = true
			if PlayerNode.ABILITYCOOLDOWN > 0: $Control/Ability.disabled = true
			else: $Control/Ability.disabled = false
		else:
			$Control/Ability.visible = false
			$Control/Ability.disabled = true

func _ability_press():
	Input.action_press("ability")

func _ability_release():
	Input.action_release("ability")
