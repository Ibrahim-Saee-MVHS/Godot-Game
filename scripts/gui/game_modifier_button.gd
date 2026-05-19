class_name GameModifierButton
extends Control

var sprites = {
	false: preload("res://assets/sprites/ui/box_off.png"),
	true: preload("res://assets/sprites/ui/box_on.png"),
}
var ID: String
var HOVERING: bool
var button_disabled: bool = false

func _ready() -> void:
	$Button/TextureRect.texture = load(str("res://assets/sprites/game_modifiers/", ID, ".png"))
	$Button/Label.text = Global.gameModifierInfo.get(ID).get("name")

func _process(_delta):
	HOVERING = $Button.is_hovered()
	$Button.disabled = button_disabled

func _on_button_toggled(toggled_on: bool) -> void:
	$Button.icon = sprites.get(toggled_on, false)
