extends Control

@onready var logout_http = $LogoutHTTPRequest

func _ready() -> void:
	if not logout_http.request_completed.is_connected(_on_logout_request_completed):
		logout_http.request_completed.connect(_on_logout_request_completed)


func _on_configure_pressed() -> void:
	pass


func _on_play_pressed() -> void:
	SceneManager.change_scene(SceneManager.SCENES.SESSION_MENU)


func _on_stats_pressed() -> void:
	pass # Replace with function body.


func _on_about_pressed() -> void:
	pass # Replace with function body.


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
