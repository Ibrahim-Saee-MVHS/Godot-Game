extends Node

var AchivementsFile = ConfigFile.new()

var ACHIEVEMENTS = {
	"normal_max": false,
	"plasma_max": false,
	"flame_max": false,
	"boomerang_max": false,
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
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
