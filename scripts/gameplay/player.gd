class_name Player
extends CharacterBody2D

@export var BASESPEED: float = 8000
@export var MAXHEALTH: int = 50
@export var BASEDAMAGE: float = 4
@export var BASEBULLETSPEED: int = 250
@export var BASEBULLETAMOUNT: int = 1
@export var BASEFIRERATE: float = 8
var BULLETVARIANCE: float = 0
var MAXBULLETAMOUNT: int = 9
var DAMAGE: float
var BULLETSPEED: int
var BULLETAMOUNT: int
var BULLETSPREAD: float
var SPEED: float
var HEALTH: int
var MAXFIRERATE: float
var MINFIRERATE: float
var FIRERATE: float = 0
var LEVEL: int = 1
var EXP: int = 0
var EXPMAX: int
var INVULNERABILITY: float = 0
var MAXINVULNERABILITY: float = 4
var currentInvulnerabilityTime: float
var ABILITY: String # ability
var ABILITYPOWER: float # ability power
var ABILITYDURATION: float # the duration that gets set to Abilities.abilityTimer
var ABILITYCOOLDOWN: float # the current cooldown for abilities
var ABILITYMAXCOOLDOWN: float # the cooldown that gets set to ABILITYCOOLDOWN
@onready var Death = load("res://scenes/vfx/player_death.tscn")
@onready var GameOver = load("res://scenes/game_over.tscn")
@onready var UpgradeScreen = load("res://scenes/upgrade_screen.tscn")
@onready var ExplosionNode = load("res://scenes/explosion.tscn")
@onready var DashNode = load("res://scenes/dash.tscn")
@onready var ShieldNode = load("res://scenes/shield.tscn")
var shaderMaterial = ShaderMaterial.new()
var knockbackDir: float
var knockbackPower: float
var knockback: Vector2
var boomerangsThrown: int = 0

var bulletType = "normal"
var Projectiles = {
	"normal": preload("res://scenes/bullet_types/player_bullet.tscn"),
	"flame": load("res://scenes/bullet_types/player_flame.tscn"),
	"plasma": load("res://scenes/bullet_types/player_plasma.tscn"),
	"boomerang": load("res://scenes/bullet_types/player_boomerang.tscn"),
}
var UPGRADE = {
	health = 0,
	firerate = 0,
	damage = 0,
	speed = 0,
	# for bullets
	bulletSpeed = 0,
	bulletAmount = 0,
	bulletVariance = 0,
	bulletUpgrades = 0,
	ricochet = 0,
	homing = 0,
	explosiveness = 0,
	# for abilities
	abilityPower = 0,
	abilityDuration = 0,
	abilityCooldown = 0,
}

func _ready() -> void:
	$Sprite2D.self_modulate = Global.playerColor
	if Global.GAMEMODIFIERS.get("no_hit", false) == true:
		MAXHEALTH = 1
	else:
		MAXHEALTH = clamp(50 + ( (LEVEL - 1) * 5), 50, 500)
	MAXFIRERATE = clamp(BASEFIRERATE, 2, 16)
	MINFIRERATE = 1
	DAMAGE = clamp(BASEDAMAGE, 4, 32)
	BULLETSPREAD = deg_to_rad(6.25 * BULLETAMOUNT)
	BULLETSPEED = BASEBULLETSPEED
	BULLETAMOUNT = BASEBULLETAMOUNT
	bulletType = "normal"
	MAXBULLETAMOUNT = 9
	SPEED = BASESPEED
	HEALTH = MAXHEALTH
	EXPMAX = 4
	ABILITY = "none"

func level():
	if Global.GAMEMODIFIERS.get("no_hit", false) == true:
		MAXHEALTH = 1
	else:
		MAXHEALTH = clamp(50 + ( (LEVEL - 1) * 5) + UPGRADE.health, 1, 500)
	if EXP >= EXPMAX:
		LEVEL += 1
		EXPMAX += 4
		if Global.GAMEMODIFIERS.get("no_hit", false) == true:
			UPGRADE.speed += 0.25
			UPGRADE.damage += 0.25
			UPGRADE.firerate -= 0.25
		else:
			MAXHEALTH = clamp(50 + ( (LEVEL - 1) * 5) + UPGRADE.health, 1, 500)
			HEALTH = clamp(HEALTH + 5, 0, MAXHEALTH)
		if HEALTH > 0:
			get_parent().add_child(UpgradeScreen.instantiate())

func getPlayerInput():
	return Input.get_vector("left", "right", "up", "down")

func _process(delta):
	level()
	setBaseStats()
	setAbilityStats()
	HEALTH = clamp(HEALTH, 0, MAXHEALTH)
	MAXFIRERATE = clamp(BASEFIRERATE + (UPGRADE.firerate if bulletType != "flame" else UPGRADE.firerate / 5), MINFIRERATE, 16)
	DAMAGE = clamp(BASEDAMAGE + UPGRADE.damage, 0.01, 32)
	SPEED = BASESPEED + (UPGRADE.speed * 200) + (1000 * ABILITYPOWER if ABILITY == "flashtime" and Abilities.abilityTimer > 0 else 0.0)
	BULLETSPEED = clamp(BASEBULLETSPEED + (UPGRADE.bulletSpeed * 10), 75, 1000)
	BULLETAMOUNT = clamp(BASEBULLETAMOUNT + UPGRADE.bulletAmount, 1, MAXBULLETAMOUNT)
	ABILITYMAXCOOLDOWN = clamp(ABILITYMAXCOOLDOWN, 6, 48)
	ABILITYCOOLDOWN = clamp(ABILITYCOOLDOWN, 0, ABILITYMAXCOOLDOWN)
	
	if Input.is_action_just_pressed("quick_upgrade") and OS.has_feature("editor"):
		EXP += EXPMAX
	
	$Sprite2D.material = shaderMaterial
	if INVULNERABILITY <= 0:
		currentInvulnerabilityTime = 0
		shaderMaterial.shader = null
		knockbackPower = 0
		knockbackDir = 0
		knockback = Vector2(0, 0)
	else:
		INVULNERABILITY -= 10 * delta
		if INVULNERABILITY >= currentInvulnerabilityTime - 1:
			shaderMaterial.shader = Global.shaders.flash
		elif INVULNERABILITY < currentInvulnerabilityTime - 1:
			shaderMaterial.shader = Global.shaders.tint
	
	if Input.is_action_pressed("shoot") and FIRERATE <= 0:
		shoot(BULLETSPREAD, BULLETVARIANCE)
	elif FIRERATE > 0 and HEALTH >= 0:
		FIRERATE -= 10 * delta
	if Input.is_action_pressed("ability") and ABILITYCOOLDOWN <= 0:
		activateAbility(delta)
	elif ABILITYCOOLDOWN > 0:
		if Abilities.abilityTimer > 0:
			ABILITYCOOLDOWN = ABILITYMAXCOOLDOWN
		elif Abilities.abilityTimer <= 0 and HEALTH >= 0:
			ABILITYCOOLDOWN -= 1 * delta
			if ABILITY == "dash":
				$CollisionShape2D.disabled = false
	if HEALTH <= 0:
		# This is so that certain things are done once
		if visible == true:
			Global.SCREENSHAKEAMOUNT = 400
			Global.SCREENSHAKEPOWER = 2
			var DEATHPARTICLE = Death.instantiate()
			DEATHPARTICLE.global_position = global_position
			DEATHPARTICLE.emitting = true
			get_parent().add_child(DEATHPARTICLE)
			visible = false
			$CollisionShape2D.disabled = true
			$Area2D/CollisionShape2D.disabled = true
		ABILITYPOWER = 0
		ABILITYCOOLDOWN = 1000
		FIRERATE = 1000
		SPEED = 0

func setBaseStats():
	if Global.GAMEMODIFIERS.get("no_hit", false) == true:
		BASESPEED = 9000
	else:
		BASESPEED = 8000
	if bulletType == "normal":
		BULLETSPREAD = deg_to_rad(6.25 * BULLETAMOUNT)
		BULLETVARIANCE = 0
		BASEFIRERATE = 8.0
		BASEDAMAGE = 4.0
		BASEBULLETSPEED = 250
		BASEBULLETAMOUNT = 1
		MAXBULLETAMOUNT = 9 - (2 * UPGRADE.bulletUpgrades) if UPGRADE.ricochet + UPGRADE.homing <= 0 else 1
		MINFIRERATE = 1 + (1.5 * UPGRADE.bulletUpgrades)
	if bulletType == "flame":
		BULLETSPREAD = deg_to_rad(45 * BULLETAMOUNT)
		BULLETVARIANCE = 5
		BASEFIRERATE = 1.0
		BASEDAMAGE = 0.01
		BASEBULLETSPEED = 125
		BASEBULLETAMOUNT = 1
		MAXBULLETAMOUNT = 1
		MINFIRERATE = 1
	if bulletType == "plasma":
		BULLETSPREAD = deg_to_rad(6.25 * BULLETAMOUNT)
		BULLETVARIANCE = 0
		BASEFIRERATE = 10.0
		BASEDAMAGE = 4.0
		BASEBULLETSPEED = 75
		BASEBULLETAMOUNT = 1
		MAXBULLETAMOUNT = 3
		MINFIRERATE = 4
	if bulletType == "boomerang":
		BULLETSPREAD = deg_to_rad(6.25 * BULLETAMOUNT)
		BULLETVARIANCE = 0
		BASEFIRERATE = 4.0
		BASEDAMAGE = 5.0
		BASEBULLETSPEED = 250
		BASEBULLETAMOUNT = 1
		MAXBULLETAMOUNT = 4 if UPGRADE.ricochet + UPGRADE.homing <= 0 else 1
		MINFIRERATE = 1

func shoot(spread, variance):
	var startDir = -spread / 2
	var dirSteps = spread / (BULLETAMOUNT - 1)
	var currentBullet = Projectiles.get(bulletType)
	if bulletType == "flame":
		$FlameThrow.pitch_scale = randf_range(0.5, 1.5)
		$FlameThrow.playing = true
	else:
		$Shoot.pitch_scale = randf_range(0.8, 1.2)
		$Shoot.playing = true
	FIRERATE = MAXFIRERATE
	if bulletType == "boomerang":
		boomerangsThrown += 1
		if boomerangsThrown == 3 + (1 * UPGRADE.bulletUpgrades):
			FIRERATE = max(FIRERATE * 2, 8)
			boomerangsThrown = 0
	for i in range(BULLETAMOUNT):
		var BULLET = currentBullet.instantiate()
		var dirOffset = startDir + (dirSteps * i) if BULLETAMOUNT > 1 else 0
		BULLET.set("TYPE", bulletType)
		BULLET.set("global_position", global_position)
		BULLET.set("SPEED", BULLETSPEED)
		BULLET.set("DAMAGE", DAMAGE)
		BULLET.set("ricochet", UPGRADE.ricochet)
		BULLET.set("explosiveness", UPGRADE.explosiveness)
		BULLET.set("upgrades", UPGRADE.bulletUpgrades)
		BULLET.set("homing", UPGRADE.homing)
		BULLET.set("MOVEDIR", (get_global_mouse_position() - global_position).angle() + dirOffset + deg_to_rad(randf_range(-variance, variance)))
		get_parent().add_child(BULLET)

func activateAbility(delta):
	if ABILITY == "detonation":
		Abilities.detonation(global_position)
	if ABILITY == "flashtime":
		Abilities.flashtime()
	if ABILITY == "dash":
		var DASH = DashNode.instantiate()
		DASH.DAMAGE = (4 + UPGRADE.abilityPower + (UPGRADE.damage / 10)) * 2
		DASH.rotation = (get_global_mouse_position() - global_position).angle() + PI
		add_child(DASH)
		$CollisionShape2D.disabled = true
		Abilities.dash(get_global_mouse_position(), global_position, delta)
	if ABILITY == "shield":
		var SHIELD = ShieldNode.instantiate()
		add_child(SHIELD)
	ABILITYCOOLDOWN = ABILITYMAXCOOLDOWN

func setAbilityStats():
	if ABILITY == "detonation":
		ABILITYPOWER = 1 + UPGRADE.abilityPower
		ABILITYDURATION = 0
		ABILITYMAXCOOLDOWN = 24 + UPGRADE.abilityCooldown
	if ABILITY == "flashtime":
		ABILITYPOWER = 1 + UPGRADE.abilityPower
		ABILITYDURATION = 10 + UPGRADE.abilityDuration
		ABILITYMAXCOOLDOWN = 16 + UPGRADE.abilityCooldown
	if ABILITY == "dash":
		ABILITYPOWER = (5 + UPGRADE.abilityPower) * 5
		ABILITYDURATION = 0.2 + UPGRADE.abilityDuration
		ABILITYMAXCOOLDOWN = 8 + UPGRADE.abilityCooldown
	if ABILITY == "shield":
		ABILITYPOWER = 2 + UPGRADE.abilityPower
		ABILITYDURATION = 0
		ABILITYMAXCOOLDOWN = 28 + UPGRADE.abilityCooldown

func _physics_process(delta):
	var input = getPlayerInput()
	var screenSize = get_viewport_rect().size / 4
	if not (ABILITY == "dash" and Abilities.abilityTimer > 0):
		if knockbackPower <= 0:
			velocity = input * SPEED * delta
		else:
			knockback = -Vector2(knockbackPower * 5000, 0).rotated(knockbackDir)
			velocity = knockback * delta
			knockbackPower -= 20 * delta
	move_and_slide()
	position = position.clamp(-screenSize + Vector2(8, 8), screenSize - Vector2(8, 8))

func explode(power, isPlayer, explosion_position):
	var EXPLOSION = ExplosionNode.instantiate()
	EXPLOSION.global_position = explosion_position
	EXPLOSION.EXPLOSIONPOWER = power
	EXPLOSION.playerExplosion = isPlayer
	get_parent().call_deferred("add_child", EXPLOSION)

func dealDamage(damage, inv):
	$Hit.pitch_scale = randf_range(0.9, 1.1)
	$Hit.playing = true
	Global.SCREENSHAKEAMOUNT = 100 * 1 + (damage / round(float(MAXHEALTH) / 25) )
	Global.SCREENSHAKEPOWER = 0.5 + (damage / round(float(MAXHEALTH) / 5) )
	Global.VIGNETTEINTENSITY = 0.5
	Global.VIGNETTECOLOR = Vector3(1, 0, 0)
	shaderMaterial.shader = Global.shaders.flash
	currentInvulnerabilityTime = inv
	INVULNERABILITY = inv
	HEALTH -= damage
	Global.spawnDamageIndicator(global_position, -damage)

func _on_area_2d_area_entered(area):
	if INVULNERABILITY <= 0 and not has_node("Shield"):
		# bullets
		if area is EnemyBullet:
			# flame
			if area.TYPE == "flame":
				dealDamage(area.DAMAGE, MAXINVULNERABILITY * 0.5)
				area.get_node("CPUParticles2D").set_deferred("emitting", false)
				area.get_node("CollisionShape2D").set_deferred("disabled", true)
			# normal
			elif area.explosiveness <= 0:
				dealDamage(area.DAMAGE, MAXINVULNERABILITY)
				area.queue_free()
			# explosive bullets
			elif area.TYPE != "bomb":
				explode(area.explosiveness, false, area.global_position)
				area.queue_free()
		# explosions
		if area is Explosion and area.playerExplosion == false:
			dealDamage(area.DAMAGE, MAXINVULNERABILITY * 2)
			knockbackPower = clampf(area.EXPLOSIONPOWER, 2, 16)
			knockbackDir = (area.global_position - global_position).angle()
	if area is HealthBox and HEALTH < MAXHEALTH:
		$Health.pitch_scale = randf_range(0.9, 1.1)
		$Health.playing = true
		Global.VIGNETTEINTENSITY = 0.25
		Global.VIGNETTECOLOR = Vector3(0, 1, 0.75)
		HEALTH += area.healingAmount
		Global.spawnDamageIndicator(global_position, area.healingAmount)
		area.queue_free()
