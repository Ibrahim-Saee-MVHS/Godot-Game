extends Control

@onready var InputButton = preload("res://scenes/input_button.tscn")
@onready var DesktopControlsList = $Panel/ScrollContainer/PanelContainer/MarginContainer/DesktopControls
@onready var MobileControlsList = $Panel/ScrollContainer/PanelContainer/MarginContainer/MobileControls
#@onready var ControllerControlsList = $Panel/ScrollContainer/PanelContainer/MarginContainer/ControllerControls/Controls
var remapping = false
var remapping_action = null
var remapping_button = null

var actions = {
	"shoot": "Shoot",
	"ability": "Use Ability",
	"up": "Move Up",
	"left": "Move Left",
	"down": "Move Down",
	"right": "Move Right",
}
var controllerActions = {
	"shoot": "Shoot",
	"ability": "Use Ability",
	"up": "Move Up",
	"left": "Move Left",
	"down": "Move Down",
	"right": "Move Right",
	"shoot_up": "Aim Up",
	"shoot_left": "Aim Left",
	"shoot_down": "Aim Down",
	"shoot_right": "Aim Right",
}

func _ready():
	if not Global.isMobileDevice:
		DesktopControlsList.visible = true
		MobileControlsList.visible = false
		generateDesktopControls()
	else:
		DesktopControlsList.visible = false
		MobileControlsList.visible = true
		setMobileControls()
	
func generateDesktopControls():
	#InputMap.load_from_project_settings() Will reset controls everytime you open controls menu
	for item in DesktopControlsList.get_children():
		item.queue_free()
	
	for action in actions:
		var button = InputButton.instantiate()
		var actionLabel = button.get_node("Action")
		var keybindLabel = button.get_node("Remapper/Keybind")
		actionLabel.text = actions[action]
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			keybindLabel.text = events[0].as_text().trim_suffix(" - Physical")
		else: keybindLabel.text = "[Not Bound]"
		
		DesktopControlsList.add_child(button)
		button.get_node("Remapper").pressed.connect(rebindAction.bind(action, button))
		
func setMobileControls():
	MobileControlsList.get_node("AnchorCrosshair/CheckButton").button_pressed = ControlsGlobal.mobileControls.get("anchor_crosshair")
	MobileControlsList.get_node("DirectionalAiming/CheckButton").button_pressed = ControlsGlobal.mobileControls.get("directional_aiming")
	MobileControlsList.get_node("Sensitivity/HSlider").value = ControlsGlobal.mobileControls.get("sensitivity")
	MobileControlsList.get_node("MovementStyle/OptionButton").selected = ControlsGlobal.mobileControls.get("movement_style")

func _process(_delta):
	if Global.isMobileDevice:
		ControlsGlobal.mobileControls.set("anchor_crosshair", MobileControlsList.get_node("AnchorCrosshair/CheckButton").button_pressed)
		ControlsGlobal.mobileControls.set("directional_aiming", MobileControlsList.get_node("DirectionalAiming/CheckButton").button_pressed)
		ControlsGlobal.mobileControls.set("sensitivity", MobileControlsList.get_node("Sensitivity/HSlider").value)
		ControlsGlobal.mobileControls.set("movement_style", MobileControlsList.get_node("MovementStyle/OptionButton").selected)
		MobileControlsList.get_node("Sensitivity").visible = !ControlsGlobal.mobileControls.get("directional_aiming")
		MobileControlsList.get_node("Sensitivity/Label").text = str(int(MobileControlsList.get_node("Sensitivity/HSlider").value*100), "%")

func rebindAction(action, button):
	if !remapping:
		remapping = true
		remapping_action = action
		remapping_button = button
		button.get_node("Remapper/Keybind").text = "[...]"
		
func _input(event):
	if remapping:
		if (event is InputEventKey || (event is InputEventMouseButton && event.is_pressed())):
			if event is InputEventMouseButton and event.double_click: event.double_click = false
			InputMap.action_erase_event(remapping_action, InputMap.action_get_events(remapping_action)[0])
			InputMap.action_add_event(remapping_action, event)
			updateControl(remapping_button, event)
			remapping = false
			remapping_action = null
			remapping_button = null
			accept_event()
			save()
	
func updateControl(button, event):
	button.get_node("Remapper/Keybind").text = event.as_text().trim_suffix(" - Physical")

func save():
	var controls = ConfigFile.new()
	for action in actions.keys():
		controls.set_value("desktop", action, InputMap.action_get_events(action)[0])
	for setting in ControlsGlobal.mobileControls:
		controls.set_value("mobile", setting, ControlsGlobal.mobileControls.get(setting))
	SettingsGlobal.checkSaveDir()
	controls.save(ControlsGlobal.save_directory + "controls.cfg")

func _exit() -> void:
	get_parent().buttonsDisabled = false
	save()
	queue_free()

func _reset() -> void:
	if Global.isMobileDevice:
		MobileControlsList.get_node("AnchorCrosshair/CheckButton").button_pressed = false
		MobileControlsList.get_node("DirectionalAiming/CheckButton").button_pressed = true
		MobileControlsList.get_node("Sensitivity/HSlider").value = 0.5
		MobileControlsList.get_node("MovementStyle/OptionButton").selected = 0
		ControlsGlobal.mobileControls.set("anchor_crosshair", false)
		ControlsGlobal.mobileControls.set("directional_aiming", true)
		ControlsGlobal.mobileControls.set("sensitivity", 0.5)
		ControlsGlobal.mobileControls.set("movement_style", 0)
		save()
	else:
		InputMap.load_from_project_settings()
		save()
		generateDesktopControls()
