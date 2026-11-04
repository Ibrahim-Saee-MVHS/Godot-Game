extends Control

@onready var InputButton = preload("res://scenes/input_button.tscn")
@onready var ControlsList = $Panel/ScrollContainer/PanelContainer/MarginContainer/Control
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

func _ready():
	generateControls()
	
func generateControls():
	#InputMap.load_from_project_settings() Will reset controls everytime you open controls menu
	for item in ControlsList.get_children():
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
		
		ControlsList.add_child(button)
		button.get_node("Remapper").pressed.connect(rebindAction.bind(action, button))
		
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
	SettingsGlobal.checkSaveDir()
	controls.save(ControlsGlobal.save_directory + "controls.cfg")

func _exit() -> void:
	get_parent().buttonsDisabled = false
	queue_free()

func _reset() -> void:
	InputMap.load_from_project_settings()
	save()
	generateControls()
