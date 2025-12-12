extends Control

func _on_button_custom_pressed() -> void:
	SceneManager.change_scene(SceneManager.SCENES.PLAYER_CONFIG)
