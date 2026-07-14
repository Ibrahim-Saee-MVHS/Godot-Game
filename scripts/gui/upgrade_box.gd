extends Control

var UPGRADE: String = ""
var validUpgrades = Global.validUpgrades.duplicate(true)
var upgradeInfo = Global.upgradeInfo
var player: CharacterBody2D
var rarity: String

func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")
	if UPGRADE != "":
		if upgradeInfo.get(UPGRADE).has("rarity"):
			rarity = upgradeInfo.get(UPGRADE).get("rarity")
		else: rarity = "common"
		
		if upgradeInfo.get(UPGRADE).has("sprite"):
			$Button/Icon.texture = upgradeInfo.get(UPGRADE).get("sprite")
		elif UPGRADE == "flamethrower":
			var upgradeVar = player.UPGRADE.bulletUpgrades + 1 if player.bulletType == "flame" else 0
			$Button/Icon.texture = upgradeInfo.get(UPGRADE).get("sprites")[upgradeVar]
		elif UPGRADE == "icicle_throw":
			var upgradeVar = player.UPGRADE.bulletUpgrades + 1 if player.bulletType == "frost" else 0
			$Button/Icon.texture = upgradeInfo.get(UPGRADE).get("sprites")[upgradeVar]
		elif UPGRADE == "thunder_strike":
			var upgradeVar = player.UPGRADE.abilityPower + 1 if player.ABILITY == "thunder_strike" else 0
			$Button/Icon.texture = upgradeInfo.get(UPGRADE).get("sprites")[upgradeVar]
			$Button/Icon.texture = upgradeInfo.get(UPGRADE).get("sprites")[upgradeVar]
		elif UPGRADE == "thermal_leaf":
			var upgradeVar = player.UPGRADE.abilitySpecial.leaf_upgrade
			$Button/Icon.texture = upgradeInfo.get(UPGRADE).get("sprites")[upgradeVar]
		else:
			$Button/Icon.texture = upgradeInfo.get(UPGRADE).get("sprites")[0]
		if UPGRADE == "card_picker":
			$Button/Title.text = "Pick NO Card!"
		else:
			$Button/Title.text = upgradeInfo.get(UPGRADE).get("name")
	else:
		queue_free()

func _process(_delta: float) -> void:
	$Button.material.set_shader_parameter("glintColor", get_tree().current_scene.get_node("UpgradeScreen").UPGRADEGLINTS.get(rarity))
