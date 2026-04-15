extends Node2D

@onready var EnemySpawnParticles = preload("res://scenes/vfx/spawning_particles.tscn")
@onready var HealthSpawnParticles = preload("res://scenes/vfx/health_spawn_particles.tscn")
@export var DIFFICULTY: float = 0
@export var ENEMYSPAWNAMOUNT: int = 1
@export var ENEMYMAXSPAWNTIMER: int = 24
@export var ENEMYMINSPAWNTIMER: int = 8
@export var HEALTHMAXSPAWNTIMER: int = 48
@export var HEALTHMINSPAWNTIMER: int = 8
var ENEMYSPAWNTIMER: float
var HEALTHSPAWNTIMER: float
var screenSize
var shake: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ENEMYSPAWNTIMER = randf_range(1, ENEMYMINSPAWNTIMER)
	HEALTHSPAWNTIMER = 0 # randf_range(HEALTHMINSPAWNTIMER, HEALTHMAXSPAWNTIMER)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	screenSize = get_viewport_rect().size / 4
	ENEMYSPAWNTIMER -= 1 * delta
	
	screenShake(delta)
	vignetteUpdate(delta)
	if get_node("Player").HEALTH > 0:
		spawnEnemies()
		spawnHealth()

func spawnHealth():
	if HEALTHSPAWNTIMER <= 0 and get_node("Player").HEALTH < get_node("Player").MAXHEALTH:
		HEALTHSPAWNTIMER = randf_range(HEALTHMINSPAWNTIMER, HEALTHMAXSPAWNTIMER)
		var newSpawnParticles = HealthSpawnParticles.instantiate()
		newSpawnParticles.global_position = generateSpawnPosition(0)
		add_child(newSpawnParticles)
		HEALTHMAXSPAWNTIMER = clamp(HEALTHMAXSPAWNTIMER - 0.05, 16, 64)

func spawnEnemies():
	if ENEMYSPAWNTIMER <= 0:
		for i in randi_range(1, ENEMYSPAWNAMOUNT):
			ENEMYSPAWNTIMER = randf_range(ENEMYMINSPAWNTIMER, ENEMYMAXSPAWNTIMER)
			var newSpawnParticles = EnemySpawnParticles.instantiate()
			newSpawnParticles.global_position = generateSpawnPosition(0)
			newSpawnParticles.TYPE = randomType()
			newSpawnParticles.statMultiplier = 1.0 + (DIFFICULTY / 2)
			add_child(newSpawnParticles)
		DIFFICULTY += 0.25
		
		ENEMYSPAWNAMOUNT = clamp(1 + floori(DIFFICULTY), 1, 6)
		ENEMYMAXSPAWNTIMER = clamp(ENEMYMAXSPAWNTIMER - floori(DIFFICULTY / 2), 16, 64)

func vignetteUpdate(delta):
	var vignetteShader = $Camera2D/BackgroundFX/Control/Vignette.material
	vignetteShader.set_shader_parameter("color", Global.VIGNETTECOLOR)
	vignetteShader.set_shader_parameter("alpha", Global.VIGNETTEINTENSITY)
	# slowly turn the vignette black again
	if Global.VIGNETTECOLOR[0] > 0:
		Global.VIGNETTECOLOR[0] -= 1 * delta
	if Global.VIGNETTECOLOR[1] > 0:
		Global.VIGNETTECOLOR[1] -= 1 * delta
	if Global.VIGNETTECOLOR[2] > 0:
		Global.VIGNETTECOLOR[2] -= 1 * delta
	# turn the vignette intensity back to normal
	if Global.VIGNETTEINTENSITY > 0.25:
		Global.VIGNETTEINTENSITY -= 1 * delta
	elif Global.VIGNETTEINTENSITY < 0.25:
		Global.VIGNETTEINTENSITY = 0.25

func randomType():
	## start from 0 and end at 1 lower than the amount of types
	#var rng: float = randf_range(0, 0.5 + clamp(DIFFICULTY / 3, 0, 6))
	#rng = clamp(rng, 0, Global.enemyTypes.size() - 1)
	return Global.enemyTypes[RandomNumberGenerator.new().rand_weighted(Global.enemyWeights)]

func generateSpawnPosition(padding):
	var spawnVector: Vector2
	spawnVector.x = randf_range(-screenSize.x-padding, screenSize.x+padding)
	spawnVector.y = randf_range(-screenSize.y-padding, screenSize.y+padding)
	return spawnVector

func screenShake(delta):
	$Camera2D.offset.x = Global.SCREENSHAKEAMOUNT * randf_range(-1, 1) * Global.SCREENSHAKEPOWER * delta
	$Camera2D.offset.y = Global.SCREENSHAKEAMOUNT * randf_range(-1, 1) * Global.SCREENSHAKEPOWER * delta
	if Global.SCREENSHAKEPOWER > 0.0:
		Global.SCREENSHAKEPOWER -= 1 * delta
