class_name PlayerLightning
extends RayCast2D

var INV: float
var DAMAGE: float
var MOVEDIR: float
var upgrades: int
var max_distance: float
var target: Vector2

func _ready() -> void:
	INV = 2 - (0.25 * upgrades)
	max_distance = 24 + (8 * upgrades)

func _process(delta: float) -> void:
	target_position = target
