extends Node

var TOAST = load("res://scenes/achievement_toast.tscn")

var save_directory = "user://" #"user://LevelShooter/"
var AchievementList: Dictionary
var ACHIEVEMENTS = {
	"normal": false,
	"plasma": false,
	"flame": false,
	"boomerang": false,
	"elemental": {
		"thunder": false,
		"frost": false,
		"flame": false,
		"earth": false,
		"air": false,
		"water": false,
		"nature": false,
		"light": false,
		"dark": false,
	},
	"super_speed": false,
}

func _ready() -> void:
	SettingsGlobal.checkSaveDir()
	loadAchievementList()
	loadAchievements()

func _process(_delta: float) -> void:
	if get_tree().current_scene is GameScene:
		achievementUnlocking()

func loadAchievementList():
	var file = FileAccess.open("res://scripts/achievement_list.json", FileAccess.READ)
	AchievementList = JSON.parse_string(file.get_as_text())

func loadAchievements():
	if not FileAccess.file_exists("user://achievements.save"):
		saveAchievements()
	var file = FileAccess.open("user://achievements.save", FileAccess.READ)
	ACHIEVEMENTS = JSON.parse_string(file.get_as_text())

func saveAchievements():
	var file = FileAccess.open("user://achievements.save", FileAccess.WRITE)
	file.store_line(JSON.stringify(ACHIEVEMENTS))

func unlockAchievement(achievementID):
	var AchievementToast = TOAST.instantiate()
	AchievementToast.get_node("Control/Toast/Frame/Icon").texture = load(str("res://assets/sprites/achievement_icons/", achievementID, ".png"))
	AchievementToast.get_node("Control/Toast/Name").text = AchievementList[achievementID].get("name")
	get_tree().current_scene.add_child(AchievementToast)
	saveAchievements()
	print(achievementID)

func achievementUnlocking():
	var PlayerNode = get_tree().current_scene.get_node("Player")
	if ACHIEVEMENTS.get("normal") == false:
		if PlayerNode.bulletType == "normal" and PlayerNode.UPGRADE.bulletUpgrades >= 4:
			unlockAchievement("normal")
			ACHIEVEMENTS.set("normal", true)
			
	if ACHIEVEMENTS.get("flame") == false:
		if PlayerNode.bulletType == "flame" and PlayerNode.UPGRADE.bulletUpgrades >= 4:
			unlockAchievement("flame")
			ACHIEVEMENTS.set("flame", true)
			
	if ACHIEVEMENTS.get("plasma") == false:
		if PlayerNode.bulletType == "plasma" and PlayerNode.UPGRADE.bulletUpgrades >= 2:
			unlockAchievement("plasma")
			ACHIEVEMENTS.set("plasma", true)
			
	if ACHIEVEMENTS.get("boomerang") == false:
		if PlayerNode.bulletType == "boomerang" and PlayerNode.UPGRADE.bulletUpgrades >= 3:
			unlockAchievement("boomerang")
			ACHIEVEMENTS.set("boomerang", true)
			
	if ACHIEVEMENTS.get("super_speed") == false:
		if (PlayerNode.ABILITY == "flashtime" and PlayerNode.UPGRADE.abilityPower >= 3) and PlayerNode.UPGRADE.speed >= 64:
			unlockAchievement("super_speed")
			ACHIEVEMENTS.set("super_speed", true)
