class_name PlayerShield
extends Area2D

var BLOCKS: int = 2

func _ready():
	modulate = Global.playerColor
	BLOCKS = get_parent().ABILITYPOWER

func _process(_delta):
	get_parent().ABILITYCOOLDOWN = get_parent().ABILITYMAXCOOLDOWN
	if BLOCKS <= 0:
		get_parent().get_node("Area2D/CollisionShape2D").disabled = false
		queue_free()

func protect():
	get_parent().get_node('Hit').pitch_scale = randf_range(0.9, 1.1)
	get_parent().get_node('Hit').playing = true
	get_parent().get_node('Block').pitch_scale = randf_range(0.9, 1.1)
	get_parent().get_node('Block').playing = true
	get_parent().currentInvulnerabilityTime = get_parent().MAXINVULNERABILITY
	get_parent().INVULNERABILITY = get_parent().MAXINVULNERABILITY
	BLOCKS -= 1

func _on_area_entered(area):
	if get_parent().INVULNERABILITY <= 0:
		if area is EnemyBullet and area.TYPE != "bomb":
			if area.TYPE == "flame":
				area.get_node("CPUParticles2D").set_deferred("emitting", false)
				area.get_node("CollisionShape2D").set_deferred("disabled", true)
			else:
				area.queue_free()
			protect()
		if area is Explosion and area.playerExplosion == false:
			protect()
