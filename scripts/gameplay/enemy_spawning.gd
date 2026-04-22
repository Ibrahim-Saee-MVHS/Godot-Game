extends CPUParticles2D

@onready var EnemyScene = preload("res://scenes/enemy.tscn")
var TYPE: String
var timer: float = 3
var statMultiplier = 1.0
var playedSound = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color = Global.enemySpawn.color.get(TYPE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= 1 * delta
	if timer <= 0.75 and playedSound == false:
		playedSound = true
		$AudioStreamPlayer2D.playing = true
	if timer <= 0:
		var newEnemy = EnemyScene.instantiate()
		newEnemy.TYPE = TYPE
		newEnemy.global_position = global_position
		newEnemy.multiplier = statMultiplier
		get_parent().add_child(newEnemy)
		queue_free()
