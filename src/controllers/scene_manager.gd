extends Node

var current_scene = null

func _ready():
	var root = get_tree().root
	
	# Using a negative index counts from the end, so this gets the last child node of `root`.
	current_scene = root.get_child(-1)
	

enum SCENES {
	NONE,
	MAIN_MENU,
	SESSION_MENU,
	SESSION_CONFIG,
	PLAYER_CONFIG,
	MINIGAME_IDENTIFICATION,
}

var scenes = {
	SCENES.MAIN_MENU: preload("res://scenes/main_menu/main_menu.tscn"),
	SCENES.SESSION_MENU: preload("res://scenes/session_config/session_menu.tscn"),
	SCENES.SESSION_CONFIG: preload("res://scenes/session_config/session_config.tscn"),
	SCENES.PLAYER_CONFIG: preload("res://scenes/player_config/player_config.tscn"),
	SCENES.MINIGAME_IDENTIFICATION: preload("res://scenes/minigames/identification/identification.tscn")
}

func change_scene(menu_scene):
	call_deferred("_deferred_change_scene", menu_scene)

func _deferred_change_scene(menu_scene):
	current_scene.free()
	current_scene = scenes[menu_scene].instantiate()
	get_tree().root.add_child(current_scene)
	
