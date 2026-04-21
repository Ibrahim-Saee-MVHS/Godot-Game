class_name GameScene
extends Node2D

@onready var EnemySpawnParticles = preload("res://scenes/vfx/spawning_particles.tscn")
@onready var HealthSpawnParticles = preload("res://scenes/vfx/health_spawn_particles.tscn")
@export var DIFFICULTY: float = 0
@export var ENEMYSPAWNAMOUNT: int = 1
@export var ENEMYMAXSPAWNTIMER: int = 24
@export var ENEMYMINSPAWNTIMER: int = 8
@export var HEALTHMAXSPAWNTIMER: int = 48
@export var HEALTHMINSPAWNTIMER: int = 16
@export var EXPMULTIPLIER: float = 1.0
@export var DIFFICULTYINCREMENT: float = 0.1
var ENEMYSPAWNTIMER: float
var HEALTHSPAWNTIMER: float
var screenSize
var shake: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.setGameModifiers()
	SettingsGlobal.setVolume()
	ENEMYSPAWNTIMER = randf_range(1, ENEMYMINSPAWNTIMER)
	HEALTHSPAWNTIMER = randf_range(HEALTHMINSPAWNTIMER, HEALTHMAXSPAWNTIMER)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	screenSize = get_viewport_rect().size / 4
	ENEMYSPAWNTIMER -= 1 * delta
	HEALTHSPAWNTIMER -= 1 * delta
	
	if OS.has_feature("editor"):
		if Input.is_action_just_pressed("force_spawn_enemy"):
			var newSpawnParticles = EnemySpawnParticles.instantiate()
			newSpawnParticles.global_position = generateSpawnPosition(0)
			newSpawnParticles.TYPE = randomType()
			newSpawnParticles.statMultiplier = 1.0 + (DIFFICULTY / 2)
			add_child(newSpawnParticles)
		if Input.is_action_just_pressed("add_difficulty"):
			DIFFICULTY += 0.1
	
	if Abilities.abilityTimer > 0 and get_node("Player").ABILITY == "flashtime":
		$Music.stream_paused = true
		if $Flashtime.playing == false:
			$Flashtime.play()
	else:
		$Flashtime.stop()
		$Music.stream_paused = false
	
	screenShake(delta)
	vignetteUpdate(delta)
	if get_node("Player").HEALTH > 0:
		spawnEnemies()
		spawnHealth()

func spawnHealth():
	if HEALTHSPAWNTIMER <= 0:
		HEALTHSPAWNTIMER = randf_range(HEALTHMINSPAWNTIMER, HEALTHMAXSPAWNTIMER)
		if get_node("Player").HEALTH < get_node("Player").MAXHEALTH:
			var newSpawnParticles = HealthSpawnParticles.instantiate()
			newSpawnParticles.global_position = generateSpawnPosition(0)
			newSpawnParticles.player_max_health = get_node("Player").MAXHEALTH
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
		DIFFICULTY += DIFFICULTYINCREMENT
		
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
	return Global.enemySpawn.types[RandomNumberGenerator.new().rand_weighted(Global.enemySpawn.weights)]

func generateSpawnPosition(padding):
	var spawnVector: Vector2
	spawnVector.x = randf_range(-screenSize.x-padding, screenSize.x+padding)
	spawnVector.y = randf_range(-screenSize.y-padding, screenSize.y+padding)
	return spawnVector

func screenShake(delta):
	$Camera2D.offset.x = round(Global.SCREENSHAKEAMOUNT * randf_range(-1, 1) * Global.SCREENSHAKEPOWER * delta)
	$Camera2D.offset.y = round(Global.SCREENSHAKEAMOUNT * randf_range(-1, 1) * Global.SCREENSHAKEPOWER * delta)
	if Global.SCREENSHAKEPOWER > 0.0:
		Global.SCREENSHAKEPOWER -= 1 * delta

func _on_music_finished():
	$Music.play()

func _on_flashtime_finished():
	if Abilities.abilityTimer > 0 and get_node("Player").ABILITY == "flashtime":
		$Flashtime.play()
