extends CPUParticles2D

@onready var healthBox = preload("res://scenes/health_box.tscn")
var timer: float = 6
var player_max_health: int
var healingAmount: int

func _ready() -> void:
	match player_max_health:
		var max_health when max_health < 75:
			healingAmount = 15
		var max_health when max_health < 100:
			healingAmount = 25
		var max_health when max_health < 175:
			healingAmount = 35
		var max_health when max_health < 200:
			healingAmount = 45
		var max_health when max_health > 200:
			healingAmount = 50


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= 1 * delta
	if timer <= 0:
		var newHealth = healthBox.instantiate()
		newHealth.global_position = global_position
		newHealth.healingAmount = healingAmount
		get_parent().add_child(newHealth)
		queue_free()
