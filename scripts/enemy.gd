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
var multiplier: float = 1.0
var explosiveness: float
var bulletType: String
@onready var Projectiles = {
	"normal": preload("res://scenes/bullet_types/enemy_bullet.tscn"),
	"bomb": preload("res://scenes/bullet_types/enemy_bomb.tscn"),
}
@onready var Death = preload("res://scenes/vfx/death_particles.tscn")
@onready var ExplosionNode = preload("res://scenes/explosion.tscn")
var shaderMaterial = ShaderMaterial.new()
var knockback: Vector2

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
		BULLETSPEED = 200
		DAMAGE = 1 * multiplier
		EXP = 4 * 1 + multiplier / 4
		bulletType = "normal"
		explosiveness = 0
		shootPitch = 1.0
	if TYPE == "repeater":
		SPEED = 4100
		MAXHEALTH = 16 * multiplier
		MAXFIRERATE = 4 * multiplier
		BULLETAMOUNT = 1
		BULLETSPEED = 250
		DAMAGE = 1 * multiplier
		EXP = 6 * 1 + multiplier / 4
		bulletType = "normal"
		explosiveness = 0
		shootPitch = 1.25
	if TYPE == "juggernaut":
		SPEED = 3000
		MAXHEALTH = 40 * multiplier
		MAXFIRERATE = 20
		BULLETAMOUNT = 3
		BULLETSPEED = 200
		DAMAGE = 6
		EXP = 8 * 1 + multiplier / 4
		bulletType = "normal"
		explosiveness = 0
		shootPitch = 0.5
	if TYPE == "bomber":
		SPEED = clamp(6000 + (10 * multiplier), 6000, 8000)
		MAXHEALTH = 10 * multiplier
		MAXFIRERATE = 0
		BULLETAMOUNT = 16
		BULLETSPEED = 300
		DAMAGE = 4 * multiplier / 4
		EXP = 12 * 1 + multiplier / 4
		bulletType = "bomb"
		explosiveness = 0
		shootPitch = 1.0
	if TYPE == "spreader":
		SPEED = 4000
		MAXHEALTH = 40 * multiplier
		MAXFIRERATE = 8
		BULLETAMOUNT = clamp(ceil(3 * multiplier), 3, 9)
		BULLETSPEED = 200
		DAMAGE = 2 * multiplier
		EXP = 6 * 1 + multiplier / 4
		bulletType = "normal"
		explosiveness = 0
		shootPitch = 1.0
	if TYPE == "grenadier":
		SPEED = 6000
		MAXHEALTH = 32 * multiplier
		MAXFIRERATE = 18
		BULLETAMOUNT = clamp(floor(1 * multiplier), 1, 6)
		BULLETSPEED = 200
		DAMAGE = 6 * multiplier
		EXP = 6 * 1 + multiplier / 4
		bulletType = "bomb"
		explosiveness = 0.75 * multiplier /4
		shootPitch = 0.5

func _process(delta):
	$Sprite2D.material = shaderMaterial
	player_position = get_parent().get_node("Player").global_position
	MOVEDIR = (player_position - global_position).angle()
	
	$HealthBar.value = HEALTH
	
	if HITSTUN <= 0:
		shaderMaterial.shader = null
	if TYPE != "bomber":
		shoot(delta, deg_to_rad(6.25 * BULLETAMOUNT))
	else:
		if global_position.distance_to(player_position) <= 64:
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
		$Shoot.pitch_scale = shootPitch + randf_range(-0.2, 0.2)
		$Shoot.playing = true
		FIRERATE = MAXFIRERATE
		var currentBullet = Projectiles.get(bulletType)
		for i in range(BULLETAMOUNT):
			var BULLET = currentBullet.instantiate()
			var dirOffset = startDir + (dirSteps * i) if BULLETAMOUNT > 1 else 0
			BULLET.global_position = global_position
			BULLET.COLOR = TYPE
			BULLET.TYPE = bulletType
			BULLET.SPEED = BULLETSPEED
			BULLET.DAMAGE = DAMAGE
			BULLET.MOVEDIR = MOVEDIR + dirOffset
			BULLET.explosiveness = explosiveness
			get_parent().add_child(BULLET)
	else:
		FIRERATE -= 10 * delta

func _physics_process(delta):
	var initialVelocity = Vector2(SPEED, 0).rotated(MOVEDIR) * delta
	if knockback == Vector2(0, 0):
		velocity = initialVelocity
		if global_position.distance_to(player_position) > 64:
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
	EXPLOSION.SIZE = power
	EXPLOSION.playerExplosion = isPlayer
	get_parent().add_child(EXPLOSION)

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
				elif area.TYPE == "plasma":
					HITSTUN = 2
				else:
					HITSTUN = 1
					knockback = Vector2(area.KNOCKBACK, 0).rotated((area.global_position - global_position).angle())
					area.queue_free()
			# explosive bullets
			else:
				explode(area.explosiveness, true, area.global_position)
				knockback = Vector2(area.KNOCKBACK, 0).rotated((area.global_position - global_position).angle())
				area.queue_free()
		# explosions
		if area is Explosion and area.playerExplosion == true:
			$Hit.pitch_scale = randf_range(0.9, 1.1)
			$Hit.playing = true
			Global.spawnDamageIndicator(global_position, -area.DAMAGE)
			shaderMaterial.shader = Global.shaders.flash
			HEALTH -= area.DAMAGE
			HITSTUN = 4
			knockback = Vector2(area.SIZE * 500, 0).rotated((area.global_position - global_position).angle())
