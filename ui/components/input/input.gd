extends VBoxContainer

@export var fieldName: String = ""
@export var inputType: int = 0

func _draw() -> void:
	$FieldName.text = fieldName
	$FieldInput.virtual_keyboard_type = inputType

func getText() -> String:
	return $FieldInput.text
