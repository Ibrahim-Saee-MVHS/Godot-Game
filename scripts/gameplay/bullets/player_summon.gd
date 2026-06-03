class_name PlayerSummon
extends Area2D

@export var TYPE: String
var SPEED: float
var DAMAGE: float
var MOVEDIR: float
var KNOCKBACK: float
var despawnTimer = 60
var power: int
var target: CollisionObject2D = null
var ID: int
var PlayerNode: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if TYPE == "nature":
		SPEED = SPEED + (5 * power)
		DAMAGE = DAMAGE + (2 * power)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	PlayerNode = get_parent().get_node("Player")
	
	if get_tree().get_nodes_in_group("enemies").size() > 0:
		homeOnEnemy(power)
	else:
		returnToPlayer()
		
	rotation = MOVEDIR
	position += Vector2(SPEED, 0).rotated(MOVEDIR) * delta

func despawnSummon():
	$CollisionShape2D.disabled = true
	modulate.a -= 5 * get_process_delta_time()
	if modulate.a <= 0:
		queue_free()

func homeOnEnemy(homing_amount):
	findNewTarget()
	MOVEDIR = lerp_angle(MOVEDIR, (target.global_position - global_position).angle(), 0.1 + (homing_amount / 10))

func findNewTarget():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() > 0:
		var min_distance = INF
		var nearest_enemy = null
		for enemy in enemies:
			var distance = PlayerNode.global_position.distance_squared_to(enemy.global_position)
			if distance < min_distance:
				min_distance = distance
				nearest_enemy = enemy
		target = nearest_enemy

func returnToPlayer():
	if target != PlayerNode:
		target = PlayerNode
	else:
		MOVEDIR = lerp_angle(MOVEDIR, (PlayerNode.global_position - global_position).angle(), 0.05)
