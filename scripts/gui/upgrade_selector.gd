extends Control

var UpgradeCardNode = preload("res://scenes/upgrade_box.tscn")
var UpgradeBoxButtonGroup = preload("res://scenes/upgrade_box_button_group.tres")
var selectedButton: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UpgradeBoxButtonGroup.pressed.connect(_upgradeSelected)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _upgradeSelected(button: BaseButton):
	$Control/Confirm.disabled = false
	selectedButton = button.get_parent()
	var upgradeInfo = Global.upgradeInfo
	if selectedButton.UPGRADE == "hearty":
		$Control/DescriptionBox/Description.parse_bbcode(str("[b]", "Hearty", "[/b]\n", "Counters Card Picker's -10 HEALTH, Heals by +35 but -1 SPEED."))
	elif selectedButton.UPGRADE == "card_picker":
		$Control/DescriptionBox/Description.parse_bbcode(str("[b]", "Card Picker", "[/b]\n", "You're losing 20 HEALTH if you pick this card."))
	else:
		$Control/DescriptionBox/Description.parse_bbcode(str("[b]", upgradeInfo.get(selectedButton.UPGRADE).get("name"), "[/b]\n", upgradeInfo.get(selectedButton.UPGRADE).get("description")))

func _on_line_edit_text_changed(new_text: String) -> void:
	var search = new_text.to_lower()
	for upgrade in $Control/ScrollContainer/GridContainer.get_children():
		if search == "" or search in upgrade.get_node("Button/Title").text.to_lower():
			upgrade.visible = true
		else:
			upgrade.visible = false

func _confirm() -> void:
	$Control/Confirm.disabled = true
	Upgrader.upgrade(selectedButton.UPGRADE)
	get_parent().get_node("AnimationPlayer").play("upgradeSelectorOut")

func addUpgradeBoxes():
	var validUpgrades = get_parent().get_node("Control/Control/HBoxContainer/Upgrade3").removeUpgrades(Global.validUpgrades.duplicate(true))
	var upgradeInfo = Global.upgradeInfo
	for key in validUpgrades:
		if upgradeInfo.get(key).has("rarity") and upgradeInfo.get(key).get("rarity") != "common":
			#validUpgrades.erase(key)
			pass
	for i in range(validUpgrades.size()):
		var card = UpgradeCardNode.instantiate()
		card.name = validUpgrades[i]
		card.UPGRADE = validUpgrades[i]
		$Control/ScrollContainer/GridContainer.add_child(card)
