extends Node

var TOAST = load("res://scenes/achievement_toast.tscn")

var save_directory = "user://" #"user://LevelShooter/"
var AchievementToastQueue: Array[String	]
var AchievementList: Dictionary
var ACHIEVEMENTS: Dictionary
var initialAchievements = {
	"normal": false,
	"plasma": false,
	"flame": false,
	"boomerang": false,
	"elemental": {
		"unlocked": false,
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
	"dash_smash": false,
	"level_10": {
		"unlocked": false,
		"max_progress": 10,
		"progress": 0,
	},
	"level_25": {
		"unlocked": false,
		"max_progress": 25,
		"progress": 0,
	},
	"level_50": {
		"unlocked": false,
		"max_progress": 50,
		"progress": 0,
	},
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
		ACHIEVEMENTS = initialAchievements
		saveAchievements()
	var file = FileAccess.open("user://achievements.save", FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())
	json.sort()
	var init = initialAchievements.duplicate(true)
	init.sort()
	if init != json:
		for i in range(init.keys().size()):
			json.get_or_add(init.keys()[i], false)
		file.store_line(JSON.stringify(json))
	ACHIEVEMENTS = json

func saveAchievements():
	var file = FileAccess.open("user://achievements.save", FileAccess.WRITE)
	file.store_line(JSON.stringify(ACHIEVEMENTS))

func unlockAchievement(achievementID):
	saveAchievements()
	if not AchievementToastQueue.has(achievementID):
		AchievementToastQueue.append(achievementID)
		
	if AchievementToastQueue[0] != achievementID and get_tree().current_scene.has_node("AchievementToast"):
		var firstID = AchievementToastQueue[0]
		await get_tree().create_timer(4.5).timeout
		AchievementToastQueue.erase(firstID)
		
	if get_tree().current_scene is GameScene:
		var AchievementToast = TOAST.instantiate()
		AchievementToast.get_node("Control/Toast/Frame/Icon").texture = load(str("res://assets/sprites/achievement_icons/", achievementID, ".png"))
		AchievementToast.get_node("Control/Toast/Name").text = AchievementList[achievementID].get("name")
		get_tree().current_scene.add_child(AchievementToast)

func isAchievementUnlocked(achievementID: String):
	if ACHIEVEMENTS.get(achievementID) is bool:
		return ACHIEVEMENTS.get(achievementID)
	else:
		return ACHIEVEMENTS.get(achievementID).get("unlocked")

func getAchievementProgress(achievementID: String, getMaxProgress: bool = false):
	if ACHIEVEMENTS.get(achievementID) is not bool:
		if ACHIEVEMENTS.get(achievementID).values()[1] is bool:
			if getMaxProgress == false:
				var counter = 0
				for i in range(ACHIEVEMENTS.get(achievementID).size() - 1):
					if ACHIEVEMENTS.get(achievementID).keys()[i] == "unlocked": continue
					if ACHIEVEMENTS.get(achievementID).get(ACHIEVEMENTS.get(achievementID).keys()[i]) == true:
						counter += 1
				return counter
			else:
				return ACHIEVEMENTS.get(achievementID).size()
		#
		elif ACHIEVEMENTS.get(achievementID).has("max_progress"): 
			if getMaxProgress == false:
				return ACHIEVEMENTS.get(achievementID).get("progress")
			else:
				return ACHIEVEMENTS.get(achievementID).get("max_progress")
	else:
		return 0

func achievementUnlocking():
	var PlayerNode = get_tree().current_scene.get_node("Player")
	if isAchievementUnlocked("normal") == false:
		if PlayerNode.bulletType == "normal" and PlayerNode.UPGRADE.bulletUpgrades >= 4:
			ACHIEVEMENTS.set("normal", true)
			unlockAchievement("normal")
	
	if isAchievementUnlocked("flame") == false:
		if PlayerNode.bulletType == "flame" and PlayerNode.UPGRADE.bulletUpgrades >= 4:
			ACHIEVEMENTS.set("flame", true)
			unlockAchievement("flame")
	
	if isAchievementUnlocked("plasma") == false:
		if PlayerNode.bulletType == "plasma" and PlayerNode.UPGRADE.bulletUpgrades >= 2:
			ACHIEVEMENTS.set("plasma", true)
			unlockAchievement("plasma")
	
	if isAchievementUnlocked("boomerang") == false:
		if PlayerNode.bulletType == "boomerang" and PlayerNode.UPGRADE.bulletUpgrades >= 3:
			ACHIEVEMENTS.set("boomerang", true)
			unlockAchievement("boomerang")
	
	if isAchievementUnlocked("elemental") == false:
		if PlayerNode.bulletType == "flame" and PlayerNode.UPGRADE.bulletUpgrades >= 4:
			ACHIEVEMENTS.get("elemental").set("flame", true)
			saveAchievements()
		if getAchievementProgress("elemental", false) >= getAchievementProgress("elemental", true):
			ACHIEVEMENTS.get("elemental").set("unlocked", true)
			unlockAchievement("elemental")
	
	if isAchievementUnlocked("super_speed") == false:
		if (PlayerNode.ABILITY == "flashtime" and PlayerNode.UPGRADE.abilityPower >= 3) and PlayerNode.UPGRADE.speed >= 64:
			ACHIEVEMENTS.set("super_speed", true)
			unlockAchievement("super_speed")
	
	if isAchievementUnlocked("dash_smash") == false:
		if (PlayerNode.ABILITY == "dash" and PlayerNode.UPGRADE.abilityPower >= 3) and PlayerNode.ABILITYMAXCOOLDOWN <= 6:
			ACHIEVEMENTS.set("dash_smash", true)
			unlockAchievement("dash_smash")
			
	if ACHIEVEMENTS.get("level_10").get("progress", 0) < PlayerNode.LEVEL: ACHIEVEMENTS.get("level_10").set("progress", clamp(PlayerNode.LEVEL, 0, 10))
	if isAchievementUnlocked("level_10") == false:
		if getAchievementProgress("level_10", false) >= getAchievementProgress("level_10", true):
			ACHIEVEMENTS.get("level_10").set("unlocked", true)
			unlockAchievement("level_10")
	
	if ACHIEVEMENTS.get("level_25").get("progress", 0) < PlayerNode.LEVEL: ACHIEVEMENTS.get("level_25").set("progress", clamp(PlayerNode.LEVEL, 0, 25))
	if isAchievementUnlocked("level_25") == false:
		if getAchievementProgress("level_25", false) >= getAchievementProgress("level_25", true):
			ACHIEVEMENTS.get("level_25").set("unlocked", true)
			unlockAchievement("level_25")
	
	if ACHIEVEMENTS.get("level_50").get("progress", 0) < PlayerNode.LEVEL: ACHIEVEMENTS.get("level_50").set("progress", clamp(PlayerNode.LEVEL, 0, 50))
	if isAchievementUnlocked("level_50") == false:
		if getAchievementProgress("level_50", false) >= getAchievementProgress("level_50", true):
			ACHIEVEMENTS.get("level_50").set("unlocked", true)
			unlockAchievement("level_50")
		
