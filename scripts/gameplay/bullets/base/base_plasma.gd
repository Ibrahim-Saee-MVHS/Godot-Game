class_name BasePlasma
extends BaseProjectile

func _ready():
	KNOCKBACK = 0
	despawnTimer = 120
	match upgrades:
		0:
			$CollisionShape2D.shape.radius = 18
			$CPUParticles2D.amount = 48
			$CPUParticles2D.initial_velocity_min = 16
			$CPUParticles2D.initial_velocity_max = 64
		1:
			$CollisionShape2D.shape.radius = 26
			$CPUParticles2D.amount = 64
			$CPUParticles2D.initial_velocity_min = 32
			$CPUParticles2D.initial_velocity_max = 80
		2:
			$CollisionShape2D.shape.radius = 48
			$CPUParticles2D.amount = 96
			$CPUParticles2D.initial_velocity_min = 48
			$CPUParticles2D.initial_velocity_max = 96

func _process(delta):
	despawnTimer -= 10 * delta
