extends Node

@onready var canvas_layer = get_tree().root.get_node("Main/CanvasLayer")

enum MENUS {
	NONE,
	MAIN_MENU,
}

var menus = {
	MENUS.MAIN_MENU: preload("res://scenes/main_menu/main_menu.tscn").instantiate(),
}

var current_menu = null

func load_menu(menu_scene):
	var container = canvas_layer.find_child("menu", false, false)
	
	if not container:
		var menu_node = Node.new()
		menu_node.set_name("menu")
		canvas_layer.add_child(menu_node)
		container = menu_node
		
	for menu_child in container.get_children():
		container.remove_child(menu_child)
			
	if menu_scene != MENUS.NONE:
		current_menu = menus[menu_scene]
		container.add_child(current_menu)
