class_name BaseProjectile
extends Area2D

var COLOR: String
var SPEED: float
var DAMAGE: float
var MOVEDIR: float
var KNOCKBACK: float
var despawnTimer: float
var upgrades: int

func _ready():
	if has_node("Outline"):
		$Outline.self_modulate = Global.enemyColor.get(COLOR)

func _process(delta):
	position += Vector2(SPEED, 0).rotated(MOVEDIR) * delta
	if despawnTimer <= 0:
		queue_free()
