extends Control

var color = 0
var buildType = "-demo"

func _ready():
	SettingsGlobal.setVolume()

func _process(_delta: float) -> void:
	$Version.text = str("v" + ProjectSettings.get_setting("application/config/version") + buildType)

func _startGame():
	$AnimationPlayer.play("fade_in_game")

func _settings() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _exit() -> void:
	get_tree().quit()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_in_game":
		get_tree().change_scene_to_file("res://scenes/game.tscn")
