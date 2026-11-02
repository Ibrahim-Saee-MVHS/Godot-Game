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
	InputMap.load_from_project_settings()
	for item in ControlsList.get_children():
		queue_free()
	
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
			InputMap.action_erase_event(remapping_action, InputMap.action_get_events(remapping_action)[0])
			InputMap.action_add_event(remapping_action, event)
			updateControl(remapping_button, event)
			remapping = false
			remapping_action = null
			remapping_button = null
	
func updateControl(button, event):
	button.get_node("Remapper/Keybind").text = event.as_text().trim_suffix(" - Physical")
