extends CanvasLayer

var player
var debug_mode = false

func _ready():
	player = get_parent().get_node("Player")

func _process(_delta):
	player = get_parent().get_node("Player")
	$Control/Health.text = "Health: " + str(player.HEALTH) + "/" + str(player.MAXHEALTH)
	$Control/Level.text = "Level: " + str(player.LEVEL)
	$Control/EXP.text = "EXP:\n" + str(player.EXP) + "/" + str(player.EXPMAX)
	if debug_mode == true:
		$Control/Stats.visible = true
		$Control/Stats.text = "Stats:" + "\n" + str(generateStats())
	else:
		$Control/Stats.visible = false
		
	if Input.is_action_just_pressed("debug_key"):
		debug_mode = !debug_mode
	
func generateStats():
	var DAMAGE = str("Damage: ", player.DAMAGE, "\n")
	var SPEED = str("Speed: ", player.SPEED, "\n")
	var FIRERATE = str("Firerate: ", snapped(player.FIRERATE, 0.1), "/", player.MAXFIRERATE, "\n")
	var BULLETSPEED = str("Bullet Speed: ", player.BULLETSPEED, "\n")
	var BULLETAMOUNT = str("Bullets: ", player.BULLETAMOUNT, "\n")
	var INVULNERABILITY = str("Invulerability: ", snapped(player.INVULNERABILITY, 0.1), "/", player.MAXINVULNERABILITY, "\n")
	return str(DAMAGE + SPEED + FIRERATE + BULLETSPEED + BULLETAMOUNT + INVULNERABILITY)
