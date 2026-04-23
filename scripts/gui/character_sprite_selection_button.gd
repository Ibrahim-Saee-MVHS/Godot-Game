extends OptionButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if selected == 0:
		get_parent().selectedCharacterSprite = "default"
	elif selected == 1:
		get_parent().selectedCharacterSprite = "circle"
	elif selected == 2:
		get_parent().selectedCharacterSprite = "triangle"
	elif selected == 3:
		get_parent().selectedCharacterSprite = "icon"
