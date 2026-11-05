extends Sprite2D

@export var SPEED: float = 250
@export var RADIUS: float = 96
var PlayerNode: Player

func _ready():
	PlayerNode = get_parent().get_node("Player")

func getInput():
	return Input.get_vector("shoot_left", "shoot_right", "shoot_up", "shoot_down")

func _process(delta):
	var screenSize = get_viewport_rect().size / 4
	if Global.isMobileDevice == true and Global.usingController == false:
		global_position += getInput() * RADIUS
		var distance = global_position - PlayerNode.global_position
		if distance.length() > RADIUS: global_position = PlayerNode.global_position + distance.normalized() * RADIUS
	else: global_position += getInput() * SPEED * delta
		
	global_position = global_position.clamp(-screenSize + Vector2(8, 8), screenSize - Vector2(8, 8))
