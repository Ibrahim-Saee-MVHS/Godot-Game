extends Node

var abilityTimer: float = 0.0
var ExplosionNode = preload("res://scenes/explosion.tscn")

var abilites = [
	flashtime
]

func _ready() -> void:
	abilityTimer = 0

func _process(delta: float) -> void:
	if abilityTimer > 0:
		abilityTimer -= 1 * delta
	else:
		Engine.time_scale = 1

func detonation(power, position):
	var EXPLOSION = ExplosionNode.instantiate()
	EXPLOSION.global_position = position
	EXPLOSION.SIZE = power
	EXPLOSION.playerExplosion = true
	get_parent().add_child(EXPLOSION)

func flashtime(power, duration):
	abilityTimer = duration
	Engine.time_scale = 1 - (0.125 * power)
	print("Flashtime!")
