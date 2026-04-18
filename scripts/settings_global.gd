extends Node

var settings = ConfigFile.new()
var save_directory = "user://" #"user://LevelShooter/"

func _ready():
	checkSaveDir()
	checkSettingsConfig()
	setVolume()

func _process(_delta: float) -> void:
	settings.load(save_directory + "settings.cfg")

func checkSaveDir():
	if not DirAccess.dir_exists_absolute(save_directory):
		DirAccess.make_dir_recursive_absolute(save_directory)
		
func checkSettingsConfig():
	var defaultSettings = ConfigFile.new()
	var check = defaultSettings.load(save_directory + "settings.cfg")
	if check != OK:
		defaultSettings.set_value("video", "render_scale", 1)
		defaultSettings.set_value("audio", "master_volume", 100)
		defaultSettings.set_value("audio", "music_volume", 100)
		defaultSettings.set_value("audio", "sound_volume", 100)
		defaultSettings.save(save_directory + "settings.cfg")

func setVolume():
	var MasterBus = AudioServer.get_bus_index("Master")
	var MusicBus = AudioServer.get_bus_index("Music")
	var SoundBus = AudioServer.get_bus_index("Sound")
	AudioServer.set_bus_volume_linear(MasterBus, settings.get_value("audio", "master_volume", 100) / 100)
	AudioServer.set_bus_volume_linear(MusicBus, settings.get_value("audio", "music_volume", 100) / 100)
	AudioServer.set_bus_volume_linear(SoundBus, settings.get_value("audio", "sound_volume", 100) / 100)
