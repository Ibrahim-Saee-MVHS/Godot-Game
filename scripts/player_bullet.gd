class_name PlayerBullet
extends Area2D

var EXPLOSION = preload("res://scenes/explosion.tscn")
var fireColors = [
	preload("res://assets/particles/normal_fire.tres"),
	preload("res://assets/particles/green_fire.tres"),
	preload("res://assets/particles/blue_fire.tres"),
	preload("res://assets/particles/purple_fire.tres"),
]

var TYPE: String
var SPEED: float
var DAMAGE: float
var MOVEDIR: float
var KNOCKBACK: float
var despawnTimer = 60
var piercing: float
var explosiveness: float
var upgrades: int

func _ready():
	if TYPE == "normal":
		KNOCKBACK = 4000
	if TYPE == "flame":
		$CPUParticles2D.emitting = true
		despawnTimer = 5 + (2 * upgrades)
		KNOCKBACK = 0
		DAMAGE += DAMAGE + (0.1 * upgrades)
		$CPUParticles2D.color_ramp = fireColors[upgrades]
	if TYPE == "plasma":
		KNOCKBACK = 0
		despawnTimer = 120
		match upgrades:
			0:
				$CollisionShape2D.shape.radius = 18
				$CPUParticles2D.amount = 18
			1:
				$CollisionShape2D.shape.radius = 26
				$CPUParticles2D.amount = 26
			2:
				$CollisionShape2D.shape.radius = 48
				$CPUParticles2D.amount = 48

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
