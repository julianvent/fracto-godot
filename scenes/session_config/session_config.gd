extends Control

@onready var school_line = $PanelContainer/Form/School/School
@onready var group_line = $PanelContainer/Form/Group/Group
@onready var minutes_line = $PanelContainer/Form/Duration/HBoxContainer/Minutes/Minutes
@onready var seconds_line = $PanelContainer/Form/Duration/HBoxContainer/Seconds/Seconds
@onready var school_error = $PanelContainer/Form/School/ErrorLabel
@onready var group_error = $PanelContainer/Form/Group/ErrorLabel
@onready var duration_error = $PanelContainer/Form/Duration/ErrorLabel

func _ready():
	_load_config_data()
	

func _on_back_pressed():
	SceneManager.change_scene(SceneManager.SCENES.SESSION_MENU)


func _load_config_data():
	var school = ConfigManager.config.get_value(ConfigManager.SESSION_SECTION, "school")
	var group = ConfigManager.config.get_value(ConfigManager.SESSION_SECTION, "group")
	var minutes = ConfigManager.config.get_value(ConfigManager.SESSION_SECTION, "minutes")
	var seconds = ConfigManager.config.get_value(ConfigManager.SESSION_SECTION, "seconds")
	
	school_line.text = school
	group_line.text = group
	minutes_line.text = minutes
	seconds_line.text = seconds


func _on_save_pressed():
	var school = school_line.text.strip_edges()
	var school_empty = _is_input_empty(school_error, school)
	
	var group = group_line.text.strip_edges()
	var group_empty = _is_input_empty(group_error, group)
	
	var minutes = minutes_line.text.strip_edges()
	var minutes_empty = _is_input_empty(duration_error, minutes)
		
	var seconds = seconds_line.text.strip_edges()
	var seconds_empty = _is_input_empty(duration_error, seconds)
	
	if not seconds_empty and minutes_empty:
		duration_error.visible = true
	
	if school_empty or group_empty or minutes_empty or seconds_empty:
		return
	
	ConfigManager.save_session_config(school, group, minutes, seconds)
	SceneManager.change_scene(SceneManager.SCENES.SESSION_MENU)

func _is_input_empty(error_label, text):
	if text.is_empty():
		error_label.visible = true
		return true
	error_label.visible = false
	return false
