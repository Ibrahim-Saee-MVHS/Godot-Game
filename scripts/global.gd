extends Node

var SCREENSHAKEAMOUNT: float = 0.0
var SCREENSHAKEPOWER: float = 0.0
var VIGNETTECOLOR: Vector3 = Vector3(0, 0, 0)
var VIGNETTEINTENSITY: float = 0.25

@onready var DAMAGEINDICATOR = preload("res://scenes/vfx/damage_indicator.tscn")
@onready var SFX = {
	select = preload("res://assets/sounds/blipSelect.wav"),
	shoot = preload("res://assets/sounds/shoot.wav"),
	spawn = preload("res://assets/sounds/spawn.wav"),
	explosion = preload("res://assets/sounds/explosion.wav"),
	health = preload("res://assets/sounds/health.wav"),
	hit = preload("res://assets/sounds/hit.wav"),
	enemyDeath = preload("res://assets/sounds/enemyDeath.wav"),
	playerDeath = preload("res://assets/sounds/playerDeath.wav"),
}

func spawnDamageIndicator(globalPos, damage):
	var damageIndicator = DAMAGEINDICATOR.instantiate()
	damageIndicator.global_position = globalPos + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	damageIndicator.DAMAGE = damage
	get_parent().add_child(damageIndicator)

const shaders = {
	"flash": preload("res://assets/shaders/flash.gdshader"),
	"tint": preload("res://assets/shaders/tint.gdshader"),
	"vignette": preload("res://assets/shaders/vignette.gdshader"),
}

var enemyTypes: Array[String] = [
	"normal",
	"repeater",
	"spreader",
	"juggernaut",
	"bomber",
]

var enemyColor = {
	"player": Color("00cdffff"),
	"normal": Color("ff004cff"),
	"repeater": Color("ffd73eff"),
	"juggernaut": Color("2659ffff"),
	"bomber": Color("5eff92ff"),
	"spreader": Color("ff693fff"),
}
