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
var velocity: Vector2
var ID: int
var PlayerNode: Player

var ashNode = load("res://scenes/vfx/ash.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if TYPE == "nature":
		SPEED = 250 + (25 * power)
		DAMAGE = 4 + (2 * power)
		KNOCKBACK = 100 + (100 * power)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	PlayerNode = get_parent().get_node("Player")
	
	if get_tree().get_nodes_in_group("enemies").size() > 0:
		homeOnEnemy(power)
	else:
		returnToPlayer()
	
	velocity = Vector2(SPEED, 0).rotated(MOVEDIR) * delta
	keepDistance(16, 8)
	
	rotation = MOVEDIR
	position += velocity

func despawnSummon():
	$CollisionShape2D.disabled = true
	modulate.a -= 5 * get_process_delta_time()
	if modulate.a <= 0:
		queue_free()

func keepDistance(min_distance, separation_amount):
	for node in get_tree().get_nodes_in_group("playerSummons"):
		if node == self:
			continue
		
		var distance = global_position.distance_to(node.global_position)
		if distance < min_distance and distance > 0:
			var push_dir = node.global_position.direction_to(global_position)
			var push_force = push_dir * (1.0 - (distance / min_distance)) * separation_amount
			velocity += push_force

func homeOnEnemy(homing_amount):
	findNewTarget()
	if target != null:
		MOVEDIR = lerp_angle(MOVEDIR, (target.global_position - global_position).angle(), 0.1 + (homing_amount / 10))

func findNewTarget():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() > 0:
		var min_distance = INF
		var nearest_enemy = null
		for enemy in enemies:
			if enemy.TYPE == "arsonist":
				continue
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

func _on_area_entered(area: Area2D) -> void:
	if area is PlayerBullet or area is EnemyBullet:
		if TYPE == "nature" and (area.TYPE == "flame" and area.upgrades != 2):
			var ASH = ashNode.instantiate()
			ASH.global_position = global_position
			get_parent().add_child(ASH)
			queue_free()
