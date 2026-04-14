class_name Explosion
extends Area2D

var DAMAGE: float = 6

func _ready():
	$CPUParticles2D.emitting = true

func _on_cpu_particles_2d_finished():
	queue_free()
