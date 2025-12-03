extends Button
class_name SessionItem

signal session_pressed(session: Dictionary)

var session_data: Dictionary = {}

func setup(data: Dictionary) -> void:
	session_data = data

	var school = data.get("school", "")
	var group = data.get("group", "")
	var date = data.get("date", "")

	$VBoxContainer/FolioLabel.text = "%s %s" % [school, group]
	$VBoxContainer/DateLabel.text = date


func _pressed() -> void:
	session_pressed.emit(session_data)
