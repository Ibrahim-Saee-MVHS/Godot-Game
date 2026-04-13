extends Node

var SCREENSHAKEAMOUNT: float = 0.0
var SCREENSHAKEPOWER: float = 0.0
var VIGNETTECOLOR: Vector3 = Vector3(0, 0, 0)
var VIGNETTEINTENSITY: float = 0.25
var save_directory = "user://UpgradeShooter/"


func _process(delta: float) -> void:
	var settings = ConfigFile.new()
	settings.load(str(Global.save_directory) + "settings.cfg")
	get_tree().root.content_scale_size = 1 - (settings.get_value("video", "render_scale") - 1) / 4 

func spawnDamageIndicator(globalPos, damage):
	var damageIndicator = DAMAGEINDICATOR.instantiate()
	damageIndicator.global_position = globalPos + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	damageIndicator.DAMAGE = damage
	get_parent().add_child(damageIndicator)

func checkSaveDir():
	if not DirAccess.dir_exists_absolute(save_directory):
		DirAccess.make_dir_recursive_absolute(save_directory)
		
func checkSettingsConfig():
	var defaultSettings = ConfigFile.new()
	var check = defaultSettings.load(str(save_directory) + "settings.cfg")
	if check != OK:
		defaultSettings.set_value("video", "render_scale", 1)
		defaultSettings.set_value("audio", "music_volume", 100)
		defaultSettings.set_value("audio", "sound_volume", 100)
		defaultSettings.save("user://settings.cfg")

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
