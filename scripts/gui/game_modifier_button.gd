class_name GameModifierButton
extends Control

var sprites = {
	false: preload("res://assets/sprites/ui/box_off.png"),
	true: preload("res://assets/sprites/ui/box_on.png"),
}
@export var ID: String
var HOVERING: bool

func _process(_delta):
	HOVERING = $Button.is_hovered()

func _on_button_toggled(toggled_on: bool) -> void:
	$Button.icon = sprites.get(toggled_on, false)
