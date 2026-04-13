class_name Player
extends CharacterBody2D

@export var BASESPEED: float = 8000
@export var MAXHEALTH: int = 50
@export var BASEDAMAGE: float = 4
@export var BASEBULLETSPEED: int = 250
@export var BASEBULLETAMOUNT: int = 1
@export var BASEFIRERATE: float = 8
var DAMAGE: float
var BULLETSPEED: int
var BULLETAMOUNT: int
var BULLETSPREAD: float
var SPEED: float
var HEALTH: int
var MAXFIRERATE: float
var FIRERATE: float = 0
var LEVEL: int = 1
var EXP: int = 0
var EXPMAX: int
var INVULNERABILITY: float = 0
var MAXINVULNERABILITY: float = 4
var ABILITY: StringName
var ABILITYDURATION: float
var ABILITYCOOLDOWN: float
@onready var Death = preload("res://scenes/vfx/player_death.tscn")
@onready var GameOver = preload("res://scenes/game_over.tscn")
@onready var UpgradeScreen = preload("res://scenes/upgrade_screen.tscn")
var shaderMaterial = ShaderMaterial.new()

var bulletType = "normal"
var Projectiles = {
	"normal": preload("res://scenes/bullet_types/player_bullet.tscn"),
	"flame": preload("res://scenes/bullet_types/player_flame.tscn"),
	"plasma": preload("res://scenes/bullet_types/player_plasma.tscn"),
}
var UPGRADE = {
	health = 0,
	firerate = 0,
	damage = 0,
	speed = 0,
	bulletSpeed = 0,
	bulletAmount= 0,
}

func _ready() -> void:
	MAXHEALTH = clamp(50 + ( (LEVEL - 1) * 5), 50, 500)
	MAXFIRERATE = clamp(BASEFIRERATE - ( float(LEVEL - 1) / 4), 2, 16)
	DAMAGE = clamp(BASEDAMAGE + ( float(LEVEL - 1) / 8), 4, 32)
	BULLETSPREAD = deg_to_rad(6.25 * BULLETAMOUNT)
	BULLETSPEED = BASEBULLETSPEED
	BULLETAMOUNT = BASEBULLETAMOUNT
	SPEED = BASESPEED
	HEALTH = MAXHEALTH
	EXPMAX = 4

func level():
	MAXHEALTH = clamp(50 + ( (LEVEL - 1) * 5) + UPGRADE.health, 50, 500)
	MAXFIRERATE = clamp(BASEFIRERATE - ( float(LEVEL - 1) / 8) + UPGRADE.firerate, 1, 16)
	DAMAGE = clamp(BASEDAMAGE + ( float(LEVEL - 1) / 16) + UPGRADE.damage, 0.01, 32)
	if EXP >= EXPMAX:
		LEVEL += 1
		EXP = 0
		EXPMAX += 4
		MAXHEALTH = clamp(50 + ( (LEVEL - 1) * 5) + UPGRADE.health, 50, 500)
		HEALTH = clamp(HEALTH + 5, HEALTH, MAXHEALTH)
		if HEALTH > 0:
			get_parent().add_child(UpgradeScreen.instantiate())

func getPlayerInput():
	var x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return Vector2(x, y).normalized()

func _process(delta):
	level()
	if bulletType == "flame":
		MAXFIRERATE = BASEFIRERATE
	SPEED = BASESPEED + (UPGRADE.speed * 200)
	BULLETSPEED = clamp(BASEBULLETSPEED + (UPGRADE.bulletSpeed * 10), 125, 1000)
	BULLETAMOUNT = BASEBULLETAMOUNT + UPGRADE.bulletAmount
	
	if Input.is_action_just_pressed("quick_upgrade"):
		EXP += EXPMAX
	
	$Sprite2D.material = shaderMaterial
	if INVULNERABILITY <= 0:
		shaderMaterial.shader = null
	else:
		INVULNERABILITY -= 10 * delta
		if INVULNERABILITY < MAXINVULNERABILITY - 1:
			shaderMaterial.shader = Global.shaders.tint
		
	if Input.is_action_pressed("shoot") and FIRERATE <= 0:
		if bulletType == "flame":
			shoot(deg_to_rad(45 * BULLETAMOUNT), 5)
		else:
			shoot(BULLETSPREAD, 0)
	elif FIRERATE > 0 and HEALTH >= 0:
		FIRERATE -= 10 * delta
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
			$CollisionShape2D.queue_free()
			$Area2D.queue_free()
		FIRERATE = 1000
		SPEED = 0

func shoot(spread, variance):
	var startDir = -spread / 2
	var dirSteps = spread / (BULLETAMOUNT - 1)
	var currentBullet = Projectiles.get(bulletType)
	$Shoot.pitch_scale = randf_range(0.8, 1.2)
	$Shoot.playing = true
	FIRERATE = MAXFIRERATE
	for i in range(BULLETAMOUNT):
		var BULLET = currentBullet.instantiate()
		var dirOffset = startDir + (dirSteps * i) if BULLETAMOUNT > 1 else 0
		BULLET.global_position = global_position
		BULLET.TYPE = bulletType
		BULLET.SPEED = BULLETSPEED
		BULLET.DAMAGE = DAMAGE
		BULLET.MOVEDIR = (get_global_mouse_position() - global_position).angle() + dirOffset + deg_to_rad(randf_range(-variance, variance))
		get_parent().add_child(BULLET)

func _physics_process(delta):
	var input = getPlayerInput()
	var screenSize = get_viewport_rect().size / 4
	velocity = input * SPEED * delta
	move_and_slide()
	position = position.clamp(-screenSize + Vector2(8, 8), screenSize - Vector2(8, 8))

func _on_area_2d_area_entered(area):
	if area is EnemyBullet and INVULNERABILITY <= 0:
		$Hit.pitch_scale = randf_range(0.9, 1.1)
		$Hit.playing = true
		Global.SCREENSHAKEAMOUNT = 100 * 1 + (area.DAMAGE/2)
		Global.SCREENSHAKEPOWER = 0.5 + (area.DAMAGE/10)
		Global.VIGNETTEINTENSITY = 0.5
		Global.VIGNETTECOLOR = Vector3(1, 0, 0)
		shaderMaterial.shader = Global.shaders.flash
		INVULNERABILITY = MAXINVULNERABILITY
		HEALTH -= area.DAMAGE
		Global.spawnDamageIndicator(global_position, -area.DAMAGE)
		area.queue_free()
	if area is HealthBox:
		$Health.pitch_scale = randf_range(0.9, 1.1)
		$Health.playing = true
		Global.VIGNETTEINTENSITY = 0.25
		Global.VIGNETTECOLOR = Vector3(0, 1, 0.75)
		HEALTH += 15
		area.queue_free()
