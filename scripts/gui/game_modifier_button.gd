extends Button

var sprites = {
	false: preload("res://assets/sprites/ui/box_off.png"),
	true: preload("res://assets/sprites/ui/box_on.png"),
}

var HOVERING: bool

func _process(_delta):
	HOVERING = is_hovered()

func _toggled(toggled_on):
	icon = sprites.get(toggled_on, false)
