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
var BULLETSPEED: float
var BULLETVARIANCE: float = 0
var DISTANCING: Array[int] # 0: Distance from player to stop moving. 1: Distance from player to move away. 2: Distance from other enemies to stop and move away.
var HITSTUN: float
var currentHitstunTime: float
var shootPitch: float = 1.0
var player_position: Vector2
var target_position: Vector2
var multiplier: float = 1.0
var explosiveness: float
var bulletType: String
var boomerangsThrown: int
@onready var Projectiles = {
	"normal": preload("res://scenes/bullet_types/enemy_bullet.tscn"),
	"flame": preload("res://scenes/bullet_types/enemy_flame.tscn"),
	"bomb": preload("res://scenes/bullet_types/enemy_bomb.tscn"),
	"boomerang": preload("res://scenes/bullet_types/enemy_boomerang.tscn"),
	"frost": preload("res://scenes/bullet_types/enemy_icicle.tscn"),
	"air": preload("res://scenes/bullet_types/enemy_air_slash.tscn"),
	"earth": preload("res://scenes/bullet_types/enemy_rock_pellet.tscn"),
}
@onready var Death = preload("res://scenes/vfx/death_particles.tscn")
@onready var BulletWarn = preload("res://scenes/bullet_types/bullet_warn.tscn")
@onready var ExplosionNode = preload("res://scenes/explosion.tscn")
var shaderMaterial = ShaderMaterial.new()
var knockback: Vector2
var UPGRADES: int

func _ready():
	setStats()
	$HealthBar.max_value = MAXHEALTH
	HITSTUN = 0
	HEALTH = MAXHEALTH
	if TYPE == "thundermancer":
		FIRERATE = round(float(MAXFIRERATE) / 2) + randf_range(-4.0, 8.0)
	else:
		FIRERATE = MAXFIRERATE

func setStats():
	$Sprite2D.self_modulate = Global.enemySpawn.color.get(TYPE)
	if TYPE == "dummy":
		SPEED = 0
		MAXHEALTH = 20
		MAXFIRERATE = INF
		BULLETAMOUNT = 0
		BULLETSPEED = 0
		BULLETVARIANCE = 0
		DISTANCING = [64, 32, 32]
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
		BULLETVARIANCE = 0
		DISTANCING = [64, 32, 32]
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
		BULLETVARIANCE = 0
		DISTANCING = [64, 32, 32]
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
		BULLETVARIANCE = 0
		DISTANCING = [64, 32, 32]
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
		BULLETVARIANCE = 0
		DISTANCING = [0, 0, 0]
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
		BULLETVARIANCE = 0
		DISTANCING = [64, 32, 32]
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
		BULLETVARIANCE = 0
		DISTANCING = [64, 32, 32]
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
		BULLETVARIANCE = 0
		DISTANCING = [64, 32, 32]
		DAMAGE = 0 + (1 * multiplier / 2)
		UPGRADES = clamp(round(0 + (0.25 * multiplier * multiplier)), 0, 4)
		EXP = 8 * 1 + multiplier / 3
		bulletType = "flame"
		explosiveness = 0
		shootPitch = 1.0
	if TYPE == "boomeranger":
		SPEED = 4000
		MAXHEALTH = 20 * multiplier
		MAXFIRERATE = 6
		BULLETAMOUNT = 1
		BULLETSPEED = 250
		BULLETVARIANCE = 0
		DISTANCING = [64, 32, 32]
		DAMAGE = 4 * multiplier
		EXP = 4 * 1 + multiplier / 4
		UPGRADES = clamp(round(0.3 * multiplier), 0, 3)
		bulletType = "boomerang"
		explosiveness = 0
		shootPitch = 1.0
	if TYPE == "frostmancer":
		SPEED = 3600
		MAXHEALTH = 24 * multiplier
		MAXFIRERATE = clamp(round(1 - (0.05 * multiplier)), 0.5, 1.5)
		BULLETAMOUNT = clamp(round(1 + (0.1 * multiplier)), 1, 5)
		BULLETSPEED = 350
		BULLETVARIANCE = 12
		DISTANCING = [64, 32, 32]
		DAMAGE = 1 + (0.25 * multiplier / 4)
		UPGRADES = clamp(round(0 + (0.25 * (multiplier * multiplier))), 0, 4)
		EXP = 8 * 1 + multiplier / 3
		bulletType = "frost"
		explosiveness = 0
		shootPitch = 1.0
	if TYPE == "thundermancer":
		SPEED = 6000
		MAXHEALTH = 38 * multiplier
		MAXFIRERATE = clamp(round(48 - (0.25 * multiplier)), 16, 48)
		BULLETAMOUNT = clamp(round(1 + (0.25 * (multiplier * (multiplier)))), 1, 6)
		BULLETSPEED = 350
		BULLETVARIANCE = clamp(round(128 - (4 * multiplier)), 48, 128)
		DISTANCING = [128, 112, 32]
		DAMAGE = 10 + (2 * multiplier / 4)
		UPGRADES = clamp(round(0 + (0.25 * (multiplier * (multiplier/1.5)))), 0, 3)
		EXP = 12 * 1 + multiplier / 3
		bulletType = "thunder"
		explosiveness = 0
		shootPitch = 1.0
	if TYPE == "thrower":
		SPEED = 3600
		MAXHEALTH = 38 * multiplier
		MAXFIRERATE = clamp(round(8 - (0.5 * multiplier)), 6, 16)
		BULLETAMOUNT = clamp(round(1 + (0.1 * multiplier)), 1, 5)
		BULLETSPEED = 400
		BULLETVARIANCE = clamp(round(16 - (1 * ((multiplier - 1) / 2))), 8, 16)
		DISTANCING = [64, 32, 32]
		UPGRADES = clamp(round(0 + (0.25 * (multiplier * multiplier))), 0, 2)
		DAMAGE = 6 + UPGRADES + (0.25 * multiplier / 4)
		EXP = 12 * 1 + multiplier / 3
		bulletType = "earth"
		explosiveness = 0
		shootPitch = 1.0
	if TYPE == "slasher":
		SPEED = 5400
		MAXHEALTH = 24 * multiplier
		MAXFIRERATE = clamp(round(5 - (0.25 * multiplier)), 1, 5)
		BULLETAMOUNT = 1
		BULLETSPEED = 500
		BULLETVARIANCE = 0
		DISTANCING = [64, 32, 32]
		UPGRADES = clamp(0 + (0.25 * multiplier), 0, 2)
		DAMAGE = 1 + (0.25 * multiplier / 2)
		EXP = 4 * 1 + multiplier / 3
		bulletType = "air"
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
				DAMAGE = max(DAMAGE * 2.5, 6)
				MAXHEALTH *= 2.5
			else:
				DAMAGE *= 2.5
				MAXHEALTH *= 1.5
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
	elif TYPE == "thrower":
		MOVEDIR = ((player_position + get_parent().get_node("Player").velocity / 2) - global_position).angle()
	else:
		MOVEDIR = (player_position - global_position).angle()
	
	$HealthBar.value = HEALTH
	
	if HITSTUN <= 0:
		currentHitstunTime = 0
		shaderMaterial.shader = null
	
	if TYPE == "bomber":
		if global_position.distance_to(player_position) <= 32:
			explode(DAMAGE, false, global_position)
			queue_free()
	elif TYPE == "thundermancer":
		if FIRERATE <= 0:
			for i in range(BULLETAMOUNT):
				var THUNDERWARNING = BulletWarn.instantiate()
				THUNDERWARNING.TYPE = "thunder"
				THUNDERWARNING.spawnTimer = 8
				THUNDERWARNING.specialVars.damage = DAMAGE
				THUNDERWARNING.specialVars.duration = 2 + UPGRADES
				THUNDERWARNING.specialVars.upgrades = UPGRADES
				if i == 0 and multiplier >= 2:
					THUNDERWARNING.global_position = player_position
				else:
					THUNDERWARNING.global_position = player_position + Vector2(randf_range(-BULLETVARIANCE, BULLETVARIANCE), randf_range(-BULLETVARIANCE, BULLETVARIANCE))
				get_parent().add_child(THUNDERWARNING)
			FIRERATE = MAXFIRERATE + randf_range(-4.0, 8.0)
		else:
			FIRERATE -= 10 * delta
	else:
		shoot(delta, deg_to_rad(6.25 * BULLETAMOUNT))
	if HEALTH <= 0:
		var DEATH = Death.instantiate()
		DEATH.global_position = global_position
		DEATH.TYPE = TYPE
		Global.SCREENSHAKE(150, 0.75)
		get_parent().add_child(DEATH)
		get_parent().get_node("Player").EXP += EXP
		queue_free()
	if get_parent().get_node("Player").HEALTH <= 0:
		FIRERATE = 10
		SPEED = 0
	if HITSTUN <= 0:
		knockback = Vector2(0, 0)
	else:
		if currentHitstunTime == 0:
			currentHitstunTime = HITSTUN
		HITSTUN -= 10 * delta
		if HITSTUN >= currentHitstunTime - 1:
			shaderMaterial.shader = Global.shaders.flash
		elif HITSTUN < currentHitstunTime - 1:
			shaderMaterial.shader = Global.shaders.tint

func shoot(delta, spread):
	var startDir = -spread / 2
	var dirSteps = spread / (BULLETAMOUNT - 1)
	if TYPE == "bomber":
		return
	if FIRERATE <= 0:
		if TYPE == "arsonist":
			FIRERATE = MAXFIRERATE + randf_range(0, 6.0) * round(randf_range(0, 1))
		elif TYPE == "froster":
			FIRERATE = MAXFIRERATE + randf_range(4.0, 8.0) * round(randf_range(-0.25, 0.6))
		else:
			FIRERATE = MAXFIRERATE
		if bulletType == "boomerang":
			boomerangsThrown += 1
			if boomerangsThrown == 3 + (1 * UPGRADES):
				FIRERATE = max(FIRERATE * 2, 8)
				boomerangsThrown = 0
		var currentBullet = Projectiles.get(bulletType)
		if bulletType == "flame":
			$FlameThrow.pitch_scale = shootPitch + randf_range(-0.2, 0.2)
			$FlameThrow.playing = true
		elif bulletType == "frost":
			$IcicleThrow.pitch_scale = shootPitch + randf_range(-0.2, 0.2)
			$IcicleThrow.playing = true
		else:
			$Shoot.pitch_scale = shootPitch + randf_range(-0.2, 0.2)
			$Shoot.playing = true
		for i in range(BULLETAMOUNT):
			var BULLET = currentBullet.instantiate()
			var dirOffset = startDir + (dirSteps * i) if BULLETAMOUNT > 1 else 0
			BULLET.set("shooter", self)
			BULLET.set("global_position", global_position)
			BULLET.set("COLOR", TYPE)
			BULLET.set("TYPE", bulletType)
			BULLET.set("SPEED", BULLETSPEED)
			BULLET.set("DAMAGE", DAMAGE)
			BULLET.set("MOVEDIR", MOVEDIR + dirOffset + deg_to_rad(randf_range(-BULLETVARIANCE, BULLETVARIANCE)))
			BULLET.set("upgrades", UPGRADES)
			BULLET.set("explosiveness", explosiveness)
			BULLET.set("destination_position", target_position)
			
			if bulletType == "frost":
				var variance = Vector2(randf_range(-BULLETVARIANCE, BULLETVARIANCE), randf_range(-BULLETVARIANCE, BULLETVARIANCE))
				BULLET.set("global_position", global_position + variance)
				BULLET.set("MOVEDIR", MOVEDIR + dirOffset)
				BULLET.set("destination_position", target_position + variance)
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
			if global_position.distance_to(node.global_position) < DISTANCING[2] and TYPE != "bomber":
				var newDir = (global_position - node.global_position).angle()
				velocity = Vector2(SPEED, 0).rotated(lerp_angle(MOVEDIR, newDir, 0.5)) * delta
				move_and_slide()
		if global_position.distance_to(player_position) > DISTANCING[0] or TYPE == "bomber":
			move_and_slide()
		elif global_position.distance_to(player_position) < DISTANCING[1]:
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

func deal_damage(area:Area2D, invulnerablity:float, knockback_type:String = "default"):
	if HITSTUN <= 0:
		$Hit.pitch_scale = randf_range(0.9, 1.1)
		$Hit.playing = true
		Global.spawnDamageIndicator(global_position, -area.DAMAGE)
		shaderMaterial.shader = Global.shaders.flash
		HEALTH -= area.DAMAGE
		HITSTUN = invulnerablity
		if knockback_type == "none":
			pass
		elif knockback_type == "explosion":
			knockback = Vector2(area.EXPLOSIONPOWER * 500, 0).rotated((area.global_position - global_position).angle())
		elif knockback_type == "air":
			knockback = Vector2(area.KNOCKBACK, 0).rotated((player_position - global_position).angle())
		else:
			knockback = Vector2(area.KNOCKBACK, 0).rotated((area.global_position - global_position).angle())

func _gotDamaged(area):
	if area is PlayerBullet:
		# bullets
		if area.explosiveness <= 0:
			var inv: float = 1
			var kbType: String = "default"
			if area.TYPE == "flame":
				inv = 0.5
				kbType = "none"
			elif area.TYPE == "water":
				area.get_node("CPUParticles2D").set_deferred("emitting", false)
				area.get_node("CollisionShape2D").set_deferred("disabled", true)
				inv = 0.75
				kbType = "none"
			elif area.TYPE == "dark":
				inv = 0.5
			elif area.TYPE == "light":
				area.get_node("CPUParticles2D").set_deferred("emitting", false)
				inv = 2
			elif area.TYPE == "air":
				inv = 1
				kbType = "none"
			elif area.TYPE == "plasma":
				inv = 2
				kbType = "none"
			else:
				inv = 1
				kbType = "default"
				if area.ricochet > 0:
					area.SPEED += 50
					area.MOVEDIR = ricochet(area)
					area.ricochet -= 1
				else:
					area.queue_free()
			deal_damage(area, inv, kbType)
		# explosive bullets
		else:
			deal_damage(area, 0, "none")
			explode(area.explosiveness, true, area.global_position)
			if area.ricochet > 0:
				area.SPEED += 50
				area.MOVEDIR = ricochet(area)
				area.ricochet -= 1
			else:
				area.queue_free()
	# player summons
	if area is PlayerSummon:
		deal_damage(area, 0.5, "none")
	# player thunder strike
	if area is PlayerThunderStrike:
		deal_damage(area, area.INV, "none")
	# explosions
	if area is Explosion and area.playerExplosion == true:
		deal_damage(area, 4, "explosion")
	# dash
	if area is Dash:
		deal_damage(area, 0.5, "none")
