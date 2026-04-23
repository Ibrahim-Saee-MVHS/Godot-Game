extends Node

var abilityTimer: float = 0.0
var abilityPower: float
var abilityDuration: float
var ExplosionNode = preload("res://scenes/explosion.tscn")
var FlashtimeFX = preload("res://scenes/vfx/flashtime.tscn")

var ICONS = {
	"flashtime" = preload("res://assets/sprites/ability_icons/flashtime.png"),
	"detonation" = preload("res://assets/sprites/ability_icons/detonation.png"),
	"dash" = preload("res://assets/sprites/ability_icons/dash.png"),
	"shield" = preload("res://assets/sprites/ability_icons/shield.png"),
}

func _ready() -> void:
	abilityTimer = 0

func _process(delta: float) -> void:
	if get_tree().current_scene is GameScene:
		updateStats()
		if abilityTimer > 0:
			abilityTimer -= 1 * delta / Engine.time_scale
			if get_tree().current_scene.get_node("Player").ABILITY == "flashtime":
				Engine.time_scale = clamp(1 - (0.25 * abilityPower), 0.125, 1)
		else:
			Engine.time_scale = 1

func updateStats():
	abilityPower = get_tree().current_scene.get_node("Player").ABILITYPOWER
	abilityDuration = get_tree().current_scene.get_node("Player").ABILITYDURATION

func flashtime():
	updateStats()
	abilityTimer = abilityDuration
	Engine.time_scale = clamp(1 - (0.25 * abilityPower), 0.5, 1)
	var FLASHTIME = FlashtimeFX.instantiate()
	get_tree().current_scene.get_node("Camera2D/BackgroundFX/Control").add_child(FLASHTIME)

func detonation(position):
	updateStats()
	var EXPLOSION = ExplosionNode.instantiate()
	EXPLOSION.global_position = position
	EXPLOSION.EXPLOSIONPOWER = abilityPower
	EXPLOSION.playerExplosion = true
	get_tree().current_scene.add_child(EXPLOSION)

func dash(mouse_position, position, delta):
	updateStats()
	abilityTimer = abilityDuration
	var temp = abilityDuration
	get_tree().current_scene.get_node("Player").shaderMaterial.shader = Global.shaders.tint
	get_tree().current_scene.get_node("Player").currentInvulnerabilityTime = 8 * (1 + temp)
	get_tree().current_scene.get_node("Player").INVULNERABILITY = 8 * (1 + temp)
	get_tree().current_scene.get_node("Player").velocity = Vector2(abilityPower * 1000, 0).rotated((mouse_position - position).angle()) * delta
