extends CanvasLayer

var selectedUpgrade: String
@export var buttonsDisabled = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttonsDisabled = true
	get_tree().paused = true
	if get_parent().get_node("Player").LEVEL == 1:
		$ColorRect/Title.text = "Free Upgrade\nYou'll need it."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if get_parent().get_node("Player").HEALTH <= 0:
		get_tree().paused = false
		queue_free()
	if Engine.time_scale < 1.0:
		$AnimationPlayer.speed_scale = 2.0 / Engine.time_scale
	
	if get_parent().get_node("HUD").debug_mode == true and $AnimationPlayer.speed_scale < 4.0:
		$AnimationPlayer.speed_scale = 4.0
	elif get_parent().get_node("HUD").debug_mode == false and $AnimationPlayer.speed_scale > 2.0:
		$AnimationPlayer.speed_scale = 2.0
	
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
			get_parent().get_node("Player").UPGRADE.speed -= 1
			get_parent().get_node("Player").MAXHEALTH = get_parent().get_node("Player").MAXHEALTH + 5
			if get_parent().get_node("Player").HEALTH + 35 <= get_parent().get_node("Player").MAXHEALTH:
				get_parent().get_node("Player").HEALTH += 35
			else:
				get_parent().get_node("Player").HEALTH = get_parent().get_node("Player").MAXHEALTH
		"spread_shot":
			get_parent().get_node("Player").UPGRADE.bulletAmount += 2
			get_parent().get_node("Player").UPGRADE.damage -= 2
		"speed_up":
			get_parent().get_node("Player").UPGRADE.speed += 4
		"quick_fingers":
			get_parent().get_node("Player").UPGRADE.firerate -= 4
		"bullet_enhancer":
			get_parent().get_node("Player").UPGRADE.damage += 4
			get_parent().get_node("Player").UPGRADE.firerate += 2
		"reinforced_chamber":
			get_parent().get_node("Player").UPGRADE.bulletSpeed += 6
			get_parent().get_node("Player").UPGRADE.damage += 1
			get_parent().get_node("Player").UPGRADE.firerate -= 3
		"flamethrower":
			if get_parent().get_node("Player").bulletType != "flame":
				get_parent().get_node("Player").bulletType = "flame"
				get_parent().get_node("Player").UPGRADE.bulletUpgrades = 0
				get_parent().get_node("Player").UPGRADE.explosiveness = 0
				get_parent().get_node("Player").UPGRADE.ricochet = 0
				get_parent().get_node("Player").UPGRADE.homing = 0
			else:
				get_parent().get_node("Player").UPGRADE.bulletUpgrades += 1
		"plasma_rounds":
			if get_parent().get_node("Player").bulletType != "plasma":
				get_parent().get_node("Player").bulletType = "plasma"
				get_parent().get_node("Player").UPGRADE.bulletUpgrades = 0
				get_parent().get_node("Player").UPGRADE.explosiveness = 0
				get_parent().get_node("Player").UPGRADE.ricochet = 0
				get_parent().get_node("Player").UPGRADE.homing = 0
			else:
				get_parent().get_node("Player").UPGRADE.bulletUpgrades += 1
		"normalcy":
			get_parent().get_node("Player").bulletType = "normal"
			get_parent().get_node("Player").UPGRADE.bulletUpgrades = 0
			get_parent().get_node("Player").UPGRADE.explosiveness = 0
			get_parent().get_node("Player").UPGRADE.ricochet = 0
			get_parent().get_node("Player").UPGRADE.homing = 0
		"sulfuric_ammo":
			get_parent().get_node("Player").UPGRADE.explosiveness += 0.25
			if get_parent().get_node("Player").MAXHEALTH - 5 > 0:
				get_parent().get_node("Player").UPGRADE.health -= 5
		"cailber_increase":
			get_parent().get_node("Player").UPGRADE.bulletUpgrades += 1
			get_parent().get_node("Player").UPGRADE.bulletSpeed -= 2
		"flashtime":
			if get_parent().get_node("Player").ABILITY != "flashtime":
				get_parent().get_node("Player").ABILITY = "flashtime"
				Abilities.abilityTimer = 0
				get_parent().get_node("Player").ABILITYCOOLDOWN = 0
				get_parent().get_node("Player").UPGRADE.abilityPower = 0
				get_parent().get_node("Player").UPGRADE.abilityDuration = 0
				get_parent().get_node("Player").UPGRADE.abilityCooldown = 0
			else:
				get_parent().get_node("Player").UPGRADE.abilityPower += 0.5
				get_parent().get_node("Player").UPGRADE.abilityDuration += 3
		"detonation":
			if get_parent().get_node("Player").ABILITY != "detonation":
				get_parent().get_node("Player").ABILITY = "detonation"
				Abilities.abilityTimer = 0
				get_parent().get_node("Player").ABILITYCOOLDOWN = 0
				get_parent().get_node("Player").UPGRADE.abilityPower = 0
				get_parent().get_node("Player").UPGRADE.abilityDuration = 0
				get_parent().get_node("Player").UPGRADE.abilityCooldown = 0
				if get_parent().get_node("Player").MAXHEALTH - 50 > 0:
					get_parent().get_node("Player").UPGRADE.health -= 50
			else:
				get_parent().get_node("Player").UPGRADE.abilityPower += 0.5
				get_parent().get_node("Player").UPGRADE.abilityCooldown -= 4
		"cooldown_reduction":
			get_parent().get_node("Player").UPGRADE.abilityCooldown -= 5
		"dash":
			if get_parent().get_node("Player").ABILITY != "dash":
				get_parent().get_node("Player").ABILITY = "dash"
				Abilities.abilityTimer = 0
				get_parent().get_node("Player").ABILITYCOOLDOWN = 0
				get_parent().get_node("Player").UPGRADE.abilityPower = 0
				get_parent().get_node("Player").UPGRADE.abilityDuration = 0
				get_parent().get_node("Player").UPGRADE.abilityCooldown = 0
			else:
				get_parent().get_node("Player").UPGRADE.abilityPower += 1
				get_parent().get_node("Player").UPGRADE.abilityDuration += 0.025
		"ricochet":
			get_parent().get_node("Player").UPGRADE.ricochet += 1
			get_parent().get_node("Player").UPGRADE.homing = 0
		"homing_rounds":
			get_parent().get_node("Player").UPGRADE.homing += 1
			get_parent().get_node("Player").UPGRADE.ricochet = 0
		"shield":
			if get_parent().get_node("Player").ABILITY != "shield":
				get_parent().get_node("Player").ABILITY = "shield"
				Abilities.abilityTimer = 0
				get_parent().get_node("Player").ABILITYCOOLDOWN = 0
				get_parent().get_node("Player").UPGRADE.abilityPower = 0
				get_parent().get_node("Player").UPGRADE.abilityDuration = 0
				get_parent().get_node("Player").UPGRADE.abilityCooldown = 0
			else:
				get_parent().get_node("Player").UPGRADE.abilityPower += 1
				get_parent().get_node("Player").UPGRADE.abilityCooldown -= 2
	endUpgrade()
