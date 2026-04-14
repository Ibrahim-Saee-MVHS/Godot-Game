class_name PlayerBullet
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
	if TYPE == "normal":
		KNOCKBACK = 4000
	if TYPE == "flame":
		$CPUParticles2D.emitting = true
		despawnTimer = 5
		KNOCKBACK = 0
	if TYPE == "plasma":
		KNOCKBACK = 0

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
