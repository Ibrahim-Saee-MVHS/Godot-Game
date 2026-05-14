extends Control

var UPGRADE: String = ""
var validUpgrades = Global.validUpgrades.duplicate(true)
var upgradeInfo = Global.upgradeInfo
var player

func _ready() -> void:
	player = load("res://scenes/player.tscn").instantiate() #get_tree().current_scene.get_node("Player")

func _process(_delta: float) -> void:
	if UPGRADE != "":
		if upgradeInfo.get(UPGRADE).has("sprite"):
			$Button/Icon.texture = upgradeInfo.get(UPGRADE).get("sprite")
		elif UPGRADE == "flamethrower":
			var upgradeVar = player.UPGRADE.bulletUpgrades + 1 if player.bulletType == "flame" else 0
			$Button/Icon.texture = upgradeInfo.get(UPGRADE).get("sprites")[upgradeVar]
		else:
			$Button/Icon.texture = upgradeInfo.get(UPGRADE).get("sprites")[0]
		$Button/Title.text = upgradeInfo.get(UPGRADE).get("name")
