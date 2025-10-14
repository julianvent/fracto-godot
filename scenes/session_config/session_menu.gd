extends Control


func _ready():
	_load_config_data()


func _on_config_session_pressed():
	SceneManager.change_scene(SceneManager.SCENES.SESSION_CONFIG)


func _on_back_pressed():
	SceneManager.change_scene(SceneManager.SCENES.MAIN_MENU)
	
	
func _load_config_data():
	ConfigManager.load_config()
	
	var school = ConfigManager.config.get_value(ConfigManager.SESSION_SECTION, "school")
	var group = ConfigManager.config.get_value(ConfigManager.SESSION_SECTION, "group")
	var minutes = ConfigManager.config.get_value(ConfigManager.SESSION_SECTION, "minutes")
	var seconds = ConfigManager.config.get_value(ConfigManager.SESSION_SECTION, "seconds")
	
	if len(seconds) == 1:
		seconds = "0"+seconds
	
	$PanelContainer/VBoxContainer/VBoxContainer/School.text = school
	$PanelContainer/VBoxContainer/VBoxContainer2/Group.text = group
	$PanelContainer/VBoxContainer/VBoxContainer3/Duration.text = minutes + ":" + seconds


func _on_continue_pressed() -> void:
	SceneManager.change_scene(SceneManager.SCENES.PLAYER_CONFIG)
