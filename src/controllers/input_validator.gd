extends Node

var error_theme = null
var normal_theme = null

func _ready():
	error_theme = load("res://scenes/register/line_edit_error.tres")
	normal_theme = load("res://scenes/register/line_edit_normal.tres")

func is_input_empty(text, line_edit, _errorLabel = null):
	var is_empty = text.is_empty()
	
	if is_empty:
		line_edit.add_theme_stylebox_override("normal", error_theme)
		return is_empty
	line_edit.add_theme_stylebox_override("normal", normal_theme)
	return is_empty
