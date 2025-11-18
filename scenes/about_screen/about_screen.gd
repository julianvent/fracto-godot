extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_button_pressed() -> void:
# Cambia la ruta si tu main_menu está en otro lugar
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
