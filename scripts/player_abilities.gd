extends Node

var abilityTimer: float = 0.0
var ExplosionNode = preload("res://scenes/explosion.tscn")
var FlashtimeFX = preload("res://scenes/vfx/flashtime.tscn")

var ICONS = {
	"flashtime" = preload("res://assets/sprites/ability_icons/flashtime.png"),
	"detonation" = preload("res://assets/sprites/ability_icons/detonation.png"),
}

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
	get_tree().current_scene.add_child(EXPLOSION)

func flashtime(power, duration):
	abilityTimer = duration
	Engine.time_scale = clamp(1 - (0.25 * power), 0.125, 1)
	var FLASHTIME = FlashtimeFX.instantiate()
	get_tree().current_scene.get_node("Camera2D/BackgroundFX/Control").add_child(FLASHTIME)
