extends Node

@onready var main = $Main
@onready var canvas_layer = $CanvasLayer

func _ready() -> void:
	SceneManager.load_menu(SceneManager.MENUS.MAIN_MENU)
