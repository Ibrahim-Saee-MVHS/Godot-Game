class_name PlayerSummon
extends Area2D

@export var TYPE: String
var SPEED: float
var DAMAGE: float
var MOVEDIR: float
var KNOCKBACK: float
var STATE: String
var despawnTimer = 60
var upgrades: int
var target: CollisionObject2D = null
var ID: int
var PlayerNode: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ID = get_tree().get_nodes_in_group("playerSummons").size() + 1
	STATE = "circle"
	setStats()

func setStats():
	if TYPE == "nature":
		SPEED = SPEED + (5 * upgrades)
		DAMAGE = DAMAGE + (2 * upgrades)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	PlayerNode = get_parent().get_node("Player")
	if get_tree().get_nodes_in_group("enemies").size() > 0:
		STATE = "attack"
	else:
		STATE = "circle"
		
	if STATE == "attack":
		homeOnEnemy(upgrades)
	if STATE == "circle":
		returnToPlayer()
		
	global_rotation = MOVEDIR
	position += Vector2(SPEED, 0).rotated(MOVEDIR) * delta
	

func despawnSummon():
	$CollisionShape2D.disabled = true
	modulate.a -= 5 * get_process_delta_time()
	if modulate.a <= 0:
		queue_free()

func homeOnEnemy(homing_amount):
	if target != null and target != PlayerNode:
		MOVEDIR = lerp_angle(MOVEDIR, (target.global_position - global_position).angle(), 0.1 + (homing_amount / 10))
	else:
		findNewTarget()

func findNewTarget():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() > 0:
		var min_distance = INF
		var nearest_enemy = null
		for enemy in enemies:
			var distance = global_position.distance_squared_to(enemy.global_position)
			if distance < min_distance:
				min_distance = distance
				nearest_enemy = enemy
		target = nearest_enemy

func returnToPlayer():
	if target != PlayerNode:
		target = PlayerNode
	elif target.HEALTH > 0:
		MOVEDIR = lerp_angle(MOVEDIR, (target.global_position - global_position).angle(), 0.05)
	else:
		despawnSummon()
