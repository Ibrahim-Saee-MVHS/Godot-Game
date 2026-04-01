class_name EnemyBullet
extends Area2D

var SPEED
var DAMAGE
var MOVEDIR
var TYPE: String
var despawnTimer = 60

func _ready():
	$Outline.self_modulate = Global.enemyColor.get(TYPE)

func _process(delta):
	position += Vector2(SPEED, 0).rotated(MOVEDIR) * delta
	despawnTimer -= 10 * delta
	
	if despawnTimer <= 0:
		queue_free()
