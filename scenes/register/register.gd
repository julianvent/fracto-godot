extends Control

@onready var name_field = $PanelContainer/VBoxContainer2/Form/Fields/NameContainer/Name
@onready var email_field = $PanelContainer/VBoxContainer2/Form/Fields/EmailContainer/Email
@onready var password_field = $PanelContainer/VBoxContainer2/Form/Fields/PasswordContainer/Password
@onready var confirm_password_field = $PanelContainer/VBoxContainer2/Form/Fields/ConfirmPasswordContainer/ConfirmPassword
@onready var error_name_label = $PanelContainer/VBoxContainer2/Form/Fields/NameContainer/ErrorLabel
@onready var error_email_label = $PanelContainer/VBoxContainer2/Form/Fields/EmailContainer/ErrorLabel
@onready var error_password_label = $PanelContainer/VBoxContainer2/Form/Fields/PasswordContainer/ErrorLabel
@onready var error_confirm_password_label = $PanelContainer/VBoxContainer2/Form/Fields/ConfirmPasswordContainer/ErrorLabel
@onready var error_register_label = $PanelContainer/VBoxContainer2/Form/Fields/ErrorLabel
@onready var register_button = $PanelContainer/VBoxContainer2/Form/Buttons/VBoxContainer/Register
@onready var login_button = $PanelContainer/VBoxContainer2/Form/Buttons/HBoxContainer/Login
@onready var http = $HTTPRequest

const ERRORS_RESPONSE = "errors"

var error_theme = null
var normal_theme = null
var full_name = ""
var email = ""
var password = ""


func _ready():
	error_theme = load("res://scenes/register/line_edit_error.tres")
	normal_theme = load("res://scenes/register/line_edit_normal.tres")
	
	# Conectamos una sola vez el HTTPRequest
	if not http.request_completed.is_connected(_http_request_completed):
		http.request_completed.connect(_http_request_completed)


func _on_register_pressed():
	if _is_data_invalid():
		return
	_register()


func _on_login_pressed():
	SceneManager.change_scene(SceneManager.SCENES.LOGIN)


func _is_input_empty(text, line_edit) -> bool:
	var is_empty = text.is_empty()
	if is_empty:
		line_edit.add_theme_stylebox_override("normal", error_theme)
		return true
	line_edit.add_theme_stylebox_override("normal", normal_theme)
	return false


func _is_data_invalid() -> bool:
	full_name = name_field.text.strip_edges()
	email = email_field.text.strip_edges()
	password = password_field.text.strip_edges()
	var confirm_password = confirm_password_field.text.strip_edges()
	
	var is_name_empty = _is_input_empty(full_name, name_field)
	var is_email_empty = _is_input_empty(email, email_field)
	var is_password_empty = _is_input_empty(password, password_field)
	var is_confirm_password_empty = _is_input_empty(confirm_password, confirm_password_field)
	var passwords_differ = _check_passwords(password, confirm_password)
	
	return is_name_empty or is_email_empty or is_password_empty or is_confirm_password_empty or passwords_differ


func _check_passwords(_password, _confirm_password) -> bool:
	var password_differs = _password != _confirm_password
	error_confirm_password_label.visible = password_differs
	return password_differs


func _register():
	register_button.text = "Creando cuenta..."
	register_button.disabled = true
	login_button.disabled = true
	error_register_label.visible = false
	
	var data = {
		"name": full_name,
		"email": email,
		"password": password
	}
	var body = JSON.stringify(data)
	var headers = [
		"Content-Type: application/json",
		"Accept: application/json"
	]
	var url = Routes.signup_url
	
	var response_code_local = http.request(url, headers, HTTPClient.METHOD_POST, body)
	if response_code_local != OK:
		error_register_label.visible = true
		error_register_label.text = "Error de conexión"
		_enable_buttons()
		push_error("An error occurred in the HTTP request.")
		return


func _http_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	if parse_result != OK:
		error_register_label.visible = true
		error_register_label.text = "Respuesta inválida del servidor"
		_enable_buttons()
		return
	
	var response = json.get_data()
	print(response_code, response)
	
	# Limpiamos estados de error previos
	error_email_label.visible = false
	error_password_label.visible = false
	error_register_label.visible = false
	
	# ÉXITO -> 201 Created (o 200 por si acaso)
	if response_code == HTTPClient.RESPONSE_CREATED or response_code == HTTPClient.RESPONSE_OK:
		_enable_buttons()
		# Podrías mostrar un mensaje tipo "Cuenta creada, inicia sesión" si quieres
		SceneManager.change_scene(SceneManager.SCENES.LOGIN)
		return
	
	# ERRORES DE VALIDACIÓN (422)
	if response_code == 422 and typeof(response) == TYPE_DICTIONARY and response.has(ERRORS_RESPONSE):
		var errors = response[ERRORS_RESPONSE]
		if typeof(errors) == TYPE_DICTIONARY:
			_set_email_error_label(errors)
			_set_password_error_label(errors)
	else:
		error_register_label.visible = true
		error_register_label.text = "Error al registrar (" + str(response_code) + ")"
	
	_enable_buttons()


func _enable_buttons():
	register_button.text = "Registrarse"
	register_button.disabled = false
	login_button.disabled = false


func _set_email_error_label(errors):
	error_email_label.visible = errors.has("email")
	if errors.has("email"):
		error_email_label.text = str(errors["email"])


func _set_password_error_label(errors):
	error_password_label.visible = errors.has("password")
	if errors.has("password"):
		error_password_label.text = str(errors["password"])
