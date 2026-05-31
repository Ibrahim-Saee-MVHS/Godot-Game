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
var start_time
var specialVars = {}

func _ready():
	start_time = Time.get_ticks_msec()
	if self.has_node("Outline"):
		$Outline.self_modulate = Global.playerColor
	if homing > 0:
		findNewTarget()
	if TYPE == "normal":
		KNOCKBACK = 4000
		despawnTimer = 60
		scale = Vector2(1 + (0.25 * upgrades), 1 + (0.25 * upgrades))
		explosiveness = explosiveness * (1 + (0.25 * upgrades))
	if TYPE == "flame":
		global_position += Vector2(16, 0).rotated(MOVEDIR)
		KNOCKBACK = 0
		despawnTimer = 5 + (2 * upgrades)
		homing = 0
		ricochet = 0
		DAMAGE = (DAMAGE / 20) + 0.1 + (0.25 * upgrades)
		$CPUParticles2D.emitting = true
		$CPUParticles2D.color_ramp = fireColors[upgrades]
	if TYPE == "water":
		global_position += Vector2(16, 0).rotated(MOVEDIR)
		KNOCKBACK = 1000 + (500 * upgrades)
		despawnTimer = 5
		homing = 0
		ricochet = 0
		SPEED = SPEED + (10 * upgrades)
		DAMAGE = (DAMAGE / 20) + 0.25 + (0.15 * upgrades)
		$CPUParticles2D.emitting = true
	if TYPE == "dark":
		global_position += Vector2(16, 0).rotated(MOVEDIR)
		KNOCKBACK = 6000
		despawnTimer = 70
		ricochet = 0
		SPEED = SPEED + (25 * upgrades)
		rotation = MOVEDIR
		specialVars.get_or_add("scaleDown", false)
		specialVars.get_or_add("baseDamage", DAMAGE)
	if TYPE == "light":
		global_position += Vector2(16, 0).rotated(MOVEDIR)
		despawnTimer = 60
		ricochet = 0
		specialVars.get_or_add("linePoints", 10)
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
		despawnTimer = 5 + (2 * upgrades)

func _process(delta):
	if homing > 0 and TYPE != "light":
		homeOnEnemy(homing)
	if TYPE == "boomerang":
		rotation_degrees += SPEED / 10
		SPEED = clamp(SPEED + 2.5, 125, 500)
	if TYPE == "dark":
		rotation = MOVEDIR
		if specialVars.get("scaleDown") == false:
			scale += Vector2(1, 1) * (2 + (2 * upgrades)) * delta
		else:
			scale -= Vector2(1, 1) * (2 + (2 * upgrades)) * delta
		if scale >= Vector2(1, 1) * (1.5 + (0.5 * upgrades)):
			specialVars.set("scaleDown", true)
		elif scale <= Vector2(1, 1) * 0.5:
			specialVars.set("scaleDown", false)
		DAMAGE = specialVars.get("baseDamage") * (scale.x)
	if TYPE == "light":
		var oldMoveDir = MOVEDIR
		homeOnEnemy(1 + upgrades + (SPEED / 100))
		if abs(angle_difference(MOVEDIR, oldMoveDir)) > 0.1:
			SPEED -= 10 - (5 * upgrades) # slow down
		else:
			SPEED += 5 + (5 * upgrades) # go fast
		SPEED = clamp(SPEED, 10, 400)
		if $CPUParticles2D.emitting == false:
			$Lightbolt.visible = false
			$CollisionShape2D.disabled = true
	if TYPE == "flame" or TYPE == "water":
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
			despawnBullet()

func despawnBullet():
	$CollisionShape2D.disabled = true
	modulate.a -= 5 * get_process_delta_time()
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
	elif target.HEALTH > 0:
		MOVEDIR = lerp_angle(MOVEDIR, (target.global_position - global_position).angle(), max(abs(despawnTimer / 25), 0.1))
	else:
		despawnBullet()

func _on_body_entered(body: Node2D) -> void:
	if TYPE == "boomerang" and despawnTimer <= 0 :
		if body is Player:
			if body.FIRERATE > body.MAXFIRERATE:
				body.FIRERATE = body.MAXFIRERATE
			queue_free()
