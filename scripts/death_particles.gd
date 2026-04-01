extends CPUParticles2D

var TYPE: String

func _ready() -> void:
	color = Global.enemyColor.get(TYPE)
	emitting = true

func _on_finished() -> void:
	queue_free()
