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

var COLOR: String
var TYPE: String
var SPEED: float
var DAMAGE: float
var MOVEDIR: float
var KNOCKBACK: float
var despawnTimer = 60
var upgrades: int

var shooter: CollisionObject2D = null
var explosiveness: float
var spawn_position: Vector2
var destination_position: Vector2
var canMove: bool = true

func _ready():
	spawn_position = global_position
	if TYPE == "normal":
		scale = Vector2(1 + (0.25 * upgrades), 1 + (0.25 * upgrades))
		explosiveness = explosiveness + (0.25 * upgrades)
	if TYPE == "flame":
		KNOCKBACK = 0
		despawnTimer = 5 + (2 * upgrades)
		DAMAGE = (DAMAGE / 100) + 0.01 + (0.01 * upgrades)
		$CPUParticles2D.emitting = true
		$CPUParticles2D.color_ramp = fireColors[upgrades]
	else:
		$Outline.self_modulate = Global.enemySpawn.color.get(COLOR)
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
