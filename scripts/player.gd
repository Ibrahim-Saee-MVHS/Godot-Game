class_name Player
extends CharacterBody2D

@export var SPEED = 8000
@export var MAXHEALTH: int = 50
@export var DAMAGE: float = 4
@export var BULLETSPEED = 250
@export var BULLETAMOUNT: int = 1
var HEALTH: int
var MAXFIRERATE: float = 8
var FIRERATE: float = 0
var LEVEL: int = 1
var EXP: int = 0
var EXPMAX: int = 2
var INVULNERABILITY: float = 0
var MAXINVULNERABILITY: float = 4
@onready var Bullet = preload("res://scenes/player_bullet.tscn")
@onready var Death = preload("res://scenes/vfx/player_death.tscn")
@onready var GameOver = preload("res://scenes/game_over.tscn")
var shaderMaterial = ShaderMaterial.new()

func _ready() -> void:
	HEALTH = MAXHEALTH

func level():
	MAXHEALTH = clamp(50 + ( (LEVEL - 1) * 5), 50, 500)
	MAXFIRERATE = clamp(8 - ( float(LEVEL - 1) / 4), 2, 16)
	DAMAGE = clamp(4 + ( float(LEVEL - 1) / 8), 4, 32)
	if EXP >= EXPMAX:
		LEVEL += 1
		EXP = 0
		EXPMAX *= 2
		MAXHEALTH = clamp(50 + ( (LEVEL - 1) * 5), 50, 500) # health isnt 5 less when level up
		HEALTH = clamp(HEALTH + 5, HEALTH, MAXHEALTH)
func getPlayerInput():
	var x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return Vector2(x, y).normalized()

func _process(delta):
	level()
	
	$Sprite2D.material = shaderMaterial
	if INVULNERABILITY <= 0:
		shaderMaterial.shader = null
	else:
		INVULNERABILITY -= 10 * delta
		if INVULNERABILITY < MAXINVULNERABILITY - 1:
			shaderMaterial.shader = Global.shaders.tint
	if Input.is_action_pressed("shoot") and FIRERATE <= 0:
		shoot(deg_to_rad(6.25 * BULLETAMOUNT))
	elif FIRERATE > 0:
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
		

func shoot(spread):
	var startDir = -spread / 2
	var dirSteps = spread / (BULLETAMOUNT - 1)
	$Shoot.pitch_scale = randf_range(0.8, 1.2)
	$Shoot.playing = true
	FIRERATE = MAXFIRERATE
	for i in range(BULLETAMOUNT):
		var BULLET = Bullet.instantiate()
		var dirOffset = startDir + (dirSteps * i) if BULLETAMOUNT > 1 else 0
		BULLET.global_position = global_position
		BULLET.SPEED = BULLETSPEED
		BULLET.DAMAGE = DAMAGE
		BULLET.MOVEDIR = (get_global_mouse_position() - global_position).angle() + dirOffset
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
