class_name PlayerLightning
extends RayCast2D

var LightningChain = load("res://scenes/bullet_types/player_lightning_chain.tscn")

var INV: float
var DAMAGE: float
var upgrades: int
var max_distance: float
var start_position: Vector2
var target: Vector2
var anim_fps: int
var anim_frame: int
var isChain: bool

func _ready() -> void:
	start_position = Vector2(0, 0)
	anim_fps = 3
	INV = 2 - (0.25 * upgrades)
	max_distance = 80 + (24 * upgrades)

func _process(_delta: float) -> void:
	add_exception(get_parent())
	if anim_frame == 0:
		animateLightningChain(start_position.distance_to(target_position))
	anim_frame = (anim_frame + 1) % anim_fps

func _physics_process(_delta: float) -> void:
	if isChain == false:
		var mouse_position = get_local_mouse_position()
		if mouse_position.length() > max_distance:
			mouse_position = mouse_position.normalized() * max_distance
		if findNearbyTarget() != null and get_local_mouse_position().distance_squared_to(findNearbyTarget().global_position) <= 64*64:
			target_position = findNearbyTarget().global_position - global_position
		else:
			target_position = mouse_position
		if is_colliding() and get_collider() is Enemy:
			target_position = get_collider().global_position - global_position
		$Area2D.position = target_position
	else:
		if findNearbyTarget() == null or not Input.is_action_pressed("shoot"): queue_free()
		
		if findNearbyTarget() != null: target_position = findNearbyTarget().global_position - global_position
		else: queue_free()
	
	if is_colliding():
		damageEnemy()

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

func damageEnemy():
	var collider = get_collider()
	if collider is Enemy and collider.HITSTUN <= 0:
		collider.get_node("Hit").pitch_scale = randf_range(0.9, 1.1)
		collider.get_node("Hit").playing = true
		Global.spawnDamageIndicator(collider.global_position, -DAMAGE)
		collider.shaderMaterial.shader = Global.shaders.flash
		collider.HEALTH -= DAMAGE
		collider.HITSTUN = INV
		if upgrades >= 0:
			summonChainLightning(collider)

func findNearbyTarget():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() > 0:
		var min_distance = INF
		var nearest_enemy = null
		for enemy in enemies:
			if enemy == get_parent():
				continue
			var distance = target_position.distance_squared_to(enemy.global_position)
			if distance < min_distance:
				min_distance = distance
				nearest_enemy = enemy
		return nearest_enemy

func summonChainLightning(enemy):
	if not enemy.has_node("PlayerLightningChain"):
		if global_position.distance_squared_to(findNearbyTarget().global_position) <= max_distance*max_distance:
			var CHAIN = LightningChain.instantiate()
			CHAIN.set("DAMAGE", DAMAGE)
			CHAIN.set("upgrades", max(upgrades - 1, 0))
			CHAIN.set("isChain", true)
			enemy.add_child(CHAIN)

func _chainDespawn(body: Node2D) -> void:
	if isChain == true and body is PlayerLightning:
		queue_free()
