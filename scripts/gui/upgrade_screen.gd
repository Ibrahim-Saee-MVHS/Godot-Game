extends CanvasLayer

var selectedUpgrade: String
@export var buttonsDisabled = true
var speed: float = 2.0

var UPGRADEGLINTS = {
	"common": Color("#FFFFFF00"),
	"uncommon": Color("FF0044"),
	"rare": Color("#C422FF"),
	"epic": Color("#00CDFF"),
	"rgb": Color.from_hsv(0.0, 1.0, 1.0),
	"legendary": Color("#FFCD22"),
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	buttonsDisabled = true
	get_tree().paused = true
	if get_parent().get_node("Player").LEVEL == 1:
		$ColorRect/Title.text = "Free Upgrade\nYou'll need it."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	UPGRADEGLINTS.set("rgb", Color.from_hsv(UPGRADEGLINTS.get("rgb").h + (4.0 / 360), 1.0, 1.0))
	
	if get_parent().get_node("Player").HEALTH <= 0:
		get_tree().paused = false
		queue_free()
	
	if get_parent().get_node("HUD").debug_mode == true:
		speed = 3.0 + SettingsGlobal.settings.get_value("misc", "upgrade_speed", 1.0)
	elif get_parent().get_node("HUD").debug_mode == false:
		speed = 1.0 + SettingsGlobal.settings.get_value("misc", "upgrade_speed", 1.0)
		
	if Engine.time_scale < 1.0:
		$AnimationPlayer.speed_scale = speed / Engine.time_scale
	else:
		$AnimationPlayer.speed_scale = speed
	
	$Control/Control/HBoxContainer/Upgrade1/Button.disabled = buttonsDisabled
	$Control/Control/HBoxContainer/Upgrade2/Button.disabled = buttonsDisabled
	$Control/Control/HBoxContainer/Upgrade3/Button.disabled = buttonsDisabled
	$Control/Control/Skip.disabled = buttonsDisabled
	

func _upgrade1Selected() -> void:
	selectedUpgrade = $Control/Control/HBoxContainer/Upgrade1.UPGRADES[0]
	upgradePlayer()

func _upgrade2Selected() -> void:
	selectedUpgrade = $Control/Control/HBoxContainer/Upgrade2.UPGRADES[1]
	upgradePlayer()
	
func _upgrade3Selected() -> void:
	selectedUpgrade = $Control/Control/HBoxContainer/Upgrade3.UPGRADES[2]
	upgradePlayer()

func _on_skip_pressed() -> void:
	get_parent().get_node("Player").EXP /= 2
	endUpgrade()

func endUpgrade():
	$AnimationPlayer.play("upgradesDown")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "upgradesDown" or anim_name == "upgradeSelectorOut":
		get_tree().paused = false
		queue_free()

func upgradePlayer():
	get_parent().get_node("Player").EXP = 0
	Upgrader.upgrade(selectedUpgrade)
	if selectedUpgrade == "card_picker":
		$UpgradeSelector.addUpgradeBoxes()
		$AnimationPlayer.play("upgradeSelectorIn")
	else:
		endUpgrade()
