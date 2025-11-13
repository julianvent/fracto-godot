extends Control

@onready var email_field = $PanelContainer/VBoxContainer2/Form/Fields/Email
@onready var password_field = $PanelContainer/VBoxContainer2/Form/Fields/Password
@onready var login_button = $PanelContainer/VBoxContainer2/Form/Buttons/VBoxContainer/Login
@onready var register_button = $PanelContainer/VBoxContainer2/Form/Buttons/HBoxContainer/Register
@onready var login_error_label = $PanelContainer/VBoxContainer2/Form/Fields/ErrorLabel
@onready var http := $HTTPRequest


const ERRORS_RESPONSE = "errors"
const MESSAGE_RESPONSE = "message"

var email = ""
var password = ""
var error_theme = null
var normal_theme = null


func _ready():
	error_theme = load("res://scenes/register/line_edit_error.tres")
	normal_theme = load("res://scenes/register/line_edit_normal.tres")
	
	if not http.request_completed.is_connected(_http_request_completed):
		http.request_completed.connect(_http_request_completed)
	http.timeout = 10.0
	
	if Global.auth_token != "" and Global.auth_user.size() > 0:
		SceneManager.change_scene(SceneManager.SCENES.MAIN_MENU)


func _on_register_pressed():
	SceneManager.change_scene(SceneManager.SCENES.REGISTER)


func _on_login_pressed():
	if _is_data_invalid():
		return
	_login()


func _is_data_invalid():
	email = email_field.text.strip_edges()
	password = password_field.text.strip_edges()
	
	var is_email_empty = InputValidator.is_input_empty(email, email_field)
	var is_password_empty = InputValidator.is_input_empty(password, password_field)
	
	return is_email_empty or is_password_empty


func _login():
	login_button.text = "Iniciando sesión..."
	login_button.disabled = true
	register_button.disabled = true
	login_error_label.visible = false
	
	
	var data = {
		"email": email,
		"password": password,
	}
	var body = JSON.stringify(data)
	var headers = ["Content-Type: application/json", "Accept: application/json"]
	var url = Routes.login_url
	
	var response = http.request(url, headers, HTTPClient.METHOD_POST, body)
	if response != OK:
		login_error_label.visible = true
		login_error_label.text = "Error de conexión"
		push_error("An error occurred in the HTTP request.")
		_enable_buttons()


func _http_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	var parse_result := json.parse(body.get_string_from_utf8())
	if parse_result != OK:
		login_error_label.visible = true
		login_error_label.text = "Respuesta inválida del servidor"
		_enable_buttons()
		return
		
	var response: Dictionary = json.get_data()
	print(response_code, response)
	
	if response_code == HTTPClient.RESPONSE_OK:
		if response.has("token"):
			var token = str(response["token"])
			var user: Dictionary = response["user"] if response.has("user") else {}
			Global.set_auth_session(user, token)

		login_error_label.visible = false
		_enable_buttons()
		SceneManager.change_scene(SceneManager.SCENES.MAIN_MENU)
		return

		
	login_error_label.visible = true
	
	if response_code == HTTPClient.RESPONSE_UNAUTHORIZED:
		# 401 → credenciales inválidas
		login_error_label.text = "Credenciales inválidas"
	elif response.has(MESSAGE_RESPONSE):
		# Si la API manda un 'message', lo mostramos
		login_error_label.text = str(response[MESSAGE_RESPONSE])
	else:
		# Mensaje genérico por si acaso
		login_error_label.text = "Error de conexión (" + str(response_code) + ")"
	
	_enable_buttons()


func _enable_buttons():
	login_button.text = "Iniciar sesión"
	login_button.disabled = false
	register_button.disabled = false
