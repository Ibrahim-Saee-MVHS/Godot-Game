class_name UpgradeButtons
extends MarginContainer

static var UPGRADES = [
	null,
	null,
	null,
]
@export var ID = 0
var validUpgrades = Global.validUpgrades.duplicate(true)
var upgradeInfo = Global.upgradeInfo
var player: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ID > 1:
		validUpgrades.erase(UPGRADES[0])
	if ID == 3:
		validUpgrades.erase(UPGRADES[1])
	player = get_tree().current_scene.get_node("Player")
	UPGRADES[ID - 1] = randomizeUpgrade()
	setUpgradeCards()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func setUpgradeCards():
	if upgradeInfo.get(UPGRADES[ID - 1]).has("sprite"):
		$Button/Icon.texture = upgradeInfo.get(UPGRADES[ID - 1]).get("sprite")
	elif UPGRADES[ID - 1] == "flamethrower":
		var upgradeVar = player.UPGRADE.bulletUpgrades + 1 if player.bulletType == "flame" else 0
		$Button/Icon.texture = upgradeInfo.get(UPGRADES[ID - 1]).get("sprites")[upgradeVar]
	else:
		$Button/Icon.texture = upgradeInfo.get(UPGRADES[ID - 1]).get("sprites")[0]
	$Button/Title.text = upgradeInfo.get(UPGRADES[ID - 1]).get("name")
	$Button/Description.text = upgradeInfo.get(UPGRADES[ID - 1]).get("description")

func randomizeUpgrade():
	# the duplicate() part is to make sure both arrays are unique and wont modify the important one
	var totalUpgrades = validUpgrades.duplicate(true)
	var totalWeights: PackedFloat32Array
	var result: String
	player = get_tree().current_scene.get_node("Player")
	if player.bulletType == "normal":
		totalUpgrades.erase("normalcy")
	if player.bulletType == "flame" and player.UPGRADE.bulletUpgrades >= 3:
		totalUpgrades.erase("flamethrower")
	if player.bulletType == "plasma" and player.UPGRADE.bulletUpgrades >= 2:
		totalUpgrades.erase("plasma_rounds")
	if player.BULLETAMOUNT + 2 >= player.MAXBULLETAMOUNT:
		totalUpgrades.erase("spread_shot")
	if player.bulletType != "normal" or player.UPGRADE.explosiveness >= 2:
		totalUpgrades.erase("sulfuric_ammo")
	if player.bulletType != "normal" or player.UPGRADE.bulletUpgrades >= 4:
		totalUpgrades.erase("cailber_increase")
	if player.ABILITY == "flashtime" and player.ABILITYPOWER >= 3:
		totalUpgrades.erase("flashtime")
	if (player.ABILITY == "detonation" and player.ABILITYPOWER >= 3) or (player.ABILITY != "detonation" and player.MAXHEALTH < 40):
		totalUpgrades.erase("detonation")
	if player.ABILITYMAXCOOLDOWN <= 6 or player.ABILITY == "none":
		totalUpgrades.erase("cooldown_reduction")
	if player.ABILITY == "dash" and player.UPGRADE.abilityPower >= 3:
		totalUpgrades.erase("dash")
	
	for i in range(totalUpgrades.size()):
		totalWeights.append(upgradeInfo.get(totalUpgrades[i]).get("weight"))
	var rng = RandomNumberGenerator.new()
	
	result = totalUpgrades[rng.rand_weighted(totalWeights)]
	validUpgrades.erase(result)
	return result
