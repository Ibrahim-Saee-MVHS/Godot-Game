extends Control

var AchievementCardNode = preload("res://scenes/achievement_card.tscn")
var ConfirmationPopup = preload("res://scenes/confirmation.tscn")

var buttonsDisabled = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	addAchievementCards()

func _process(delta: float) -> void:
	$Back.disabled = buttonsDisabled
	$Reset.disabled = buttonsDisabled

func _back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _reset() -> void:
	buttonsDisabled = true
	var confirm = ConfirmationPopup.instantiate()
	

func addAchievementCards():
	var AchievementList = Achievements.AchievementList.duplicate(true)
	for i in range(AchievementList.size()):
		var card = AchievementCardNode.instantiate()
		
		if Achievements.isAchievementUnlocked(AchievementList.keys()[i]):
			card.get_node("Card/Frame/Icon").texture = load("res://assets/sprites/achievement_icons/" + str(AchievementList.keys()[i]) + ".png")
			card.get_node("Card/Name").text = str(AchievementList.get(AchievementList.keys()[i]).name)
		else:
			card.get_node("Card").texture = load("res://assets/achievement_card_locked.tres")
			card.get_node("Card/Frame/Icon").texture = load("res://assets/sprites/achievement_icons/achievement_locked.png")
			card.get_node("Card/Name").text = "This Achievement is Locked!"
		if Achievements.getAchievementProgress(AchievementList.keys()[i], true) == 0:
			card.get_node("Card/Progress").queue_free()
		else:
			card.get_node("Card/Progress").max_value = Achievements.getAchievementProgress(AchievementList.keys()[i], true)
			card.get_node("Card/Progress").value = Achievements.getAchievementProgress(AchievementList.keys()[i], false)
		
		card.get_node("Card/Description").text = str(AchievementList.get(AchievementList.keys()[i]).description)
		card.get_node("Card").tooltip_text = str(AchievementList.get(AchievementList.keys()[i]).description)
		$ScrollContainer/BoxContainer.add_child(card)
