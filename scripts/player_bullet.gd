class_name PlayerBullet
extends Area2D

var SPEED
var DAMAGE
var MOVEDIR
var despawnTimer = 60

func _ready():
	pass # $AudioStreamPlayer2D.pitch_scale = randf_range(0.8, 1.2)

func _process(delta):
	position += Vector2(SPEED, 0).rotated(MOVEDIR) * delta
	despawnTimer -= 10 * delta
	
	if despawnTimer <= 0:
		queue_free()
