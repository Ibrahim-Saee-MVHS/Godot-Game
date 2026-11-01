extends Node2D

var ROTATION: float
var COLOR: Color

func _process(_delta):
	$Outline.modulate = COLOR
	rotation = ROTATION
