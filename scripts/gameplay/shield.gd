class_name PlayerShield
extends Area2D

@onready var BLOCKINDICATOR = preload("res://scenes/vfx/block_indicator.tscn")
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
	get_parent().currentInvulnerabilityTime = 12
	get_parent().INVULNERABILITY = 12
	var blockIndicator = BLOCKINDICATOR.instantiate()
	blockIndicator.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	get_tree().current_scene.add_child(blockIndicator)
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
