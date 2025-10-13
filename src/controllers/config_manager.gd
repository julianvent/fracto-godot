extends Node

static var CONFIG_PATH = "user://config.cfg"
static var SESSION_SECTION = "Session"
static var PLAYER_SECTION = "Player"
var config = ConfigFile.new()

func load_config():
	var err = config.load(CONFIG_PATH)
	
	if err != OK:
		print("Config file not found, creating default configuration")
		save_session_config("Escuela", "Grupo", "2", "00")	
		
		
func save_session_config(school: String, group: String, minutes: String, seconds: String):
	config.set_value(SESSION_SECTION, "school", school)
	config.set_value(SESSION_SECTION, "group", group)
	config.set_value(SESSION_SECTION, "minutes", minutes)
	config.set_value(SESSION_SECTION, "seconds", seconds)
	config.save(CONFIG_PATH)

	
	
