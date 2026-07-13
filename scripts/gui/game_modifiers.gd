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
	

func _process(_delta):
	setDescriptionText()
	lockModifiers()

func _modifierSelected(button: BaseButton):
	if Global.GAMEMODIFIERS.has(button.get_parent().ID):
		Global.GAMEMODIFIERS.set(button.get_parent().ID, button.button_pressed)

func lockModifiers():
	for button in $ScrollContainer/CenterContainer/GridContainer.get_children(false):
		if button.ID == "tbd":
			button.button_disabled = true
		# achievement required game modifiers
		if Global.gameModifierInfo.get(button.ID).has("achievements_required"):
			var requirement = 0
			for achievement in Global.gameModifierInfo.get(button.ID).get("achievements_required"):
				if achievement is String:
					if Achievements.isAchievementUnlocked(achievement) == true:
						requirement += 1
				else:
					if Achievements.ACHIEVEMENTS.get(achievement.keys()[0]).get(achievement.values()[0]) == true:
						requirement += 1
			if requirement >= Global.gameModifierInfo.get(button.ID).get("achievements_required").size():
				button.button_disabled = false
			else:
				button.button_disabled = true
		# incompatible game modifiers
		if Global.gameModifierInfo.get(button.ID).has("incompatiblilty_id"):
			var id = Global.gameModifierInfo.get(button.ID).get("incompatiblilty_id")
			for button2 in $ScrollContainer/CenterContainer/GridContainer.get_children(false):
				if button2.ID == button.ID:
					pass
				elif Global.gameModifierInfo.get(button2.ID).get("incompatiblilty_id") == id:
					if Global.GAMEMODIFIERS.get(button2.ID) == true:
						button.button_disabled = true
					else:
						button.button_disabled = false
						

func setDescriptionText():
	for button in $ScrollContainer/CenterContainer/GridContainer.get_children(false):
		var title = str("[font_size=48]", Global.gameModifierInfo.get(button.ID).get("name", ""), "[/font_size]")
		var description = str(Global.gameModifierInfo.get(button.ID).get("description", ERROR))
		if button.HOVERING:
			$DescriptionBox/Description.parse_bbcode(str(title, "\n", description))

func _back():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
