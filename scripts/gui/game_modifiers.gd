extends Control

var ERROR: String = "ERROR: Description Not Found"
var DESCRIPTIONS = {
	"trinity_of_doom": "The most destructive enemies have come together to create an unstoppable force, perhaps you have become the hero this world needs. \n ALT NAME: Hell Trinity \n (Bombers, Grenadiers, and Arsonists only.)",
	"hard_mode": "They became so powerful they got higher quality shading in this icon. \n (DIFFICULTY starts at 1 rather than 0, and increments by 0.25 rather than 0.1.)",
}

func _ready():
	$Control/TrinityOfDoom.button_pressed = Global.GAMEMODIFIERS.get("trinity_of_doom")
	$Control/HardMode.button_pressed = Global.GAMEMODIFIERS.get("hard_mode")

func _process(_delta):
	Global.GAMEMODIFIERS.set("trinity_of_doom", $Control/TrinityOfDoom.button_pressed)
	Global.GAMEMODIFIERS.set("hard_mode", $Control/HardMode.button_pressed)
	setDescriptionText()
	
func setDescriptionText():
	if $Control/TrinityOfDoom.HOVERING:
		$DescriptionBox/Description.text = DESCRIPTIONS.get("trinity_of_doom", ERROR)
	elif $Control/HardMode.HOVERING:
		$DescriptionBox/Description.text = DESCRIPTIONS.get("hard_mode", ERROR)
	else:
		$DescriptionBox/Description.text = ""

func _back():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
