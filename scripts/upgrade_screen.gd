extends CanvasLayer

var selectedUpgrade: String
@export var buttonsDisabled = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttonsDisabled = true
	get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Control/HBoxContainer/Upgrade1/Button.disabled = buttonsDisabled
	$Control/HBoxContainer/Upgrade2/Button.disabled = buttonsDisabled
	$Control/HBoxContainer/Upgrade3/Button.disabled = buttonsDisabled

func _upgrade1Selected() -> void:
	selectedUpgrade = $Control/HBoxContainer/Upgrade1.UPGRADES[0]
	upgradePlayer()

func _upgrade2Selected() -> void:
	selectedUpgrade = $Control/HBoxContainer/Upgrade2.UPGRADES[1]
	upgradePlayer()
	
func _upgrade3Selected() -> void:
	selectedUpgrade = $Control/HBoxContainer/Upgrade3.UPGRADES[2]
	upgradePlayer()
	
func upgradePlayer():
	match selectedUpgrade:
		"hearty":
			get_parent().get_node("Player").UPGRADE.health += 5
			get_parent().get_node("Player").HEALTH += get_parent().get_node("Player").MAXHEALTH
		"spread_shot":
			get_parent().get_node("Player").BULLETAMOUNT += 2
		"speed_up":
			get_parent().get_node("Player").UPGRADE.speed += 2
	endUpgrade()

func endUpgrade():
	$AnimationPlayer.play("upgradesDown")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "upgradesDown":
		get_tree().paused = false
		queue_free()
