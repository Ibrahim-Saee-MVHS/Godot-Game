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
		defaultSettings.set_value("video", "render_scale", 1)
		defaultSettings.set_value("video", "fullscreen", false)
		defaultSettings.set_value("audio", "master_volume", 100)
		defaultSettings.set_value("audio", "music_volume", 100)
		defaultSettings.set_value("audio", "sound_volume", 100)
		defaultSettings.save(save_directory + "settings.cfg")

func setAllSettings():
	settings.load(save_directory + "settings.cfg")
	setFullscreen(settings.get_value("video", "fullscreen", false))
	setVolume(settings.get_value("audio", "master_volume", 100), settings.get_value("audio", "music_volume", 100), settings.get_value("audio", "sound_volume", 100))

func setFullscreen(fullscreen):
	if fullscreen == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func setVolume(MasterVol, MusicVol, SoundVol):
	var MasterBus = AudioServer.get_bus_index("Master")
	var MusicBus = AudioServer.get_bus_index("Music")
	var SoundBus = AudioServer.get_bus_index("Sound")
	AudioServer.set_bus_volume_linear(MasterBus, MasterVol / 100)
	AudioServer.set_bus_volume_linear(MusicBus, MusicVol / 100)
	AudioServer.set_bus_volume_linear(SoundBus, SoundVol / 100)
