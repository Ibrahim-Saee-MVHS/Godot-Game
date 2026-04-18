class_name Dash
extends Area2D

var DAMAGE: float

func _ready():
	$VFX.emitting = true

func _process(_delta):
	if Abilities.abilityTimer <= 0:
		$VFX.emitting = false

func _on_cpu_particles_2d_finished():
	queue_free()
