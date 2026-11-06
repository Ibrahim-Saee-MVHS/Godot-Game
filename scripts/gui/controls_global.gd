extends Node

var controls = ConfigFile.new()
var save_directory = SettingsGlobal.save_directory

func _ready():
	SettingsGlobal.checkSaveDir()
	getDefaultControls()
	checkControls()
	controls.load(save_directory + "controls.cfg")
	loadControls()
	if Global.isMobileDevice: InputMap.action_erase_event("shoot", desktopControls.get("default").get("shoot"))

var actions = [
	"shoot",
	"ability",
	"up",
	"left",
	"down",
	"right"
]

var desktopControls: Dictionary = {
	"default": {},
	"current": {}
}
var mobileControls: Dictionary = {
	"anchor_crosshair": false,
	"directional_aiming": true,
	"sensitivity": 0.5,
	"movement_style": 0
}

func getDefaultControls():
	InputMap.load_from_project_settings()
	for action in actions: desktopControls.get("default").set(action, InputMap.action_get_events(action)[0])

func checkControls():
	var newControls = ConfigFile.new()
	var check = newControls.load(save_directory + "controls.cfg")
	if check != OK:
		for action in actions: newControls.set_value("desktop", action, desktopControls.get("default").get(action))
		for setting in mobileControls: newControls.set_value("mobile", setting, mobileControls.get(setting))
		newControls.save(save_directory + "controls.cfg")
		
func loadControls():
	for action in actions:
		InputMap.action_erase_event(action, desktopControls.get("default").get(action))
		InputMap.action_add_event(action, controls.get_value("desktop", action, desktopControls.get("default").get(action)))
	for setting in mobileControls:
		if controls.has_section("mobile"):
			mobileControls.set(setting, controls.get_value("mobile", setting))

func _process(_delta: float) -> void:
	for action in actions:
		if not Global.usingController:
			if not Global.isMobileDevice:
				desktopControls.get("current").set(action, InputMap.action_get_events(action)[0])
