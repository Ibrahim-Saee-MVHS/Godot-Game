class_name Enemy
extends CharacterBody2D

@export var TYPE: String = "normal"
var SPEED = 4000
var MAXHEALTH = 25
var MAXFIRERATE = 10
var FIRERATE = 0
var DAMAGE = 1
var EXP = 4
var HEALTH: int
var MOVEDIR: float
var BULLETAMOUNT: int = 1
var HITSTUN: float
var BULLETSPEED: float
var shootPitch: float = 1.0
var player_position: Vector2
var target_position: Vector2
var multiplier: float = 1.0
var explosiveness: float
var bulletType: String
@onready var Projectiles = {
	"normal": preload("res://scenes/bullet_types/enemy_bullet.tscn"),
	"flame": preload("res://scenes/bullet_types/enemy_flame.tscn"),
	"bomb": preload("res://scenes/bullet_types/enemy_bomb.tscn"),
}
@onready var Death = preload("res://scenes/vfx/death_particles.tscn")
@onready var ExplosionNode = preload("res://scenes/explosion.tscn")
var shaderMaterial = ShaderMaterial.new()
var knockback: Vector2
var UPGRADES: int

func _ready():
	setStats()
	$HealthBar.max_value = MAXHEALTH
	HITSTUN = 0
	HEALTH = MAXHEALTH
	FIRERATE = MAXFIRERATE

func setStats():
	$Sprite2D.self_modulate = Global.enemySpawn.color.get(TYPE)
	if TYPE == "dummy":
		SPEED = 0
		MAXHEALTH = 20
		MAXFIRERATE = INF
		BULLETAMOUNT = 0
		BULLETSPEED = 0
		DAMAGE = -1
		EXP = 0
		UPGRADES = 0
		bulletType = "none"
		explosiveness = 0
		shootPitch = 1.0
	
	if TYPE == "normal":
		SPEED = 4000
		MAXHEALTH = 26 * multiplier
		MAXFIRERATE = 10
		BULLETAMOUNT = 1
		BULLETSPEED = 200
		DAMAGE = 1 * multiplier
		EXP = 4 * 1 + multiplier / 4
		UPGRADES = 0
		bulletType = "normal"
		explosiveness = 0
		shootPitch = 1.0
	if TYPE == "repeater":
		SPEED = 4100
		MAXHEALTH = 20 * multiplier
		MAXFIRERATE = clamp(4 + (-0.25 * multiplier), 2.5, 4)
		BULLETAMOUNT = 1
		BULLETSPEED = 250
		DAMAGE = 1 * multiplier
		EXP = 6 * 1 + multiplier / 4
		UPGRADES = 0
		bulletType = "normal"
		explosiveness = 0
		shootPitch = 1.25
	if TYPE == "juggernaut":
		SPEED = 3000
		MAXHEALTH = 40 * multiplier
		MAXFIRERATE = 20
		BULLETAMOUNT = 3
		BULLETSPEED = 200
		DAMAGE = 6 * multiplier / 2
		UPGRADES = clamp(round(0 + (0.25 * multiplier)), 0, 6)
		EXP = 8 * 1 + multiplier / 3
		bulletType = "normal"
		explosiveness = 0
		shootPitch = 0.5
	if TYPE == "bomber":
		SPEED = clamp(6000 + (10 * multiplier), 6000, 8000)
		MAXHEALTH = 16 * multiplier
		MAXFIRERATE = 0
		BULLETAMOUNT = 16
		BULLETSPEED = 300
		DAMAGE = 4 * multiplier / 2
		EXP = 12 * 1 + multiplier / 2
		UPGRADES = 0
		bulletType = "bomb"
		explosiveness = 0
		shootPitch = 1.0
	if TYPE == "spreader":
		SPEED = 4000
		MAXHEALTH = 40 * multiplier
		MAXFIRERATE = 8
		BULLETAMOUNT = clamp(ceil(3 * multiplier), 3, 6)
		BULLETSPEED = 200
		DAMAGE = 2 * multiplier
		EXP = 6 * 1 + multiplier / 4
		UPGRADES = 0
		bulletType = "normal"
		explosiveness = 0
		shootPitch = 1.0
	if TYPE == "grenadier":
		SPEED = 5000
		MAXHEALTH = 32 * multiplier
		MAXFIRERATE = 16
		BULLETAMOUNT = clamp(floor(1 * multiplier), 1, 3)
		BULLETSPEED = 200
		DAMAGE = 4 * multiplier
		EXP = 10 * 1 + multiplier / 2
		UPGRADES = 0
		bulletType = "bomb"
		explosiveness = clamp(0.5 * multiplier / 4, 0.5, 1)
		shootPitch = 0.5
	if TYPE == "arsonist":
		SPEED = 3500
		MAXHEALTH = 32 * multiplier
		MAXFIRERATE = 1
		BULLETAMOUNT = 1
		BULLETSPEED = 200
		DAMAGE = 0 + (1 * multiplier / 2)
		UPGRADES = clamp(round(0 + (0.25 * multiplier * multiplier)), 0, 4)
		EXP = 8 * 1 + multiplier / 3
		bulletType = "flame"
		explosiveness = 0
		shootPitch = 1.0
	if Global.GAMEMODIFIERS.get("juggernauts_reign_supreme", false) == true:
		if TYPE == "juggernaut":
			SPEED = 4000
			MAXHEALTH = 80 * multiplier
			MAXFIRERATE = 18
			BULLETAMOUNT = 3
			BULLETSPEED = 400
			DAMAGE = 8 * multiplier / 2
			EXP = 10 * 1 + multiplier / 2
			explosiveness = 0.5
			shootPitch = 0.25
		else:
			$TypeIndicator.self_modulate = Global.enemyColor.get(TYPE)
			$TypeIndicator.visible = true
			if TYPE != "bomber":
				DAMAGE = max(DAMAGE, 6)
				MAXHEALTH = 40 * multiplier
			else:
				DAMAGE = 5 * multiplier / 2
				MAXHEALTH = 28 * multiplier
			if bulletType == "normal": UPGRADES = clamp(round(0 + (0.25 * multiplier)), 0, 6)
			shootPitch = 0.5
	if Global.GAMEMODIFIERS.get("no_hit", false) == true:
		SPEED /= 2
		FIRERATE *= 2
		BULLETSPEED /= 2

func _process(delta):
	$Sprite2D.material = shaderMaterial
	player_position = get_parent().get_node("Player").global_position
	if TYPE == "grenadier":
		target_position = (player_position + get_parent().get_node("Player").velocity / 2.5)
		MOVEDIR = ((player_position + get_parent().get_node("Player").velocity / 2.5) - global_position).angle()
	elif TYPE == "arsonist":
		MOVEDIR = ((player_position + get_parent().get_node("Player").velocity / 4) - global_position).angle()
	else:
		MOVEDIR = (player_position - global_position).angle()
	
	$HealthBar.value = HEALTH
	
	if HITSTUN <= 0:
		shaderMaterial.shader = null
	
	if TYPE != "bomber":
		shoot(delta, deg_to_rad(6.25 * BULLETAMOUNT))
	else:
		if global_position.distance_to(player_position) <= 32:
			explode(DAMAGE, false, global_position)
			queue_free()
	if HEALTH <= 0:
		var DEATH = Death.instantiate()
		DEATH.global_position = global_position
		DEATH.TYPE = TYPE
		Global.SCREENSHAKEAMOUNT = 150
		Global.SCREENSHAKEPOWER = 0.75
		get_parent().add_child(DEATH)
		get_parent().get_node("Player").EXP += EXP
		queue_free()
	if get_parent().get_node("Player").HEALTH <= 0:
		FIRERATE = 10
		SPEED = 0
	if HITSTUN <= 0:
		knockback = Vector2(0, 0)
	else:
		HITSTUN -= 10 * delta

func shoot(delta, spread):
	var startDir = -spread / 2
	var dirSteps = spread / (BULLETAMOUNT - 1)
	if FIRERATE <= 0:
		if TYPE == "arsonist":
			FIRERATE = MAXFIRERATE + randf_range(0, 6.0) * round(randf_range(0, 1))
		else:
			FIRERATE = MAXFIRERATE
		var currentBullet = Projectiles.get(bulletType)
		if bulletType == "flame":
			$FlameThrow.pitch_scale = shootPitch + randf_range(-0.2, 0.2)
			$FlameThrow.playing = true
		else:
			$Shoot.pitch_scale = shootPitch + randf_range(-0.2, 0.2)
			$Shoot.playing = true
		for i in range(BULLETAMOUNT):
			var BULLET = currentBullet.instantiate()
			var dirOffset = startDir + (dirSteps * i) if BULLETAMOUNT > 1 else 0
			BULLET.set("global_position", global_position)
			BULLET.set("COLOR", TYPE)
			BULLET.set("TYPE", bulletType)
			BULLET.set("SPEED", BULLETSPEED)
			BULLET.set("DAMAGE", DAMAGE)
			BULLET.set("MOVEDIR", MOVEDIR + dirOffset)
			BULLET.set("upgrades", UPGRADES)
			BULLET.set("explosiveness", explosiveness)
			BULLET.set("destination_position", target_position)
			get_parent().add_child(BULLET)
	else:
		FIRERATE -= 10 * delta

func _physics_process(delta):
	var initialVelocity = Vector2(SPEED, 0).rotated(MOVEDIR) * delta
	var enemy_group = get_tree().get_nodes_in_group("enemies").duplicate()
	enemy_group.erase(self)
	if knockback == Vector2(0, 0):
		velocity = initialVelocity
		for node in enemy_group:
			if global_position.distance_to(node.global_position) < 32 and TYPE != "bomber":
				var newDir = (global_position - node.global_position).angle()
				velocity = Vector2(SPEED, 0).rotated(lerp_angle(MOVEDIR, newDir, 0.5)) * delta
				move_and_slide()
		if global_position.distance_to(player_position) > 64 or TYPE == "bomber":
			move_and_slide()
		elif global_position.distance_to(player_position) < 32:
			velocity = -initialVelocity
			move_and_slide()
	else:
		velocity = -(knockback * 2) * delta
		move_and_slide()

func explode(power, isPlayer, explosion_position):
	var EXPLOSION = ExplosionNode.instantiate()
	EXPLOSION.global_position = explosion_position
	EXPLOSION.EXPLOSIONPOWER = power
	EXPLOSION.playerExplosion = isPlayer
	get_parent().call_deferred("add_child", EXPLOSION)

func ricochet(bullet: PlayerBullet):
	var nearest_node
	var enemies = get_tree().get_nodes_in_group("enemies").duplicate()
	
	enemies.erase(self)
	if enemies.size() < 1:
		return bullet.MOVEDIR
	else:
		nearest_node = enemies[randi_range(0, enemies.size() - 1)]
		return (bullet.global_position - (nearest_node.global_position + nearest_node.velocity)).angle() + PI

func _gotDamaged(area):
	if HITSTUN <= 0:
		if area is PlayerBullet:
			# bullets
			if area.explosiveness <= 0:
				$Hit.pitch_scale = randf_range(0.9, 1.1)
				$Hit.playing = true
				Global.spawnDamageIndicator(global_position, -area.DAMAGE)
				shaderMaterial.shader = Global.shaders.flash
				HEALTH -= area.DAMAGE
				if area.TYPE == "flame":
					area.get_node("CPUParticles2D").set_deferred("emitting", false)
					area.get_node("CollisionShape2D").set_deferred("disabled", true)
					HITSTUN = 1.5
				elif area.TYPE == "plasma":
					HITSTUN = 2
				else:
					HITSTUN = 1
					knockback = Vector2(area.KNOCKBACK, 0).rotated((area.global_position - global_position).angle())
					if area.ricochet > 0:
						area.SPEED += 50
						area.MOVEDIR = ricochet(area)
						area.ricochet -= 1
					else:
						area.queue_free()
			# explosive bullets
			else:
				$Hit.pitch_scale = randf_range(0.9, 1.1)
				$Hit.playing = true
				Global.spawnDamageIndicator(global_position, -area.DAMAGE)
				HEALTH -= area.DAMAGE
				explode(area.explosiveness, true, area.global_position)
				knockback = Vector2(area.KNOCKBACK, 0).rotated((area.global_position - global_position).angle())
				if area.ricochet > 0:
					area.SPEED += 50
					area.MOVEDIR = ricochet(area)
					area.ricochet -= 1
				else:
					area.queue_free()
		# explosions
		if area is Explosion and area.playerExplosion == true:
			$Hit.pitch_scale = randf_range(0.9, 1.1)
			$Hit.playing = true
			Global.spawnDamageIndicator(global_position, -area.DAMAGE)
			shaderMaterial.shader = Global.shaders.flash
			HEALTH -= area.DAMAGE
			HITSTUN = 4
			knockback = Vector2(area.EXPLOSIONPOWER * 500, 0).rotated((area.global_position - global_position).angle())
		# dash
		if area is Dash:
			$Hit.pitch_scale = randf_range(0.9, 1.1)
			$Hit.playing = true
			Global.spawnDamageIndicator(global_position, -area.DAMAGE)
			shaderMaterial.shader = Global.shaders.flash
			HEALTH -= area.DAMAGE
			HITSTUN = 0.5
