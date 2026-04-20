extends CPUParticles2D

var GameOver = preload("res://scenes/game_over.tscn")

func _ready() -> void:
	emitting = true
	$SecondaryParticles.emitting = true

func _on_finished() -> void:
	var GAMEOVER = GameOver.instantiate()
	get_parent().add_child(GAMEOVER)
	queue_free()
