extends CanvasLayer

var selectedUpgrade: String
@export var buttonsDisabled = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttonsDisabled = true
	get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if get_parent().get_node("Player").HEALTH <= 0:
		get_tree().paused = false
		queue_free()
	
	$Control/Control/HBoxContainer/Upgrade1/Button.disabled = buttonsDisabled
	$Control/Control/HBoxContainer/Upgrade2/Button.disabled = buttonsDisabled
	$Control/Control/HBoxContainer/Upgrade3/Button.disabled = buttonsDisabled

func _upgrade1Selected() -> void:
	selectedUpgrade = $Control/Control/HBoxContainer/Upgrade1.UPGRADES[0]
	upgradePlayer()

func _upgrade2Selected() -> void:
	selectedUpgrade = $Control/Control/HBoxContainer/Upgrade2.UPGRADES[1]
	upgradePlayer()
	
func _upgrade3Selected() -> void:
	selectedUpgrade = $Control/Control/HBoxContainer/Upgrade3.UPGRADES[2]
	upgradePlayer()

func endUpgrade():
	$AnimationPlayer.play("upgradesDown")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "upgradesDown":
		get_tree().paused = false
		queue_free()

func upgradePlayer():
	match selectedUpgrade:
		"hearty":
			get_parent().get_node("Player").UPGRADE.health += 5
			get_parent().get_node("Player").HEALTH += get_parent().get_node("Player").MAXHEALTH
		"spread_shot":
			get_parent().get_node("Player").UPGRADE.bulletAmount += 2
		"speed_up":
			get_parent().get_node("Player").UPGRADE.speed += 4
		"quick_fingers":
			get_parent().get_node("Player").UPGRADE.firerate -= 2
		"bullet_enhancer":
			get_parent().get_node("Player").UPGRADE.damage += 1
		"reinforced_chamber":
			get_parent().get_node("Player").UPGRADE.bulletSpeed += 6
			get_parent().get_node("Player").UPGRADE.firerate += 4
		"flamethrower":
			get_parent().get_node("Player").bulletType = "flame"
			get_parent().get_node("Player").BASEFIRERATE = 1.0
			get_parent().get_node("Player").BASEDAMAGE = 0.01
			get_parent().get_node("Player").BASEBULLETSPEED = 120
	endUpgrade()
