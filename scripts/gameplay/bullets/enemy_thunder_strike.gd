class_name EnemyThunderStrike
extends Area2D

var INV: float
var DAMAGE: float
var upgrades: float
var start_position: Vector2
var target_position: Vector2
var anim_fps: int
var anim_frame: int
var despawnTimer = 2
var lightningTypes = [
	{
		"line": preload("res://assets/sprites/projectiles/natural_lightning.png"),
		"strike": preload("res://assets/sprites/projectiles/natural_lightning_strike.png"),
	},
	{
		"line": preload("res://assets/sprites/projectiles/yellow_lightning.png"),
		"strike": preload("res://assets/sprites/projectiles/yellow_lightning_strike.png"),
	},
	{
		"line": preload("res://assets/sprites/projectiles/lightning.png"),
		"strike": preload("res://assets/sprites/projectiles/lightning_strike.png"),
	},
	{
		"line": preload("res://assets/sprites/projectiles/red_lightning.png"),
		"strike": preload("res://assets/sprites/projectiles/red_lightning_strike.png"),
	},
]

func _ready() -> void:
	start_position = Vector2(0, 0)
	target_position = Vector2(0, -720)
	anim_fps = 3
	INV = 2 - (upgrades/2)
	DAMAGE *= ((upgrades/2) + 1)
	despawnTimer = 2 + (upgrades/2)
	$Line2D.texture = lightningTypes[(upgrades)].get("line")
	$Sprite2D.texture = lightningTypes[(upgrades)].get("strike")

func _process(delta: float) -> void:
	if anim_frame == 0:
		animateLightningChain(start_position.distance_to(target_position))
	anim_frame = (anim_frame + 1) % anim_fps
	
	despawnTimer -= 10 * delta
	if despawnTimer <= 0:
		despawn()
	
func despawn():
	$CollisionShape2D.disabled = true
	modulate.a -= 5 * get_process_delta_time()
	if modulate.a <= 0:
		queue_free()

func animateLightningChain(distance):
	var segments = clamp(distance/32, 4, 20)
	var radius = clamp(distance/16, 10, 16)
	var point_array: PackedVector2Array = []
	point_array.append(start_position)
	for i in range(segments-1):
		var weight = float(i+1) / float(segments)
		point_array.append(start_position.lerp(target_position, weight))
		point_array[i+1] = point_array[i+1] + Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
	point_array.append(target_position)
	$Line2D.points = point_array
