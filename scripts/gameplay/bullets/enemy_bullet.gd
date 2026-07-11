class_name EnemyBullet
extends Area2D

var EXPLOSION = preload("res://scenes/explosion.tscn")
var fireColors = [
	preload("res://assets/particles/normal_fire.tres"),
	preload("res://assets/particles/yellow_fire.tres"),
	preload("res://assets/particles/green_fire.tres"),
	preload("res://assets/particles/blue_fire.tres"),
	preload("res://assets/particles/purple_fire.tres"),
]
var icicleTypes = [
	preload("res://assets/sprites/projectiles/clear_icicle.png"),
	preload("res://assets/sprites/projectiles/white_icicle.png"),
	preload("res://assets/sprites/projectiles/icicle.png"),
	preload("res://assets/sprites/projectiles/blood_icicle.png"),
	preload("res://assets/sprites/projectiles/blue_icicle.png"),
]

var COLOR: String
var TYPE: String
var SPEED: float
var DAMAGE: float
var MOVEDIR: float
var KNOCKBACK: float
var despawnTimer = 60
var upgrades: int
var specialVars = {}

var shooter: CollisionObject2D = null
var explosiveness: float
var spawn_position: Vector2
var destination_position: Vector2
var canMove: bool = true

func _ready():
	spawn_position = global_position
	if self.has_node("Outline"):
		$Outline.self_modulate = Global.enemyColor.get(COLOR)
	if TYPE == "normal":
		scale = Vector2(1 + (0.25 * upgrades), 1 + (0.25 * upgrades))
		explosiveness = explosiveness + (0.25 * upgrades)
	if TYPE == "flame":
		KNOCKBACK = 0
		despawnTimer = 5 + (2 * upgrades)
		DAMAGE = (DAMAGE / 100) + 0.01 + (0.01 * upgrades)
		$CPUParticles2D.emitting = true
		$CPUParticles2D.color_ramp = fireColors[upgrades]
		global_position += Vector2(16, 0).rotated(MOVEDIR)
	if TYPE == "dark":
		global_position += Vector2(16, 0).rotated(MOVEDIR)
		KNOCKBACK = 6000
		despawnTimer = 70
		SPEED = SPEED + (25 * upgrades)
		rotation = MOVEDIR
		specialVars.get_or_add("scaleDown", false)
		specialVars.get_or_add("baseDamage", DAMAGE)
	if TYPE == "light":
		global_position += Vector2(16, 0).rotated(MOVEDIR)
		despawnTimer = 25
		specialVars.get_or_add("linePoints", 10)
	if TYPE == "air":
		global_position += Vector2(16, 0).rotated(MOVEDIR)
		KNOCKBACK = 16000
		despawnTimer = 0.5 + (0.25 * upgrades)
		DAMAGE = (DAMAGE / 20) + 0.95 + (0.5 * upgrades)
		SPEED = ((SPEED - 500) / 4) + 500 + (100 * upgrades)
		rotation = MOVEDIR
		specialVars.get_or_add("start_position", global_position)
	if TYPE == "frost":
		scale = Vector2(0.75, 0.75)
		global_position += Vector2(8, 0).rotated(MOVEDIR)
		KNOCKBACK = 1000
		despawnTimer = 2 + (1 * upgrades)
		DAMAGE = (DAMAGE / 100) + 0.05 + (0.25 * upgrades)
		rotation = MOVEDIR
		$Sprite2D.texture = icicleTypes[upgrades]
	if TYPE == "earth":
		scale = Vector2(1.0, 1.0) * (1 + (0.25 * upgrades))
		global_position += Vector2(8, 0).rotated(MOVEDIR)
		KNOCKBACK = 8000
		despawnTimer = 60
	if TYPE == "bomb":
		despawnTimer = 10
		explosiveness = clamp(explosiveness, 0.5, explosiveness)
	if TYPE == "boomerang":
		KNOCKBACK = 2000
		despawnTimer = 5 + (2 * upgrades)

func _process(delta):
	if TYPE == "bomb" and canMove == true:
		SPEED = (global_position.distance_to(destination_position) + spawn_position.distance_to(destination_position))
		if global_position.distance_to(destination_position) < 8:
			canMove = false
	elif TYPE == "bomb":
		SPEED -= SPEED * delta
	
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
		if despawnTimer <= 20:
			homeOnPlayer(5 + (upgrades * 5) + (SPEED / 100))
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
		
	if TYPE == "air" or TYPE == "frost":
		rotation = MOVEDIR
	
	position += Vector2(SPEED, 0).rotated(MOVEDIR) * delta
	if despawnTimer <= 0:
		if TYPE == "bomb":
			var BombExplosion = EXPLOSION.instantiate()
			BombExplosion.global_position = global_position
			BombExplosion.EXPLOSIONPOWER = explosiveness
			BombExplosion.playerExplosion = false
			get_parent().add_child(BombExplosion)
			queue_free()
		elif TYPE == "boomerang":
			returnToSender()
		else:
			despawnBullet()

func homeOnPlayer(homing_amount):
	var player = get_parent().get_node("Player")
	if player.HEALTH > 0:
		MOVEDIR = lerp_angle(MOVEDIR, (player.global_position - global_position).angle(), 0.05 * homing_amount)
	else:
		despawnBullet()

func returnToSender():
	if shooter != null:
		MOVEDIR = lerp_angle(MOVEDIR, (shooter.global_position - global_position).angle(), max(abs(despawnTimer / 25), 0.1))
	else:
		despawnBullet()

func despawnBullet():
	$CollisionShape2D.disabled = true
	modulate.a -= 10 * get_process_delta_time()
	if modulate.a <= 0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if TYPE == "boomerang" and despawnTimer <= 0 :
		if body == shooter:
			if body.FIRERATE > body.MAXFIRERATE:
				body.FIRERATE = body.MAXFIRERATE
			queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is EnemyBullet or area is PlayerBullet:
		if TYPE == "flame" and area.TYPE == "water":
			$CPUParticles2D.emitting = false
			$CollisionShape2D.disabled = true
