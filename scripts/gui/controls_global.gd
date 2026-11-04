extends Node

var controls = ConfigFile.new()
var save_directory = SettingsGlobal.save_directory

func _ready():
	SettingsGlobal.checkSaveDir()
	getDefaultControls()
	checkControls()
	controls.load(save_directory + "controls.cfg")
	loadControls()

var actions = [
	"shoot",
	"ability",
	"up",
	"left",
	"down",
	"right"
]

var defaultControls: Dictionary = {}
var currentControls: Dictionary = {}

func getDefaultControls():
	InputMap.load_from_project_settings()
	for action in actions: defaultControls.set(action, InputMap.action_get_events(action)[0])

func checkControls():
	var newControls = ConfigFile.new()
	var check = newControls.load(save_directory + "controls.cfg")
	if check != OK:
		for action in actions: newControls.set_value("desktop", action, defaultControls.get(action))
		newControls.save(save_directory + "controls.cfg")
		
func loadControls():
	for action in actions:
		InputMap.action_erase_event(action, defaultControls.get(action))
		InputMap.action_add_event(action, controls.get_value("desktop", action, defaultControls.get(action)))

func _process(_delta: float) -> void:
	for action in actions: currentControls.set(action, InputMap.action_get_events(action)[0])
