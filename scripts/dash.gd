class_name Dash
extends Area2D

var DAMAGE: float

func _ready():
	$VFX.emitting = true

func _process(_delta):
	if Abilities.abilityTimer <= 0:
		$VFX.emitting = false
		if top_level == false:
			top_level = true
			global_position = get_parent().global_position

func _on_cpu_particles_2d_finished():
	queue_free()
