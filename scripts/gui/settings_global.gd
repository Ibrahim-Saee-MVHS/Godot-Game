extends Node

var settings = ConfigFile.new()
var save_directory = "user://" #"user://LevelShooter/"

func _ready():
	checkSaveDir()
	checkSettingsConfig()
	settings.load(save_directory + "settings.cfg")
	setAllSettings()

func _process(_delta: float) -> void:
	settings.load(save_directory + "settings.cfg")
	if Input.is_action_just_pressed("fullscreen"):
		if settings.get_value("video", "fullscreen", false) == true:
			settings.set_value("video", "fullscreen", false)
			setFullscreen(false)
		else:
			settings.set_value("video", "fullscreen", true)
			setFullscreen(true)
		settings.save(save_directory + "settings.cfg")

func checkSaveDir():
	if not DirAccess.dir_exists_absolute(save_directory):
		DirAccess.make_dir_recursive_absolute(save_directory)
		
func checkSettingsConfig():
	var defaultSettings = ConfigFile.new()
	var check = defaultSettings.load(save_directory + "settings.cfg")
	if check != OK:
		defaultSettings.set_value("video", "bloom", 1)
		defaultSettings.set_value("video", "bloom_intensity", 0.5)
		defaultSettings.set_value("video", "fullscreen", false)
		defaultSettings.set_value("audio", "master_volume", 100)
		defaultSettings.set_value("audio", "music_volume", 100)
		defaultSettings.set_value("audio", "sound_volume", 100)
		defaultSettings.save(save_directory + "settings.cfg")

func setAllSettings():
	settings.load(save_directory + "settings.cfg")
	setFullscreen(settings.get_value("video", "fullscreen", false))
	setVolume(settings.get_value("audio", "master_volume", 100), settings.get_value("audio", "music_volume", 100), settings.get_value("audio", "sound_volume", 100))
	setBloom(settings.get_value("video", "bloom", 1), settings.get_value("video", "bloom_intensity", 0.5))

func setBloom(mode, intensity):
	if get_tree().current_scene.has_node("BaseCamera"):
		if mode == 0 or (mode == 1 and get_tree().current_scene is GameScene):
			get_tree().current_scene.get_node("BaseCamera/WorldEnvironment").environment.glow_intensity = intensity
		else:
			get_tree().current_scene.get_node("BaseCamera/WorldEnvironment").environment.glow_intensity = 0

func setFullscreen(fullscreen):
	if fullscreen == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func setVolume(MasterVol, MusicVol, SoundVol):
	var MasterBus = AudioServer.get_bus_index("Master")
	var MusicBus = AudioServer.get_bus_index("Music")
	var SoundBus = AudioServer.get_bus_index("Sound")
	AudioServer.set_bus_volume_linear(MasterBus, MasterVol / 100)
	AudioServer.set_bus_volume_linear(MusicBus, MusicVol / 100)
	AudioServer.set_bus_volume_linear(SoundBus, SoundVol / 100)
