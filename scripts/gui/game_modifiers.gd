extends Control

var ERROR: String = "ERROR: Description Not Found"
var GameModifierButtonNode = preload("res://scenes/game_modifier_button.tscn")


func _ready():
	for i in range(Global.GAMEMODIFIERS.size()):
		var button = GameModifierButtonNode.instantiate()
		button.ID = Global.GAMEMODIFIERS.keys()[i]
		button.get_node("Button").button_pressed = Global.GAMEMODIFIERS.values()[i]
		button.get_node("Button").pressed.connect(_modifierSelected.bind(button.get_node("Button")))
		$ScrollContainer/CenterContainer/GridContainer.add_child(button)
	if true:
		var button = GameModifierButtonNode.instantiate()
		button.ID = "tbd"
		$ScrollContainer/CenterContainer/GridContainer.add_child(button)
	lockModifiers()

func _process(_delta):
	setDescriptionText()

func _modifierSelected(button: BaseButton):
	if Global.GAMEMODIFIERS.has(button.get_parent().ID):
		Global.GAMEMODIFIERS.set(button.get_parent().ID, button.button_pressed)

func lockModifiers():
	for button in $ScrollContainer/CenterContainer/GridContainer.get_children(false):
		if button.ID == "tbd":
			button.button_disabled = true
		if Global.gameModifierInfo.get(button.ID).has("achievements_required"):
			var requirement = 0
			for achievement in Global.gameModifierInfo.get(button.ID).get("achievements_required"):
				print(achievement)
				if achievement is String:
					if Achievements.isAchievementUnlocked(achievement) == true:
						requirement += 1
				else:
					print(Achievements.ACHIEVEMENTS.get(achievement.keys()[0]).get(achievement.values()[0]))
					if Achievements.ACHIEVEMENTS.get(achievement.get(achievement.values()[0])) == true:
						requirement += 1
			if requirement >= Global.gameModifierInfo.get(button.ID).get("achievements_required").size():
				button.button_disabled = false
			else:
				button.button_disabled = true

func setDescriptionText():
	$DescriptionBox/Description.text = ""
	for button in $ScrollContainer/CenterContainer/GridContainer.get_children(false):
		var description = str(Global.gameModifierInfo.get(button.ID).get("description", ERROR))
		if button.HOVERING:
			$DescriptionBox/Description.parse_bbcode(description)

func _back():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
