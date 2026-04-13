extends Control

func _ready() -> void:
	Global.checkSaveDir()
	loadSettings()

func loadSettings():
	var settings = ConfigFile.new()
	settings.load(str(Global.save_directory) + "settings.cfg")
	$"RenderScale/HSlider".value = settings.get_value("video", "render_scale", 1)

func save():
	var settings = ConfigFile.new()
	settings.set_value("video", "render_scale", $"RenderScale/HSlider".value)
	
	settings.set_value("audio", "music_volume", 100)
	settings.set_value("audio", "sound_volume", 100)
	
	Global.checkSaveDir()
	#get_tree().root.content_scale_size = Vector2i(1280, 640) * clampi(settings.get_value("video", "render_scale", 1) / 5, 0, 2)
	settings.save(str(Global.save_directory) + "settings.cfg")

func _on_save_pressed() -> void:
	save()

func _back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
