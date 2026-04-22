extends Control

var ERROR: String = "ERROR: Description Not Found"
var DESCRIPTIONS = {
	"trinity_of_doom": "The most destructive enemies have come together to create an unstoppable force, perhaps you have become the hero this world needs.\nALT NAME: Hell Trinity\n(Bombers, Grenadiers, and Arsonists only.)",
	"hard_mode": "They became so powerful they got higher quality shading in this icon.\n(DIFFICULTY starts at 1 rather than 0, and increments by 0.25 rather than 0.1.)",
	"juggernauts_reign_supreme": "Looks like all of the enemies went to the gym.\n(All enemies have the same HEALTH(except for Bombers) and color of Juggernauts and have a minimium DAMAGE of 6, actual Juggernauts become far more powerful and less common, there is also an Enemy Type indicator above their Health Bar.",
}

func _ready():
	$Control/TrinityOfDoom.button_pressed = Global.GAMEMODIFIERS.get("trinity_of_doom")
	$Control/HardMode.button_pressed = Global.GAMEMODIFIERS.get("hard_mode")
	$Control/JuggernautsReignSupreme.button_pressed = Global.GAMEMODIFIERS.get("juggernauts_reign_supreme")

func _process(_delta):
	Global.GAMEMODIFIERS.set("trinity_of_doom", $Control/TrinityOfDoom.button_pressed)
	Global.GAMEMODIFIERS.set("hard_mode", $Control/HardMode.button_pressed)
	Global.GAMEMODIFIERS.set("juggernauts_reign_supreme", $Control/JuggernautsReignSupreme.button_pressed)
	setDescriptionText()
	
func setDescriptionText():
	$DescriptionBox/Description.text = ""
	for button in get_node("Control").get_children():
		if button.HOVERING:
			$DescriptionBox/Description.text = DESCRIPTIONS.get(button.ID, ERROR)

func _back():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
