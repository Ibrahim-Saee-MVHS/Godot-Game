extends Node

var SCREENSHAKEAMOUNT: float = 0.0
var SCREENSHAKEPOWER: float = 0.0
var VIGNETTECOLOR: Vector3 = Vector3(0, 0, 0)
var VIGNETTEINTENSITY: float = 0.25

var upgradesJson: Dictionary
var validUpgrades: Array
var upgradeInfo: Dictionary

func _ready() -> void:
	loadJSONUpgrades()

func _process(_delta):
	pass

func spawnDamageIndicator(globalPos, damage):
	var damageIndicator = DAMAGEINDICATOR.instantiate()
	damageIndicator.global_position = globalPos + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	damageIndicator.DAMAGE = damage
	get_parent().add_child(damageIndicator)

func loadJSONUpgrades():
	var file = FileAccess.open("res://scripts/upgrades.json", FileAccess.READ)
	upgradesJson = JSON.parse_string(file.get_as_text())
	validUpgrades = upgradesJson.keys()
	upgradeInfo = upgradesJson
	for i in range(upgradeInfo.size()):
		if upgradeInfo.get(validUpgrades[i]).has("sprite"):
			upgradeInfo.get(validUpgrades[i]).set("sprite", load(upgradeInfo.get(validUpgrades[i]).get("sprite")))
		else:
			for k in range(upgradeInfo.get(validUpgrades[i]).get("sprites").size()):
				upgradeInfo.get(validUpgrades[i]).get("sprites").set(k, load(upgradeInfo.get(validUpgrades[i]).get("sprites")[k]))

func setGameModifiers():
	enemySpawn.types = enemyTypes.duplicate()
	enemySpawn.weights = enemyWeights.duplicate()
	enemySpawn.color = enemyColor.duplicate()
	if GAMEMODIFIERS.get("trinity_of_doom", false) == true:
		enemySpawn.types = ["bomber", "grenadier", "arsonist"]
		enemySpawn.weights = [0.5, 1, 0.75]
	if GAMEMODIFIERS.get("hard_mode", false) == true:
		var UpgradeScreen = preload("res://scenes/upgrade_screen.tscn")
		get_tree().current_scene.DIFFICULTY = 1
		get_tree().current_scene.DIFFICULTYINCREMENT = 0.25
		get_tree().current_scene.add_child(UpgradeScreen.instantiate())
	if GAMEMODIFIERS.get("juggernauts_reign_supreme", false) == true:
		if enemySpawn.types.has("juggernaut") == false:
			enemySpawn.types.insert(3, "juggernaut")
		enemySpawn.weights.insert(enemySpawn.types.find("juggernaut"), 0.75)
		for i in range(enemySpawn.color.size()):
			enemySpawn.color.set(enemySpawn.color.keys()[i], enemyColor.get("juggernaut"))

@onready var DAMAGEINDICATOR = preload("res://scenes/vfx/damage_indicator.tscn")
@onready var SFX = {
	select = preload("res://assets/sounds/blipSelect.wav"),
	shoot = preload("res://assets/sounds/shoot.wav"),
	spawn = preload("res://assets/sounds/spawn.wav"),
	explosion = preload("res://assets/sounds/explosion.wav"),
	health = preload("res://assets/sounds/health.wav"),
	hit = preload("res://assets/sounds/hit.wav"),
	enemyDeath = preload("res://assets/sounds/enemyDeath.wav"),
	playerDeath = preload("res://assets/sounds/playerDeath.wav"),
}

const shaders = {
	"flash": preload("res://assets/shaders/flash.gdshader"),
	"tint": preload("res://assets/shaders/tint.gdshader"),
	"vignette": preload("res://assets/shaders/vignette.gdshader"),
}

var GAMEMODIFIERS = {
	"trinity_of_doom": false,
	"hard_mode": false,
	"juggernauts_reign_supreme": false,
}

var playerColor = Color("00cdffff")
var playerSprite = "default"

# only includes enemy types that spawn
var enemyTypes: Array[String] = [
	"normal",
	"repeater",
	"spreader",
	"juggernaut",
	"bomber",
	"grenadier",
	"arsonist",
]

var enemyWeights: Array[float] = [
	4, # normal
	3.75, # repeater
	3.25, # spreader
	2, # juggernaut
	1, # bomber
	1.5, # grenadier
	1, # arsonist
]

var enemySpawn: Dictionary = {
	"types": [],
	"weights": [],
	"color": {},
}

var enemyColor = {
	"dummy": Color("aaaaaaff"),
	"normal": Color("ff004cff"),
	"repeater": Color("ffd73eff"),
	"spreader": Color("ff833fff"),
	"juggernaut": Color("2643ffff"),
	"bomber": Color("94ff5eff"),
	"grenadier": Color("df44ffff"),
	"arsonist": Color("8e3222ff"),
}
var enemySprites = {
	"dummy": "default",
	"normal": "default",
	"repeater": "default",
	"spreader": "default",
	"juggernaut": "default",
	"bomber": "default",
	"grenadier": "default",
	"arsonist": "default",
}

var defaultColors = {
	"player": Color("00cdffff"),
	"dummy": Color("aaaaaaff"),
	"normal": Color("ff004cff"),
	"repeater": Color("ffd73eff"),
	"spreader": Color("ff833fff"),
	"juggernaut": Color("2643ffff"),
	"bomber": Color("94ff5eff"),
	"grenadier": Color("df44ffff"),
	"arsonist": Color("8e3222ff"),
}

var characterSprites = {
	"default": load("res://assets/sprites/characters/default.png"),
	"circle": load("res://assets/sprites/characters/circle.png"),
	"triangle": load("res://assets/sprites/characters/triangle.png"),
	"icon": load("res://assets/sprites/characters/icon.png"),
}
