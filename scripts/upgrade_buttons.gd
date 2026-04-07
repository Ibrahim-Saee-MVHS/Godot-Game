class_name UpgradeButtons
extends MarginContainer

@onready var validUpgrades = [
	"hearty",
	"spread_shot",
	"speed_up",
]
@onready var upgradeInfo = {
	hearty = {
		sprite = preload("res://assets/sprites/upgrade_icons/hearty.png"),
		name = "Hearty",
		description = "Gives +5 HEALTH and heals the player",
	},
	spread_shot = {
		sprite = preload("res://assets/sprites/upgrade_icons/spread_shot.png"),
		name = "Spread Shot",
		description = "Gives +2 BULLETS",
	},
	speed_up = {
		sprite = preload("res://assets/sprites/upgrade_icons/speed_up.png"),
		name = "Speed Up",
		description = "Speeds up the player by +2",
	},
}
static var UPGRADES = [
	null,
	null,
	null,
]
@export var ID = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomizeUpgrade()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
