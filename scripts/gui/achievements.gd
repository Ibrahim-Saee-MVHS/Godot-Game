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
		"locked": true,
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

func isAchievementUnlocked(achievementID: String):
	if ACHIEVEMENTS.get(achievementID) is bool:
		return ACHIEVEMENTS.get(achievementID)
	else:
		if ACHIEVEMENTS.get(achievementID).values()[0] is bool:
			return (not false in ACHIEVEMENTS.get(achievementID).values())
		elif ACHIEVEMENTS.get(achievementID).values()[0] is int:
			return ACHIEVEMENTS.get(achievementID).get("progress") >= ACHIEVEMENTS.get(achievementID).get("max_progress")

func getAchievementProgress(achievementID: String, getMaxProgress: bool):
	if ACHIEVEMENTS.get(achievementID) is not bool:
		if ACHIEVEMENTS.get(achievementID).values()[0] is bool:
			if getMaxProgress == false:
				var counter = 0
				for i in range(ACHIEVEMENTS.get(achievementID).size() - 1):
					if ACHIEVEMENTS.get(achievementID).get(ACHIEVEMENTS.get(achievementID).keys()[i]) == true:
						counter += 1
				return counter
			else:
				return ACHIEVEMENTS.get(achievementID).size()
		elif ACHIEVEMENTS.get(achievementID).values()[0] is int: 
			if getMaxProgress == false:
				return ACHIEVEMENTS.get(achievementID).get("max_progress")
			else:
				return ACHIEVEMENTS.get(achievementID).get("progress")
	else:
		return 0

func achievementUnlocking():
	var PlayerNode = get_tree().current_scene.get_node("Player")
	if isAchievementUnlocked("normal") == false:
		if PlayerNode.bulletType == "normal" and PlayerNode.UPGRADE.bulletUpgrades >= 4:
			unlockAchievement("normal")
			ACHIEVEMENTS.set("normal", true)
			
	if isAchievementUnlocked("flame") == false:
		if PlayerNode.bulletType == "flame" and PlayerNode.UPGRADE.bulletUpgrades >= 4:
			unlockAchievement("flame")
			ACHIEVEMENTS.set("flame", true)
			
	if isAchievementUnlocked("plasma") == false:
		if PlayerNode.bulletType == "plasma" and PlayerNode.UPGRADE.bulletUpgrades >= 2:
			unlockAchievement("plasma")
			ACHIEVEMENTS.set("plasma", true)
			
	if isAchievementUnlocked("boomerang") == false:
		if PlayerNode.bulletType == "boomerang" and PlayerNode.UPGRADE.bulletUpgrades >= 3:
			unlockAchievement("boomerang")
			ACHIEVEMENTS.set("boomerang", true)
			
	if isAchievementUnlocked("elemental") == false:
		if PlayerNode.bulletType == "flame" and PlayerNode.UPGRADE.bulletUpgrades >= 4:
			ACHIEVEMENTS.get("elemental").set("flame", true)
		if ACHIEVEMENTS.get("elemental").get("locked") == false:
			unlockAchievement("elemental")
			ACHIEVEMENTS.get("elemental").set("locked", true)
			
	if isAchievementUnlocked("super_speed") == false:
		if (PlayerNode.ABILITY == "flashtime" and PlayerNode.UPGRADE.abilityPower >= 3) and PlayerNode.UPGRADE.speed >= 64:
			unlockAchievement("super_speed")
			ACHIEVEMENTS.set("super_speed", true)
	
