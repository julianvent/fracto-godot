extends Node

var current_scene = null

func _ready():
	var root = get_tree().root
	
	# Using a negative index counts from the end, so this gets the last child node of `root`.
	current_scene = root.get_child(-1)

enum MENUS {
	NONE,
	MAIN_MENU,
	SESSION_MENU,
	SESSION_FORM_MENU
}

var menus = {
	MENUS.MAIN_MENU: preload("res://scenes/main_menu/main_menu.tscn"),
	MENUS.SESSION_MENU: preload("res://scenes/configure_session_menu/config_session.tscn"),
	MENUS.SESSION_FORM_MENU: preload("res://scenes/configure_session_menu/config_session_form.tscn"),
}

func change_scene(menu_scene):
	call_deferred("_deferred_change_scene", menu_scene)

func _deferred_change_scene(menu_scene):
	current_scene.free()
	current_scene = menus[menu_scene].instantiate()
	get_tree().root.add_child(current_scene)
	
