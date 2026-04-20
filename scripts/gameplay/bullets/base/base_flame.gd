class_name BaseFlame
extends BaseProjectile

var fireColors = [
	preload("res://assets/particles/normal_fire.tres"),
	preload("res://assets/particles/yellow_fire.tres"),
	preload("res://assets/particles/green_fire.tres"),
	preload("res://assets/particles/blue_fire.tres"),
	preload("res://assets/particles/purple_fire.tres"),
]

func _ready():
	despawnTimer = 5 + (2 * upgrades)
	KNOCKBACK = 0
	DAMAGE = (DAMAGE / 100) + 0.01 + (0.01 * upgrades)
	$CPUParticles2D.emitting = true
	$CPUParticles2D.color_ramp = fireColors[upgrades]

func _process(delta):
	SPEED -= 1 * delta
	SPEED = max(SPEED, 0)
	if $CPUParticles2D.emitting == false:
		$CollisionShape2D.disabled = true
		despawnTimer -= 10 * delta
		
	position += Vector2(SPEED, 0).rotated(MOVEDIR) * delta
	if despawnTimer <= 0:
		queue_free()
