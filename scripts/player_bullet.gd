class_name PlayerBullet
extends Area2D

var TYPE
var SPEED: float
var DAMAGE
var MOVEDIR
var despawnTimer = 60
var piercing

func _ready():
	if TYPE == "flame":
		$CPUParticles2D.emitting = true
		despawnTimer = 5

func _process(delta):
	if TYPE == "flame":
		SPEED -= 1 * delta
		SPEED = max(SPEED, 0)
		if $CPUParticles2D.emitting == false:
			$CollisionShape2D.disabled = true
			despawnTimer -= 10 * delta
	else:
		despawnTimer -= 10 * delta
	position += Vector2(SPEED, 0).rotated(MOVEDIR) * delta
	if despawnTimer <= 0:
		queue_free()
