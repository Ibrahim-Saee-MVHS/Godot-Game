class_name GameModifierButton
extends Control

var sprites = {
	false: preload("res://assets/sprites/ui/box_off.png"),
	true: preload("res://assets/sprites/ui/box_on.png"),
}
var NAME: String
var ID: String
var HOVERING: bool
var enabled: bool = false

func _ready() -> void:
	$Button/TextureRect.texture = load(str("res://assets/sprites/achievement_icons/", ID, ".png"))
	$Button/Label.text = NAME

func _process(_delta):
	HOVERING = $Button.is_hovered()
	$Button.disabled = enabled

func _on_button_toggled(toggled_on: bool) -> void:
	$Button.icon = sprites.get(toggled_on, false)
