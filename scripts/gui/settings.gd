extends Control

func _ready() -> void:
	SettingsGlobal.checkSaveDir()
	loadSettings()

func _process(_delta):
	$"Video/RenderScale".text = "Render Scale: " + str(roundi($"Video/RenderScale/HSlider".value))
	$"Audio/MasterVolume".text = "Master Volume: " + str(roundi($"Audio/MasterVolume/HSlider".value))
	$"Audio/MusicVolume".text = "Music Volume: " + str(roundi($"Audio/MusicVolume/HSlider".value))
	$"Audio/SoundVolume".text = "Sound Volume: " + str(roundi($"Audio/SoundVolume/HSlider".value))

func loadSettings():
	var settings = ConfigFile.new()
	settings.load(SettingsGlobal.save_directory + "settings.cfg")
	$"Video/RenderScale/HSlider".value = settings.get_value("video", "render_scale", 1)
	$"Video/Fullscreen/CheckButton".button_pressed = settings.get_value("video", "fullscreen", false)
	$"Audio/MasterVolume/HSlider".value = settings.get_value("audio", "master_volume", 100)
	$"Audio/MusicVolume/HSlider".value = settings.get_value("audio", "music_volume", 100)
	$"Audio/SoundVolume/HSlider".value = settings.get_value("audio", "sound_volume", 100)

func save():
	var settings = ConfigFile.new()
	settings.set_value("video", "render_scale", $"Video/RenderScale/HSlider".value)
	settings.set_value("video", "fullscreen", bool($"Video/Fullscreen/CheckButton".button_pressed))
	
	settings.set_value("audio", "master_volume", $"Audio/MasterVolume/HSlider".value)
	settings.set_value("audio", "music_volume", $"Audio/MusicVolume/HSlider".value)
	settings.set_value("audio", "sound_volume", $"Audio/SoundVolume/HSlider".value)
	
	SettingsGlobal.checkSaveDir()
	settings.save(SettingsGlobal.save_directory + "settings.cfg")

func _on_save_pressed() -> void:
	save()
	SettingsGlobal.setAllSettings()

func _back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
