extends CPUParticles2D

@onready var healthBox = preload("res://scenes/health_box.tscn")
var timer: float = 6

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= 1 * delta
	if timer <= 0:
		var newHealth = healthBox.instantiate()
		newHealth.global_position = global_position
		get_parent().add_child(newHealth)
		queue_free()
