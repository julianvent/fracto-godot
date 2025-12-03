extends Control

@onready var logout_http = $LogoutHTTPRequest

func _ready() -> void:
	if not logout_http.request_completed.is_connected(_on_logout_request_completed):
		logout_http.request_completed.connect(_on_logout_request_completed)
	# Intentar sincronizar sesiones pendientes
	_try_sync_sessions()


func _try_sync_sessions() -> void:
	# Opcional: solo si hay pendientes
	if StatsManager.has_pending_sessions():
		StatsManager.sync_pending_sessions()

func _on_configure_pressed() -> void:
	# Aquí podrías abrir directamente la pantalla de configuración de sesión
	# por ejemplo:
	# SceneManager.change_scene(SceneManager.SCENES.SESSION_CONFIG)
	pass


func _on_play_pressed() -> void:
	# IDEA DE FLUJO:
	# - Si hay sesión activa → mostrar menú de sesión / datos de sesión.
	# - Si NO hay sesión activa → mandar a configurar sesión.
	#
	# Por ahora mantenemos el flujo actual que siempre va al SESSION_MENU,
	# pero ya tenemos StatsManager.has_active_session() disponible.
	
	if StatsManager.has_active_session():
		SceneManager.change_scene(SceneManager.SCENES.SESSION_MENU)
	else:
		# Si más adelante tienes una escena específica para configurar sesión
		# puedes cambiar esta línea por:
		# SceneManager.change_scene(SceneManager.SCENES.SESSION_CONFIG)
		SceneManager.change_scene(SceneManager.SCENES.SESSION_MENU)


func _on_stats_pressed() -> void:
	SceneManager.change_scene(SceneManager.SCENES.STATS_MENU)


func _on_about_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/about_screen/about_screen.tscn")


func _on_exit_pressed() -> void:
	$ConfirmationDialog.dialog_text = "¿Estás seguro de que quieres cerrar sesión?"
	$ConfirmationDialog.popup_centered()


func _on_confirmation_dialog_confirmed() -> void:
	if Global.auth_token == "":
		Global.clear_auth_session()
		SceneManager.change_scene(SceneManager.SCENES.LOGIN)
		return
	
	var headers = [
		"Accept: application/json",
		"Content-Type: application/json",
		"Authorization: Bearer " + Global.auth_token,
	]
	
	var url = Routes.logout_url  
	var body = ""  
	
	var res = logout_http.request(url, headers, HTTPClient.METHOD_POST, body)
	if res != OK:
		print("Error al llamar /logout, cerrando sesión local igualmente")
		Global.clear_auth_session()
		SceneManager.change_scene(SceneManager.SCENES.LOGIN)


func _on_logout_request_completed(result, response_code, headers, body):
	print("Logout response:", response_code, body.get_string_from_utf8())
	Global.clear_auth_session()
	SceneManager.change_scene(SceneManager.SCENES.LOGIN)
