class_name EnemyBullet
extends Area2D

var EXPLOSION = preload("res://scenes/explosion.tscn")

var TYPE: String
var SPEED: float
var DAMAGE: float
var MOVEDIR: float
var KNOCKBACK: float
var despawnTimer = 60
var piercing: float
var explosiveness: float

func _ready():
	$Outline.self_modulate = Global.enemyColor.get(TYPE)

func _process(delta):
	position += Vector2(SPEED, 0).rotated(MOVEDIR) * delta
	despawnTimer -= 10 * delta
	
	if despawnTimer <= 0:
		queue_free()
