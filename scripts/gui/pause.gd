extends CanvasLayer

func _ready():
	visible = false

func pause():
	if visible == true:
		visible = false
		get_parent().get_node("Music").process_mode = Node.PROCESS_MODE_ALWAYS
		get_parent().get_node("Flashtime").process_mode = Node.PROCESS_MODE_ALWAYS
		if get_parent().has_node("UpgradeScreen"):
			get_parent().get_node("UpgradeScreen").process_mode = Node.PROCESS_MODE_ALWAYS
		else:
			get_tree().paused = false
	elif visible == false:
		visible = true
		get_tree().paused = true
		get_parent().get_node("Music").process_mode = Node.PROCESS_MODE_DISABLED
		get_parent().get_node("Flashtime").process_mode = Node.PROCESS_MODE_DISABLED
		if get_parent().has_node("UpgradeScreen"):
			get_parent().get_node("UpgradeScreen").process_mode = Node.PROCESS_MODE_DISABLED
	

func _process(_delta):
	if get_parent().get_node("Player").HEALTH <= 0:
		get_tree().paused = false
		queue_free()
	
	if Input.is_action_just_pressed("escape"):
		pause()

func _on_continue_pressed():
	pause()

func _on_menu_pressed():
	$Control/AnimationPlayer.play("fade_out")

func _on_animation_player_animation_finished(_anim_name):
	#if anim_name == "fade_out":
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
