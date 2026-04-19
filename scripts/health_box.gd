class_name HealthBox
extends Area2D

var healingAmount: int

func _ready() -> void:
	$CPUParticles2D.emitting = true
