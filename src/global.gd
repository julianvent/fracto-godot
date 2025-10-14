extends Node

var player_name: String = ""
var player_gender: String
var seconds_left: int

func _ready():
	ConfigManager.load_config()
	var config = ConfigManager.config 
	var minutes = config.get_value(ConfigManager.SESSION_SECTION, "minutes").to_int()
	var seconds = config.get_value(ConfigManager.SESSION_SECTION, "seconds").to_int()

	seconds_left = minutes * 60 + seconds
