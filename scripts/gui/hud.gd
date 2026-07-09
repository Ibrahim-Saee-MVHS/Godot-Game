extends CanvasLayer

var player
var debug_mode = false

func _ready():
	player = get_parent().get_node("Player")
	$Control/Ability.visible = false

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
	if player.ABILITY != "none":
		$Control/Ability.visible = true
		if Abilities.ICONS.get(player.ABILITY) is Array:
			$Control/Ability/Frame/Icon.texture = Abilities.ICONS.get(player.ABILITY)[player.UPGRADE.abilityPower]
		else:
			$Control/Ability/Frame/Icon.texture = Abilities.ICONS.get(player.ABILITY)
		$Control/Ability/Frame/Text.text = Global.upgradeInfo.get(player.ABILITY).get("name")
		if Abilities.abilityTimer <= 0:
			$Control/Ability/Frame/Bar.max_value = player.ABILITYMAXCOOLDOWN
			$Control/Ability/Frame/Bar.value = player.ABILITYCOOLDOWN
		else:
			$Control/Ability/Frame/Bar.max_value = player.ABILITYDURATION
			$Control/Ability/Frame/Bar.value = player.ABILITYDURATION - Abilities.abilityTimer
	else:
		$Control/Ability.visible = false
		
	if Input.is_action_just_pressed("debug_key"):
		debug_mode = !debug_mode
	
func generateStats():
	var STATS = str(
		str("Difficulty: ", get_parent().DIFFICULTY, "\n"),
		str("Velocity: ", snapped(player.velocity.length(), 0.01), "\n"),
		str("Damage: ", player.DAMAGE, "\n"),
		str("Defense: ", player.DEFENSE, "\n"),
		str("Speed: ", player.SPEED, "\n"),
		str("Firerate: ", snapped(player.FIRERATE, 0.1), "/", player.MAXFIRERATE, "\n"),
		str("Bullet Speed: ", player.BULLETSPEED, "\n"),
		str("Bullets: ", player.BULLETAMOUNT, "\n"),
		str("Bullet Upgrades: ", player.UPGRADE.bulletUpgrades, "\n"),
		str("Invulerability: ", snapped(player.INVULNERABILITY, 0.1), "/", player.MAXINVULNERABILITY, "\n"),
		str("Ability: ", player.ABILITY, "\n"),
		str("Ability Power: ", player.ABILITYPOWER, "\n"),
		str("Ability Cooldown: ", snapped(player.ABILITYCOOLDOWN, 0.1), "/", player.ABILITYMAXCOOLDOWN, "\n"),
		str("Ability Duration: ", snapped(Abilities.abilityTimer, 0.1), "/", player.ABILITYDURATION, "\n"),
		str("Screenshake Intensity: ", Global.SCREENSHAKEAMOUNT, "\n"),
		str("Screenshake Power: ", Global.SCREENSHAKEPOWER, "\n"),
	)
	return STATS
