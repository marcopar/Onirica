extends Node

var music_on: bool = true
var sound_on: bool = true
var color_blind_on: bool = true

const FILE_NAME: String = "res://settings.cfg"

func load_config() -> void:
	var config_file = ConfigFile.new()	
	var error = config_file.load(FILE_NAME)
	
	if error != OK:
		Log.warn("Settings file error, creating default config")
		config_file.save(FILE_NAME)
		error = config_file.load(FILE_NAME)
		if error != OK:
			Log.error("Settings file error")
			return
		
	music_on = config_file.get_value("Settings", "music_on", true)
	sound_on = config_file.get_value("Settings", "sound_on", true)
	color_blind_on = config_file.get_value("Settings", "color_blind_on", false)

func save_config() -> void:
	var config_file = ConfigFile.new()
	config_file.set_value("Settings", "music_on", music_on)
	config_file.set_value("Settings", "sound_on", sound_on)
	config_file.set_value("Settings", "color_blind_on", color_blind_on)
	config_file.save(FILE_NAME)
