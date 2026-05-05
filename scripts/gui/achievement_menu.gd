extends Control

var AchievementCardNode = preload("res://scenes/achievement_card.tscn")
var ConfirmationPopup = preload("res://scenes/confirmation.tscn")

var buttonsDisabled = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	addAchievementCards()

func _process(_delta: float) -> void:
	$Back.disabled = buttonsDisabled
	$Reset.disabled = buttonsDisabled
	if has_node("Confirmation"):
		if $Confirmation.reset == true:
			Achievements.ACHIEVEMENTS = Achievements.initialAchievements.duplicate(true)
			Achievements.saveAchievements()
			buttonsDisabled = false
			$Confirmation.queue_free()

func _back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _reset() -> void:
	buttonsDisabled = true
	var confirm = ConfirmationPopup.instantiate()
	add_child(confirm)

func addAchievementCards():
	var AchievementList = Achievements.AchievementList.duplicate(true)
	for i in range(AchievementList.size()):
		var card = AchievementCardNode.instantiate()
		card.ID = AchievementList.keys()[i]
		$ScrollContainer/BoxContainer.add_child(card)
