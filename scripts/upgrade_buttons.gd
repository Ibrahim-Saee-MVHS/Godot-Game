class_name UpgradeButtons
extends MarginContainer

static var UPGRADES = [
	null,
	null,
	null,
]
@export var ID = 0
var validUpgrades = Global.validUpgrades
var upgradeInfo = Global.upgradeInfo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomizeUpgrades()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Button/Icon.texture = upgradeInfo.get(UPGRADES[ID - 1]).get("sprite")
	$Button/Title.text = upgradeInfo.get(UPGRADES[ID - 1]).get("name")
	$Button/Description.text = upgradeInfo.get(UPGRADES[ID - 1]).get("description")

func randomizeUpgrades():
	UPGRADES[0] = randomizeUpgrade()
	UPGRADES[1] = randomizeUpgrade()
	UPGRADES[2] = randomizeUpgrade()
	UPGRADES[0] = "plasma_rounds"
	while UPGRADES[1] == UPGRADES[0]:
		UPGRADES[1] = randomizeUpgrade()
	while UPGRADES[2] == UPGRADES[1] or UPGRADES[2] == UPGRADES[0]:
		UPGRADES[2] = randomizeUpgrade()

func randomizeUpgrade():
	var totalUpgrades: Array = validUpgrades
	var totalWeights: PackedFloat32Array
	var result: String
	var player = get_tree().current_scene.get_node("Player")
	if result == "normalcy" and player.bulletType == "normal":
		totalUpgrades.erase("normalcy")
	if result == "flamethrower" and player.bulletType == "flame":
		totalUpgrades.erase("flamethrower")
	if result == "plasma_rounds" and player.bulletType == "plasma":
		totalUpgrades.erase("plasma_rounds")
	if result == "spread_shot" and player.BULLETAMOUNT + 2 >= player.MAXBULLETAMOUNT:
		totalUpgrades.erase("spread_shot")
	
	for i in range(totalUpgrades.size()):
		totalWeights.append(upgradeInfo.get(totalUpgrades[i]).get("weight"))
	var rng = RandomNumberGenerator.new()
	
	result = totalUpgrades[rng.rand_weighted(totalWeights)]
	return result
