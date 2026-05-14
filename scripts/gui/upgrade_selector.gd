extends CanvasLayer

var UpgradeCardNode = preload("res://scenes/upgrade_box.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	addAchievementCards()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func addAchievementCards():
	var validUpgrades = Global.validUpgrades.duplicate(true)
	var upgradeInfo = Global.upgradeInfo
	for key in validUpgrades:
		if upgradeInfo.get(key).has("rarity") and upgradeInfo.get(key).get("rarity") != "common":
			validUpgrades.erase(key)
	for i in range(validUpgrades.size()):
		var card = UpgradeCardNode.instantiate()
		card.UPGRADE = validUpgrades[i]
		$Control/ScrollContainer/GridContainer.add_child(card)
