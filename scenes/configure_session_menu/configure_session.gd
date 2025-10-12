extends Control


func _on_config_session_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/configure_session_menu/config_form.tscn")
