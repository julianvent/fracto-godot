extends Control

func _ready():
	_load_config_data()

func _on_back_pressed():
	SceneManager.change_scene(SceneManager.MENUS.SESSION_MENU)

func _load_config_data():
	var school = ConfigManager.config.get_value(ConfigManager.SESSION_SECTION, "school")
	var group = ConfigManager.config.get_value(ConfigManager.SESSION_SECTION, "group")
	var minutes = ConfigManager.config.get_value(ConfigManager.SESSION_SECTION, "minutes")
	var seconds = ConfigManager.config.get_value(ConfigManager.SESSION_SECTION, "seconds")
	
	$PanelContainer/Form/School/School.text = school
	$PanelContainer/Form/Group/Group.text = group
	$PanelContainer/Form/Duration/HBoxContainer/Minutes/Minutes.text = minutes
	$PanelContainer/Form/Duration/HBoxContainer/Seconds/Seconds.text = seconds


func _on_save_pressed():
	var school = $PanelContainer/Form/School/School.text
	var group = $PanelContainer/Form/Group/Group.text
	var minutes = $PanelContainer/Form/Duration/HBoxContainer/Minutes/Minutes.text
	var seconds = $PanelContainer/Form/Duration/HBoxContainer/Seconds/Seconds.text
	
	if len(seconds) == 1:
		seconds = "0"+seconds
	
	ConfigManager.save_session_config(school, group, minutes, seconds)
	
	SceneManager.change_scene(SceneManager.MENUS.SESSION_MENU)
