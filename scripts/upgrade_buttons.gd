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
	randomizeUpgrade()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Button/Icon.texture = upgradeInfo.get(UPGRADES[ID - 1]).get("sprite")
	$Button/Title.text = upgradeInfo.get(UPGRADES[ID - 1]).get("name")
	$Button/Description.text = upgradeInfo.get(UPGRADES[ID - 1]).get("description")

func randomizeUpgrade():
	UPGRADES[0] = validUpgrades[randi_range(0, validUpgrades.size() - 1)]
	UPGRADES[1] = validUpgrades[randi_range(0, validUpgrades.size() - 1)]
	UPGRADES[2] = validUpgrades[randi_range(0, validUpgrades.size() - 1)]
	while UPGRADES[1] == UPGRADES[0]:
		UPGRADES[1] = validUpgrades[randi_range(0, validUpgrades.size() - 1)]
	while UPGRADES[2] == UPGRADES[1] or UPGRADES[2] == UPGRADES[0]:
		UPGRADES[2] = validUpgrades[randi_range(0, validUpgrades.size() - 1)]
