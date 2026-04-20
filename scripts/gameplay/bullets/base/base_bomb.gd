class_name BaseBomb
extends BaseProjectile

var EXPLOSION = preload("res://scenes/explosion.tscn")

var explosiveness: float
var destination_position: Vector2

func _ready():
	despawnTimer = 10
	explosiveness = clamp(explosiveness, 0.5, explosiveness)

func _process(delta):
	SPEED -= (-global_position.distance_to(destination_position) + (global_position.distance_to(destination_position) / 5)) * delta
	
	if despawnTimer <= 0:
		var BombExplosion = EXPLOSION.instantiate()
		BombExplosion.global_position = global_position
		BombExplosion.SIZE = explosiveness
		BombExplosion.playerExplosion = false
		get_parent().add_child(BombExplosion)
		queue_free()
