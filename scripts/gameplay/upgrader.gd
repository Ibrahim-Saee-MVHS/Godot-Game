extends Node

func upgrade(selectedUpgrade):
	if get_tree().current_scene is GameScene:
		var playerNode = get_tree().current_scene.get_node("Player")
		match selectedUpgrade:
			"hearty":
				playerNode.UPGRADE.health += 10
				playerNode.UPGRADE.speed -= 1
				playerNode.MAXHEALTH = playerNode.MAXHEALTH + 10
				if playerNode.HEALTH + 35 <= playerNode.MAXHEALTH:
					playerNode.HEALTH += 35
				else:
					playerNode.HEALTH = playerNode.MAXHEALTH
			"spread_shot":
				playerNode.UPGRADE.bulletAmount += 2
				playerNode.UPGRADE.damage -= 2
			"speed_up":
				playerNode.UPGRADE.speed += 4
			"quick_fingers":
				playerNode.UPGRADE.firerate -= 4
			"bullet_enhancer":
				playerNode.UPGRADE.damage += 4
				playerNode.UPGRADE.firerate += 2
			"reinforced_chamber":
				playerNode.UPGRADE.bulletSpeed += 6
				playerNode.UPGRADE.damage += 1
				playerNode.UPGRADE.firerate -= 3
				playerNode.UPGRADE.defense -= 5
			"flamethrower":
				if playerNode.bulletType != "flame":
					playerNode.bulletType = "flame"
					playerNode.UPGRADE.bulletUpgrades = 0
					playerNode.UPGRADE.explosiveness = 0
					playerNode.UPGRADE.ricochet = 0
					playerNode.UPGRADE.homing = 0
				else:
					playerNode.UPGRADE.bulletUpgrades += 1
			"plasma_rounds":
				if playerNode.bulletType != "plasma":
					playerNode.bulletType = "plasma"
					playerNode.UPGRADE.bulletUpgrades = 0
					playerNode.UPGRADE.explosiveness = 0
					playerNode.UPGRADE.ricochet = 0
					playerNode.UPGRADE.homing = 0
				else:
					playerNode.UPGRADE.bulletUpgrades += 1
			"normalcy":
				playerNode.bulletType = "normal"
				playerNode.UPGRADE.bulletUpgrades = 0
				playerNode.UPGRADE.explosiveness = 0
				playerNode.UPGRADE.ricochet = 0
				playerNode.UPGRADE.homing = 0
			"sulfuric_ammo":
				playerNode.UPGRADE.explosiveness += 0.25
				if playerNode.MAXHEALTH - 5 > 0:
					playerNode.UPGRADE.health -= 5
			"cailber_increase":
				playerNode.UPGRADE.bulletUpgrades += 1
				playerNode.UPGRADE.bulletSpeed -= 2
			"flashtime":
				if playerNode.ABILITY != "flashtime":
					playerNode.ABILITY = "flashtime"
					Abilities.abilityTimer = 0
					playerNode.ABILITYCOOLDOWN = 0
					playerNode.UPGRADE.abilityPower = 0
					playerNode.UPGRADE.abilityDuration = 0
					playerNode.UPGRADE.abilityCooldown = 0
				else:
					playerNode.UPGRADE.abilityPower += 0.5
					playerNode.UPGRADE.abilityDuration += 3
			"detonation":
				if playerNode.ABILITY != "detonation":
					playerNode.ABILITY = "detonation"
					Abilities.abilityTimer = 0
					playerNode.ABILITYCOOLDOWN = 0
					playerNode.UPGRADE.abilityPower = 0
					playerNode.UPGRADE.abilityDuration = 0
					playerNode.UPGRADE.abilityCooldown = 0
					if playerNode.MAXHEALTH - 50 > 0:
						playerNode.UPGRADE.health -= 50
				else:
					playerNode.UPGRADE.abilityPower += 0.5
					playerNode.UPGRADE.abilityCooldown -= 4
			"cooldown_reduction":
				playerNode.UPGRADE.abilityCooldown -= 4
			"dash":
				if playerNode.ABILITY != "dash":
					playerNode.ABILITY = "dash"
					Abilities.abilityTimer = 0
					playerNode.ABILITYCOOLDOWN = 0
					playerNode.UPGRADE.abilityPower = 0
					playerNode.UPGRADE.abilityDuration = 0
					playerNode.UPGRADE.abilityCooldown = 0
				else:
					playerNode.UPGRADE.abilityPower += 1
					playerNode.UPGRADE.abilityDuration += 0.025
			"ricochet":
				playerNode.UPGRADE.ricochet += 1
				playerNode.UPGRADE.homing = 0
			"homing_rounds":
				playerNode.UPGRADE.homing += 1
				playerNode.UPGRADE.ricochet = 0
			"shield":
				if playerNode.ABILITY != "shield":
					playerNode.ABILITY = "shield"
					Abilities.abilityTimer = 0
					playerNode.ABILITYCOOLDOWN = 0
					playerNode.UPGRADE.abilityPower = 0
					playerNode.UPGRADE.abilityDuration = 0
					playerNode.UPGRADE.abilityCooldown = 0
				else:
					playerNode.UPGRADE.abilityPower += 1
					playerNode.UPGRADE.abilityCooldown -= 2
			"boomerang":
				if playerNode.bulletType != "boomerang":
					playerNode.bulletType = "boomerang"
					playerNode.UPGRADE.bulletUpgrades = 0
					playerNode.UPGRADE.explosiveness = 0
					playerNode.UPGRADE.ricochet = 0
					playerNode.UPGRADE.homing = 0
				else:
					playerNode.UPGRADE.bulletUpgrades += 1
			"card_picker":
				if playerNode.HEALTH - 10 > 0:
					playerNode.UPGRADE.health -= 10
					playerNode.MAXHEALTH = playerNode.MAXHEALTH - 10
					if playerNode.HEALTH > playerNode.MAXHEALTH:
						playerNode.HEALTH = playerNode.MAXHEALTH
			"defense_up":
				playerNode.UPGRADE.defense += 4
			"pressure_washer":
				if playerNode.bulletType != "water":
					playerNode.bulletType = "water"
					playerNode.UPGRADE.bulletUpgrades = 0
					playerNode.UPGRADE.explosiveness = 0
					playerNode.UPGRADE.ricochet = 0
					playerNode.UPGRADE.homing = 0
				else:
					playerNode.UPGRADE.bulletUpgrades += 1
			"dark_pulse":
				if playerNode.bulletType != "dark":
					playerNode.bulletType = "dark"
					playerNode.UPGRADE.bulletUpgrades = 0
					playerNode.UPGRADE.explosiveness = 0
					playerNode.UPGRADE.ricochet = 0
					playerNode.UPGRADE.homing = 0
				else:
					playerNode.UPGRADE.bulletUpgrades += 1
			"lightbolt":
				if playerNode.bulletType != "light":
					playerNode.bulletType = "light"
					playerNode.UPGRADE.bulletUpgrades = 0
					playerNode.UPGRADE.explosiveness = 0
					playerNode.UPGRADE.ricochet = 0
					playerNode.UPGRADE.homing = 0
				else:
					playerNode.UPGRADE.bulletUpgrades += 1
			"leaf_summon":
				if playerNode.ABILITY != "leaf_summon":
					playerNode.ABILITY = "leaf_summon"
					Abilities.abilityTimer = 0
					playerNode.ABILITYCOOLDOWN = 0
					playerNode.UPGRADE.abilityPower = 0
					playerNode.UPGRADE.abilityDuration = 0
					playerNode.UPGRADE.abilityCooldown = 0
				else:
					playerNode.UPGRADE.abilityPower += 1
					playerNode.UPGRADE.abilityCooldown -= 2
					playerNode.ABILITYCOOLDOWN = playerNode.ABILITYMAXCOOLDOWN
