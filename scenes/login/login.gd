extends Control

@onready var email_field = $PanelContainer/VBoxContainer2/Form/Fields/Email
@onready var password_field = $PanelContainer/VBoxContainer2/Form/Fields/Password
@onready var login_button = $PanelContainer/VBoxContainer2/Form/Buttons/VBoxContainer/Login
@onready var register_button = $PanelContainer/VBoxContainer2/Form/Buttons/HBoxContainer/Register
@onready var login_error_label = $PanelContainer/VBoxContainer2/Form/Fields/ErrorLabel

const ERRORS_RESPONSE = "errors"
const MESSAGE_RESPONSE = "message"

var email = ""
var password = ""
var error_theme = null
var normal_theme = null


func _ready():
	error_theme = load("res://scenes/register/line_edit_error.tres")
	normal_theme = load("res://scenes/register/line_edit_normal.tres")


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
	
	$HTTPRequest.request_completed.connect(_http_request_completed)
	$HTTPRequest.timeout = 10.0
	
	var data = {
		"email": email,
		"password": password,
	}
	var body = JSON.stringify(data)
	var headers = ["Content-Type: application/json", "Accept: application/json"]
	var url = Routes.login_url
	
	var response = $HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, body)
	if response != OK:
		login_error_label.text = "Error de conexión"
		push_error("An error occurred in the HTTP request.")


func _http_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	print(response_code, response)
	
	if response:
		login_error_label.visible = response.has(ERRORS_RESPONSE) or response.has(MESSAGE_RESPONSE)
		login_error_label.text = "Credenciales inválidas"
	else:
		login_error_label.visible = true
		login_error_label.text = "Error de conexión"
	_enable_buttons()
	
	if response_code == HTTPClient.RESPONSE_OK:
		SceneManager.change_scene(SceneManager.SCENES.MAIN_MENU)


func _enable_buttons():
	login_button.text = "Iniciar sesión"
	login_button.disabled = false
	register_button.disabled = false
