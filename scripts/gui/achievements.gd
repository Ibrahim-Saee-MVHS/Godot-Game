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
	"dash_smash": false,
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
	var file = FileAccess.open("user://achievements.save", FileAccess.READ_WRITE)
	var json = JSON.parse_string(file.get_as_text())
	if initialAchievements.keys().size() > json.keys().size():
		for i in range(initialAchievements.keys().size()):
			json.get_or_add(initialAchievements.keys()[i], false)
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
		if ACHIEVEMENTS.get(achievementID).values()[1] is bool:
			return (not false in ACHIEVEMENTS.get(achievementID).values())
		elif ACHIEVEMENTS.get(achievementID).values()[1] is int:
			return ACHIEVEMENTS.get(achievementID).get("progress") >= ACHIEVEMENTS.get(achievementID).get("max_progress")

func getAchievementProgress(achievementID: String, getMaxProgress: bool):
	if ACHIEVEMENTS.get(achievementID) is not bool:
		if ACHIEVEMENTS.get(achievementID).values()[0] is bool:
			if getMaxProgress == false:
				var counter = 0
				for i in range(ACHIEVEMENTS.get(achievementID).size() - 1):
					if ACHIEVEMENTS.get(achievementID).get(ACHIEVEMENTS.get(achievementID).keys()[i]) == true:
						counter += 1
				return counter - 1 # to account for the Locked variable
			else:
				return ACHIEVEMENTS.get(achievementID).size() - 1 # to account for the Locked variable
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
		if ACHIEVEMENTS.get("elemental").get("locked") == false:
			ACHIEVEMENTS.get("elemental").set("locked", true)
			unlockAchievement("elemental")
	
	if isAchievementUnlocked("super_speed") == false:
		if (PlayerNode.ABILITY == "flashtime" and PlayerNode.UPGRADE.abilityPower >= 3) and PlayerNode.UPGRADE.speed >= 64:
			ACHIEVEMENTS.set("super_speed", true)
			unlockAchievement("super_speed")
	
	if isAchievementUnlocked("dash_smash") == false:
		if (PlayerNode.ABILITY == "dash" and PlayerNode.UPGRADE.abilityPower >= 3) and PlayerNode.ABILITYMAXCOOLDOWN <= 6:
			ACHIEVEMENTS.set("dash_smash", true)
			unlockAchievement("dash_smash")
