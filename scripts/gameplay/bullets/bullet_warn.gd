extends Sprite2D

@onready var WarnSprites = {
	"floor": preload("res://assets/sprites/projectiles/floor_warning.png"),
}
var Projectiles = {
	"thunder": preload("res://scenes/bullet_types/enemy_thunder_strike.tscn"),
}

var TYPE: String
var bulletName: String
var spawnTimer: float
var specialVars = {}

func _ready():
	if TYPE == "thunder":
		texture = WarnSprites.get("floor")
		z_index = -1

func _process(delta):
	spawnTimer -= 10 * delta
	
	if spawnTimer <= 0:
		summonBullet()
		queue_free()

func summonBullet():
	if TYPE == "thunder":
		var thunderNode = Projectiles.get("thunder")
		var THUNDER = thunderNode.instantiate()
		THUNDER.set("DAMAGE", specialVars.damage)
		THUNDER.set("despawnTimer", specialVars.duration)
		THUNDER.set("upgrades", specialVars.upgrades)
		THUNDER.global_position = global_position
		get_parent().add_child(THUNDER)
		Global.SCREENSHAKE(200, 1.5)
