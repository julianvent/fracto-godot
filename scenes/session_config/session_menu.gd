extends Control

@onready var school_label   = $PanelContainer/VBoxContainer/VBoxContainer/School
@onready var group_label    = $PanelContainer/VBoxContainer/VBoxContainer2/Group
@onready var duration_label = $PanelContainer/VBoxContainer/VBoxContainer3/Duration


func _ready() -> void:
	_update_session_view()


func _update_session_view() -> void:
	# 1) Si aún no hay sesión activa, la creamos a partir de ConfigManager
	if not StatsManager.has_active_session():
		StatsManager.create_session_from_config()

	var session := StatsManager.get_active_session()

	# Si por alguna razón sigue sin haber sesión, usamos el viejo fallback
	if session.is_empty():
		_load_config_data_fallback()
		return

	# 2) Leer datos de la sesión activa
	var school: String = str(session.get("school", ""))
	var group: String = str(session.get("group", ""))
	var duration_seconds: int = int(session.get("duration_seconds", 0))

	var minutes: int = duration_seconds / 60
	var seconds: int = duration_seconds % 60

	# 3) Pintar en los labels
	school_label.text = school
	group_label.text = group
	duration_label.text = "%d minutos %02d segundos" % [minutes, seconds]


func _load_config_data_fallback() -> void:
	# Fallback por si algo raro pasa con StatsManager
	ConfigManager.load_config()

	var school = str(ConfigManager.config.get_value(ConfigManager.SESSION_SECTION, "school", ""))
	var group  = str(ConfigManager.config.get_value(ConfigManager.SESSION_SECTION, "group", ""))
	var minutes = str(ConfigManager.config.get_value(ConfigManager.SESSION_SECTION, "minutes", "0"))
	var seconds = str(ConfigManager.config.get_value(ConfigManager.SESSION_SECTION, "seconds", "0"))

	if seconds.length() == 1:
		seconds = "0" + seconds

	school_label.text = school
	group_label.text = group
	duration_label.text = "%s minutos %s segundos" % [minutes, seconds]


func _on_config_session_pressed() -> void:
	SceneManager.change_scene(SceneManager.SCENES.SESSION_CONFIG)


func _on_continue_pressed() -> void:
	SceneManager.change_scene(SceneManager.SCENES.PLAYER_CONFIG)


func _on_back_pressed() -> void:
	SceneManager.change_scene(SceneManager.SCENES.MAIN_MENU)
