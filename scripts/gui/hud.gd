extends CanvasLayer

var player
var debug_mode = false

var controlIndicatorSprites = {
	"lmb": preload("res://assets/sprites/ui/lmb.png"),
	"rmb": preload("res://assets/sprites/ui/rmb.png"),
	"mobile": preload("res://assets/sprites/ui/ability_button_hud.png"),
}

func _ready():
	player = get_parent().get_node("Player")
	$Control/Ability.visible = false
	setControlIndicator()

func _process(_delta):
	setControlIndicator()
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
			if player.ABILITY == "leaf_summon":
				$Control/Ability/Frame/Icon.texture = Abilities.ICONS.get(player.ABILITY)[player.UPGRADE.abilitySpecial.get("leaf_upgrade", 0)]
			else:
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
	
func setControlIndicator():
	$Control/Ability/Frame/KeybindIndicator.visible = false
	$Control/Ability/Frame/ControlIndicator.visible = true
	if Global.isMobileDevice: 
		$Control/Ability/Frame/ControlIndicator.texture = controlIndicatorSprites.get("mobile")
	else:
		if InputMap.action_get_events("ability")[0] is InputEventMouseButton:
			if InputMap.action_get_events("ability")[0].button_index == MOUSE_BUTTON_LEFT:
				$Control/Ability/Frame/ControlIndicator.texture = controlIndicatorSprites.get("lmb")
			else: $Control/Ability/Frame/ControlIndicator.texture = controlIndicatorSprites.get("rmb")
		else:
			$Control/Ability/Frame/KeybindIndicator.visible = true
			$Control/Ability/Frame/ControlIndicator.visible = false
			$Control/Ability/Frame/KeybindIndicator/Label.text = InputMap.action_get_events("ability")[0].as_text().trim_suffix(" - Physical")

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
