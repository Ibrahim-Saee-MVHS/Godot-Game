class_name BaseBullet
extends BaseProjectile

var EXPLOSION = preload("res://scenes/explosion.tscn")

var explosiveness: float
var ricohet: float

func _ready():
	despawnTimer = 60
	KNOCKBACK = 4000
	scale = Vector2(1 + (0.25 * upgrades), 1 + (0.25 * upgrades))
	explosiveness = explosiveness * (1 + (0.25 * upgrades))

func _process(delta):
	despawnTimer -= 10 * delta
		
	position += Vector2(SPEED, 0).rotated(MOVEDIR) * delta
	if despawnTimer <= 0:
		queue_free()
