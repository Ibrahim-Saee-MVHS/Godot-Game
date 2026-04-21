class_name Explosion
extends Area2D

var EXPLOSIONPOWER: float
var DAMAGE: float
var playerExplosion: bool
var timer: float = 4

func _ready():
	initializeExplosion()
	$Fire.emitting = true
	$Wave.emitting = true

func initializeExplosion():
	DAMAGE = maxf(6 * EXPLOSIONPOWER, 1)
	$CollisionShape2D.shape.radius = 64 * clampf(EXPLOSIONPOWER, 0, 8)
	$Fire.initial_velocity_min = 64 * clampf(EXPLOSIONPOWER, 0, 8)
	$Fire.initial_velocity_max = 256 * clampf(EXPLOSIONPOWER, 0, 8)
	$Fire.amount = 48 * clampf(EXPLOSIONPOWER, 0, 8)
	$Wave.scale_amount_min = 1 * clampf(EXPLOSIONPOWER, 0, 8)
	$Wave.scale_amount_max = 1 * clampf(EXPLOSIONPOWER, 0, 8)
	$Sound.pitch_scale = randf_range(0.9, 1.1)
	$Sound.playing = true

func _process(delta):
	timer -= 10 * delta
	if timer <= 0:
		$CollisionShape2D.disabled = true

func _on_fire_finished():
	queue_free()
