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
var shootPitch: float = 1.0
var player_position: Vector2
var multiplier: float = 1.0
@onready var Bullet = preload("res://scenes/enemy_bullet.tscn")
@onready var Death = preload("res://scenes/vfx/death_particles.tscn")
var shaderMaterial = ShaderMaterial.new()

func _ready():
	setStats()
	$HealthBar.max_value = MAXHEALTH
	HITSTUN = 0
	HEALTH = MAXHEALTH
	FIRERATE = MAXFIRERATE

func setStats():
	$Sprite2D.self_modulate = Global.enemyColor.get(TYPE)
	if TYPE == "normal":
		SPEED = 4000
		MAXHEALTH = 25 * multiplier
		MAXFIRERATE = 10
		BULLETAMOUNT = 1
		DAMAGE = 1 * multiplier
		EXP = 4 * 1 + multiplier / 4
		shootPitch = 1.0
	if TYPE == "repeater":
		SPEED = 4100
		MAXHEALTH = 16 * multiplier
		MAXFIRERATE = 4 * multiplier
		BULLETAMOUNT = 1
		DAMAGE = 1 * multiplier
		EXP = 6 * 1 + multiplier / 4
		shootPitch = 1.25
	if TYPE == "juggernaut":
		SPEED = 3000
		MAXHEALTH = 40 * multiplier
		MAXFIRERATE = 20
		BULLETAMOUNT = 3
		DAMAGE = 6
		EXP = 8 * 1 + multiplier / 4
		shootPitch = 0.5
	if TYPE == "bomber":
		SPEED = clamp(6000 + (10 * multiplier), 6000, 8000)
		MAXHEALTH = 8  * multiplier
		MAXFIRERATE = 0
		BULLETAMOUNT = 16
		DAMAGE = 18 * multiplier
		EXP = 12 * 1 + multiplier / 4
		shootPitch = 1.0
	if TYPE == "spreader":
		SPEED = 4000
		MAXHEALTH = 40 * multiplier
		MAXFIRERATE = 8
		BULLETAMOUNT = clamp(ceil(3 * multiplier), 3, 9)
		DAMAGE = 2 * multiplier
		EXP = 6 * 1 + multiplier / 4
		shootPitch = 1.0

func _process(delta):
	$Sprite2D.material = shaderMaterial
	player_position = get_parent().get_node("Player").global_position
	MOVEDIR = (player_position - global_position).angle()
	
	$HealthBar.value = HEALTH
	
	if HITSTUN <= 0:
		shaderMaterial.shader = null
	if TYPE != "bomber":
		shoot(delta, deg_to_rad(6.25 * BULLETAMOUNT))
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

func shoot(delta, spread):
	var startDir = -spread / 2
	var dirSteps = spread / (BULLETAMOUNT - 1)
	if FIRERATE <= 0:
		$Shoot.pitch_scale = shootPitch + randf_range(-0.2, 0.2)
		$Shoot.playing = true
		FIRERATE = MAXFIRERATE
		for i in range(BULLETAMOUNT):
			var BULLET = Bullet.instantiate()
			var dirOffset = startDir + (dirSteps * i) if BULLETAMOUNT > 1 else 0
			BULLET.global_position = global_position
			BULLET.SPEED = 200
			BULLET.DAMAGE = DAMAGE
			BULLET.TYPE = TYPE
			BULLET.MOVEDIR = MOVEDIR + dirOffset
			get_parent().add_child(BULLET)
	else:
		FIRERATE -= 10 * delta

func _physics_process(delta):
	var initialVelocity = Vector2(SPEED, 0).rotated(MOVEDIR) * delta
	if HITSTUN <= 0:
		velocity = initialVelocity
		if global_position.distance_to(player_position) > 64:
			move_and_slide()
		elif global_position.distance_to(player_position) < 32:
			velocity = -initialVelocity
			move_and_slide()
		elif TYPE == "bomber":
			$Explosion.pitch_scale = shootPitch + randf_range(-0.1, 0.1)
			$Explosion.playing = true
			get_parent().get_node("Player").POINTS += 2
			shoot(delta, deg_to_rad(360))
			queue_free()
	else:
		velocity = -initialVelocity * 2
		move_and_slide()
		HITSTUN -= 10 * delta

		
func _damagedByBullet(area):
	if area is PlayerBullet and HITSTUN <= 0:
		$Hit.pitch_scale = randf_range(0.9, 1.1)
		$Hit.playing = true
		Global.spawnDamageIndicator(global_position, -area.DAMAGE)
		shaderMaterial.shader = Global.shaders.flash
		HITSTUN = 1
		HEALTH -= area.DAMAGE
		area.queue_free()
