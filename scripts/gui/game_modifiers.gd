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

func setDescriptionText():
	$DescriptionBox/Description.text = ""
	for button in $ScrollContainer/CenterContainer/GridContainer.get_children(false):
		if button.HOVERING:
			$DescriptionBox/Description.parse_bbcode(str(Global.gameModifierInfo.get(button.ID).get("description", ERROR)))

func _back():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
