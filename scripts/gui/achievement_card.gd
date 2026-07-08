extends Control

var ID: String
var AchievementList
var ElementalProgress = preload("res://assets/sprites/ui/achievement_bar_elemental.png")

func _process(_delta):
	AchievementList = Achievements.AchievementList
	$Card/Frame/Icon.texture = load("res://assets/sprites/achievement_icons/" + str(ID) + ".png")
	$Card/Name.text = str(AchievementList.get(ID).name)
	if AchievementList.get(ID).has("impossible") and AchievementList.get(ID).get("impossible") == true:
		$Card/Description.parse_bbcode(str(AchievementList.get(ID).description) + "\n[color=#FF001A]This achievement is currently impossible, probably due to lack of content.[/color]")
	elif AchievementList.get(ID).has("warn") and AchievementList.get(ID).get("warn") == true:
		$Card/Description.parse_bbcode(str(AchievementList.get(ID).description) + "\n[color=#FFEE88]This achievment hasn't been tested or obtained yet, there is a chance it is impossible.[/color]")
	else:
		$Card/Description.parse_bbcode(str(AchievementList.get(ID).description))
	
	if Achievements.isAchievementUnlocked(ID) == true:
		$Card/Frame/Lock.visible = false
		$Card.texture = load("res://assets/achievement_card.tres")
	else:
		$Card/Frame/Lock.visible = true
		$Card.texture = load("res://assets/achievement_card_locked.tres")
		
	if Achievements.getAchievementProgress(ID, true) == 0:
		$Card/Progress.visible = false
	else:
		$Card/Progress.max_value = Achievements.getAchievementProgress(ID, true)
		$Card/Progress.value = Achievements.getAchievementProgress(ID, false)
	
	if ID == "elemental":
		$Card/Progress.texture_progress = ElementalProgress
