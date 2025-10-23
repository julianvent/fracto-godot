extends Control

@onready var name_field = $PanelContainer/VBoxContainer2/Form/Fields/NameContainer/Name
@onready var email_field = $PanelContainer/VBoxContainer2/Form/Fields/EmailContainer/Email
@onready var password_field = $PanelContainer/VBoxContainer2/Form/Fields/PasswordContainer/Password
@onready var confirm_password_field = $PanelContainer/VBoxContainer2/Form/Fields/ConfirmPasswordContainer/ConfirmPassword

@onready var error_name_label = $PanelContainer/VBoxContainer2/Form/Fields/NameContainer/ErrorLabel
@onready var error_email_label = $PanelContainer/VBoxContainer2/Form/Fields/EmailContainer/ErrorLabel
@onready var error_password_label = $PanelContainer/VBoxContainer2/Form/Fields/PasswordContainer/ErrorLabel
@onready var error_confirm_password_label = $PanelContainer/VBoxContainer2/Form/Fields/ConfirmPasswordContainer/ErrorLabel
@onready var error_http_label = $PanelContainer/VBoxContainer2/Form/Buttons/VBoxContainer/ErrorLabel

@onready var register_button = $PanelContainer/VBoxContainer2/Form/Buttons/VBoxContainer/Register
@onready var login_button = $PanelContainer/VBoxContainer2/Form/Buttons/HBoxContainer/Login

const ERRORS_RESPONSE = "errors"

var error_theme = null
var normal_theme = null

var full_name = ""
var email = ""
var password = ""

func _ready():
	error_theme = load("res://scenes/register/line_edit_error.tres")
	normal_theme = load("res://scenes/register/line_edit_normal.tres")

func _on_register_pressed():
	if _is_data_invalid():
		return
	_register()
	
	
func _on_login_pressed():
	SceneManager.change_scene(SceneManager.SCENES.LOGIN)
	
func _is_input_empty(text, line_edit, _errorLabel = null):
	var is_empty = text.is_empty()
	
	if is_empty:
		line_edit.add_theme_stylebox_override("normal", error_theme)
		return is_empty
	line_edit.add_theme_stylebox_override("normal", normal_theme)
	return is_empty

func _is_data_invalid():
	full_name = name_field.text.strip_edges()
	email = email_field.text.strip_edges()
	password = password_field.text.strip_edges()
	var confirm_password = confirm_password_field.text.strip_edges()
	
	var is_name_empty = _is_input_empty(full_name, name_field)
	var is_email_emtpy = _is_input_empty(email, email_field)
	var is_password_empty = _is_input_empty(password, password_field)
	var is_confirm_password_empty = _is_input_empty(confirm_password, confirm_password_field)
	
	var password_matches = _check_passwords(password, confirm_password)
	
	return is_name_empty or is_email_emtpy or is_password_empty or is_confirm_password_empty or password_matches
	
func _check_passwords(_password, _confirmPassword):
	var password_matches = _password != _confirmPassword
	error_confirm_password_label.visible = password_matches
	return password_matches
	
func _register():
	register_button.text = "Creando cuenta..."
	register_button.disabled = true
	login_button.disabled = true
	
	$HTTPRequest.request_completed.connect(_http_request_completed)
	
	var data = {
		"name": full_name,
		"email": email,
		"password": password
	}
	var body = JSON.stringify(data)
	var headers = ["Content-Type: application/json", "Accept: application/json"]
	var url = "https://fracto-api.onrender.com/api/v1/auth/register"
	
	var response = $HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, body)
	if response != OK:
		_enable_buttons()
		push_error("An error occurred in the HTTP request.")
		return
		
func _http_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	
	_enable_buttons()
	if response.has(ERRORS_RESPONSE):
		_set_email_error_label(response[ERRORS_RESPONSE])
		_set_password_error_label(response[ERRORS_RESPONSE])

	print(response_code)
	print(response)

func _enable_buttons():
	register_button.text = "Registrarse"
	register_button.disabled = false
	login_button.disabled = false

func _set_email_error_label(errors):		
	error_email_label.visible = errors.has("email")
	
func _set_password_error_label(errors):		
	error_password_label.visible = errors.has("password")
