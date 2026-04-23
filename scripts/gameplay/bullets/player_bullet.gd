class_name PlayerBullet
extends Area2D

var EXPLOSION = preload("res://scenes/explosion.tscn")
var fireColors = [
	preload("res://assets/particles/normal_fire.tres"),
	preload("res://assets/particles/yellow_fire.tres"),
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
var ricochet: float
var homing: float
var explosiveness: float
var upgrades: int
var target: Enemy = null

func _ready():
	if homing > 0:
		findNewTarget()
	if TYPE == "normal":
		$Outline.self_modulate = Global.playerColor
		KNOCKBACK = 4000
		scale = Vector2(1 + (0.25 * upgrades), 1 + (0.25 * upgrades))
		explosiveness = explosiveness * (1 + (0.25 * upgrades))
	if TYPE == "flame":
		KNOCKBACK = 0
		despawnTimer = 5 + (2 * upgrades)
		DAMAGE = (DAMAGE / 100) + 0.01 + (0.01 * upgrades)
		$CPUParticles2D.emitting = true
		$CPUParticles2D.color_ramp = fireColors[upgrades]
	if TYPE == "plasma":
		$Outline.self_modulate = Global.playerColor
		KNOCKBACK = 0
		despawnTimer = 120
		match upgrades:
			0:
				$CollisionShape2D.shape.radius = 18
				$CPUParticles2D.amount = 48
				$CPUParticles2D.initial_velocity_min = 16
				$CPUParticles2D.initial_velocity_max = 64
			1:
				$CollisionShape2D.shape.radius = 26
				$CPUParticles2D.amount = 64
				$CPUParticles2D.initial_velocity_min = 32
				$CPUParticles2D.initial_velocity_max = 80
			2:
				$CollisionShape2D.shape.radius = 48
				$CPUParticles2D.amount = 96
				$CPUParticles2D.initial_velocity_min = 48
				$CPUParticles2D.initial_velocity_max = 96

func _process(delta):
	if homing > 0:
		homeOnEnemy(homing)
		despawnTimer += 5 * homing
	if TYPE == "flame":
		SPEED -= 1 * delta
		SPEED = max(SPEED, 0)
		if $CPUParticles2D.emitting == false:
			$CollisionShape2D.disabled = true
			despawnTimer -= 10 * delta
	else:
		despawnTimer -= 10 * delta
		
	position += Vector2(SPEED, 0).rotated(MOVEDIR) * delta
	if ricochet > 0:
		var screenSize = (get_viewport_rect().size / 4) - Vector2(8, 8)
		if (position.x > screenSize.x or position.x < -screenSize.x) or (position.y > screenSize.y or position.y < -screenSize.y):
			findNewTarget()
			if target != null:
				homeOnEnemy(20) # instant rotation
			else:
				MOVEDIR += deg_to_rad(45)
		
	if despawnTimer <= 0:
		queue_free()

func homeOnEnemy(homing_amount):
	if target != null:
		MOVEDIR = lerp_angle(MOVEDIR, (target.global_position - global_position).angle(), 0.05 * homing_amount)
	else:
		findNewTarget()

func findNewTarget():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() > 0:
		var min_distance = INF
		var nearest_enemy = null
		for enemy in enemies:
			var distance = global_position.distance_squared_to(enemy.global_position)
			if distance < min_distance:
				min_distance = distance
				nearest_enemy = enemy
		target = nearest_enemy
