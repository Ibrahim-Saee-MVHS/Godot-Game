extends Control

var color = 0
var buildType = "-rc-2"
var InstructionBoardNode = preload("res://scenes/instructions_board.tscn")
var buttonsDisabled = false

func _ready():
	get_tree().paused = false
	SettingsGlobal.setAllSettings()

func _process(_delta: float) -> void:
	$Version.text = str("v" + ProjectSettings.get_setting("application/config/version") + buildType)
	for node in get_tree().get_nodes_in_group("mainMenuButtons"):
		node.disabled = buttonsDisabled

func _startGame():
	$AnimationPlayer.play("fade_in_game")
	buttonsDisabled = true

func _settings() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _instructions() -> void:
	add_child(InstructionBoardNode.instantiate())
	buttonsDisabled = true

func _exit() -> void:
	get_tree().quit()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_in_game":
		get_tree().change_scene_to_file("res://scenes/game.tscn")

func _game_modifiers():
	get_tree().change_scene_to_file("res://scenes/game_modifiers.tscn")

func _achievements() -> void:
	get_tree().change_scene_to_file("res://scenes/achievement_menu.tscn")
