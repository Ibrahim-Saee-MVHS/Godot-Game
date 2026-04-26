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
var target: CollisionObject2D = null

func _ready():
	if homing > 0:
		findNewTarget()
	if TYPE == "normal":
		KNOCKBACK = 4000
		despawnTimer = 60
		scale = Vector2(1 + (0.25 * upgrades), 1 + (0.25 * upgrades))
		explosiveness = explosiveness * (1 + (0.25 * upgrades))
	if TYPE == "flame":
		KNOCKBACK = 0
		despawnTimer = 5 + (2 * upgrades)
		homing = 0
		DAMAGE = (DAMAGE / 100) + 0.01 + (0.01 * upgrades)
		$CPUParticles2D.emitting = true
		$CPUParticles2D.color_ramp = fireColors[upgrades]
	else:
		$Outline.self_modulate = Global.playerColor
	if TYPE == "plasma":
		KNOCKBACK = 0
		despawnTimer = 120
		homing = 0
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
	if TYPE == "boomerang":
		KNOCKBACK = 8000
		despawnTimer = 5 + (5 * upgrades)

func _process(delta):
	if homing > 0:
		homeOnEnemy(homing)
	if TYPE == "boomerang":
		rotation_degrees += SPEED / 10
		SPEED = clamp(SPEED + 2.5, 125, 500)
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
			ricochet -= 1
			if target != null:
				homeOnEnemy(20) # instant rotation
			else:
				# either rotates 135 degress left or right
				MOVEDIR += deg_to_rad([-135, 135].pick_random())
		
	if despawnTimer <= 0:
		if TYPE == "boomerang":
			returnToPlayer()
		else:
			despawnBullet(delta)

func despawnBullet(delta):
	$CollisionShape2D.disabled = true
	modulate.a -= 5 * delta
	if modulate.a <= 0:
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

func returnToPlayer():
	if target != get_parent().get_node("Player"):
		target = get_parent().get_node("Player")
	MOVEDIR = lerp_angle(MOVEDIR, (target.global_position - global_position).angle(), 0.1)

func _on_body_entered(body: Node2D) -> void:
	if TYPE == "boomerang" and despawnTimer <= 0 :
		if body is Player:
			body.FIRERATE = body.MAXFIRERATE
			queue_free()
