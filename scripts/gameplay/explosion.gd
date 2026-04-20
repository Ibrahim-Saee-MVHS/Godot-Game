class_name Explosion
extends Area2D

var SIZE: float
var DAMAGE: float
var playerExplosion: bool
var timer: float = 4

func _ready():
	initializeExplosion()
	$Fire.emitting = true
	$Wave.emitting = true

func initializeExplosion():
	SIZE = clampf(SIZE, 0, 8)
	$CollisionShape2D.shape.radius = 64 * SIZE
	DAMAGE = maxf(6 * SIZE, 1)
	$Fire.initial_velocity_min = 64 * SIZE
	$Fire.initial_velocity_max = 256 * SIZE
	$Fire.amount = 48 * SIZE
	$Wave.scale_amount_min = 1 * SIZE
	$Wave.scale_amount_max = 1 * SIZE
	$Sound.pitch_scale = randf_range(0.9, 1.1)
	$Sound.playing = true

func _process(delta):
	timer -= 10 * delta
	if timer <= 0:
		$CollisionShape2D.disabled = true

func _on_fire_finished():
	queue_free()
