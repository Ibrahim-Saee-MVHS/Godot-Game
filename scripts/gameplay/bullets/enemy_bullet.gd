class_name EnemyBullet
extends Area2D

var EXPLOSION = preload("res://scenes/explosion.tscn")

var COLOR: String
var TYPE: String
var SPEED: float
var DAMAGE: float
var MOVEDIR: float
var KNOCKBACK: float
var despawnTimer = 60

var explosiveness: float
var spawn_position: Vector2
var destination_position: Vector2
var canMove: bool = true

func _ready():
	spawn_position = global_position
	$Outline.self_modulate = Global.enemyColor.get(COLOR)
	if TYPE == "bomb":
		despawnTimer = 10
		explosiveness = clamp(explosiveness, 0.5, explosiveness)

func _process(delta):
	if TYPE == "bomb" and canMove == true:
		SPEED = (global_position.distance_to(destination_position) + spawn_position.distance_to(destination_position))
		if global_position.distance_to(destination_position) < 8:
			canMove = false
	elif TYPE == "bomb":
		SPEED -= SPEED * delta
	position += Vector2(SPEED, 0).rotated(MOVEDIR) * delta
	despawnTimer -= 10 * delta
	
	if despawnTimer <= 0:
		if TYPE == "bomb":
			var BombExplosion = EXPLOSION.instantiate()
			BombExplosion.global_position = global_position
			BombExplosion.SIZE = explosiveness
			BombExplosion.playerExplosion = false
			get_parent().add_child(BombExplosion)
		queue_free()
