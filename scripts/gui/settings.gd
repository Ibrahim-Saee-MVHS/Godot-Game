extends Control

func _ready() -> void:
	SettingsGlobal.checkSaveDir()
	loadSettings()

func _process(_delta):
	$"RenderScale".text = "Render Scale: " + str(roundi($"RenderScale/HSlider".value))
	$"Audio/MasterVolume".text = "Master Volume: " + str(roundi($"Audio/MasterVolume/HSlider".value))
	$"Audio/MusicVolume".text = "Music Volume: " + str(roundi($"Audio/MusicVolume/HSlider".value))
	$"Audio/SoundVolume".text = "Sound Volume: " + str(roundi($"Audio/SoundVolume/HSlider".value))

func loadSettings():
	var settings = ConfigFile.new()
	settings.load(SettingsGlobal.save_directory + "settings.cfg")
	$"RenderScale/HSlider".value = settings.get_value("video", "render_scale", 1)
	$"Audio/MasterVolume/HSlider".value = settings.get_value("audio", "master_volume", 100)
	$"Audio/MusicVolume/HSlider".value = settings.get_value("audio", "music_volume", 100)
	$"Audio/SoundVolume/HSlider".value = settings.get_value("audio", "sound_volume", 100)

func save():
	var settings = ConfigFile.new()
	settings.set_value("video", "render_scale", $"RenderScale/HSlider".value)
	
	settings.set_value("audio", "master_volume", $"Audio/MasterVolume/HSlider".value)
	settings.set_value("audio", "music_volume", $"Audio/MusicVolume/HSlider".value)
	settings.set_value("audio", "sound_volume", $"Audio/SoundVolume/HSlider".value)
	
	SettingsGlobal.setVolume()
	#get_tree().root.content_scale_size = Vector2i(1280, 640) * clampi(settings.get_value("video", "render_scale", 1) / 5, 0, 2)
	
	SettingsGlobal.checkSaveDir()
	settings.save(SettingsGlobal.save_directory + "settings.cfg")

func _on_save_pressed() -> void:
	save()

func _back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
