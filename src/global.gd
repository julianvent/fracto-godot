extends Node

var player_name: String = ""
var player_gender: String
var play_time: int

func _ready():
	ConfigManager.load_config()
	var config = ConfigManager.config 
	var minutes = config.get_value(ConfigManager.SESSION_SECTION, "minutes").to_int()
	var seconds = config.get_value(ConfigManager.SESSION_SECTION, "seconds").to_int()

	play_time = minutes * 60 + seconds
