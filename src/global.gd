extends Node

var player_name: String = ""
var player_gender: String
var play_time: int
var auth_token: String = ""
var auth_user: Dictionary = {}
const AUTH_SECTION := "auth"
const AUTH_FILE_PATH := "user://auth.cfg"

func _ready():
	ConfigManager.load_config()
	var config = ConfigManager.config 
	var minutes = config.get_value(ConfigManager.SESSION_SECTION, "minutes").to_int()
	var seconds = config.get_value(ConfigManager.SESSION_SECTION, "seconds").to_int()
	play_time = minutes * 60 + seconds
	_load_auth_session()
	
	
func set_auth_session(user: Dictionary, token: String) -> void:
	auth_token = str(token)
	auth_user = user
	if user.has("name"):
		player_name = str(user["name"])
	_save_auth_session()


func clear_auth_session() -> void:
	auth_token = ""
	auth_user.clear()
	player_name = ""

	var dir := DirAccess.open("user://")
	if dir and dir.file_exists("auth.cfg"):
		dir.remove("auth.cfg")


func _save_auth_session() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(AUTH_SECTION, "token", auth_token)
	cfg.set_value(AUTH_SECTION, "user", auth_user)
	var err := cfg.save(AUTH_FILE_PATH)

	if err != OK:
		push_warning("Global: No se pudo guardar la sesión (" + str(err) + ")")


func _load_auth_session() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(AUTH_FILE_PATH)

	if err != OK:

		return

	auth_token = str(cfg.get_value(AUTH_SECTION, "token", ""))
	auth_user = cfg.get_value(AUTH_SECTION, "user", {})

	if auth_user.has("name"):
		player_name = str(auth_user["name"])
		
		
func load_play_time():
	ConfigManager.load_config()
	var config = ConfigManager.config 
	var minutes = config.get_value(ConfigManager.SESSION_SECTION, "minutes").to_int()
	var seconds = config.get_value(ConfigManager.SESSION_SECTION, "seconds").to_int()
	play_time = minutes * 60 + seconds
